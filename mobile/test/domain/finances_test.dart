import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/equipe.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/employe.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/regles.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/avancer_partie_use_case.dart';

/// Un atelier équipé, avec du monde, mais privé de composants : il ne vend
/// plus rien et continue de payer. C'est la situation qui doit faire mal.
EtatPartie _atelierALArret({required int employes, bool avecMachines = true}) {
  final e = EtatPartie.neuve()..composants = 0;
  if (avecMachines) {
    e.exemplaires[0] = 20;
    e.exemplaires[1] = 8;
  }
  for (var i = 0; i < employes; i++) {
    e.equipe.add(Employe(
      prenom: 'Essai',
      nom: '$i',
      caractereId: caracteres.first.id,
      poste: 'Atelier',
      part: .05,
      partInitiale: .05,
      age: 35,
      ageRetraite: 64,
      graine: i + 1,
    ));
  }
  e.tresorerie = 5000;
  return e;
}

void main() {
  group('les charges tombent que l’atelier tourne ou non', () {
    test('un atelier à l’arrêt vide la caisse', () {
      /* Avec des gens dedans, le bricolage limite la casse sans la combler :
         ce qu'ils récupèrent ne couvre pas leur salaire. */
      final e = _atelierALArret(employes: 3);
      final depart = e.tresorerie;
      final avancer = AvancerPartieUseCase();
      for (var t = 0; t < 200; t++) {
        avancer(e, 1);
      }
      expect(e.tresorerie, lessThan(depart),
          reason: 'sans charges fixes, ne rien produire ne coûterait rien');
    });

    test('embaucher engage : trois personnes coûtent plus qu’une', () {
      final une = Regles.chargesParSeconde(_atelierALArret(employes: 1));
      final trois = Regles.chargesParSeconde(_atelierALArret(employes: 3));
      expect(trois, greaterThan(une * 1.5));
    });

    test('le parc coûte à entretenir même sans personne', () {
      final e = _atelierALArret(employes: 0);
      expect(Regles.entretienParc(e), greaterThan(0));
    });
  });

  group('la banque', () {
    test('un découvert prolongé force à se séparer de quelque chose', () {
      final e = _atelierALArret(employes: 4);
      e.tresorerie = -Regles.decouvertTolere(e) * 1.2;
      final machinesAvant = e.exemplaires.reduce((a, b) => a + b);
      final gensAvant = e.equipe.length;
      AvancerPartieUseCase()(e, 1);
      expect(e.equipe.length + e.exemplaires.reduce((a, b) => a + b),
          lessThan(gensAvant + machinesAvant),
          reason: 'la banque doit finir par couper');
    });

    test('la banque coupe une fois par tour, pas tout d’un coup', () {
      final e = _atelierALArret(employes: 4);
      e.tresorerie = -Regles.decouvertTolere(e) * 5;
      AvancerPartieUseCase()(e, 1);
      expect(e.equipe.length, 3,
          reason: 'un plan social en un instant ne laisse pas redresser');
    });

    test('le dépôt de bilan efface la dette et rouvre un atelier', () {
      /* Sans machines, ce que l'équipe récupère ne couvre pas sa paie : la
         situation est sans issue et la banque va au bout. */
      final e = _atelierALArret(employes: 4, avecMachines: false);
      e.tresorerie = -Regles.decouvertTolere(e) * 5;
      final avancer = AvancerPartieUseCase();
      /* On laisse la banque aller au bout : gens, puis machines, puis
         liquidation. */
      for (var t = 0; t < 60; t++) {
        avancer(e, 1);
      }
      /* Ce qui compte n'est pas d'être à zéro, c'est de pouvoir s'en sortir :
         le trou repasse sous le découvert toléré, et l'atelier vidé se
         reconstruit au clic. */
      expect(e.tresorerie, greaterThan(-Regles.decouvertTolere(e)),
          reason: 'sans issue, le joueur resterait endetté à vie');
      expect(e.equipe, isEmpty);
      expect(e.exemplaires.reduce((a, b) => a + b), 0,
          reason: 'la liquidation solde tout le parc');
    });

    test('le patrimoine survit au dépôt de bilan', () {
      final e = _atelierALArret(employes: 4, avecMachines: false)
        ..actions = 900
        ..parts = 2;
      e.jalonsAtteints.addAll(['u1', 'c3']);
      e.tresorerie = -Regles.decouvertTolere(e) * 5;
      final avancer = AvancerPartieUseCase();
      for (var t = 0; t < 60; t++) {
        avancer(e, 1);
      }
      expect(e.actions, 900);
      expect(e.parts, 2);
      expect(e.jalonsAtteints, containsAll(['u1', 'c3']),
          reason: 'vingt heures de partie ne doivent pas s’effacer d’un coup');
    });
  });

  group('l’impôt', () {
    test('frappe le bénéfice à la clôture, jamais la perte', () {
      final e = EtatPartie.neuve()
        ..tresorerie = 10000
        ..resultatExercice = 4000
        ..secondesJouees = Regles.secondesParAnnee
        ..prochainExercice = Regles.secondesParAnnee;
      AvancerPartieUseCase()(e, 1);
      expect(e.dernierImpot, greaterThan(0));

      final deficitaire = EtatPartie.neuve()
        ..tresorerie = 10000
        ..resultatExercice = -4000
        ..secondesJouees = Regles.secondesParAnnee
        ..prochainExercice = Regles.secondesParAnnee;
      AvancerPartieUseCase()(deficitaire, 1);
      expect(deficitaire.dernierImpot, 0);
    });
  });
}
