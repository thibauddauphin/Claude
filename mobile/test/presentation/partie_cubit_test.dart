import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/gateways/sauvegarde_partie_gateway.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/cubit/partie_cubit.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/cubit/partie_state.dart';

class SauvegardeEspionne implements SauvegardePartieGateway {
  EtatPartie? aRelire;
  int ecritures = 0;

  @override
  Future<EtatPartie?> lire() async => aRelire;

  @override
  Future<void> ecrire(EtatPartie etat) async => ecritures++;

  @override
  Future<void> effacer() async {}
}

void main() {
  late SauvegardeEspionne sauvegarde;
  late PartieCubit cubit;

  /// Horloge pilotée par le test : la boucle mesure le temps réel, il faut
  /// donc pouvoir le faire avancer de concert avec le minuteur.
  late DateTime instant;

  setUp(() {
    instant = DateTime(2026);
    sauvegarde = SauvegardeEspionne();
    cubit = PartieCubit(sauvegarde: sauvegarde, horloge: () => instant);
  });

  tearDown(() => cubit.close());

  test('le démarrage rend la main sur une partie jouable', () async {
    await cubit.demarrer();
    expect(cubit.state.statut, StatutPartie.enCours);
    expect(cubit.partie, isNotNull);
    expect(cubit.partie!.tresorerie, 30);
  });

  test('assembler encaisse et consomme des composants', () async {
    await cubit.demarrer();
    final avant = cubit.partie!.composants;
    cubit.assembler();
    expect(cubit.partie!.tresorerie, greaterThan(30));
    expect(cubit.partie!.composants, lessThan(avant));
  });

  testWidgets('la partie est sauvée environ une fois par seconde',
      (tester) async {
    await cubit.demarrer();
    expect(sauvegarde.ecritures, 0);

    // Deux secondes et demie de jeu, par pas de seize millisecondes.
    for (var i = 0; i < 160; i++) {
      instant = instant.add(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(sauvegarde.ecritures, inInclusiveRange(2, 3),
        reason: 'une sauvegarde par seconde écoulée, ni plus ni moins');
    await cubit.mettreEnVeille();
  });

  testWidgets('la simulation avance avec le temps réel, pas avec le minuteur',
      (tester) async {
    await cubit.demarrer();
    cubit.partie!.exemplaires[0] = 40;
    cubit.partie!.composants = 1e6;
    final avant = cubit.partie!.unitesVendues;

    for (var i = 0; i < 60; i++) {
      instant = instant.add(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(cubit.partie!.unitesVendues, greaterThan(avant));
    await cubit.mettreEnVeille();
  });

  test('la mise en veille sauve et arrête la simulation', () async {
    await cubit.demarrer();
    await cubit.mettreEnVeille();
    expect(sauvegarde.ecritures, greaterThan(0));
  });
}
