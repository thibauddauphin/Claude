import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Format/nombres.dart';
import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../../domain/entities/etat_partie.dart';
import '../../domain/regles.dart';
import '../cubit/partie_cubit.dart';
import 'afficheur.dart';

/// Emprunter pour acheter la machine avant d'en avoir les moyens.
///
/// C'est le levier de celui qui crée sa boîte, et son risque : l'échéance
/// tombe tous les mois, que l'atelier tourne ou non.
class PanneauBanque extends StatelessWidget {
  const PanneauBanque({required this.etat, super.key});

  final EtatPartie etat;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<PartieCubit>();
    final disponible = Regles.empruntDisponible(etat);
    final echeance = Regles.echeanceEmprunt(etat);

    return Panneau(
      titre: 'Banque',
      indication: '${(Regles.tauxInteretAnnuel * 100).round()} % l’an',
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              Chiffre(
                intitule: 'Capital dû',
                valeur: Nombres.euros(etat.emprunt),
                couleur: etat.emprunt > 0 ? p.mauvais : null,
              ),
              Chiffre(
                intitule: 'Échéance',
                valeur: '${Nombres.euros(echeance)}/s',
              ),
              Chiffre(
                intitule: 'Encore empruntable',
                valeur: Nombres.euros(disponible),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (disponible > 0)
            _Bouton(
              titre: 'Emprunter ${Nombres.euros(disponible)}',
              detail: 'Remboursable sur cinq ans · l’échéance entre '
                  'immédiatement dans vos charges',
              onAppui: () => cubit.emprunter(disponible),
            ),
          if (etat.emprunt > 0) ...[
            const SizedBox(height: 8),
            _Bouton(
              titre: 'Solder par anticipation',
              detail: etat.tresorerie >= etat.emprunt
                  ? 'Supprime l’échéance et allège vos charges d’autant'
                  : 'Trésorerie insuffisante : '
                      '${Nombres.euros(etat.emprunt - etat.tresorerie)} manquants',
              onAppui: etat.tresorerie >= etat.emprunt
                  ? () => cubit.rembourserEmprunt(etat.emprunt)
                  : null,
            ),
          ],
          if (etat.emprunt <= 0 && disponible <= 0)
            Text(
              'La banque ne prête pas davantage pour l’instant : son plafond '
              'suit ce que la société encaisse.',
              style: ThemeAtelier.corps(p, couleur: p.encrePale, taille: 12),
            ),
        ],
      ),
    );
  }
}

class _Bouton extends StatelessWidget {
  const _Bouton({required this.titre, required this.detail, this.onAppui});

  final String titre;
  final String detail;
  final VoidCallback? onAppui;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: p.panneauCreux,
        foregroundColor: p.encre,
        side: BorderSide(color: p.traitFranc),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: const EdgeInsets.symmetric(vertical: 11),
      ),
      onPressed: onAppui,
      child: Column(
        children: [
          Text(titre,
              textAlign: TextAlign.center,
              style: ThemeAtelier.corps(p)
                  .copyWith(fontWeight: FontWeight.w600)),
          Text(detail,
              textAlign: TextAlign.center,
              style: ThemeAtelier.chiffres(p,
                  couleur: p.encreDouce, taille: 11, graisse: FontWeight.w400)),
        ],
      ),
    );
  }
}
