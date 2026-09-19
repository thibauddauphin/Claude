import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Format/nombres.dart';
import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../../domain/catalogue/ameliorations_holding.dart';
import '../../domain/entities/etat_partie.dart';
import '../../domain/regles.dart';
import '../cubit/partie_cubit.dart';
import 'afficheur.dart';
import 'bouton_confirme.dart';

/// Le second niveau de prestige : solder les actions pour des parts de holding,
/// puis dépenser ces parts en avantages définitifs.
///
/// Reste caché tant que le joueur n'en approche pas : montrer une mécanique
/// hors de portée depuis 1975 n'apprend rien à personne.
class PanneauConglomerat extends StatelessWidget {
  const PanneauConglomerat({required this.etat, super.key});

  final EtatPartie etat;

  static bool estVisible(EtatPartie etat) =>
      etat.parts > 0 || etat.conglomerats > 0 || etat.actions >= 100;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<PartieCubit>();
    final aGagner = Regles.partsConglomerat(etat);

    return Panneau(
      titre: 'Conglomérat',
      indication: '${etat.holding.length}/${ameliorationsHolding.length} · '
          '${etat.parts} part${etat.parts > 1 ? 's' : ''}',
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            aGagner > 0
                ? 'Solder les actions pour fonder une holding : tout repart de '
                    'zéro, les parts restent.'
                : 'Il faut 150 actions pour convertir votre groupe en holding. '
                    'Vous en détenez ${Nombres.format(etat.actions.floorToDouble())}.',
            style: ThemeAtelier.corps(p, couleur: p.encreDouce, taille: 12.5),
          ),
          if (aGagner > 0) ...[
            const SizedBox(height: 10),
            BoutonConfirme(
              titre: 'Fonder le conglomérat',
              titreArme: 'Confirmer : les actions sont soldées',
              detail: '$aGagner part${aGagner > 1 ? 's' : ''} de holding · '
                  'production et prix ×1,3 par part',
              onConfirme: cubit.fonderConglomerat,
            ),
          ],
          const SizedBox(height: 12),
          for (final (i, amelioration) in ameliorationsHolding.indexed) ...[
            if (i > 0) const SizedBox(height: 6),
            LigneAchat(
              marqueur: _Losange(acquise: etat.holding.contains(amelioration.id)),
              nom: amelioration.nom,
              detail: amelioration.effet,
              prix: etat.holding.contains(amelioration.id)
                  ? 'actif'
                  : '${amelioration.cout}',
              unite: etat.holding.contains(amelioration.id) ? '' : 'parts',
              abordable: etat.parts >= amelioration.cout,
              acquis: etat.holding.contains(amelioration.id),
              onTap: () => cubit.acheterAmelioration(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _Losange extends StatelessWidget {
  const _Losange({required this.acquise});

  final bool acquise;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: acquise ? p.accent : p.enfonce,
        border: Border.all(color: p.traitFranc),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text('◆',
          style: TextStyle(
              fontSize: 12, color: acquise ? p.surAccent : p.encreDouce)),
    );
  }
}
