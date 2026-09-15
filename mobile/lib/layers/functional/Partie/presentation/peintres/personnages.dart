import 'dart:math';

import 'palette_pixel.dart';
import 'pinceau_pixel.dart';

/// Les silhouettes qui peuplent l'atelier.
class Personnages {
  const Personnages._();

  /// Un ouvrier debout, neuf pixels sur quinze. Renvoie la position de sa main,
  /// pour y accrocher les étincelles de soudure.
  static Point<double> debout(PinceauPixel p, double x, double y, int i, double anim) {
    final tenue = CouleursPixel.tenues[i % CouleursPixel.tenues.length];
    final peau = CouleursPixel.peaux[i % CouleursPixel.peaux.length];
    final bras = anim != 0 ? (sin(anim) > 0 ? 0.0 : 2.0) : 0.0;

    p.px(x + 2, y, 5, 1, CouleursPixel.noir);
    p.px(x + 1, y + 1, 1, 2, CouleursPixel.noir);
    p.px(x + 7, y + 1, 1, 2, CouleursPixel.noir);
    p.px(x + 2, y + 1, 5, 4, peau);
    p.px(x + 3, y + 2, 1, 1, CouleursPixel.noir);
    p.px(x + 5, y + 2, 1, 1, CouleursPixel.noir);
    p.px(x + 1, y + 5, 7, 6, tenue);
    p.px(x, y + 6, 1, 4, tenue);
    p.px(x + 8, y + 6 + bras, 1, 3, tenue);
    p.px(x + 8, y + 9 + bras, 1, 1, peau);
    p.px(x + 1, y + 11, 3, 3, CouleursPixel.metalFonce);
    p.px(x + 5, y + 11, 3, 3, CouleursPixel.metalFonce);
    p.px(x, y + 14, 4, 1, CouleursPixel.noir);
    p.px(x + 5, y + 14, 4, 1, CouleursPixel.noir);
    return Point(x + 8, y + 9 + bras);
  }

  /// Une personne assise à son poste, neuf pixels sur douze.
  static void assis(PinceauPixel p, double x, double y, int i, double anim) {
    final tenue = CouleursPixel.tenues[(i + 2) % CouleursPixel.tenues.length];
    final peau = CouleursPixel.peaux[(i + 1) % CouleursPixel.peaux.length];
    final bras = anim != 0 ? (sin(anim) > 0 ? 0.0 : 1.0) : 0.0;

    p.px(x + 2, y, 5, 1, CouleursPixel.noir);
    p.px(x + 2, y + 1, 5, 4, peau);
    p.px(x + 3, y + 2, 1, 1, CouleursPixel.noir);
    p.px(x + 5, y + 2, 1, 1, CouleursPixel.noir);
    p.px(x + 1, y + 5, 7, 5, tenue);
    p.px(x + 8, y + 6 + bras, 2, 2, tenue);
    p.px(x + 1, y + 10, 7, 2, CouleursPixel.metalFonce);
  }
}
