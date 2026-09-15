import 'package:flutter/material.dart';

import '../../../../technical/Format/nombres.dart';
import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../../domain/catalogue/concurrents.dart';
import '../../domain/catalogue/jalons.dart';
import '../../domain/entities/etat_partie.dart';
import '../../domain/regles.dart';
import '../widgets/afficheur.dart';
import '../widgets/courbe_revenu.dart';

/// L'onglet du dehors : parts de marché, revenu, journal de bord, jalons.
class MarcheView extends StatelessWidget {
  const MarcheView({required this.etat, super.key});

  final EtatPartie etat;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final total = etat.puissance + Regles.puissanceTotaleRivaux(etat);
    final parts = <(String, double, Color)>[
      ('Silicium & Cie', total > 0 ? etat.puissance / total * 100 : 0, p.vous),
      for (var i = 0; i < concurrents.length; i++)
        (concurrents[i].nom, total > 0 ? etat.puissanceRivaux[i] / total * 100 : 0,
            p.rivaux[i]),
    ];
    final acquis = jalons.where((j) => etat.jalonsAtteints.contains(j.id)).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        Panneau(
          titre: 'Parts de marché',
          enfant: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 20,
                child: Row(
                  children: [
                    for (final (i, part) in parts.indexed) ...[
                      if (i > 0) const SizedBox(width: 2),
                      Expanded(
                        flex: (part.$2 * 100).round().clamp(1, 1000000),
                        child: ColoredBox(color: part.$3),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              for (final part in parts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, color: part.$3),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(part.$1,
                            style: ThemeAtelier.corps(p, taille: 12.5).copyWith(
                                fontWeight:
                                    part.$1.startsWith('Silicium') ? FontWeight.w600 : null)),
                      ),
                      Text(Nombres.pourcent(part.$2),
                          style: ThemeAtelier.chiffres(p,
                              couleur: p.encreDouce, taille: 11.5)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Panneau(
          titre: 'Revenu · 60 s',
          enfant: SizedBox(
            height: 76,
            child: CustomPaint(
              painter: CourbeRevenuPeintre(
                valeurs: etat.historiqueRevenu,
                accent: p.accent,
                trait: p.trait,
                fond: p.panneau,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Panneau(
          titre: 'Journal de bord',
          enfant: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (etat.journal.isEmpty)
                Text('Rien à signaler pour le moment.',
                    style: ThemeAtelier.corps(p, couleur: p.encrePale, taille: 12))
              else
                for (final ligne in etat.journal.reversed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ligne.annee,
                            style: ThemeAtelier.chiffres(p,
                                couleur: p.encrePale, taille: 11, graisse: FontWeight.w400)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(ligne.texte,
                              style: ThemeAtelier.corps(p, couleur: p.encreDouce, taille: 12)),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Panneau(
          titre: 'Jalons',
          indication: '$acquis/${jalons.length} · production '
              '+${((Regles.bonusJalons(etat) - 1) * 100).round()} %',
          enfant: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final jalon in jalons)
                _Jalon(jalon: jalon, atteint: etat.jalonsAtteints.contains(jalon.id)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Jalon extends StatelessWidget {
  const _Jalon({required this.jalon, required this.atteint});

  final dynamic jalon;
  final bool atteint;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Opacity(
      opacity: atteint ? 1 : .45,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: atteint ? p.panneauCreux : null,
          border: Border(
            left: BorderSide(color: atteint ? p.accent : p.trait, width: atteint ? 4 : 1),
            top: BorderSide(color: p.trait),
            right: BorderSide(color: p.trait),
            bottom: BorderSide(color: p.trait),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(jalon.nom as String,
                style: ThemeAtelier.corps(p, taille: 11.5)
                    .copyWith(fontWeight: FontWeight.w600)),
            Text(jalon.description as String,
                style: ThemeAtelier.etiquette(p,
                    couleur: atteint ? p.accent : p.encrePale, taille: 9)),
          ],
        ),
      ),
    );
  }
}
