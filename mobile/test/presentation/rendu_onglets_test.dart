import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/stations.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/technologies.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/avancer_partie_use_case.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/gerer_atelier_use_case.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/use_cases/gerer_equipe_use_case.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/views/atelier_view.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/views/equipe_view.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/views/marche_view.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/views/production_view.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/views/recherche_view.dart';

import 'aides/hote_partie.dart';

/// Une partie déjà entamée : ateliers montés, brevets déposés, équipe embauchée.
///
/// Les listes d'achat ne se peignent que si elles ont quelque chose à montrer ;
/// un état neuf laisserait la moitié des écrans vides et le garde-fou muet.
EtatPartie _partieEntamee() {
  final hasard = Random(5);
  final etat = EtatPartie.neuve();
  final avancer = AvancerPartieUseCase(hasard: hasard);
  const atelier = GererAtelierUseCase();
  final equipe = GererEquipeUseCase(hasard: hasard);

  for (var t = 0.0; t < 4 * 3600; t += 2) {
    avancer(etat, 2);
    atelier.acheterComposants(etat);
    atelier.assembler(etat);
    for (var i = stations.length - 1; i >= 0; i--) {
      if (atelier.acheterStation(etat, i)) break;
    }
    for (var i = 0; i < technologies.length; i++) {
      if (!etat.possede(technologies[i].id)) {
        atelier.acheterTechnologie(etat, i);
      }
    }
    equipe.embaucher(etat);
  }
  return etat;
}

void main() {
  late EtatPartie etat;

  setUpAll(() {
    etat = _partieEntamee();
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
    expect(find.text('Fonder le conglomérat'), findsOneWidget);
  });
}
