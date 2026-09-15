import 'dart:math';
import 'dart:ui';

import 'palette_pixel.dart';
import 'personnages.dart';
import 'pinceau_pixel.dart';

/// Ce qu'une vignette peut demander à la scène : une étincelle, une fumée.
typedef SemeurParticules = void Function(double x, double y, bool estFumee);

/// Les douze moyens de production, dessinés à leur poste.
///
/// Chaque vignette tient dans une case et pose ses pieds sur la ligne [base].
class VignettesProduction {
  const VignettesProduction._();

  static void peindre(
    PinceauPixel p,
    int index,
    double x,
    double base,
    double t,
    bool tourne,
    SemeurParticules semer,
    Random hasard,
  ) {
    switch (index) {
      case 0: _etabli(p, x, base, t, tourne, semer, hasard);
      case 1: _stagiaire(p, x, base, t, tourne);
      case 2: _technicien(p, x, base, t, tourne);
      case 3: _chaine(p, x, base, t, tourne);
      case 4: _atelierSousTraite(p, x, base, t, tourne, semer, hasard);
      case 5: _usineIntegree(p, x, base, t, tourne, semer, hasard);
      case 6: _robotCms(p, x, base, t, tourne, semer, hasard);
      case 7: _ligneAutomatisee(p, x, base, t, tourne);
      case 8: _fermeServeurs(p, x, base, t, tourne);
      case 9: _fonderie(p, x, base, t, tourne);
      case 10: _ordonnanceur(p, x, base, t, tourne);
      case 11: _essaim(p, x, base, t, tourne);
    }
  }

  static void _etabli(PinceauPixel p, double x, double b, double t, bool tourne,
      SemeurParticules semer, Random hasard) {
    final main = Personnages.debout(p, x + 38, b - 31, 0, tourne ? t * 7 : 0);
    p.px(x + 16, b - 14, 52, 3, CouleursPixel.boisClair);
    p.px(x + 16, b - 11, 52, 2, CouleursPixel.boisFonce);
    p.px(x + 18, b - 9, 4, 9, CouleursPixel.bois);
    p.px(x + 62, b - 9, 4, 9, CouleursPixel.bois);
    p.px(x + 24, b - 18, 16, 4, CouleursPixel.vertCircuit);
    p.px(x + 26, b - 17, 3, 2, CouleursPixel.metalClair);
    p.px(x + 33, b - 17, 4, 2, CouleursPixel.metalClair);
    p.px(x + 50, b - 19, 6, 5, CouleursPixel.rouge);
    if (tourne && hasard.nextDouble() < .5) semer(main.x, main.y, false);
  }

  static void _stagiaire(PinceauPixel p, double x, double b, double t, bool tourne) {
    p.px(x + 14, b - 16, 56, 3, CouleursPixel.beigeFonce);
    p.px(x + 16, b - 13, 3, 13, CouleursPixel.metalFonce);
    p.px(x + 66, b - 13, 3, 13, CouleursPixel.metalFonce);
    Personnages.assis(p, x + 26, b - 29, 1, tourne ? t * 6 : 0);
    p.px(x + 22, b - 26, 4, 10, CouleursPixel.metalFonce);
    p.px(x + 40, b - 24, 18, 8, CouleursPixel.beige);
    p.px(x + 42, b - 22, 14, 4, const Color(0xFF2F5A3C));
    p.px(x + 46, b - 16, 6, 2, CouleursPixel.beigeFonce);
    p.px(x + 56, b - 19, 10, 3, CouleursPixel.beigeClair);
    p.px(x + 18, b - 21, 8, 5, CouleursPixel.vertCircuit);
    p.px(x + 18, b - 24, 8, 3, CouleursPixel.vert);
  }

  static void _technicien(PinceauPixel p, double x, double b, double t, bool tourne) {
    p.px(x + 12, b - 18, 60, 3, CouleursPixel.metalClair);
    p.px(x + 14, b - 15, 3, 15, CouleursPixel.metalFonce);
    p.px(x + 68, b - 15, 3, 15, CouleursPixel.metalFonce);
    Personnages.debout(p, x + 22, b - 35, 2, tourne ? t * 8 : 0);
    p.px(x + 42, b - 36, 28, 18, CouleursPixel.beigeFonce);
    p.px(x + 45, b - 33, 17, 12, const Color(0xFF0D2418));
    for (var i = 0; i < 16; i++) {
      p.px(x + 45 + i, b - 27 + sin(t * 6 + i * .8) * 4, 1, 1, CouleursPixel.vertClair);
    }
    p.px(x + 64, b - 33, 4, 3, CouleursPixel.ambre);
    p.px(x + 64, b - 27, 4, 3, CouleursPixel.rouge);
    p.px(x + 20, b - 22, 14, 4, CouleursPixel.vertCircuit);
  }

  static void _chaine(PinceauPixel p, double x, double b, double t, bool tourne) {
    final d = tourne ? (t * 26) % 8 : 0.0;
    p.px(x + 8, b - 14, 76, 6, CouleursPixel.metalFonce);
    p.px(x + 8, b - 14, 76, 1, CouleursPixel.metalClair);
    for (var i = -1; i < 11; i++) {
      p.px(x + 10 + i * 8 + d, b - 12, 3, 2, CouleursPixel.metal);
    }
    p.px(x + 10, b - 8, 4, 8, CouleursPixel.metalFonce);
    p.px(x + 78, b - 8, 4, 8, CouleursPixel.metalFonce);
    for (var j = 0; j < 4; j++) {
      p.px(x + 14 + ((j * 22 + d * 2) % 74), b - 18, 10, 4, CouleursPixel.vertCircuit);
    }
    final h = tourne ? sin(t * 3).abs() * 6 : 3.0;
    p.px(x + 40, b - 40, 16, 6, CouleursPixel.rouge);
    p.px(x + 46, b - 34, 4, 10 - h, CouleursPixel.metalClair);
    p.px(x + 42, b - 24 - h, 12, 6, CouleursPixel.metalFonce);
    Personnages.assis(p, x + 64, b - 30, 3, tourne ? t * 5 : 0);
  }

  static void _atelierSousTraite(PinceauPixel p, double x, double b, double t,
      bool tourne, SemeurParticules semer, Random hasard) {
    p.px(x + 10, b - 34, 64, 34, CouleursPixel.beigeFonce);
    p.px(x + 10, b - 34, 64, 3, CouleursPixel.metalFonce);
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 2; j++) {
        final allumee = tourne && ((t * 2).floor() + i * 3 + j) % 5 < 3;
        p.px(x + 15 + i * 12, b - 28 + j * 12, 8, 7,
            allumee ? CouleursPixel.ambre : const Color(0xFF5C5646));
      }
    }
    p.px(x + 62, b - 52, 8, 18, CouleursPixel.beigeFonce);
    p.px(x + 62, b - 52, 8, 2, CouleursPixel.metalFonce);
    p.px(x + 30, b - 8, 14, 8, CouleursPixel.noir);
    if (tourne && hasard.nextDouble() < .2) semer(x + 64, b - 54, true);
  }

  static void _usineIntegree(PinceauPixel p, double x, double b, double t,
      bool tourne, SemeurParticules semer, Random hasard) {
    p.px(x + 6, b - 40, 52, 40, const Color(0xFFA89A7C));
    p.px(x + 6, b - 40, 52, 3, CouleursPixel.metalFonce);
    p.px(x + 6, b - 30, 52, 2, const Color(0xFF8D8065));
    for (var e = 0; e < 2; e++) {
      for (var i = 0; i < 4; i++) {
        final allumee = tourne && ((t * 2).floor() + i * 2 + e) % 5 < 3;
        p.px(x + 11 + i * 12, b - 26 + e * 13, 8, 8,
            allumee ? CouleursPixel.ambre : const Color(0xFF5C5646));
      }
    }
    p.px(x + 4, b - 48, 72, 3, CouleursPixel.metalFonce);
    final gx = x + 10 + (tourne ? (sin(t * .9) * .5 + .5) * 52 : 26);
    p.px(gx, b - 45, 3, 10, CouleursPixel.metalClair);
    p.px(gx - 3, b - 35, 9, 6, CouleursPixel.rouge);
    p.px(x + 60, b - 14, 22, 14, const Color(0xFF7B6D55));
    p.px(x + 62, b - 12, 18, 3, CouleursPixel.boisClair);
    p.px(x + 14, b - 52, 7, 12, const Color(0xFF9A8D72));
    p.px(x + 14, b - 52, 7, 2, CouleursPixel.metalFonce);
    if (tourne && hasard.nextDouble() < .12) semer(x + 16, b - 54, true);
  }

  static void _robotCms(PinceauPixel p, double x, double b, double t, bool tourne,
      SemeurParticules semer, Random hasard) {
    p.px(x + 10, b - 12, 72, 4, CouleursPixel.metalFonce);
    p.px(x + 14, b - 16, 20, 4, CouleursPixel.vertCircuit);
    p.px(x + 52, b - 16, 20, 4, CouleursPixel.vertCircuit);
    p.px(x + 38, b - 10, 16, 10, CouleursPixel.metalClair);
    final a1 = tourne ? sin(t * 2.2) * .7 : .3;
    final a2 = tourne ? sin(t * 2.2 + 1.3) * .9 : -.4;
    final x0 = x + 46, y0 = b - 10;
    final x1 = x0 + cos(a1 - 1.2) * 16, y1 = y0 + sin(a1 - 1.2) * 16;
    final x2 = x1 + cos(a2 - .4) * 14, y2 = y1 + sin(a2 - .4) * 14;
    p.segment(x0, y0, x1, y1, CouleursPixel.ambreFonce, 3);
    p.segment(x1, y1, x2, y2, CouleursPixel.ambre, 2);
    p.px(x2 - 1, y2 - 1, 3, 3, CouleursPixel.rouge);
    if (tourne && hasard.nextDouble() < .25) semer(x2, y2, false);
  }

  static void _ligneAutomatisee(PinceauPixel p, double x, double b, double t, bool tourne) {
    p.px(x + 4, b - 30, 76, 22, const Color(0xFF4F5560));
    p.px(x + 4, b - 30, 76, 2, const Color(0xFF79808D));
    p.px(x + 4, b - 8, 76, 8, const Color(0xFF3A3F48));
    final d = tourne ? (t * 30) % 14 : 0.0;
    for (var i = 0; i < 5; i++) {
      p.px(x + 9 + i * 15, b - 26, 11, 12, const Color(0xFF1B2029));
      p.px(x + 9 + i * 15 + ((d + i * 4) % 14) - 3, b - 22, 6, 3, CouleursPixel.vertCircuit);
    }
    final h = tourne ? sin(t * 2.6).abs() * 5 : 2.0;
    p.px(x + 36, b - 44, 12, 5, const Color(0xFF79808D));
    p.px(x + 41, b - 39, 3, 8 - h, CouleursPixel.metalClair);
    p.px(x + 37, b - 31 - h, 10, 4, CouleursPixel.ambreFonce);
    for (var k = 0; k < 4; k++) {
      final allumee = tourne && ((t * 4).floor() + k) % 4 < 2;
      p.px(x + 10 + k * 18, b - 6, 5, 3,
          allumee ? CouleursPixel.vertClair : const Color(0xFF2C313A));
    }
  }

  static void _fermeServeurs(PinceauPixel p, double x, double b, double t, bool tourne) {
    for (var r = 0; r < 3; r++) {
      final rx = x + 12 + r * 24.0;
      p.px(rx, b - 42, 20, 42, const Color(0xFF1F2A34));
      p.px(rx, b - 42, 20, 2, const Color(0xFF3D5163));
      for (var i = 0; i < 7; i++) {
        final allumee = tourne && ((t * 5).floor() + r * 2 + i) % 6 < 4;
        p.px(rx + 3, b - 38 + i * 5, 10, 3,
            allumee ? const Color(0xFF2F4D5F) : const Color(0xFF233542));
        p.px(rx + 15, b - 38 + i * 5, 2, 3,
            allumee ? CouleursPixel.cyan : const Color(0xFF1C2B36));
      }
    }
    p.px(x + 8, b - 46, 72, 4, CouleursPixel.metalFonce);
  }

  static void _fonderie(PinceauPixel p, double x, double b, double t, bool tourne) {
    p.px(x + 6, b - 44, 74, 44, const Color(0xFFDFE3E6));
    p.px(x + 6, b - 44, 74, 3, const Color(0xFFB6BCC2));
    p.px(x + 6, b - 12, 74, 2, const Color(0xFFC4C9CE));
    for (var i = 0; i < 2; i++) {
      final ox = x + 16 + i * 34.0;
      p.px(ox + 2, b - 34, 7, 1, const Color(0xFFEEF1F3));
      p.px(ox + 2, b - 33, 7, 5, const Color(0xFFF4F6F8));
      p.px(ox + 3, b - 31, 5, 2, const Color(0xFF38506A));
      p.px(ox + 1, b - 28, 9, 12, const Color(0xFFF4F6F8));
      p.px(ox + 1, b - 16, 3, 4, const Color(0xFFD8DDE2));
      p.px(ox + 6, b - 16, 3, 4, const Color(0xFFD8DDE2));
    }
    final lueur = tourne ? .4 + .6 * sin(t * 2.1).abs() : .25;
    p.px(x + 30, b - 24, 24, 10, const Color(0xFF9AA3AB));
    p.px(x + 34, b - 22, 16, 6, const Color(0xFF7FE0FF), opacite: lueur);
    p.px(x + 30, b - 30, 24, 6, const Color(0xFF7FE0FF), opacite: lueur * .33);
    p.px(x + 6, b - 54, 74, 10, const Color(0xFFC9CED3));
    for (var k = 0; k < 4; k++) {
      p.px(x + 12 + k * 18, b - 52, 10, 6,
          tourne && ((t * 3).floor() + k) % 3 != 0
              ? const Color(0xFFEEF6FA)
              : const Color(0xFFC4D2DA));
    }
  }

  static void _ordonnanceur(PinceauPixel p, double x, double b, double t, bool tourne) {
    p.px(x + 26, b - 48, 40, 48, const Color(0xFF13121C));
    p.px(x + 26, b - 48, 40, 2, CouleursPixel.violet);
    final pulsation = tourne ? .45 + .55 * sin(t * 1.7).abs() : .3;
    p.px(x + 34, b - 38, 24, 24, CouleursPixel.violet, opacite: pulsation);
    p.px(x + 38, b - 34, 16, 16, CouleursPixel.cyan, opacite: pulsation);
    p.px(x + 42, b - 30, 8, 8, CouleursPixel.blanc);
    for (var i = 0; i < 6; i++) {
      final an = t * 1.1 + i * 1.05;
      p.px(x + 46 + cos(an) * 22, b - 26 + sin(an) * 13, 2, 2,
          i.isOdd ? CouleursPixel.ambre : CouleursPixel.cyan);
    }
  }

  static void _essaim(PinceauPixel p, double x, double b, double t, bool tourne) {
    for (var i = 0; i < 4; i++) {
      final cx = x + 6 + (i % 2) * 40.0;
      final cy = b - 40 + (i ~/ 2) * 22.0;
      p.px(cx, cy, 34, 20, const Color(0xFF0F0F16));
      p.px(cx, cy, 34, 2, const Color(0xFF2A2A3A));
      final a = tourne ? .25 + .75 * sin(t * 1.4 + i * 1.1).abs() : .2;
      p.px(cx + 4, cy + 6, 26, 2,
          i.isOdd ? CouleursPixel.violet : CouleursPixel.cyan, opacite: a);
      p.px(cx + 4, cy + 12, 18, 2,
          i.isOdd ? CouleursPixel.cyan : CouleursPixel.violet, opacite: a);
    }
    for (var k = 0; k < 3; k++) {
      final an = t * 1.6 + k * 2.1;
      p.px(x + 44 + cos(an) * 34, b - 30 + sin(an) * 16, 3, 2, CouleursPixel.ambre);
    }
  }
}
