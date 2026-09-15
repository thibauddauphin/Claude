import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/stations.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/technologies.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/regles.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/avancer_partie_use_case.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/gerer_atelier_use_case.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/gerer_equipe_use_case.dart';

/// Rejoue une partie sans interface, comme le fait outils/equilibrage.js côté web,
/// pour vérifier que le portage Dart tient le même rythme que la version calibrée.
({Map<int, double> arrivees, double fin, EtatPartie etat}) simuler({
  required int graine,
  double heuresMax = 40,
  double marge = 1,
}) {
  final hasard = Random(graine);
  final etat = EtatPartie.neuve()..marge = marge;
  final avancer = AvancerPartieUseCase(hasard: hasard);
  final atelier = const GererAtelierUseCase();
  final equipe = GererEquipeUseCase(hasard: hasard);

  const dt = 2.0;
  const periodeDecision = 4.0;
  var t = 0.0;
  var prochaine = 0.0;
  final arrivees = <int, double>{0: 0};

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
    for (var n = 0; n < 30 && etat.composants < besoin * max(cadence, 1) * 90; n++) {
      if (etat.tresorerie < Regles.lotComposants(etat) * prix) break;
      if (!atelier.acheterComposants(etat)) break;
    }
    final reserve = etat.possede('appro')
        ? besoin * cadence * prix * 60
        : besoin * cadence * prix * 180;
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
    if (ere == 14 && etat.technologies.length == technologies.length) break;
  }
  return (arrivees: arrivees, fin: t, etat: etat);
}

void main() {
  group('le portage tient le rythme de la version calibrée', () {
    test('une partie complète dure entre quinze et trente heures', () {
      final r = simuler(graine: 7);
      expect(r.etat.technologies.length, technologies.length,
          reason: 'la partie doit aller au bout des 45 technologies');
      final heures = r.fin / 3600;
      expect(heures, greaterThan(15), reason: 'trop rapide : $heures h');
      expect(heures, lessThan(30), reason: 'trop lent : $heures h');
    });

    test('les ères se franchissent dans l’ordre, de plus en plus lentement', () {
      final r = simuler(graine: 11);
      final arrivees = r.arrivees;
      for (var ere = 1; ere <= 14; ere++) {
        expect(arrivees[ere], isNotNull, reason: 'ère $ere jamais atteinte');
        expect(arrivees[ere]!, greaterThan(arrivees[ere - 1]!));
      }
      final debut = arrivees[3]! - arrivees[2]!;
      final fin = arrivees[14]! - arrivees[13]!;
      expect(fin, greaterThan(debut * 5),
          reason: 'la dernière ère doit être bien plus longue que les premières');
    });

    test('la part de marché monte puis se stabilise autour de l’équilibre', () {
      final r = simuler(graine: 3);
      final part = Regles.partMarche(r.etat);
      expect(part, greaterThan(35));
      expect(part, lessThan(60));
    });
  });

  group('la vie de l’équipe', () {
    test('un atelier bien tenu ne perd personne', () {
      final hasard = Random(5);
      final etat = EtatPartie.neuve();
      final avancer = AvancerPartieUseCase(hasard: hasard);
      final equipe = GererEquipeUseCase(hasard: hasard);
      etat.exemplaires[0] = 20;
      var departs = 0;
      for (var t = 0.0; t < 4 * 3600; t += 2) {
        if (etat.candidat != null) equipe.embaucher(etat);
        etat.composants = 1e9;
        departs += avancer(etat, 2).departs.length;
      }
      expect(etat.equipe, isNotEmpty);
      expect(departs, 0);
    });

    test('brader sans augmenter personne finit par vider l’atelier', () {
      final hasard = Random(5);
      final etat = EtatPartie.neuve()..marge = .7;
      final avancer = AvancerPartieUseCase(hasard: hasard);
      final equipe = GererEquipeUseCase(hasard: hasard);
      etat.exemplaires[0] = 20;
      var departs = 0;
      for (var t = 0.0; t < 8 * 3600; t += 2) {
        if (etat.candidat != null) equipe.embaucher(etat);
        etat.composants = 1e9;
        departs += avancer(etat, 2).departs.length;
      }
      expect(departs, greaterThan(0),
          reason: 'à prix cassés, la concurrence doit débaucher');
    });
  });
}
