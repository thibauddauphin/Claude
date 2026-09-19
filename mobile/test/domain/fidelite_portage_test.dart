import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

// Le joueur simulé est partagé avec « dart run tool/rythme.dart » : deux
// copies finiraient par mesurer deux jeux différents.
import '../../tool/joueur_simule.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/technologies.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/regles.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/avancer_partie_use_case.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/gerer_equipe_use_case.dart';

/// Rejoue une partie sans interface, comme le fait outils/equilibrage.js côté web,
/// pour vérifier que le portage Dart tient le même rythme que la version calibrée.
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
