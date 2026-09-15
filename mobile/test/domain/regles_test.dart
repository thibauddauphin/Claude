import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/regles.dart';

void main() {
  group('une partie neuve', () {
    test('démarre dans le garage avec trente euros', () {
      final etat = EtatPartie.neuve();
      expect(etat.tresorerie, 30);
      expect(etat.composants, 12);
      expect(Regles.ereCourante(etat), 0);
      expect(Regles.cadence(etat), 0);
      expect(Regles.gamme(etat).nom, 'Kit à souder 8 bits');
    });

    test('le premier établi coûte 45 €, le second 19 % de plus', () {
      final etat = EtatPartie.neuve();
      expect(Regles.coutStation(etat, 0), 45);
      etat.exemplaires[0] = 1;
      expect(Regles.coutStation(etat, 0), 54);
    });
  });

  group('la politique de prix', () {
    test('casser les prix accélère la conquête et réduit la recette', () {
      final etat = EtatPartie.neuve()..marge = .7;
      expect(Regles.conquete(etat), closeTo(1.3, .001));
      expect(Regles.multPrix(etat), closeTo(.7, .001));
    });

    test('vendre cher fait l’inverse', () {
      final etat = EtatPartie.neuve()..marge = 1.6;
      expect(Regles.conquete(etat), closeTo(.4, .001));
      expect(Regles.multPrix(etat), closeTo(1.6, .001));
    });
  });

  group('le moral visé', () {
    test('suit les conditions de travail', () {
      final etat = EtatPartie.neuve();
      expect(Regles.cibleMoral(etat, estBloquee: false, protection: 1), closeTo(66, .5));
      etat.marge = .8;
      expect(Regles.cibleMoral(etat, estBloquee: false, protection: 1), closeTo(20, .5));
      etat.marge = 1;
      expect(Regles.cibleMoral(etat, estBloquee: true, protection: 1), closeTo(36, .5));
    });
  });

  group('le prestige', () {
    test("l'introduction en bourse demande un milliard de chiffre d'affaires", () {
      final etat = EtatPartie.neuve();
      expect(Regles.actionsIntroduction(etat), 0);
      etat.chiffreAffaires = 1e10;
      expect(Regles.actionsIntroduction(etat), 10);
      etat.chiffreAffaires = 1e15;
      expect(Regles.actionsIntroduction(etat), 39);
    });

    test('le conglomérat demande cent cinquante actions', () {
      final etat = EtatPartie.neuve();
      etat.actions = 149;
      expect(Regles.partsConglomerat(etat), 0);
      etat.actions = 150;
      expect(Regles.partsConglomerat(etat), 3);
    });
  });
}
