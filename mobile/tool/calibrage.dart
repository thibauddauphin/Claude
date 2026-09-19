// ignore_for_file: avoid_print — la sortie console est le produit de cet outil.

import 'dart:io';
import 'dart:math';

import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/eres.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/technologies.dart';

import 'joueur_simule.dart';

/// Durée visée pour chaque ère, en minutes.
///
/// Une progression géométrique : chaque ère dure environ 35 % de plus que la
/// précédente, pour une première partie d'une vingtaine d'heures.
const cibles = <double>[
  5, 6.8, 9.1, 12.3, 16.6, 22.4, 30.3, 40.9, 55.2,
  74.5, 100.6, 135.8, 183.3, 247.5, 334.1,
];

/// Ajuste les coûts de recherche pour que chaque ère dure ce qu'elle doit.
///
/// Mesure sur le code Dart lui-même : c'est tout l'intérêt, l'ancien
/// calibrateur JavaScript mesurait une économie que le jeu ne joue plus.
///
/// Un passage réécrit `../jeu/donnees.js`, qui reste la source des tables. Il
/// faut ensuite régénérer et relancer pour converger :
///
///     dart run tool/calibrage.dart
///     (cd ../outils && node porter_vers_dart.js)
///
/// à répéter jusqu'à ce que l'écart annoncé descende sous quelques pour cent.
void main() {
  final fichier = File('../jeu/donnees.js');
  if (!fichier.existsSync()) {
    print('Introuvable : ${fichier.path}');
    exitCode = 1;
    return;
  }

  /* Trois parties plutôt qu'une : les événements aléatoires font varier une
     ère de plusieurs minutes, et corriger sur ce bruit fait osciller sans
     jamais converger. */
  const graines = [7, 11, 23];
  final parties = [for (final g in graines) simuler(graine: g, heuresMax: 80)];
  final durees = _moyenne([for (final p in parties) _durees(p.arrivees)]);
  final dureeMoyenne =
      parties.map((p) => p.fin).reduce((a, b) => a + b) / parties.length;
  final facteurs = List<double>.filled(eres.length, 1);
  var ecart = 0.0;
  var mesurees = 0;

  for (var i = 0; i < eres.length; i++) {
    final obtenu = durees[i];
    if (obtenu == null || obtenu <= 0) continue;
    final rapport = cibles[i] * 60 / obtenu;
    /* L'exposant amortit la correction : l'appliquer d'un coup fait osciller,
       parce qu'une ère dépend aussi de ce que le joueur a accumulé avant. */
    facteurs[i] = pow(rapport, .4).toDouble();
    ecart += (rapport - 1).abs();
    mesurees++;
    print('${eres[i].annee}  ${eres[i].nom.padRight(30)}'
        ' visé ${_min(cibles[i] * 60).padLeft(8)}'
        ' obtenu ${_min(obtenu).padLeft(8)}'
        ' ×${facteurs[i].toStringAsFixed(2)}');
  }

  print('\npartie complète ${(dureeMoyenne / 3600).toStringAsFixed(2)} h'
      ' · écart moyen ${(ecart / max(mesurees, 1) * 100).toStringAsFixed(1)} %');
  _ecrire(fichier, facteurs);
}

/// Durée moyenne de chaque ère sur plusieurs parties.
Map<int, double> _moyenne(List<Map<int, double>> mesures) {
  final total = <int, double>{};
  final compte = <int, int>{};
  for (final m in mesures) {
    m.forEach((ere, duree) {
      total[ere] = (total[ere] ?? 0) + duree;
      compte[ere] = (compte[ere] ?? 0) + 1;
    });
  }
  return {for (final e in total.keys) e: total[e]! / compte[e]!};
}

Map<int, double> _durees(Map<int, double> arrivees) {
  final d = <int, double>{};
  for (var i = 0; i < eres.length; i++) {
    final at = arrivees[i];
    final suivant = arrivees[i + 1];
    if (at != null && suivant != null) d[i] = suivant - at;
  }
  return d;
}

String _min(double secondes) => '${(secondes / 60).toStringAsFixed(1)} min';

void _ecrire(File fichier, List<double> facteurs) {
  var texte = fichier.readAsStringSync();
  var change = 0;
  for (final t in technologies) {
    final f = facteurs[t.ere];
    if ((f - 1).abs() < .002) continue;
    final motif = RegExp('(\\{id:"${t.id}",[^}]*?cout:)(\\d+)');
    if (!motif.hasMatch(texte)) continue;
    texte = texte.replaceFirstMapped(
        motif, (m) => '${m[1]}${max(1, (int.parse(m[2]!) * f).round())}');
    change++;
  }
  fichier.writeAsStringSync(texte);
  print('$change coûts réécrits dans ${fichier.path}');
}
