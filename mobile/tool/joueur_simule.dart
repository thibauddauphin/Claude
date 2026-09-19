import 'dart:math';

import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/stations.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/technologies.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/regles.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/avancer_partie_use_case.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/gerer_atelier_use_case.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/gerer_equipe_use_case.dart';

/// Ce qu'une partie jouée sans interface a donné.
class Deroule {
  const Deroule({
    required this.arrivees,
    required this.effectifs,
    required this.caisses,
    required this.fin,
    required this.etat,
  });

  /// Pour chaque ère, l'instant où le joueur y est arrivé, en secondes.
  final Map<int, double> arrivees;

  /// Effectif et trésorerie relevés à l'arrivée dans chaque ère.
  final Map<int, int> effectifs;
  final Map<int, double> caisses;

  /// Durée totale de la partie simulée, en secondes.
  final double fin;

  final EtatPartie etat;
}

/// Joue une partie complète sans interface, en jouant correctement.
///
/// C'est l'instrument de mesure du rythme : il joue contre les règles réelles
/// du jeu, pas contre un modèle à part qui pourrait diverger d'elles.
Deroule simuler({
  required int graine,
  double heuresMax = 40,
  double marge = 1,
}) {
  final hasard = Random(graine);
  final etat = EtatPartie.neuve()..marge = marge;
  final avancer = AvancerPartieUseCase(hasard: hasard);
  const atelier = GererAtelierUseCase();
  final equipe = GererEquipeUseCase(hasard: hasard);

  const dt = 2.0;
  const periodeDecision = 4.0;
  var t = 0.0;
  var prochaine = 0.0;
  final arrivees = <int, double>{0: 0};
  final effectifs = <int, int>{};
  final caisses = <int, double>{};

  void decider() {
    if (Regles.cadence(etat) < 3) {
      for (var c = 0; c < 12; c++) {
        atelier.assembler(etat);
      }
    }
    if (etat.candidat != null) equipe.embaucher(etat);
    for (var i = 0; i < etat.equipe.length; i++) {
      if (etat.equipe[i].moral < 35) equipe.augmenter(etat, i);
    }
    for (var i = 0; i < technologies.length; i++) {
      if (!etat.possede(technologies[i].id) &&
          etat.pointsRecherche >= Regles.coutTechnologie(etat, i)) {
        atelier.acheterTechnologie(etat, i);
      }
    }
    final besoin = Regles.besoinComposants(etat);
    final cadence = Regles.cadence(etat);
    final prix = Regles.prixComposant(etat);
    for (var n = 0;
        n < 30 && etat.composants < besoin * max(cadence, 1) * 90;
        n++) {
      if (etat.tresorerie < Regles.lotComposants(etat) * prix) break;
      if (!atelier.acheterComposants(etat)) break;
    }
    /* Un dirigeant correct ne met pas tout dans les machines : il garde de
       quoi tenir ses charges. Sans cette réserve, le joueur simulé tombe en
       découvert à chaque palier et la banque le restructure — ce qui mesure
       sa maladresse, pas le rythme du jeu. */
    final coussin = Regles.chargesParSeconde(etat) * Regles.secondesParAnnee * 3;
    final reserve = coussin +
        (etat.possede('appro')
            ? besoin * cadence * prix * 60
            : besoin * cadence * prix * 180);
    for (var tour = 0; tour < 8; tour++) {
      var meilleur = -1;
      var note = 0.0;
      for (var k = 0; k < stations.length; k++) {
        final cout = Regles.coutStation(etat, k);
        if (cout > etat.tresorerie - reserve) continue;
        final rapport = stations[k].cadence / cout;
        if (rapport > note) {
          note = rapport;
          meilleur = k;
        }
      }
      if (meilleur < 0) break;
      atelier.acheterStation(etat, meilleur);
    }
  }

  final limite = heuresMax * 3600;
  while (t < limite) {
    if (t >= prochaine) {
      decider();
      prochaine = t + periodeDecision;
    }
    avancer(etat, dt);
    t += dt;
    final ere = Regles.ereCourante(etat);
    arrivees.putIfAbsent(ere, () => t);
    effectifs.putIfAbsent(ere, () => etat.equipe.length);
    caisses.putIfAbsent(ere, () => etat.tresorerie);
    if (ere == 14 && etat.technologies.length == technologies.length) break;
  }
  return Deroule(
      arrivees: arrivees,
      effectifs: effectifs,
      caisses: caisses,
      fin: t,
      etat: etat);
}
