import 'dart:math';
import 'dart:ui';

import '../../domain/entities/ere.dart';
import 'dimensions_scene.dart';
import 'palette_pixel.dart';
import 'pinceau_pixel.dart';

/// Les quinze décors d'ère, du garage de 1975 à la salle de culture de 2040.
class Decors {
  const Decors._();

  static void peindre(PinceauPixel p, Decor decor, double t) {
    final d = teintesDecor[decor]!;
    const l = DimensionsScene.largeur;
    const h = DimensionsScene.hauteur;
    const sol = DimensionsScene.sol;

    p.px(0, 0, l, sol, d.mur);
    p.px(0, sol - 3, l, 3, d.murFonce);
    p.px(0, sol, l, h - sol, d.sol);
    for (var x = 0.0; x < l; x += 24) {
      p.px(x, sol, 1, h - sol, d.solFonce);
    }
    p.px(0, sol, l, 1, d.solFonce);

    switch (decor) {
      case Decor.garage:     _garage(p, d, t);
      case Decor.salon:      _salon(p, d, t);
      case Decor.minitel:    _minitel(p, d, t);
      case Decor.bureau:     _bureau(p, d, t);
      case Decor.openspace:  _openspace(p, d, t);
      case Decor.multimedia: _multimedia(p, d, t);
      case Decor.loft:       _loft(p, d, t);
      case Decor.bulle:      _bulle(p, d, t);
      case Decor.habitat:    _habitat(p, d, t);
      case Decor.showroom:   _showroom(p, d, t);
      case Decor.datacenter: _datacenter(p, d, t);
      case Decor.objets:     _objets(p, d, t);
      case Decor.hall:       _hall(p, d, t);
      case Decor.quantique:  _quantique(p, d, t);
      case Decor.neuro:      _neuro(p, d, t);
    }
  }

  // ----------------------------- pièces communes -----------------------------

  static void _fenetre(PinceauPixel p, double x, double y, double l, double h, TeinteDecor d) {
    p.px(x - 2, y - 2, l + 4, h + 4, CouleursPixel.boisFonce);
    p.px(x, y, l, h, d.ciel);
    p.px(x, y + h - 4, l, 4, const Color(0xFF6F8F5F));
    p.px(x + l / 2 - 1, y, 2, h, CouleursPixel.boisFonce);
    p.px(x, y + (h / 2).roundToDouble(), l, 1, CouleursPixel.boisFonce);
    p.px(x + 2, y + 2, 4, 3, CouleursPixel.blanc, opacite: .13);
  }

  static void _ampoule(PinceauPixel p, double x, double y, double t) {
    final oscillation = sin(t * .7) * 1.5;
    p.px(x + 2, 0, 1, y, CouleursPixel.metalFonce);
    p.px(x + oscillation, y, 5, 4, CouleursPixel.jaune);
    p.px(x - 3 + oscillation, y + 4, 11, 2, CouleursPixel.jaune, opacite: .2);
    p.px(x - 6 + oscillation, y + 6, 17, 3, CouleursPixel.jaune, opacite: .09);
  }

  static void _etagere(PinceauPixel p, double x, double y, double l) {
    p.px(x, y, l, 2, CouleursPixel.bois);
    p.px(x, y + 2, 2, 3, CouleursPixel.boisFonce);
    p.px(x + l - 2, y + 2, 2, 3, CouleursPixel.boisFonce);
    for (var i = 0; i < (l / 9).floor(); i++) {
      final h = 5 + (i * 7) % 6;
      p.px(x + 3 + i * 9, y - h, 7, h, i.isEven ? CouleursPixel.bois : CouleursPixel.boisClair);
      p.px(x + 4 + i * 9, y - h + 2, 5, 1, CouleursPixel.beigeFonce);
    }
  }

  static void _affiche(PinceauPixel p, double x, double y, Color fond, Color motif) {
    p.px(x, y, 18, 24, CouleursPixel.beigeClair);
    p.px(x + 1, y + 1, 16, 22, fond);
    p.px(x + 3, y + 4, 12, 10, motif);
    p.px(x + 3, y + 17, 12, 1, CouleursPixel.beigeClair);
    p.px(x + 3, y + 19, 8, 1, CouleursPixel.beigeClair);
  }

  static void _plante(PinceauPixel p, double x, double y) {
    p.px(x + 2, y - 6, 2, 6, const Color(0xFF4A7A3A));
    p.px(x, y - 10, 3, 5, const Color(0xFF5D9448));
    p.px(x + 4, y - 12, 3, 7, const Color(0xFF6BA553));
    p.px(x + 2, y - 14, 2, 5, const Color(0xFF5D9448));
    p.px(x, y, 7, 5, const Color(0xFFA8613C));
    p.px(x, y, 7, 1, const Color(0xFFC07A4E));
  }

  static void _horloge(PinceauPixel p, double x, double y, double t) {
    p.px(x, y, 11, 11, CouleursPixel.beigeClair);
    p.px(x + 1, y + 1, 9, 9, CouleursPixel.blanc);
    final a = t * .35;
    p.px(x + 5 + cos(a) * 3, y + 5 + sin(a) * 3, 1, 1, CouleursPixel.noir);
    p.px(x + 5 + cos(a * 12) * 4, y + 5 + sin(a * 12) * 4, 1, 1, CouleursPixel.rouge);
    p.px(x + 5, y + 5, 1, 1, CouleursPixel.noir);
  }

  // -------------------------------- les décors --------------------------------

  static void _garage(PinceauPixel p, TeinteDecor d, double t) {
    p.px(250, 26, 124, DimensionsScene.sol - 26, const Color(0xFFA8A094));
    for (var y = 30.0; y < DimensionsScene.sol - 4; y += 9) {
      p.px(250, y, 124, 2, const Color(0xFF8B8378));
    }
    p.px(250, 26, 124, 2, CouleursPixel.metalFonce);
    _fenetre(p, 40, 34, 44, 30, d);
    _etagere(p, 120, 74, 70);
    _ampoule(p, 180, 0, t);
    _affiche(p, 104, 26, CouleursPixel.bleu, CouleursPixel.ambre);
    _plante(p, 232, DimensionsScene.sol);
  }

  static void _salon(PinceauPixel p, TeinteDecor d, double t) {
    for (var x = 0.0; x < DimensionsScene.largeur; x += 8) {
      p.px(x, 0, 3, DimensionsScene.sol - 3, CouleursPixel.noir, opacite: .06);
    }
    _fenetre(p, 34, 30, 50, 34, d);
    _etagere(p, 110, 70, 84);
    _affiche(p, 212, 24, CouleursPixel.rouge, CouleursPixel.jaune);
    _horloge(p, 252, 30, t);
    _ampoule(p, 150, 0, t);
    _plante(p, 286, DimensionsScene.sol);
    const sol = DimensionsScene.sol;
    p.px(306, sol - 30, 46, 30, CouleursPixel.boisFonce);
    p.px(310, sol - 26, 34, 20, CouleursPixel.noir);
    p.px(311, sol - 25, 32, 18,
        (t * 3).floor().isEven ? const Color(0xFF2D4A66) : const Color(0xFF38597A));
    p.px(346, sol - 24, 4, 4, CouleursPixel.ambre);
  }

  static void _minitel(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    p.px(0, sol - 30, DimensionsScene.largeur, 1, d.murFonce);
    _fenetre(p, 20, 26, 52, 34, d);
    for (var r = 0; r < 3; r++) {
      for (var i = 0; i < 9; i++) {
        p.px(92 + i * 7, 44 + r * 16, 5, 14,
            i % 3 != 0 ? const Color(0xFFC9B98E) : const Color(0xFFA8823F));
      }
    }
    for (final y in [58.0, 74.0, 90.0]) {
      p.px(90, y, 66, 2, CouleursPixel.metalFonce);
    }
    _affiche(p, 172, 30, const Color(0xFF2F5F7A), CouleursPixel.beigeClair);
    _horloge(p, 204, 32, t);
    p.px(240, sol - 26, 84, 26, const Color(0xFF9A8D72));
    p.px(240, sol - 30, 84, 4, const Color(0xFFB7A98C));
    p.px(262, sol - 48, 30, 22, const Color(0xFFD8D2BD));
    p.px(265, sol - 45, 22, 14, const Color(0xFF1D2A1E));
    final ligne = (t * 4).floor() % 4;
    for (var k = 0; k < 3; k++) {
      p.px(267, sol - 43 + k * 4, k == ligne ? 18 : 11, 2, const Color(0xFF7FD08A));
    }
    p.px(262, sol - 26, 30, 4, const Color(0xFFC2BCA7));
    _plante(p, 336, sol);
  }

  static void _bureau(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    _fenetre(p, 24, 26, 64, 40, d);
    _fenetre(p, 108, 26, 64, 40, d);
    p.px(0, sol - 26, DimensionsScene.largeur, 1, d.murFonce);
    _affiche(p, 194, 30, CouleursPixel.vertCircuit, CouleursPixel.beigeClair);
    _horloge(p, 226, 32, t);
    _etagere(p, 254, 76, 60);
    p.px(330, sol - 34, 38, 34, CouleursPixel.metal);
    p.px(333, sol - 30, 32, 8, CouleursPixel.metalFonce);
    p.px(333, sol - 19, 32, 8, CouleursPixel.metalFonce);
    p.px(346, sol - 27, 6, 2, CouleursPixel.metalClair);
    p.px(346, sol - 16, 6, 2, CouleursPixel.metalClair);
  }

  static void _openspace(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    p.px(0, 18, DimensionsScene.largeur, 4, CouleursPixel.metalClair);
    for (var x = 16.0; x < DimensionsScene.largeur; x += 64) {
      p.px(x, 20, 40, 5, const Color(0xFFF6F4EC));
      p.px(x, 25, 40, 1, CouleursPixel.noir, opacite: .09);
    }
    _fenetre(p, 36, 34, 80, 44, d);
    _fenetre(p, 140, 34, 80, 44, d);
    _affiche(p, 244, 36, CouleursPixel.bleu, CouleursPixel.blanc);
    _plante(p, 300, sol);
    p.px(322, sol - 40, 44, 40, CouleursPixel.metalClair);
    p.px(326, sol - 36, 36, 22, CouleursPixel.noir);
    p.px(328, sol - 34, 32, 18, const Color(0xFF3A4A58));
    p.px(338, sol - 12, 12, 6, CouleursPixel.rouge);
  }

  static void _multimedia(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    for (var x = 0.0; x < DimensionsScene.largeur; x += 6) {
      p.px(x, 0, 2, sol - 3, CouleursPixel.blanc, opacite: .03);
    }
    _affiche(p, 26, 24, const Color(0xFF1E2A52), const Color(0xFFD8A23F));
    _affiche(p, 52, 30, const Color(0xFF5A1E2A), const Color(0xFFE0D060));
    _fenetre(p, 96, 28, 44, 30, d);
    p.px(160, 52, 78, 3, CouleursPixel.boisFonce);
    for (var i = 0; i < 13; i++) {
      p.px(163 + i * 6, 38, 4, 14,
          i.isEven ? const Color(0xFFD8D8E0) : const Color(0xFF8F8FA8));
    }
    p.px(160, 84, 78, 3, CouleursPixel.boisFonce);
    for (var j = 0; j < 13; j++) {
      p.px(163 + j * 6, 70, 4, 14,
          j % 3 != 0 ? const Color(0xFFC0C8D8) : const Color(0xFFC05A5A));
    }
    p.px(258, sol - 40, 52, 40, const Color(0xFF26262E));
    p.px(262, sol - 36, 44, 10, const Color(0xFF15151A));
    p.px(265, sol - 33, 8, 4,
        (t * 3).floor().isEven ? const Color(0xFF7FD08A) : const Color(0xFF2A5A36));
    p.px(276, sol - 33, 26, 4, const Color(0xFF3A5A7A));
    p.px(264, sol - 22, 20, 20, const Color(0xFF1A1A20));
    p.px(288, sol - 22, 20, 20, const Color(0xFF1A1A20));
    p.px(270, sol - 16, 8, 8, const Color(0xFF3A3A46));
    p.px(294, sol - 16, 8, 8, const Color(0xFF3A3A46));
    _plante(p, 330, sol);
  }

  static void _loft(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    for (var y = 8.0; y < sol - 3; y += 7) {
      for (var x = (y % 14 != 0 ? 0.0 : -8.0); x < DimensionsScene.largeur; x += 17) {
        p.px(x, y, 15, 5, CouleursPixel.noir, opacite: .07);
      }
    }
    _fenetre(p, 26, 22, 90, 56, d);
    p.px(140, 20, 60, 26, CouleursPixel.noir);
    p.px(143, 23, 54, 20, CouleursPixel.vertClair);
    for (var i = 0; i < 3; i++) {
      p.px(146 + i * 9, 28, 6, 10, CouleursPixel.noir);
    }
    _etagere(p, 222, 72, 60);
    _plante(p, 300, sol);
    p.px(318, sol - 24, 52, 24, CouleursPixel.boisFonce);
    p.px(318, sol - 30, 52, 8, CouleursPixel.rouge);
    p.px(322, sol - 22, 44, 4, CouleursPixel.rougeClair);
  }

  static void _bulle(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    // Les rectangles clairs : les affiches décrochées.
    p.px(34, 28, 30, 38, const Color(0xFFD6D1C2));
    p.px(78, 34, 24, 30, const Color(0xFFD6D1C2));
    p.px(120, 26, 40, 26, const Color(0xFFD6D1C2));
    _fenetre(p, 190, 26, 58, 36, d);
    p.px(262, 30, 44, 20, CouleursPixel.beigeClair);
    p.px(264, 32, 40, 16, const Color(0xFFB8352A));
    p.px(268, 36, 32, 3, CouleursPixel.beigeClair);
    p.px(268, 41, 20, 3, CouleursPixel.beigeClair);
    for (var i = 0; i < 7; i++) {
      final cx = 24 + (i % 4) * 15.0;
      final cy = sol - 11 - (i ~/ 4) * 11.0;
      p.px(cx, cy, 13, 11, CouleursPixel.bois);
      p.px(cx, cy, 13, 2, CouleursPixel.boisClair);
      p.px(cx + 6, cy + 2, 2, 9, CouleursPixel.boisFonce);
    }
    p.px(300, sol - 24, 4, 24, CouleursPixel.metalFonce);
    p.px(288, sol - 26, 28, 3, const Color(0xFF4A4A52));
    p.px(288, sol - 44, 4, 18, CouleursPixel.metalFonce);
    p.px(288, sol - 44, 24, 3, const Color(0xFF4A4A52));
    p.px(296, sol - 2, 14, 2, CouleursPixel.noir, opacite: .2);
  }

  static void _habitat(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    for (var x = 0.0; x < DimensionsScene.largeur; x += 14) {
      p.px(x, 0, 6, sol - 3, CouleursPixel.noir, opacite: .03);
    }
    _fenetre(p, 28, 28, 50, 34, d);
    _affiche(p, 100, 30, const Color(0xFF2A5A4A), CouleursPixel.beigeClair);
    p.px(150, sol - 34, 84, 34, CouleursPixel.boisFonce);
    p.px(150, sol - 38, 84, 4, CouleursPixel.boisClair);
    p.px(158, sol - 70, 58, 32, const Color(0xFF1C1C22));
    p.px(161, sol - 67, 52, 26,
        (t * 2).floor().isEven ? const Color(0xFF2F5F8A) : const Color(0xFF3A6F9A));
    p.px(222, sol - 52, 20, 14, const Color(0xFFE4E0D6));
    for (var k = 0; k < 4; k++) {
      final allumee = ((t * 5).floor() + k) % 5 < 3;
      p.px(225 + k * 4, sol - 48, 2, 2,
          allumee ? const Color(0xFF5FC07A) : const Color(0xFF3A5A42));
    }
    p.px(238, sol - 56, 1, 6, CouleursPixel.metalClair);
    p.px(241, sol - 58, 1, 8, CouleursPixel.metalClair);
    p.px(264, sol - 26, 74, 26, const Color(0xFF7A5F6A));
    p.px(264, sol - 36, 74, 10, const Color(0xFF8D6F7C));
    p.px(264, sol - 24, 10, 24, const Color(0xFF6B5260));
    p.px(328, sol - 24, 10, 24, const Color(0xFF6B5260));
    _plante(p, 352, sol);
  }

  static void _showroom(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    p.px(0, 10, DimensionsScene.largeur, 6, const Color(0xFFFFFFFF));
    for (var x = 20.0; x < DimensionsScene.largeur; x += 56) {
      p.px(x, 16, 28, 3, CouleursPixel.blanc, opacite: .8);
    }
    p.px(30, 30, 110, 60, const Color(0xFFDCD9D2));
    p.px(34, 34, 102, 52, const Color(0xFFFFFFFF));
    for (var i = 0; i < 3; i++) {
      p.px(44 + i * 32, 46, 20, 28, const Color(0xFFC9C6C0));
    }
    _affiche(p, 170, 34, CouleursPixel.noir, CouleursPixel.blanc);
    p.px(214, sol - 54, 68, 54, const Color(0xFFFFFFFF));
    p.px(214, sol - 54, 68, 2, const Color(0xFFD2CFC8));
    p.px(240, sol - 40, 16, 26, CouleursPixel.noir);
    p.px(242, sol - 38, 12, 22,
        (t * 2).floor().isEven ? const Color(0xFF4AA3D8) : const Color(0xFF6FBDE8));
    _plante(p, 306, sol);
  }

  static void _datacenter(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    for (var x = 8.0; x < DimensionsScene.largeur - 8; x += 26) {
      p.px(x, 24, 20, sol - 30, const Color(0xFF1A242E));
      p.px(x, 24, 20, 2, const Color(0xFF33465A));
      for (var y = 30.0; y < sol - 10; y += 6) {
        final allumee = ((t * 4).floor() + x.toInt() + y.toInt()) % 7 < 4;
        p.px(x + 3, y, 3, 2, allumee ? CouleursPixel.cyan : const Color(0xFF1D3240));
        p.px(x + 13, y, 3, 2, allumee ? const Color(0xFF3F7F9A) : const Color(0xFF1D3240));
      }
    }
    p.px(0, 6, DimensionsScene.largeur, 4, const Color(0xFF2A4A5E));
    for (var i = 0.0; i < DimensionsScene.largeur; i += 48) {
      p.px(i, 10, 24, 2, const Color(0xFF5FD0E0), opacite: .67);
    }
  }

  static void _objets(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    for (var c = 0; c < 7; c++) {
      final bx = 6 + c * 54.0;
      p.px(bx, 20, 46, sol - 26, const Color(0xFF4A515C));
      for (var r = 0; r < 4; r++) {
        p.px(bx, 26 + r * 24, 46, 3, const Color(0xFF6A7381));
        for (var i = 0; i < 7; i++) {
          final allumee = ((t * 6).floor() + c * 3 + r * 2 + i) % 9 < 3;
          p.px(bx + 3 + i * 6, 30 + r * 24, 4, 4,
              allumee ? const Color(0xFF6FD8C0) : const Color(0xFF39424D));
        }
      }
      p.px(bx + 3, 24, 18, 2, const Color(0xFFC9D2DD));
    }
    final nx = (t * 26) % (DimensionsScene.largeur + 60) - 30;
    p.px(nx, sol + 10, 30, 10, const Color(0xFFD8A23F));
    p.px(nx + 4, sol + 6, 22, 4, const Color(0xFFB9822A));
    p.px(nx + 3, sol + 20, 6, 4, const Color(0xFF1A1A20));
    p.px(nx + 21, sol + 20, 6, 4, const Color(0xFF1A1A20));
  }

  static void _hall(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    p.px(0, 0, DimensionsScene.largeur, sol, const Color(0xFF1B1A24));
    for (var x = 0.0; x < DimensionsScene.largeur; x += 48) {
      final pulsation = .4 + .6 * sin(t * .8 + x * .03).abs();
      p.px(x + 6, 12, 36, 2, CouleursPixel.violet);
      p.px(x + 6, 14, 36, 1, CouleursPixel.cyan, opacite: pulsation);
    }
    for (var i = 0; i < 6; i++) {
      final bx = 14 + i * 62.0;
      p.px(bx, 34, 44, sol - 42, const Color(0xFF101019));
      p.px(bx, 34, 44, 2, const Color(0xFF2C2A3E));
      for (var j = 0; j < 5; j++) {
        final a = .25 + .75 * sin(t * 1.6 + i + j * .7).abs();
        p.px(bx + 5, 42 + j * 14, 34, 3,
            j.isOdd ? CouleursPixel.ambre : CouleursPixel.violet, opacite: a);
      }
    }
  }

  static void _quantique(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    p.px(0, 0, DimensionsScene.largeur, sol, const Color(0xFF16232E));
    for (var i = 0.0; i < DimensionsScene.largeur; i += 64) {
      p.px(i + 8, 6, 48, 2, const Color(0xFF3F8FA8));
    }
    const cx = 192.0;
    final brille = .55 + .45 * sin(t * 1.1).abs();
    p.px(cx - 1, 0, 3, 18, const Color(0xFF8A7A4A));
    for (var e = 0; e < 6; e++) {
      final l = 66 - e * 9.0;
      final y = 18 + e * 17.0;
      p.px(cx - l / 2, y, l, 4, const Color(0xFFC9962F));
      p.px(cx - l / 2, y + 4, l, 2, const Color(0xFF8A6A1F));
      for (var k = -2; k <= 2; k++) {
        p.px(cx + k * (l / 6), y + 6, 2, 11, const Color(0xFFA8802A));
      }
    }
    p.px(cx - 10, sol - 22, 20, 20, const Color(0xFF6FD8EC), opacite: brille);
    p.px(cx - 16, sol - 14, 32, 10, const Color(0xFF6FD8EC), opacite: brille * .2);
    p.px(cx - 6, sol - 16, 12, 12, const Color(0xFFD8F6FF));
    for (final bx in [14.0, 316.0]) {
      p.px(bx, 40, 54, sol - 46, const Color(0xFF1D2B38));
      p.px(bx, 40, 54, 2, const Color(0xFF31526A));
      for (var j = 0; j < 5; j++) {
        p.px(bx + 6, 48 + j * 14, 42, 6, const Color(0xFF16222C));
        p.px(bx + 42, 50 + j * 14, 4, 2, const Color(0xFF6FD8EC));
      }
    }
  }

  static void _neuro(PinceauPixel p, TeinteDecor d, double t) {
    const sol = DimensionsScene.sol;
    p.px(0, 0, DimensionsScene.largeur, sol, const Color(0xFF1A1420));
    for (var c = 0; c < 6; c++) {
      final x = 16 + c * 62.0;
      final pulsation = .3 + .7 * sin(t * .9 + c * .9).abs();
      p.px(x, 22, 34, sol - 30, const Color(0xFF241A2E));
      p.px(x, 22, 34, 2, const Color(0xFF4A3A60));
      p.px(x + 5, 30, 24, sol - 46, const Color(0xFF8A5FD8), opacite: pulsation);
      p.px(x + 9, 36, 16, sol - 58, const Color(0xFFC89FF0), opacite: pulsation);
      for (var k = 0; k < 5; k++) {
        final y = 36 + k * 16.0;
        final ondulation = sin(t * 1.3 + k + c) * 4;
        p.segment(x + 9, y, x + 25, y + ondulation, const Color(0xFFE0C0FF), 1);
      }
      p.px(x + 2, sol - 10, 30, 8, const Color(0xFF191222));
    }
    for (var i = 0.0; i < DimensionsScene.largeur; i += 8) {
      final a = .1 + .25 * sin(t * .6 + i * .05).abs();
      p.px(i, 8, 5, 2, const Color(0xFFA87FE8), opacite: a);
    }
  }
}
