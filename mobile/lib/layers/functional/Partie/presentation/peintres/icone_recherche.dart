import 'dart:math';

import 'package:flutter/rendering.dart';

import 'palette_pixel.dart';
import 'pinceau_pixel.dart';

/// Les icônes des technologies, douze pixels de côté.
class IconesRecherche {
  const IconesRecherche._();

  static void peindre(PinceauPixel p, String nom, double x, double y) {
    switch (nom) {
      case 'fer':
        p.px(x + 2, y + 8, 6, 2, CouleursPixel.bois);
        p.segment(x + 3, y + 7, x + 9, y + 2, CouleursPixel.metalClair, 2);
        p.px(x + 9, y + 1, 2, 2, CouleursPixel.ambre);
      case 'puce':
      case 'puce2':
        final coeur = nom == 'puce' ? const Color(0xFF3A5A48) : CouleursPixel.cyan;
        p.px(x + 2, y + 2, 8, 8, CouleursPixel.noir);
        p.px(x + 3, y + 3, 6, 6, coeur);
        for (var i = 0; i < 3; i++) {
          p.px(x, y + 3 + i * 3, 2, 1, CouleursPixel.metalClair);
          p.px(x + 10, y + 3 + i * 3, 2, 1, CouleursPixel.metalClair);
        }
      case 'carte':
      case 'carte2':
        p.px(x + 1, y + 2, 10, 8, CouleursPixel.vertCircuit);
        p.px(x + 3, y + 4, 3, 3, CouleursPixel.noir);
        p.px(x + 7, y + 4, 2, 2, CouleursPixel.metalClair);
        p.px(x + 3, y + 8, 6, 1, CouleursPixel.ambre);
      case 'carton':
        p.px(x + 1, y + 3, 10, 7, CouleursPixel.bois);
        p.px(x + 1, y + 3, 10, 2, CouleursPixel.boisClair);
        p.px(x + 5, y + 3, 2, 7, CouleursPixel.boisFonce);
      case 'clavier':
        p.px(x + 1, y + 4, 10, 6, CouleursPixel.beige);
        p.px(x + 1, y + 4, 10, 1, CouleursPixel.beigeClair);
        for (var i = 0; i < 4; i++) {
          p.px(x + 2 + i * 2, y + 6, 1, 1, CouleursPixel.gris);
          p.px(x + 3 + i * 2, y + 8, 1, 1, CouleursPixel.gris);
        }
      case 'modem':
        p.px(x + 1, y + 5, 10, 5, CouleursPixel.beigeFonce);
        p.px(x + 2, y + 7, 2, 1, CouleursPixel.vert);
        p.px(x + 5, y + 7, 2, 1, CouleursPixel.ambre);
        p.px(x + 9, y + 1, 1, 4, CouleursPixel.metalClair);
        p.px(x + 7, y + 2, 1, 1, CouleursPixel.cyan);
      case 'livre':
        p.px(x + 2, y + 1, 8, 10, const Color(0xFFA8823F));
        p.px(x + 3, y + 2, 6, 8, CouleursPixel.beigeClair);
        p.px(x + 2, y + 1, 2, 10, const Color(0xFF7B5F2C));
      case 'palette':
        p.px(x + 1, y + 7, 10, 2, CouleursPixel.bois);
        p.px(x + 2, y + 2, 8, 5, CouleursPixel.boisClair);
        p.px(x + 2, y + 9, 2, 2, CouleursPixel.boisFonce);
        p.px(x + 8, y + 9, 2, 2, CouleursPixel.boisFonce);
      case 'bus':
        p.px(x + 1, y + 4, 10, 4, CouleursPixel.vertCircuit);
        for (var i = 0; i < 5; i++) {
          p.px(x + 1 + i * 2, y + 8, 1, 2, CouleursPixel.ambre);
        }
        p.px(x + 3, y + 1, 6, 3, CouleursPixel.noir);
      case 'souris':
        p.px(x + 3, y + 2, 6, 8, CouleursPixel.beige);
        p.px(x + 3, y + 2, 6, 3, CouleursPixel.beigeFonce);
        p.px(x + 5, y + 2, 2, 3, CouleursPixel.metalFonce);
      case 'reseau':
        p.segment(x + 2, y + 2, x + 9, y + 6, CouleursPixel.violet, 1);
        p.segment(x + 2, y + 9, x + 9, y + 6, CouleursPixel.violet, 1);
        p.px(x + 1, y + 1, 3, 3, CouleursPixel.cyan);
        p.px(x + 1, y + 8, 3, 3, CouleursPixel.cyan);
        p.px(x + 8, y + 5, 3, 3, CouleursPixel.ambre);
      case 'ecran':
        p.px(x + 1, y + 2, 10, 6, const Color(0xFF3A3A44));
        p.px(x + 2, y + 3, 8, 4, const Color(0xFF6F9EA8));
        p.px(x + 4, y + 8, 4, 2, CouleursPixel.metalFonce);
      case 'pile':
        p.px(x + 4, y + 1, 4, 1, CouleursPixel.metalClair);
        p.px(x + 3, y + 2, 6, 9, const Color(0xFF3A6B4A));
        p.px(x + 4, y + 4, 4, 2, CouleursPixel.vertClair);
      case 'casque':
        p.px(x + 2, y + 2, 8, 2, CouleursPixel.noir);
        p.px(x + 1, y + 3, 2, 5, CouleursPixel.noir);
        p.px(x + 9, y + 3, 2, 5, CouleursPixel.noir);
        p.px(x + 9, y + 8, 3, 1, CouleursPixel.metalClair);
      case 'disque':
        p.px(x + 1, y + 3, 10, 6, CouleursPixel.metal);
        p.px(x + 1, y + 3, 10, 1, CouleursPixel.metalClair);
        p.px(x + 4, y + 5, 4, 2, CouleursPixel.noir);
        p.px(x + 9, y + 7, 1, 1, CouleursPixel.ambre);
      case 'gpu':
        p.px(x + 1, y + 3, 10, 7, const Color(0xFF22222C));
        p.px(x + 2, y + 4, 3, 3, CouleursPixel.cyan);
        p.px(x + 6, y + 4, 3, 3, CouleursPixel.cyan);
        p.px(x + 2, y + 8, 8, 1, CouleursPixel.ambre);
      case 'megaphone':
        p.px(x + 2, y + 4, 3, 4, CouleursPixel.rouge);
        p.px(x + 5, y + 2, 4, 8, CouleursPixel.rougeClair);
        p.px(x + 10, y + 3, 1, 2, CouleursPixel.ambre);
        p.px(x + 10, y + 7, 1, 2, CouleursPixel.ambre);
      case 'prise':
        p.px(x + 3, y + 1, 6, 5, CouleursPixel.beige);
        p.px(x + 4, y + 2, 1, 3, CouleursPixel.noir);
        p.px(x + 7, y + 2, 1, 3, CouleursPixel.noir);
        p.px(x + 5, y + 6, 2, 5, CouleursPixel.gris);
      case 'baie':
        p.px(x + 2, y + 1, 8, 10, const Color(0xFF242E38));
        for (var i = 0; i < 4; i++) {
          p.px(x + 3, y + 2 + i * 2, 4, 1, const Color(0xFF16202A));
          p.px(x + 8, y + 2 + i * 2, 1, 1, CouleursPixel.cyan);
        }
      case 'cadenas':
        p.px(x + 4, y + 1, 4, 1, CouleursPixel.metalClair);
        p.px(x + 3, y + 2, 1, 3, CouleursPixel.metalClair);
        p.px(x + 8, y + 2, 1, 3, CouleursPixel.metalClair);
        p.px(x + 2, y + 5, 8, 6, CouleursPixel.ambreFonce);
        p.px(x + 5, y + 7, 2, 2, CouleursPixel.noir);
      case 'courbe':
        p.px(x + 1, y + 10, 10, 1, CouleursPixel.gris);
        p.segment(x + 2, y + 8, x + 5, y + 5, CouleursPixel.vertClair, 1);
        p.segment(x + 5, y + 5, x + 7, y + 7, CouleursPixel.vertClair, 1);
        p.segment(x + 7, y + 7, x + 10, y + 2, CouleursPixel.vertClair, 1);
      case 'ciseaux':
        p.segment(x + 2, y + 1, x + 8, y + 7, CouleursPixel.metalClair, 1);
        p.segment(x + 9, y + 1, x + 3, y + 7, CouleursPixel.metalClair, 1);
        p.px(x + 1, y + 8, 3, 3, CouleursPixel.rouge);
        p.px(x + 8, y + 8, 3, 3, CouleursPixel.rouge);
      case 'fibre':
        p.segment(x + 1, y + 9, x + 10, y + 2, const Color(0xFF6FD8EC), 2);
        p.px(x + 9, y + 1, 3, 3, CouleursPixel.blanc);
      case 'globe':
        p.px(x + 2, y + 2, 8, 8, const Color(0xFF2F6B8F));
        p.px(x + 2, y + 5, 8, 1, const Color(0xFF8FD0E8));
        p.px(x + 5, y + 2, 2, 8, const Color(0xFF8FD0E8));
      case 'onde':
        p.px(x + 5, y + 7, 2, 4, CouleursPixel.metalFonce);
        for (var i = 0; i < 3; i++) {
          p.px(x + 3 - i, y + 5 - i * 2, 1, 2, CouleursPixel.cyan);
          p.px(x + 8 + i, y + 5 - i * 2, 1, 2, CouleursPixel.cyan);
        }
        p.px(x + 5, y + 4, 2, 2, CouleursPixel.ambre);
      case 'sac':
        p.px(x + 2, y + 3, 8, 8, const Color(0xFF3A6B8F));
        p.px(x + 4, y + 1, 1, 3, CouleursPixel.metalClair);
        p.px(x + 7, y + 1, 1, 3, CouleursPixel.metalClair);
      case 'doigt':
        p.px(x + 5, y + 1, 2, 6, CouleursPixel.peaux[0]);
        p.px(x + 4, y + 7, 5, 4, CouleursPixel.peaux[1]);
        p.px(x + 2, y + 2, 2, 1, CouleursPixel.ambre);
        p.px(x + 8, y + 2, 2, 1, CouleursPixel.ambre);
      case 'nuage':
        p.px(x + 2, y + 5, 8, 4, CouleursPixel.blanc);
        p.px(x + 4, y + 3, 5, 3, CouleursPixel.blanc);
        p.px(x + 1, y + 6, 2, 3, CouleursPixel.beigeFonce);
      case 'boite':
        p.px(x + 1, y + 3, 10, 7, const Color(0xFF2F6B8F));
        p.px(x + 1, y + 3, 10, 2, const Color(0xFF57A3C8));
        p.px(x + 5, y + 3, 2, 7, const Color(0xFF1D4A66));
      case 'antenne':
        p.px(x + 5, y + 5, 2, 6, CouleursPixel.metalFonce);
        p.segment(x + 2, y + 1, x + 6, y + 5, CouleursPixel.metalClair, 1);
        p.segment(x + 10, y + 1, x + 6, y + 5, CouleursPixel.metalClair, 1);
        p.px(x + 4, y + 3, 4, 1, CouleursPixel.ambre);
      case 'neurone':
        p.px(x + 4, y + 4, 4, 4, const Color(0xFFA87FE8));
        for (var k = 0; k < 4; k++) {
          final a = k * 1.57 + .4;
          p.segment(x + 6, y + 6, x + 6 + 5 * cos(a), y + 6 + 5 * sin(a),
              const Color(0xFFC89FF0), 1);
        }
        p.px(x + 5, y + 5, 2, 2, CouleursPixel.blanc);
      case 'eclair':
        p.px(x + 6, y + 1, 3, 4, CouleursPixel.ambre);
        p.px(x + 4, y + 4, 4, 2, CouleursPixel.ambre);
        p.px(x + 3, y + 6, 3, 5, CouleursPixel.jaune);
      case 'goutte':
        p.px(x + 5, y + 1, 2, 3, const Color(0xFF6FD8EC));
        p.px(x + 4, y + 4, 4, 3, const Color(0xFF6FD8EC));
        p.px(x + 3, y + 7, 6, 4, const Color(0xFF3FA8D8));
      case 'atome':
        p.px(x + 5, y + 5, 2, 2, CouleursPixel.ambre);
        p.px(x + 1, y + 5, 10, 1, const Color(0xFF6FD8EC));
        p.px(x + 5, y + 1, 1, 10, const Color(0xFF6FD8EC));
        p.px(x + 2, y + 2, 2, 2, CouleursPixel.cyan);
        p.px(x + 8, y + 8, 2, 2, CouleursPixel.cyan);
      case 'bouclier':
        p.px(x + 2, y + 1, 8, 6, const Color(0xFF3A6B8F));
        p.px(x + 3, y + 7, 6, 2, const Color(0xFF3A6B8F));
        p.px(x + 5, y + 9, 2, 2, const Color(0xFF3A6B8F));
        p.px(x + 4, y + 3, 4, 1, CouleursPixel.blanc);
      case 'flocon':
        p.px(x + 5, y + 1, 2, 10, const Color(0xFFA8E0F0));
        p.px(x + 1, y + 5, 10, 2, const Color(0xFFA8E0F0));
        p.segment(x + 2, y + 2, x + 9, y + 9, const Color(0xFF7FC8E0), 1);
        p.segment(x + 9, y + 2, x + 2, y + 9, const Color(0xFF7FC8E0), 1);
      case 'spirale':
        for (var k = 0; k < 14; k++) {
          final a = k * .55;
          final r = 1 + k * .32;
          p.px(x + 6 + r * cos(a), y + 6 + r * sin(a), 1, 1,
              k < 7 ? const Color(0xFFC89FF0) : const Color(0xFF8A5FD8));
        }
      case 'oeil':
        p.px(x + 1, y + 4, 10, 4, CouleursPixel.beigeClair);
        p.px(x + 2, y + 3, 8, 6, CouleursPixel.beigeClair);
        p.px(x + 4, y + 4, 4, 4, const Color(0xFF3A6B8F));
        p.px(x + 5, y + 5, 2, 2, CouleursPixel.noir);
      default:
        p.px(x + 2, y + 2, 8, 8, CouleursPixel.gris);
    }
  }

}

/// Affiche une icône de technologie à la taille voulue.
class IconeRecherchePeintre extends CustomPainter {
  const IconeRecherchePeintre({required this.nom});

  final String nom;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 12, size.height / 12);
    IconesRecherche.peindre(PinceauPixel(canvas), nom, 0, 0);
    canvas.restore();
  }

  @override
  bool shouldRepaint(IconeRecherchePeintre ancien) => ancien.nom != nom;
}
