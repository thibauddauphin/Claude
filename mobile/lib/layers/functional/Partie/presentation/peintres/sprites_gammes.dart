import 'dart:ui';

import 'palette_pixel.dart';
import 'pinceau_pixel.dart';

/// Les quinze gammes, telles qu'elles défilent sur le tapis roulant.
/// Quatorze pixels de large, onze de haut.
class SpritesGammes {
  const SpritesGammes._();

  static void peindre(PinceauPixel p, int gamme, double x, double y) {
    switch (gamme) {
      case 0: _kit(p, x, y);
      case 1: _microFamilial(p, x, y);
      case 2: _telematique(p, x, y);
      case 3: _compatiblePc(p, x, y);
      case 4: _portable(p, x, y);
      case 5: _multimedia(p, x, y);
      case 6: _serveur(p, x, y);
      case 7: _baie(p, x, y);
      case 8: _box(p, x, y);
      case 9: _telephone(p, x, y);
      case 10: _cloud(p, x, y);
      case 11: _capteur(p, x, y);
      case 12: _grappe(p, x, y);
      case 13: _quantique(p, x, y);
      case 14: _neuro(p, x, y);
    }
  }

  static void _kit(PinceauPixel p, double x, double y) {
    p.px(x, y + 2, 14, 7, CouleursPixel.vertCircuit);
    p.px(x, y + 2, 14, 1, CouleursPixel.vert);
    p.px(x + 2, y + 4, 4, 3, CouleursPixel.noir);
    p.px(x + 8, y + 4, 3, 2, CouleursPixel.metalClair);
    p.px(x + 8, y + 7, 4, 1, CouleursPixel.ambre);
  }

  static void _microFamilial(PinceauPixel p, double x, double y) {
    p.px(x + 1, y, 12, 6, CouleursPixel.beige);
    p.px(x + 3, y + 1, 8, 3, const Color(0xFF2F5A3C));
    p.px(x, y + 6, 14, 4, CouleursPixel.beigeFonce);
    p.px(x + 1, y + 7, 12, 1, CouleursPixel.beigeClair);
  }

  static void _telematique(PinceauPixel p, double x, double y) {
    p.px(x + 1, y, 11, 7, const Color(0xFFD8D2BD));
    p.px(x + 3, y + 1, 7, 4, const Color(0xFF1D2A1E));
    p.px(x + 4, y + 2, 5, 1, const Color(0xFF7FD08A));
    p.px(x + 4, y + 4, 3, 1, const Color(0xFF7FD08A));
    p.px(x, y + 7, 13, 3, const Color(0xFFC2BCA7));
    p.px(x + 2, y + 8, 9, 1, const Color(0xFF8D8873));
  }

  static void _compatiblePc(PinceauPixel p, double x, double y) {
    p.px(x, y, 7, 7, CouleursPixel.beige);
    p.px(x + 1, y + 1, 5, 4, const Color(0xFF28425A));
    p.px(x + 8, y + 1, 5, 9, CouleursPixel.beigeFonce);
    p.px(x + 9, y + 3, 3, 1, CouleursPixel.noir);
    p.px(x + 9, y + 6, 3, 1, CouleursPixel.ambre);
    p.px(x, y + 8, 7, 2, CouleursPixel.beigeFonce);
  }

  static void _portable(PinceauPixel p, double x, double y) {
    p.px(x, y, 13, 6, const Color(0xFF3A3A3E));
    p.px(x + 1, y + 1, 11, 4, const Color(0xFF6F9EA8));
    p.px(x, y + 6, 14, 3, const Color(0xFF4A4A50));
    p.px(x + 2, y + 7, 10, 1, const Color(0xFF6A6A72));
  }

  static void _multimedia(PinceauPixel p, double x, double y) {
    p.px(x, y, 6, 11, CouleursPixel.beige);
    p.px(x + 1, y + 2, 4, 1, const Color(0xFF3A3A44));
    p.px(x + 1, y + 5, 4, 2, const Color(0xFF5A5A66));
    p.px(x + 7, y + 1, 7, 9, const Color(0xFF2A2A34));
    p.px(x + 8, y + 2, 5, 5, const Color(0xFF5A8FBF));
    p.px(x + 9, y + 8, 3, 1, const Color(0xFFC8C8D4));
  }

  static void _serveur(PinceauPixel p, double x, double y) {
    p.px(x, y + 2, 14, 6, const Color(0xFF2B3540));
    p.px(x, y + 2, 14, 1, const Color(0xFF49607A));
    p.px(x + 2, y + 4, 6, 2, const Color(0xFF1C2530));
    p.px(x + 10, y + 4, 1, 2, CouleursPixel.cyan);
    p.px(x + 12, y + 4, 1, 2, CouleursPixel.vertClair);
  }

  static void _baie(PinceauPixel p, double x, double y) {
    p.px(x + 2, y, 10, 11, const Color(0xFF242E38));
    p.px(x + 2, y, 10, 1, const Color(0xFF46607A));
    for (var i = 0; i < 4; i++) {
      p.px(x + 4, y + 2 + i * 2, 4, 1, const Color(0xFF16202A));
      p.px(x + 9, y + 2 + i * 2, 2, 1, i.isEven ? CouleursPixel.cyan : CouleursPixel.vertClair);
    }
  }

  static void _box(PinceauPixel p, double x, double y) {
    p.px(x + 1, y + 4, 12, 6, const Color(0xFFE8E4DA));
    p.px(x + 1, y + 4, 12, 1, const Color(0xFFF4F2EC));
    p.px(x + 3, y + 7, 2, 1, CouleursPixel.vertClair);
    p.px(x + 6, y + 7, 2, 1, CouleursPixel.ambre);
    p.px(x + 9, y + 7, 2, 1, const Color(0xFF4A9FD8));
    p.px(x + 2, y, 1, 4, CouleursPixel.metalClair);
    p.px(x + 11, y + 1, 1, 3, CouleursPixel.metalClair);
  }

  static void _telephone(PinceauPixel p, double x, double y) {
    p.px(x + 4, y, 6, 11, const Color(0xFF22222A));
    p.px(x + 5, y + 1, 4, 8, const Color(0xFF4AA3D8));
    p.px(x + 6, y + 10, 2, 1, const Color(0xFF5A5A66));
  }

  static void _cloud(PinceauPixel p, double x, double y) {
    p.px(x + 1, y, 12, 11, const Color(0xFF1D2833));
    for (var i = 0; i < 4; i++) {
      p.px(x + 3, y + 1 + i * 3, 6, 2, const Color(0xFF33465A));
      p.px(x + 10, y + 1 + i * 3, 2, 2, CouleursPixel.cyan);
    }
  }

  static void _capteur(PinceauPixel p, double x, double y) {
    p.px(x + 3, y + 5, 8, 4, const Color(0xFF3A4450));
    p.px(x + 3, y + 5, 8, 1, const Color(0xFF5F6D7C));
    p.px(x + 6, y + 6, 2, 2, CouleursPixel.vertClair);
    p.px(x + 7, y + 1, 1, 4, CouleursPixel.metalClair);
    p.px(x + 6, y, 3, 1, CouleursPixel.metalClair);
  }

  static void _grappe(PinceauPixel p, double x, double y) {
    p.px(x, y + 1, 14, 9, const Color(0xFF191A24));
    p.px(x, y + 1, 14, 1, CouleursPixel.violet);
    p.px(x + 2, y + 3, 4, 4, const Color(0xFF2C2C3A));
    p.px(x + 8, y + 3, 4, 4, const Color(0xFF2C2C3A));
    p.px(x + 3, y + 4, 2, 2, CouleursPixel.cyan);
    p.px(x + 9, y + 4, 2, 2, CouleursPixel.cyan);
    p.px(x + 2, y + 8, 10, 1, CouleursPixel.ambre);
  }

  static void _quantique(PinceauPixel p, double x, double y) {
    p.px(x + 6, y, 2, 2, const Color(0xFF8A7A4A));
    for (var e = 0; e < 4; e++) {
      final l = 11 - e * 2.0;
      p.px(x + 7 - l / 2, y + 2 + e * 2, l, 1, const Color(0xFFC9962F));
    }
    p.px(x + 5, y + 10, 5, 1, const Color(0xFF6FD8EC));
    p.px(x + 6, y + 9, 3, 1, const Color(0xFFD8F6FF));
  }

  static void _neuro(PinceauPixel p, double x, double y) {
    p.px(x + 1, y + 2, 12, 8, const Color(0xFF241A2E));
    p.px(x + 1, y + 2, 12, 1, const Color(0xFF4A3A60));
    p.px(x + 3, y + 4, 8, 4, const Color(0xFF8A5FD8));
    p.px(x + 5, y + 5, 4, 2, const Color(0xFFC89FF0));
    p.px(x + 2, y + 9, 10, 1, const Color(0xFFA87FE8));
  }
}
