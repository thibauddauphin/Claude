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

  static double cadence(EtatPartie e) {
    var u = 0.0;
    for (var i = 0; i < stations.length; i++) {
      u += e.exemplaires[i] * stations[i].cadence;
    }
    return u * multProduction(e);
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
  static double masseSalariale(EtatPartie e) {
    var t = 0.0;
    for (final membre in e.equipe) {
      t += membre.part;
    }
    return min(.6, t);
  }

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
      membre.part * cadence(e) * prixUnite(e) * 180;

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
