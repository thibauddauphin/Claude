// ignore_for_file: avoid_print — la sortie console est le produit de cet outil.

import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/eres.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/technologies.dart';
import 'package:silicium_et_cie/layers/technical/Format/nombres.dart';

import 'joueur_simule.dart';

/// Rapport de rythme d'une première partie.
///
/// Usage : dart run tool/rythme.dart [heures_max]
void main(List<String> args) {
  final heures = double.tryParse(args.isEmpty ? '' : args.first) ?? 60;
  final d = simuler(graine: 7, heuresMax: heures);

  print('\n=== RYTHME DE LA PREMIÈRE PARTIE ===\n');
  print('ère  année  nom                          atteinte à     durée'
      ' équipe     trésorerie');
  var precedent = 0.0;
  for (var i = 0; i < eres.length; i++) {
    final at = d.arrivees[i];
    if (at == null) {
      print('${i.toString().padRight(5)}${eres[i].annee}   '
          '${eres[i].nom.padRight(30)}jamais atteinte');
      continue;
    }
    print('${i.toString().padRight(5)}${eres[i].annee}   '
        '${eres[i].nom.padRight(30)}${_duree(at).padLeft(10)}'
        '${_duree(at - precedent).padLeft(10)}'
        '${(d.effectifs[i] ?? 0).toString().padLeft(7)}'
        '${Nombres.euros(d.caisses[i] ?? 0).padLeft(14)}');
    precedent = at;
  }

  final e = d.etat;
  print('\n=== ÉTAT FINAL ===');
  print('durée de la partie     ${_duree(d.fin)}');
  print('technologies           ${e.technologies.length}/${technologies.length}');
  print('trésorerie             ${Nombres.euros(e.tresorerie)}');
  print("chiffre d'affaires     ${Nombres.euros(e.chiffreAffairesCumule)}");
  print('équipe                 ${e.equipe.length} personnes');
  print('jalons                 ${e.jalonsAtteints.length}');
  print('\n=== DERNIÈRES LIGNES DU JOURNAL ===');
  for (final ligne in e.journal) {
    print('  ${ligne.texte}');
  }
}

String _duree(double s) {
  if (s < 90) return '${s.round()} s';
  if (s < 5400) return '${(s / 60).toStringAsFixed(1)} min';
  return '${(s / 3600).toStringAsFixed(2)} h';
}
