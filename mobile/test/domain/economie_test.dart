import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/equipe.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/employe.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/regles.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/gerer_atelier_use_case.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/rattraper_hors_ligne_use_case.dart';

/// Un atelier sans machine, sans stock et sans le sou.
EtatPartie _aSec({int employes = 0}) {
  final e = EtatPartie.neuve()
    ..tresorerie = 0
    ..composants = 0;
  for (var i = 0; i < e.exemplaires.length; i++) {
    e.exemplaires[i] = 0;
  }
  for (var i = 0; i < employes; i++) {
    e.equipe.add(Employe(
      prenom: 'Essai',
      nom: '$i',
      caractereId: caracteres.first.id,
      poste: 'Atelier',
      part: .05,
      partInitiale: .05,
      age: 30,
      ageRetraite: 64,
      graine: i + 1,
    ));
  }
  return e;
}

void main() {
  const atelier = GererAtelierUseCase();

  group('le clic rapporte toujours', () {
    test('un atelier à sec peut repartir de lui-même', () {
      final e = _aSec();
      var gagne = 0.0;
      for (var i = 0; i < 10; i++) {
        gagne += atelier.assembler(e);
      }
      expect(gagne, greaterThan(0),
          reason: 'sans cela, zéro euro et zéro composant est sans issue');
      expect(atelier.acheterComposants(e), isTrue,
          reason: 'le joueur doit pouvoir racheter du stock après avoir cliqué');
    });

    test('les composants restent nettement plus rentables', () {
      final avec = EtatPartie.neuve()
        ..tresorerie = 0
        ..composants = 100;
      final sans = EtatPartie.neuve()
        ..tresorerie = 0
        ..composants = 0;
      final rapport = atelier.assembler(avec) / atelier.assembler(sans);
      expect(rapport, closeTo(1 / Regles.partBricolage, .01),
          reason: 'le bricolage ne doit jamais remplacer l’approvisionnement');
    });
  });

  group('hors ligne', () {
    /// Quatre heures d'absence sur un atelier sans machine ni stock.
    double gainApresAbsence({required int employes}) {
      final e = _aSec(employes: employes);
      e.derniereSauvegarde =
          DateTime.now().subtract(const Duration(hours: 4));
      final avant = e.tresorerie;
      const RattraperHorsLigneUseCase()(e);
      return e.tresorerie - avant;
    }

    test('l’équipe fait tourner l’atelier en l’absence du joueur', () {
      expect(gainApresAbsence(employes: 1), greaterThan(0));
    });

    test('sans personne à l’atelier, rien ne sort', () {
      expect(gainApresAbsence(employes: 0), 0);
    });
  });
}
