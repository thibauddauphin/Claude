import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/views/atelier_view.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/views/equipe_view.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/views/marche_view.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/views/production_view.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/views/recherche_view.dart';

import '../../tool/joueur_simule.dart';
import 'aides/hote_partie.dart';

void main() {
  late EtatPartie etat;

  setUpAll(() {
    etat = simuler(graine: 5, heuresMax: 4).etat;
    /* Sans quoi le garde-fou serait creux : des écrans vides se peignent
       toujours. On exige que la partie simulée ait vraiment de quoi montrer. */
    expect(etat.exemplaires.where((n) => n > 0).length, greaterThan(2),
        reason: 'aucun poste monté : la production n’aurait rien à peindre');
    expect(etat.technologies, isNotEmpty,
        reason: 'aucun brevet : la recherche n’aurait rien à peindre');
    expect(etat.equipe, isNotEmpty,
        reason: 'personne d’embauché : l’équipe n’aurait rien à peindre');
  });

  /* Peindre un onglet suffit à faire tomber le test : une décoration
     impossible, une police absente ou un débordement lèvent à la peinture.
     C'est ce qui manquait quand un liseré non uniforme arrondi a traversé
     toutes les listes d'achat sans qu'aucun test ne s'en aperçoive. */
  Future<void> peindre(WidgetTester tester, Widget onglet) async {
    await tester.pumpWidget(hotePartie(onglet));
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  group('chaque onglet se peint sur une partie entamée', () {
    testWidgets('atelier', (t) => peindre(t, AtelierView(etat: etat)));
    testWidgets('production', (t) => peindre(t, ProductionView(etat: etat)));
    testWidgets('recherche', (t) => peindre(t, RechercheView(etat: etat)));
    testWidgets('équipe', (t) => peindre(t, EquipeView(etat: etat)));
    testWidgets('marché', (t) => peindre(t, MarcheView(etat: etat)));
  });

  testWidgets('la barre de parts de marché occupe vraiment sa hauteur',
      (tester) async {
    await tester.pumpWidget(hotePartie(MarcheView(etat: EtatPartie.neuve())));
    await tester.pump();
    /* Peindre ne suffit pas : un ColoredBox sans enfant se réduit à une
       hauteur nulle sans rien signaler, et la barre disparaît en silence. */
    final segments = find.byType(ColoredBox).evaluate()
        .map((e) => tester.getSize(find.byWidget(e.widget)))
        .where((t) => t.width > 20 && t.width < 700);
    expect(segments, isNotEmpty, reason: 'aucun segment de barre trouvé');
    for (final t in segments) {
      expect(t.height, greaterThan(10), reason: 'segment aplati : $t');
    }
  });

  testWidgets('l’atelier montre le second niveau de prestige une fois mérité',
      (tester) async {
    final riche = EtatPartie.neuve()..actions = 600;
    await tester.pumpWidget(hotePartie(AtelierView(etat: riche)));
    /* L'onglet est une liste : ce qui dépasse de l'écran n'est pas construit,
       il faut y faire défiler comme le ferait le joueur. */
    await tester.dragUntilVisible(
      find.text('Fonder le conglomérat'),
      find.byType(AtelierView),
      const Offset(0, -220),
    );
    expect(find.text('Fonder le conglomérat'), findsOneWidget);
  });
}
