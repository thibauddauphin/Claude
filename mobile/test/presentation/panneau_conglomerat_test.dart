import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/widgets/panneau_conglomerat.dart';

import 'aides/hote_partie.dart';

Widget _sous(EtatPartie etat) =>
    hotePartie(SingleChildScrollView(child: PanneauConglomerat(etat: etat)));

void main() {
  group('le panneau Conglomérat', () {
    test('reste caché tant que le joueur n’en approche pas', () {
      expect(PanneauConglomerat.estVisible(EtatPartie.neuve()), isFalse);
      expect(PanneauConglomerat.estVisible(EtatPartie.neuve()..actions = 100), isTrue);
      expect(PanneauConglomerat.estVisible(EtatPartie.neuve(parts: 1)), isTrue);
    });

    testWidgets('annonce ce qu’il manque quand les actions sont insuffisantes',
        (tester) async {
      await tester.pumpWidget(_sous(EtatPartie.neuve()..actions = 120));
      expect(find.textContaining('150 actions'), findsOneWidget);
      expect(find.text('Fonder le conglomérat'), findsNothing);
    });

    testWidgets('propose de fonder la holding dès 150 actions', (tester) async {
      await tester.pumpWidget(_sous(EtatPartie.neuve()..actions = 600));
      expect(find.text('Fonder le conglomérat'), findsOneWidget);
      expect(find.textContaining('parts de holding'), findsOneWidget);
    });

    testWidgets('liste les huit améliorations et marque celles acquises',
        (tester) async {
      final etat = EtatPartie.neuve(parts: 5, holding: {'heritage'});
      await tester.pumpWidget(_sous(etat));
      expect(find.text('Héritage industriel'), findsOneWidget);
      expect(find.text('actif'), findsOneWidget);
      expect(find.text("Carnet d'adresses"), findsOneWidget);
      expect(find.text('Empire industriel'), findsOneWidget);
    });

    testWidgets('un premier appui arme, il faut confirmer pour solder',
        (tester) async {
      await tester.pumpWidget(_sous(EtatPartie.neuve()..actions = 600));
      await tester.tap(find.text('Fonder le conglomérat'));
      await tester.pump();
      expect(find.text('Confirmer : les actions sont soldées'), findsOneWidget);
      // L'armement doit retomber seul : sans cela, un appui oublié resterait
      // amorcé et le geste suivant solderait la société sans prévenir.
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Fonder le conglomérat'), findsOneWidget);
    });
  });
}
