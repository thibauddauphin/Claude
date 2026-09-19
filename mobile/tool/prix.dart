// ignore_for_file: avoid_print — la sortie console est le produit de cet outil.

/// Compare trois politiques de prix sur la même partie.
///
/// Sert à vérifier qu'aucune n'est gratuitement gagnante : vendre cher doit
/// rapporter davantage tout de suite et coûter du terrain sur la durée.
///
/// Usage : dart run tool/prix.dart
library;

import 'package:silicium_et_cie/layers/functional/Partie/domain/regles.dart';
import 'package:silicium_et_cie/layers/technical/Format/nombres.dart';

import 'joueur_simule.dart';

void main() {
  print('marge   ères franchies   part de marché   trésorerie   conquête');
  for (final marge in [.7, 1.0, 1.3, 1.6]) {
    final d = simuler(graine: 7, heuresMax: 3, marge: marge);
    final e = d.etat;
    print('${(marge * 100).round().toString().padLeft(4)} %'
        '${Regles.ereCourante(e).toString().padLeft(15)}'
        '${'${Regles.partMarche(e).toStringAsFixed(1)} %'.padLeft(17)}'
        '${Nombres.euros(e.tresorerie).padLeft(14)}'
        '${'×${Regles.conquete(e).toStringAsFixed(2)}'.padLeft(11)}');
  }
}
