import 'package:flutter/material.dart';

import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';

/// Un bouton qui demande deux appuis.
///
/// Les remises à zéro du jeu sont irréversibles : on ne solde pas sa société
/// d'une tape involontaire. Le premier appui arme, le second engage, et
/// l'armement retombe seul au bout de quelques secondes.
class BoutonConfirme extends StatefulWidget {
  const BoutonConfirme({
    required this.titre,
    required this.titreArme,
    required this.detail,
    required this.onConfirme,
    super.key,
  });

  final String titre;
  final String titreArme;
  final String detail;
  final VoidCallback onConfirme;

  @override
  State<BoutonConfirme> createState() => _BoutonConfirmeState();
}

class _BoutonConfirmeState extends State<BoutonConfirme> {
  bool _arme = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: p.surAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () {
        if (!_arme) {
          setState(() => _arme = true);
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) setState(() => _arme = false);
          });
          return;
        }
        setState(() => _arme = false);
        widget.onConfirme();
      },
      child: Column(
        children: [
          Text(_arme ? widget.titreArme : widget.titre,
              textAlign: TextAlign.center,
              style: ThemeAtelier.corps(p, couleur: p.surAccent)
                  .copyWith(fontWeight: FontWeight.w600)),
          Text(widget.detail,
              textAlign: TextAlign.center,
              style: ThemeAtelier.chiffres(p,
                  couleur: p.surAccent, taille: 11, graisse: FontWeight.w400)),
        ],
      ),
    );
  }
}
