import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Format/nombres.dart';
import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../../domain/catalogue/stations.dart';
import '../../domain/entities/etat_partie.dart';
import '../../domain/regles.dart';
import '../cubit/partie_cubit.dart';
import '../widgets/afficheur.dart';

/// Les douze moyens de production. Seuls les paliers proches sont montrés :
/// afficher l'essaim d'usines noires en 1975 ne renseigne personne.
class ProductionView extends StatelessWidget {
  const ProductionView({required this.etat, super.key});

  final EtatPartie etat;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<PartieCubit>();
    final multiplicateur = Regles.multProduction(etat);

    var dernier = -1;
    for (var i = 0; i < stations.length; i++) {
      if (etat.exemplaires[i] > 0) dernier = i;
    }
    final visibles = (dernier + 3).clamp(3, stations.length);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        Panneau(
          titre: 'Moyens de production',
          indication: '${Nombres.format(etat.totalExemplaires.toDouble())} en service',
          enfant: Column(
            children: [
              for (var i = 0; i < visibles; i++) ...[
                if (i > 0) const SizedBox(height: 6),
                LigneAchat(
                  marqueur: _Palier(numero: i + 1, possede: etat.exemplaires[i] > 0),
                  nom: stations[i].nom,
                  detail: '${stations[i].detail} · '
                      '${Nombres.format(stations[i].cadence * multiplicateur)} u/s'
                      '${etat.exemplaires[i] > 0 ? ' · ${Nombres.format(etat.exemplaires[i] * stations[i].cadence * multiplicateur)} u/s au total' : ''}',
                  prix: Nombres.euros(Regles.coutStation(etat, i)),
                  unite: etat.exemplaires[i] > 0
                      ? '×${Nombres.format(etat.exemplaires[i].toDouble())}'
                      : 'aucun',
                  abordable: etat.tresorerie >= Regles.coutStation(etat, i),
                  possede: etat.exemplaires[i] > 0,
                  onTap: () => cubit.acheterStation(i),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Chaque exemplaire supplémentaire coûte 19 % de plus que le précédent.',
          style: ThemeAtelier.corps(p, couleur: p.encrePale, taille: 11.5),
        ),
      ],
    );
  }
}

class _Palier extends StatelessWidget {
  const _Palier({required this.numero, required this.possede});

  final int numero;
  final bool possede;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: possede ? p.accent : p.enfonce,
        border: Border.all(color: p.traitFranc),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text('$numero',
          style: ThemeAtelier.chiffres(p,
              couleur: possede ? p.surAccent : p.encreDouce, taille: 11)),
    );
  }
}
