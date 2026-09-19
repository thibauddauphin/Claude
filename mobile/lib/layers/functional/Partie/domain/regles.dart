import 'dart:math';

import 'catalogue/caracteres_index.dart';
import 'catalogue/equipe.dart';
import 'catalogue/gammes.dart';
import 'catalogue/jalons.dart';
import 'catalogue/stations.dart';
import 'catalogue/technologies.dart';
import 'entities/caractere.dart';
import 'entities/employe.dart';
import 'entities/etat_partie.dart';
import 'entities/evenement.dart';
import 'entities/gamme.dart';
import 'entities/jalon.dart';

/// Tout le calcul dérivé de la partie : multiplicateurs, coûts, cadences.
///
/// Fonctions pures sur l'agrégat, sans dépendance à Flutter ni au stockage.
class Regles {
  const Regles._();

  /// Une année de carrière toutes les six minutes de présence.
  static const anneesParSeconde = 1 / 360;

  /// Une année de jeu dure six minutes réelles. C'est le rythme des exercices
  /// comptables : l'impôt tombe à chaque clôture.
  static const double secondesParAnnee = 360;

  /// Impôt sur les bénéfices. Ne frappe que le résultat positif.
  static const double tauxImpot = .25;

  /// Agios sur le découvert, par seconde. La banque ne prête pas gratuitement.
  static const double tauxAgios = .0004;

  /// Le découvert toléré : trois années de charges.
  ///
  /// Le plancher compte autant que le calcul : sans lui, un atelier qu'on
  /// vient de vider n'a plus de charges, donc plus aucune tolérance, et le
  /// joueur reste endetté à vie sans rien à vendre pour s'en sortir.
  static double decouvertTolere(EtatPartie e) =>
      max(chargesParSeconde(e) * secondesParAnnee * 3, prixUnite(e) * 400);

  static const plafondHorsLigne = Duration(hours: 12);
  static const rendementHorsLigne = .6;

  // ----------------------------- multiplicateurs -----------------------------

  static double bonusJalons(EtatPartie e) {
    var bonus = 0.0;
    for (final jalon in jalons) {
      if (e.jalonsAtteints.contains(jalon.id)) bonus += jalon.bonus;
    }
    return 1 + bonus;
  }

  static double multActions(EtatPartie e) => 1 + e.actions * .08;
  static double multParts(EtatPartie e) => pow(1.3, e.parts).toDouble();

  /// Chaque départ à la retraite laisse un savoir-faire derrière lui.
  static double heritage(EtatPartie e) => 1 + min(.3, e.retraites * .015);

  /// Un employé rend d'autant mieux qu'il a le moral : à plat, il ne donne
  /// plus que 40 % de ce qu'il apporte. Un binôme majore le reste de moitié.
  static double multEquipe(EtatPartie e, double? Function(EffetsChiffres) champ) {
    var m = 1.0;
    for (final membre in e.equipe) {
      final caractere = caractereParId[membre.caractereId];
      if (caractere == null) continue;
      final valeur = champ(caractere);
      if (valeur == null) continue;
      var force = .4 + .6 * membre.moral.clamp(0, 100) / 100;
      if (membre.binome != null && partenaire(e, membre) != null) force *= 1.5;
      m *= 1 + (valeur - 1) * force;
    }
    for (final duo in binomes(e)) {
      final y = synergieDe(duo.$1, duo.$2);
      if (y == null) continue;
      final valeur = champ(y);
      if (valeur != null) m *= valeur;
    }
    return m;
  }

  static double multProduction(EtatPartie e) {
    var m = multActions(e) * multParts(e) * bonusJalons(e) * heritage(e);
    for (final t in technologies) {
      if (t.production != null && e.possede(t.id)) m *= t.production!;
    }
    if (e.aHolding('cadence')) m *= 3;
    if (e.aHolding('empire')) m *= 2;
    m *= multEquipe(e, (c) => c.production);
    final ev = e.evenement;
    if (ev != null && ev.evenement.cible == CibleEvenement.production) {
      m *= ev.evenement.facteur;
    }
    return m;
  }

  static double multPrix(EtatPartie e) {
    var m = multActions(e) * multParts(e) * e.marge;
    for (final t in technologies) {
      if (t.prix != null && e.possede(t.id)) m *= t.prix!;
    }
    if (e.aHolding('empire')) m *= 2;
    m *= multEquipe(e, (c) => c.prix);
    final ev = e.evenement;
    if (ev != null && ev.evenement.cible == CibleEvenement.prix) {
      m *= ev.evenement.facteur;
    }
    return m;
  }

  static double multRecherche(EtatPartie e) {
    var m = (e.aHolding('labo') ? 2.0 : 1.0) * multEquipe(e, (c) => c.recherche);
    final ev = e.evenement;
    if (ev != null && ev.evenement.cible == CibleEvenement.recherche) {
      m *= ev.evenement.facteur;
    }
    return m;
  }

  static double multPrixComposant(EtatPartie e) {
    var m = 1.0;
    if (e.possede('logi')) m *= .8;
    if (e.aHolding('integree')) m *= .65;
    m *= multEquipe(e, (c) => c.composants);
    final ev = e.evenement;
    if (ev != null && ev.evenement.cible == CibleEvenement.composants) {
      m *= ev.evenement.facteur;
    }
    return m;
  }

  /// Une marge élevée rapporte davantage mais freine la conquête.
  static double conquete(EtatPartie e) {
    var c = (2 - e.marge).clamp(.4, 1.35).toDouble();
    for (final t in technologies) {
      if (t.conquete != null && e.possede(t.id)) c *= t.conquete!;
    }
    return c * multEquipe(e, (car) => car.conquete);
  }

  // ------------------------------- production -------------------------------

  static Gamme gamme(EtatPartie e) => gammes[e.gamme];

  static double besoinComposants(EtatPartie e) =>
      gamme(e).composants * (e.possede('pcb') ? .8 : 1);

  static double prixUnite(EtatPartie e) => gamme(e).prix * multPrix(e);

  static double prixComposant(EtatPartie e) =>
      gamme(e).prixComposant * multPrixComposant(e);

  /// Ce qu'une paire de mains vaut face à la meilleure machine en service.
  static const double partMain = .5;

  /// Une unité montée sans composants, de bric et de broc.
  static const double partBricolage = .3;

  /// Ce que le bricolage peut couvrir, en part de la cadence nominale.
  ///
  /// Sans ce plafond une équipe se paierait toute seule en récupérant des
  /// pièces, les composants deviendraient facultatifs et plus rien ne pourrait
  /// mal tourner. C'est une roue de secours, pas un modèle économique.
  static const double capaciteBricolage = .2;

  /// Ce que l'équipe assemble de ses mains, en plus des machines.
  ///
  /// C'est pour cela qu'on embauche : l'atelier continue de produire quand
  /// personne ne clique. Le taux suit la meilleure machine en service, donc
  /// il reste utile à toutes les ères sans courbe inventée pour l'occasion.
  static double cadenceEquipe(EtatPartie e) {
    if (e.equipe.isEmpty) return 0;
    var meilleure = stations[0].cadence;
    for (var i = 0; i < stations.length; i++) {
      if (e.exemplaires[i] > 0 && stations[i].cadence > meilleure) {
        meilleure = stations[i].cadence;
      }
    }
    return e.equipe.length * meilleure * partMain;
  }

  static double cadence(EtatPartie e) {
    var u = 0.0;
    for (var i = 0; i < stations.length; i++) {
      u += e.exemplaires[i] * stations[i].cadence;
    }
    return (u + cadenceEquipe(e)) * multProduction(e);
  }

  static double forceClic(EtatPartie e) =>
      (e.possede('fer') ? 4 : 1) * multActions(e) * multParts(e);

  static double coutStation(EtatPartie e, int i) {
    var c = stations[i].coutBase * pow(1.19, e.exemplaires[i]);
    if (e.possede('restruct')) c *= .85;
    return c.ceilToDouble();
  }

  static double coutTechnologie(EtatPartie e, int i) {
    var c = technologies[i].cout;
    if (e.aHolding('carnet')) c *= .8;
    return c.ceilToDouble();
  }

  static double lotComposants(EtatPartie e) =>
      max(25, (besoinComposants(e) * max(cadence(e), 1) * 30).ceilToDouble());

  /// La paie se prélève sur la recette, plafonnée à 60 %.
  /// Ce que l'atelier encaisserait par seconde s'il tournait à plein.
  ///
  /// Sert de référence à tout ce qui se chiffre en euros : les salaires du
  /// marché comme les charges. Elle ne dépend pas de vos ennuis du moment.
  static double recetteBrute(EtatPartie e) => cadence(e) * prixUnite(e);

  /// Ce qu'une personne coûte sur le marché du travail, en euros par seconde.
  ///
  /// Un ingénieur de 2040 ne se paie pas au tarif de 1975 : le tarif suit
  /// l'activité. Un salaire figé à l'embauche décroche donc peu à peu, et il
  /// faut augmenter les gens pour les garder — comme dans la vraie vie.
  static const double tauxSalaireMarche = .05;

  /// Le plancher évite un tarif nul quand l'atelier ne tourne pas encore :
  /// personne ne travaille gratuitement en attendant la première machine.
  static double salaireMarche(EtatPartie e) =>
      tauxSalaireMarche * max(recetteBrute(e), prixUnite(e));

  /// Ce que coûte cette personne, en euros par seconde.
  ///
  /// Les salaires suivent l'activité : l'atelier grandit, la paie aussi. Ce
  /// qui change tout par rapport à une commission sur les ventes, c'est qu'ils
  /// tombent même les jours où l'on ne vend rien.
  static double salaireDe(EtatPartie e, Employe membre) =>
      membre.part / tauxSalaireMarche * salaireMarche(e);

  /// La masse salariale, en euros par seconde.
  ///
  /// Elle tombe que l'atelier produise ou non. C'est ce qui rend une embauche
  /// engageante plutôt que gratuite.
  static double masseSalariale(EtatPartie e) {
    var t = 0.0;
    for (final membre in e.equipe) {
      t += salaireDe(e, membre);
    }
    return t;
  }

  /// Part du prix d'achat d'une machine qu'il faut dépenser chaque seconde
  /// pour la garder en état. Un parc immobile coûte quand même.
  static const double tauxEntretien = 1 / 12000;

  static double entretienParc(EtatPartie e) {
    var t = 0.0;
    for (var i = 0; i < stations.length; i++) {
      t += e.exemplaires[i] * stations[i].coutBase * tauxEntretien;
    }
    return t;
  }

  /// Tout ce qui sort chaque seconde, production ou pas.
  static double chargesParSeconde(EtatPartie e) =>
      masseSalariale(e) + entretienParc(e);

  /// Ce qui reste par seconde une fois les charges payées. Négatif, l'atelier
  /// perd de l'argent : c'est le chiffre que regarde un patron.
  static double resultatParSeconde(EtatPartie e) =>
      recetteBrute(e) - besoinComposants(e) * cadence(e) * prixComposant(e) -
          chargesParSeconde(e);

  static int placesEquipe(EtatPartie e) =>
      3 + (ereCourante(e) ~/ 2) + (e.aHolding('empire') ? 3 : 0);

  // --------------------------------- marché ---------------------------------

  static int ereCourante(EtatPartie e) {
    var ere = 0;
    for (final t in technologies) {
      if (t.ouvre != null && e.possede(t.id) && t.ouvre! > ere) ere = t.ouvre!;
    }
    return ere;
  }

  static double puissanceTotaleRivaux(EtatPartie e) =>
      e.puissanceRivaux.fold(0, (a, b) => a + b);

  static double partMarche(EtatPartie e) {
    final total = e.puissance + puissanceTotaleRivaux(e);
    return total > 0 ? e.puissance / total * 100 : 0;
  }

  // -------------------------------- prestige --------------------------------

  static int actionsIntroduction(EtatPartie e) {
    if (e.chiffreAffaires < 1e10) return 0;
    return (10 * pow(e.chiffreAffaires / 1e10, .12)).floor();
  }

  static int partsConglomerat(EtatPartie e) {
    if (e.actions < 150) return 0;
    return (3 * pow(e.actions / 150, .6)).floor();
  }

  // --------------------------------- équipe ---------------------------------

  static Employe? partenaire(EtatPartie e, Employe membre) {
    final graine = membre.binome;
    if (graine == null) return null;
    for (final autre in e.equipe) {
      if (autre.graine == graine) return autre;
    }
    return null;
  }

  static List<(Employe, Employe)> binomes(EtatPartie e) {
    final vus = <int>{};
    final paires = <(Employe, Employe)>[];
    for (final membre in e.equipe) {
      if (membre.binome == null || vus.contains(membre.graine)) continue;
      final autre = partenaire(e, membre);
      if (autre == null) continue;
      vus..add(membre.graine)..add(autre.graine);
      paires.add((membre, autre));
    }
    return paires;
  }

  static Synergie? synergieDe(Employe a, Employe b) {
    for (final y in synergies) {
      final correspond = (y.a == a.caractereId && y.b == b.caractereId) ||
          (y.a == b.caractereId && y.b == a.caractereId);
      if (correspond) return y;
    }
    return null;
  }

  /// Le moral ne s'use pas avec l'horloge : il converge vers ce que valent les
  /// conditions de travail du moment.
  static double cibleMoral(EtatPartie e, {required bool estBloquee, required double protection}) {
    var malus = 0.0;
    if (e.marge < 1) malus += (1 - e.marge) * 230;
    if (estBloquee) malus += 30;
    final ev = e.evenement;
    if (ev != null && !ev.evenement.estFavorable) malus += 12;

    var bonus = 0.0;
    if (partMarche(e) > 50) bonus += 12;
    if (e.possede('sav')) bonus += 10;
    if (e.possede('marque')) bonus += 6;

    return 66 - malus * protection + bonus;
  }

  static double coutPrime(EtatPartie e, Employe membre) =>
      salaireDe(e, membre) * 180;

  // --------------------------------- jalons ---------------------------------

  static double mesureJalon(EtatPartie e, MesureJalon mesure) {
    switch (mesure) {
      case MesureJalon.unites:
        return e.unitesVendues;
      case MesureJalon.chiffreAffaires:
        return e.chiffreAffairesCumule;
      case MesureJalon.stations:
        return e.totalExemplaires.toDouble();
      case MesureJalon.technologies:
        return e.technologies.length.toDouble();
      case MesureJalon.partMarche:
        return partMarche(e);
      case MesureJalon.ere:
        return ereCourante(e).toDouble();
      case MesureJalon.introductions:
        return e.introductions.toDouble();
      case MesureJalon.actions:
        return e.actions;
      case MesureJalon.parts:
        return e.parts.toDouble();
    }
  }
}
