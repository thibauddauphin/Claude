import 'package:flutter/material.dart';

import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../../domain/entities/evenement.dart';

/// La secousse de marché en cours, affichée au pied de la scène.
///
/// Glisse depuis le bas tant qu'elle dure, puis se retire : le joueur doit
/// pouvoir relier ce qu'il voit à ce que ses chiffres font.
class BanniereEvenement extends StatelessWidget {
  const BanniereEvenement({required this.evenement, super.key});

  final EvenementActif? evenement;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final actif = evenement;

    return AnimatedSlide(
      offset: actif == null ? const Offset(0, 1.2) : Offset.zero,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: actif == null
          ? const SizedBox(height: 0)
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: p.panneau,
                border: Border(
                  top: BorderSide(
                    color: actif.evenement.estFavorable ? p.bon : p.mauvais,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    actif.evenement.estFavorable
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 16,
                    color: actif.evenement.estFavorable ? p.bon : p.mauvais,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(actif.evenement.nom,
                        style: ThemeAtelier.corps(p, taille: 13)
                            .copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Text(actif.evenement.effet,
                      style: ThemeAtelier.chiffres(p,
                          couleur: p.encreDouce, taille: 11, graisse: FontWeight.w400)),
                ],
              ),
            ),
    );
  }
}
