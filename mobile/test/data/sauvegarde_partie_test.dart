import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/functional/Partie/data/gateways/sauvegarde_partie_locale.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/employe.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/regles.dart';

/// Préférences en mémoire, pour éprouver la passerelle sans le greffon.
class PreferencesEnMemoire implements PreferencesAsync {
  final Map<String, String> _valeurs = {};
  bool echoue = false;

  @override
  Future<String?> getString(String cle) async {
    if (echoue) throw StateError('stockage indisponible');
    return _valeurs[cle];
  }

  @override
  Future<void> setString(String cle, String valeur) async {
    if (echoue) throw StateError('stockage indisponible');
    _valeurs[cle] = valeur;
  }

  @override
  Future<void> remove(String cle) async => _valeurs.remove(cle);
}

void main() {
  late PreferencesEnMemoire preferences;
  late SauvegardePartieLocale sauvegarde;

  setUp(() {
    preferences = PreferencesEnMemoire();
    sauvegarde = SauvegardePartieLocale(preferences);
  });

  test('une partie avancée se retrouve intacte après relecture', () async {
    final etat = EtatPartie.neuve()
      ..tresorerie = 1.2e14
      ..composants = 42000
      ..pointsRecherche = 8.4e9
      ..gamme = 12
      ..marge = 1.15
      ..unitesVendues = 9.1e9
      ..chiffreAffaires = 2.4e14
      ..puissance = 1.2e12
      ..actions = 180
      ..parts = 2
      ..retraites = 7;
    etat.exemplaires[0] = 200;
    etat.exemplaires[5] = 60;
    etat.technologies.addAll(['fer', 'mos', 'gui', 'nn']);
    etat.holding.add('heritage');
    etat.jalonsAtteints.addAll(['u1', 'c3', 'p2']);
    etat.equipe.add(Employe(
      prenom: 'Michèle', nom: 'Vasseur', caractereId: 'soudure',
      poste: 'Établi de garage', part: .018, partInitiale: .018,
      age: 58, ageRetraite: 64, graine: 4271, moral: 88,
      ancienneteSecondes: 11000, binome: 5522,
    ));
    etat.equipe.add(Employe(
      prenom: 'Gérard', nom: 'Benali', caractereId: 'formation',
      poste: 'Usine intégrée', part: .019, partInitiale: .016,
      age: 47, ageRetraite: 63, graine: 5522, moral: 82, binome: 4271,
    ));

    await sauvegarde.ecrire(etat);
    final relu = await sauvegarde.lire();

    expect(relu, isNotNull);
    expect(relu!.tresorerie, etat.tresorerie);
    expect(relu.gamme, 12);
    expect(relu.exemplaires[0], 200);
    expect(relu.exemplaires[5], 60);
    expect(relu.technologies, containsAll(['fer', 'mos', 'gui', 'nn']));
    expect(relu.jalonsAtteints, containsAll(['u1', 'c3', 'p2']));
    expect(relu.holding, contains('heritage'));
    expect(relu.parts, 2);
    expect(relu.retraites, 7);
    expect(relu.equipe, hasLength(2));
    expect(relu.equipe.first.nomComplet, 'Michèle Vasseur');
    expect(Regles.partenaire(relu, relu.equipe.first)?.prenom, 'Gérard',
        reason: 'le binôme doit survivre à la relecture');
    expect(Regles.ereCourante(relu), Regles.ereCourante(etat));
    expect(Regles.cadence(relu), closeTo(Regles.cadence(etat), 1e-6));
  });

  test('un binôme orphelin est dénoué à la relecture', () async {
    final etat = EtatPartie.neuve();
    etat.equipe.add(Employe(
      prenom: 'Chantal', nom: 'Delaunay', caractereId: 'nego',
      poste: 'Établi de garage', part: .016, partInitiale: .016,
      age: 29, ageRetraite: 62, graine: 100, binome: 999,
    ));
    await sauvegarde.ecrire(etat);
    final relu = await sauvegarde.lire();
    expect(relu!.equipe.single.binome, isNull);
  });

  test('une sauvegarde corrompue ne bloque pas le démarrage', () async {
    await preferences.setString(SauvegardePartieLocale.cle, '{ceci n’est pas du json');
    expect(await sauvegarde.lire(), isNull);
  });

  test('un stockage indisponible ne fait pas échouer la partie', () async {
    preferences.echoue = true;
    expect(await sauvegarde.lire(), isNull);
    await sauvegarde.ecrire(EtatPartie.neuve());
  });

  test('une sauvegarde absente rend une partie neuve', () async {
    expect(await sauvegarde.lire(), isNull);
  });
}
