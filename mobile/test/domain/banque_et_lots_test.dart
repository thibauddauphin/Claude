import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/regles.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/avancer_partie_use_case.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/gerer_atelier_use_case.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/gerer_banque_use_case.dart';

void main() {
  const atelier = GererAtelierUseCase();
  const banque = GererBanqueUseCase();

  group('acheter par lots', () {
    test('le lot choisi décide du nombre d’exemplaires', () {
      final e = EtatPartie.neuve()
        ..tresorerie = 1e9
        ..lotAchat = 10;
      atelier.acheterStation(e, 0);
      expect(e.exemplaires[0], 10);
    });

    test('dix machines coûtent plus cher que dix fois la première', () {
      final e = EtatPartie.neuve();
      final dix = Regles.coutStations(e, 0, 10);
      expect(dix, greaterThan(Regles.coutStation(e, 0) * 10),
          reason: 'chaque exemplaire se paie 19 % de plus que le précédent');
    });

    test('un lot trop cher achète ce que la caisse permet', () {
      final e = EtatPartie.neuve()
        ..lotAchat = 100
        ..tresorerie = Regles.coutStations(EtatPartie.neuve(), 0, 3);
      expect(atelier.acheterStation(e, 0), isTrue);
      expect(e.exemplaires[0], inInclusiveRange(1, 3),
          reason: 'mieux vaut acheter trois machines que rien du tout');
    });

    test('« au maximum » vide la caisse sans la faire passer sous zéro', () {
      final e = EtatPartie.neuve()
        ..lotAchat = 0
        ..tresorerie = 5e6;
      atelier.acheterStation(e, 0);
      expect(e.exemplaires[0], greaterThan(1));
      expect(e.tresorerie, greaterThanOrEqualTo(0));
    });
  });

  group('le prix face au marché', () {
    test('vendre au prix du marché ne pénalise ni n’avantage', () {
      final e = EtatPartie.neuve()..marge = 1;
      expect(Regles.prixUnite(e), closeTo(Regles.prixMarche(e), .001));
      expect(Regles.conquete(e), closeTo(1, .01));
    });

    test('vendre très cher freine fortement la conquête', () {
      final cher = EtatPartie.neuve()..marge = 1.6;
      final marche = EtatPartie.neuve()..marge = 1;
      expect(Regles.conquete(cher), lessThan(Regles.conquete(marche) / 5),
          reason: 'sinon le prix fort est toujours gagnant');
    });

    test('vendre trop cher réduit ce qu’on écoule', () {
      final marche = EtatPartie.neuve()..marge = 1;
      final cher = EtatPartie.neuve()..marge = 1.6;
      expect(Regles.demande(marche), closeTo(1, .001));
      expect(Regles.demande(cher), lessThan(.3),
          reason: 'au-dessus du marché, les clients vont voir ailleurs');
    });

    test('on ne vend jamais plus qu’on ne fabrique', () {
      final brade = EtatPartie.neuve()..marge = .7;
      expect(Regles.demande(brade), 1,
          reason: 'brader n’invente pas de la production en plus');
    });

    test('les salaires ne suivent pas la politique de prix', () {
      final marche = EtatPartie.neuve()..marge = 1;
      final cher = EtatPartie.neuve()..marge = 1.6;
      expect(Regles.assietteSalaire(cher),
          closeTo(Regles.assietteSalaire(marche), .001),
          reason: 'sinon se tromper de prix allégerait la paie et '
              'amortirait l’erreur qu’on veut faire sentir');
    });

    test('casser les prix accélère la conquête', () {
      final bas = EtatPartie.neuve()..marge = .7;
      expect(Regles.conquete(bas), greaterThan(1.4));
    });
  });

  group('la banque', () {
    test('prête même à celui qui démarre', () {
      final e = EtatPartie.neuve();
      final obtenu = banque.emprunter(e, 1e9);
      expect(obtenu, greaterThan(0),
          reason: 'on ouvre un atelier sans capital grâce au crédit');
      expect(e.tresorerie, greaterThan(30));
      expect(e.emprunt, obtenu);
    });

    test('ne prête pas au-delà de son plafond', () {
      final e = EtatPartie.neuve();
      banque.emprunter(e, 1e30);
      expect(e.emprunt, closeTo(Regles.plafondEmprunt(e), 1));
      expect(banque.emprunter(e, 1e6), 0);
    });

    test('l’échéance alourdit les charges et éteint le capital', () {
      final e = EtatPartie.neuve();
      final sansDette = Regles.chargesParSeconde(e);
      banque.emprunter(e, 1e5);
      expect(Regles.chargesParSeconde(e), greaterThan(sansDette));

      final avant = e.emprunt;
      final avancer = AvancerPartieUseCase();
      for (var t = 0; t < 300; t++) {
        avancer(e, 1);
      }
      expect(e.emprunt, lessThan(avant), reason: 'le capital doit s’amortir');
    });

    test('rembourser par anticipation supprime l’échéance', () {
      final e = EtatPartie.neuve();
      banque.emprunter(e, 1e5);
      e.tresorerie = 1e9;
      banque.rembourser(e, 1e9);
      expect(e.emprunt, 0);
      expect(Regles.echeanceEmprunt(e), 0);
    });

    test('on ne rembourse pas avec de l’argent qu’on n’a pas', () {
      final e = EtatPartie.neuve();
      banque.emprunter(e, 1e5);
      e.tresorerie = 0;
      expect(banque.rembourser(e, 1e5), 0);
    });
  });
}
