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

  /// Un emprunt se rembourse sur cinq années de jeu, à 8 % l'an.
  static const double dureeEmprunt = secondesParAnnee * 5;
  static const double tauxInteretAnnuel = .08;

  /// Ce que la banque accepte de vous prêter au total.
  ///
  /// Elle regarde ce que la société encaisse, et consent un minimum même à
  /// celui qui démarre : c'est ainsi qu'on ouvre un atelier sans capital.
  static double plafondEmprunt(EtatPartie e) =>
      max(recetteBrute(e) * secondesParAnnee * 2, prixUnite(e) * 3000);

  /// Ce qu'il reste possible d'emprunter aujourd'hui.
  static double empruntDisponible(EtatPartie e) =>
      max(0, plafondEmprunt(e) - e.emprunt);

  /// L'échéance, en euros par seconde : amortissement du capital et intérêts.
  static double echeanceEmprunt(EtatPartie e) =>
      e.emprunt * (1 / dureeEmprunt + tauxInteretAnnuel / secondesParAnnee);

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

  /// Le prix que pratique le marché pour cette génération de produits.
  ///
  /// C'est la référence à laquelle le client vous compare : votre politique de
  /// prix n'est rien d'autre que l'écart que vous creusez avec elle.
  static double prixMarche(EtatPartie e) => prixUnite(e) / e.marge;

  /// Une marge élevée rapporte davantage mais freine la conquête.
  ///
  /// La courbe est volontairement raide : vendre 60 % au-dessus du marché
  /// divise la conquête par huit, ce qui laisse les concurrents reprendre le
  /// terrain. Une pente douce rendait le prix fort toujours gagnant — on
  /// encaissait 60 % de plus en ne perdant presque rien.
  static double conquete(EtatPartie e) {
    var c = pow(max(2 - e.marge, .05), 2.2).clamp(.05, 1.6).toDouble();
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

  /// Ce que coûte l'achat de [quantite] exemplaires d'un coup.
  ///
  /// Chaque exemplaire se paie 19 % de plus que le précédent, d'où la somme
  /// géométrique : acheter dix machines n'est pas dix fois le prix d'une.
  static double coutStations(EtatPartie e, int i, int quantite) {
    if (quantite <= 0) return 0;
    final unitaire = coutStation(e, i);
    return (unitaire * (pow(1.19, quantite) - 1) / .19).ceilToDouble();
  }

  /// Combien d'exemplaires la trésorerie permet d'acheter d'un coup.
  static int quantiteAbordable(EtatPartie e, int i, {int plafond = 1000}) {
    var n = 0;
    while (n < plafond && coutStations(e, i, n + 1) <= e.tresorerie) {
      n++;
    }
    return n;
  }

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

  /// Ce que le marché absorbe, en part de ce que l'atelier sait produire.
  ///
  /// Au-dessus du prix du marché, les clients vont voir ailleurs : c'est le
  /// vrai prix d'une marge élevée. Sans cela on vendait autant quoi qu'il
  /// arrive, et vendre cher n'avait aucun inconvénient. En dessous du marché
  /// on écoule tout ce qu'on fabrique, jamais plus : on ne vend pas ce qu'on
  /// n'a pas produit.
  static double demande(EtatPartie e) =>
      pow(max(2 - e.marge, .05), 1.5).clamp(.1, 1).toDouble();

  /// Ce que l'atelier écoule réellement par seconde, demande comprise.
  static double cadenceVendue(EtatPartie e) => cadence(e) * demande(e);

  /// Ce que l'atelier encaisse par seconde à plein régime.
  static double recetteBrute(EtatPartie e) => cadenceVendue(e) * prixUnite(e);

  /// La taille de la maison, valorisée au prix du marché.
  ///
  /// Sert d'assiette aux salaires : ce qu'on doit à ses gens tient à
  /// l'ampleur de l'atelier, pas à la politique tarifaire du patron. Les
  /// indexer sur la recette ferait baisser la paie quand on se trompe de
  /// prix, ce qui amortirait justement l'erreur qu'on veut faire sentir.
  static double assietteSalaire(EtatPartie e) =>
      max(cadence(e) * prixMarche(e), prixMarche(e));

  /// Ce qu'une personne coûte sur le marché du travail, en euros par seconde.
  ///
  /// Un ingénieur de 2040 ne se paie pas au tarif de 1975 : le tarif suit
  /// l'activité. Un salaire figé à l'embauche décroche donc peu à peu, et il
  /// faut augmenter les gens pour les garder — comme dans la vraie vie.
  /// Ce que pèse la paie, rapporté à ce que l'atelier encaisse à plein régime.
  ///
  /// C'est le poste le plus lourd d'une entreprise qui fabrique, et c'est ce
  /// qui doit rendre une embauche sérieuse. Il grandit avec la société : on ne
  /// paie pas dans un garage comme dans un groupe. Le tenir constant étouffait
  /// les ères du milieu, où une masse salariale de grande entreprise tombe sur
  /// une société qui n'en est pas encore une.
  static double coefficientSalaire(EtatPartie e) => 1.2 + .2 * ereCourante(e);

  /// Ce que coûte cette personne, en euros par seconde.
  ///
  /// Les salaires suivent l'activité : l'atelier grandit, la paie aussi. Ce
  /// qui change tout par rapport à une commission sur les ventes, c'est qu'ils
  /// tombent même les jours où l'on ne vend rien.
  static double salaireDe(EtatPartie e, Employe membre) =>
      membre.part * coefficientSalaire(e) * assietteSalaire(e);

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

  /// Ce que vaut le parc : la somme de ce que chaque exemplaire a coûté.
  ///
  /// Chaque exemplaire supplémentaire se paie 19 % de plus que le précédent,
  /// d'où la somme géométrique. C'est la valeur à entretenir, et elle suit la
  /// progression du joueur — au contraire du prix de base, qui ne bouge pas.
  static double valeurParc(EtatPartie e) {
    var t = 0.0;
    for (var i = 0; i < stations.length; i++) {
      final n = e.exemplaires[i];
      if (n <= 0) continue;
      t += stations[i].coutBase * (pow(1.19, n) - 1) / .19;
    }
    return t;
  }

  /// Part de la valeur du parc qu'il faut dépenser chaque seconde pour le
  /// garder en état. Un parc immobile coûte quand même.
  static const double tauxEntretien = 1 / 13000;

  static double entretienParc(EtatPartie e) => valeurParc(e) * tauxEntretien;

  /// Tout ce qui sort chaque seconde, production ou pas.
  static double chargesParSeconde(EtatPartie e) =>
      masseSalariale(e) + entretienParc(e) + echeanceEmprunt(e);

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
