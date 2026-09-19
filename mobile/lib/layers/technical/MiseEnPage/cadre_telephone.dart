import 'package:flutter/material.dart';

import '../Theme/palette.dart';

/// Garde l'application dans une colonne de largeur téléphone.
///
/// Le jeu est dessiné pour un écran étroit. Dans un navigateur de bureau, la
/// scène de l'atelier garde son rapport 16/9 : étalée sur 1300 pixels de large
/// elle en réclame 730 de haut, ne laisse plus de place aux panneaux et les
/// chasse hors de l'écran. Les brider en largeur règle la cause.
class CadreTelephone extends StatelessWidget {
  const CadreTelephone({required this.enfant, super.key});

  /// Au-delà, on n'élargit plus : un atelier de deux mètres de large ne se lit
  /// pas mieux, et les pixels du décor deviennent des pavés.
  static const double largeurMax = 460;

  final Widget enfant;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (MediaQuery.sizeOf(context).width <= largeurMax) return enfant;
    return ColoredBox(
      color: p.fond,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: largeurMax),
          child: enfant,
        ),
      ),
    );
  }
}
