import 'package:flutter/rendering.dart';

import 'palette_pixel.dart';
import 'pinceau_pixel.dart';

/// Un visage de seize pixels sur dix-huit, composé depuis une graine :
/// même personne, même tête, d'une session à l'autre.
///
/// L'âge blanchit les tempes et finit par poser des lunettes.
class PortraitPeintre {
  const PortraitPeintre._();

  static void peindre(PinceauPixel p, double x, double y, int graine, {double? age}) {
    final r = Alea(graine);
    final peau = CouleursPixel.peaux[r.entier(CouleursPixel.peaux.length)];
    var cheveux = CouleursPixel.cheveux[r.entier(CouleursPixel.cheveux.length)];
    final col = CouleursPixel.tenues[r.entier(CouleursPixel.tenues.length)];
    final style = r.entier(5);
    var lunettes = r.suivant() < .32;
    final barbe = r.suivant() < .26;

    if (age != null) {
      final gris = ((age - 44) / 26).clamp(0.0, .85);
      if (gris > 0) cheveux = melange(cheveux, const Color(0xFFD8D5CD), gris);
      if (age > 52) lunettes = true;
    }
    final ombre = melange(peau, const Color(0xFF000000), .22);

    p.px(x + 1, y + 14, 14, 4, col);
    p.px(x + 1, y + 14, 14, 1, melange(col, const Color(0xFFFFFFFF), .18));
    p.px(x + 6, y + 14, 4, 2, melange(col, const Color(0xFFFFFFFF), .3));
    p.px(x + 6, y + 12, 4, 2, ombre);

    p.px(x + 4, y + 3, 8, 10, peau);
    p.px(x + 3, y + 5, 1, 6, peau);
    p.px(x + 12, y + 5, 1, 6, peau);
    p.px(x + 11, y + 4, 1, 8, ombre);
    p.px(x + 2, y + 7, 1, 2, peau);
    p.px(x + 13, y + 7, 1, 2, peau);

    switch (style) {
      case 0:
        p.px(x + 3, y + 1, 10, 3, cheveux);
        p.px(x + 3, y + 4, 1, 2, cheveux);
        p.px(x + 12, y + 4, 1, 2, cheveux);
      case 1:
        p.px(x + 3, y + 1, 10, 3, cheveux);
        p.px(x + 2, y + 3, 2, 8, cheveux);
        p.px(x + 12, y + 3, 2, 8, cheveux);
      case 2:
        p.px(x + 3, y + 3, 2, 3, cheveux);
        p.px(x + 11, y + 3, 2, 3, cheveux);
        p.px(x + 5, y + 2, 6, 1, cheveux);
      case 3:
        p.px(x + 2, y, 12, 4, cheveux);
        p.px(x + 2, y + 4, 1, 3, cheveux);
        p.px(x + 13, y + 4, 1, 3, cheveux);
      case 4:
        p.px(x + 3, y + 2, 10, 2, cheveux);
        p.px(x + 6, y, 4, 2, cheveux);
        p.px(x + 3, y + 4, 1, 2, cheveux);
        p.px(x + 12, y + 4, 1, 2, cheveux);
    }

    p.px(x + 5, y + 7, 2, 2, const Color(0xFFFFFFFF));
    p.px(x + 9, y + 7, 2, 2, const Color(0xFFFFFFFF));
    p.px(x + 6, y + 7, 1, 2, const Color(0xFF20202A));
    p.px(x + 9, y + 7, 1, 2, const Color(0xFF20202A));
    p.px(x + 5, y + 6, 2, 1, cheveux);
    p.px(x + 9, y + 6, 2, 1, cheveux);
    p.px(x + 7, y + 9, 1, 1, ombre);
    p.px(x + 6, y + 11, 4, 1, melange(peau, const Color(0xFF8A3A3A), .45));

    if (barbe) {
      p.px(x + 5, y + 10, 6, 3, melange(cheveux, peau, .25));
      p.px(x + 6, y + 11, 4, 1, const Color(0xFF7A2F2F));
    }
    if (lunettes) {
      p.px(x + 4, y + 6, 3, 3, const Color(0xFF2A2A34));
      p.px(x + 9, y + 6, 3, 3, const Color(0xFF2A2A34));
      p.px(x + 5, y + 7, 1, 1, const Color(0xFFA8D8E8));
      p.px(x + 10, y + 7, 1, 1, const Color(0xFFA8D8E8));
      p.px(x + 7, y + 7, 2, 1, const Color(0xFF2A2A34));
      p.px(x + 2, y + 6, 2, 1, const Color(0xFF2A2A34));
      p.px(x + 12, y + 6, 2, 1, const Color(0xFF2A2A34));
    }
  }
}

/// Affiche un portrait à la taille voulue, sans lissage.
class PortraitWidgetPeintre extends CustomPainter {
  const PortraitWidgetPeintre({required this.graine, this.age});

  final int graine;
  final double? age;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 16, size.height / 18);
    PortraitPeintre.peindre(PinceauPixel(canvas), 0, 0, graine, age: age);
    canvas.restore();
  }

  @override
  bool shouldRepaint(PortraitWidgetPeintre ancien) =>
      ancien.graine != graine || (ancien.age ?? 0).floor() != (age ?? 0).floor();
}
