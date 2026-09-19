// ignore_for_file: avoid_print — la sortie console est le produit de cet outil.

/// Le compte de résultat à quatre moments d'une partie.
///
/// Sert à vérifier que les charges pèsent vraiment, et qu'elles pèsent de plus
/// en plus à mesure que la société grandit : un atelier à 85 % de marge n'a
/// pas de patron qui dort mal.
///
/// Usage : dart run tool/comptes.dart
library;

import 'package:silicium_et_cie/layers/functional/Partie/domain/regles.dart';
import 'package:silicium_et_cie/layers/technical/Format/nombres.dart';

import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'joueur_simule.dart';

void main() {
  for (final h in [0.25, 1.0, 4.0, 12.0]) {
    final e = simuler(graine: 7, heuresMax: h).etat;
    _montrer(h, e);
  }
}

void _montrer(double h, EtatPartie e) {
  final recette = Regles.recetteBrute(e);
  final comps = Regles.besoinComposants(e) * Regles.cadence(e) * Regles.prixComposant(e);
  final sal = Regles.masseSalariale(e);
  final ent = Regles.entretienParc(e);
  final res = Regles.resultatParSeconde(e);
  print('--- après $h h ---');
  print('  équipe ${e.equipe.length} · machines ${e.exemplaires.reduce((a, b) => a + b)}'
      ' · trésorerie ${Nombres.euros(e.tresorerie)}');
  print('  recette    ${Nombres.euros(recette)}/s');
  print('  composants ${Nombres.euros(-comps)}/s');
  print('  salaires   ${Nombres.euros(-sal)}/s'
      '  (${(recette > 0 ? sal / recette * 100 : 0).toStringAsFixed(1)} % de la recette)');
  print('  entretien  ${Nombres.euros(-ent)}/s'
      '  (${(recette > 0 ? ent / recette * 100 : 0).toStringAsFixed(1)} %)');
  print('  RÉSULTAT   ${Nombres.euros(res)}/s'
      '  (${(recette > 0 ? res / recette * 100 : 0).toStringAsFixed(1)} % de marge)');
  print('  exercice en cours ${Nombres.euros(e.resultatExercice)}'
      ' · dernier impôt ${Nombres.euros(e.dernierImpot)}');
}
