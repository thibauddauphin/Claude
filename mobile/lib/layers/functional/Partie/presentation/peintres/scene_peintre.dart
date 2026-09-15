import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../domain/catalogue/eres.dart';
import '../../domain/catalogue/stations.dart';
import '../../domain/entities/etat_partie.dart';
import '../../domain/regles.dart';
import 'decors.dart';
import 'dimensions_scene.dart';
import 'palette_pixel.dart';
import 'particules.dart';
import 'pinceau_pixel.dart';
import 'sprites_gammes.dart';
import 'vignettes_production.dart';

/// Un colis sur le tapis, en route vers le quai d'expédition.
class Colis {
  Colis({required this.x, required this.gamme});
  double x;
  final int gamme;
}

/// L'atelier animé.
///
/// Peint sur la grille logique puis agrandi sans lissage : c'est ce qui donne
/// les bords francs. Le peintre ne décide de rien — il lit l'agrégat et le
/// dessine ; l'avancement des colis et des particules est piloté par la vue.
class ScenePeintre extends CustomPainter {
  ScenePeintre({
    required this.etat,
    required this.temps,
    required this.particules,
    required this.colis,
    required this.hasard,
    required Listenable battement,
  }) : super(repaint: battement);

  final EtatPartie etat;
  final double temps;
  final Particules particules;
  final List<Colis> colis;
  final Random hasard;

  @override
  void paint(Canvas canvas, Size size) {
    final echelle = size.width / DimensionsScene.largeur;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(echelle);

    final p = PinceauPixel(canvas);
    final decor = eres[Regles.ereCourante(etat)].decor;
    final cadence = Regles.cadence(etat);
    final tourne = cadence > 0 && etat.composants >= Regles.besoinComposants(etat);

    Decors.peindre(p, decor, temps);
    _cartons(p);
    _vignettes(p, tourne);
    _tapis(p);
    particules.peindre(p);

    canvas.restore();
  }

  /// La pile de cartons dit d'un coup d'œil s'il reste des composants.
  void _cartons(PinceauPixel p) {
    final besoin = Regles.besoinComposants(etat);
    final piles = (log(1 + etat.composants / max(besoin, 1)) / ln10 * 4)
        .round()
        .clamp(0, 9);
    if (piles == 0) {
      p.px(4, DimensionsScene.sol - 4, 12, 4, CouleursPixel.noir, opacite: .13);
      return;
    }
    for (var i = 0; i < piles; i++) {
      final cx = 4 + (i % 3) * 13.0;
      final cy = DimensionsScene.sol - 10 - (i ~/ 3) * 10.0;
      p.px(cx, cy, 12, 10, CouleursPixel.bois);
      p.px(cx, cy, 12, 2, CouleursPixel.boisClair);
      p.px(cx + 5, cy + 2, 2, 8, CouleursPixel.boisFonce);
    }
  }

  /// La scène montre les huit paliers les plus avancés que vous possédez,
  /// plus le prochain à débloquer, en pointillés.
  void _vignettes(PinceauPixel p, bool tourne) {
    final montres = <int>[];
    for (var i = 0; i < stations.length; i++) {
      if (etat.exemplaires[i] > 0) montres.add(i);
    }
    final suivant = etat.exemplaires.indexWhere((n) => n == 0);
    if (suivant >= 0) montres.add(suivant);
    final visibles =
        montres.length > 8 ? montres.sublist(montres.length - 8) : montres;

    for (var c = 0; c < visibles.length; c++) {
      final index = visibles[c];
      final x = DimensionsScene.margeCase + (c % 4) * DimensionsScene.largeurCase;
      final base = DimensionsScene.rangees[c < 4 ? 0 : 1];

      if (etat.exemplaires[index] > 0) {
        VignettesProduction.peindre(
          p, index, x, base, temps, tourne,
          (px, py, estFumee) => estFumee ? particules.fumee(px, py) : particules.etincelle(px, py),
          hasard,
        );
        _badge(p, x + DimensionsScene.largeurCase - 26,
            base - DimensionsScene.hauteurCase + 2, etat.exemplaires[index]);
      } else {
        _pointille(p, x + 14, base - 20, 62, 18);
      }
    }
  }

  void _badge(PinceauPixel p, double x, double y, int n) {
    final texte = n >= 1000
        ? '×${(n / 1000).toStringAsFixed(1).replaceAll('.', ',')}k'
        : '×$n';
    final l = 4 + texte.length * 4.0;
    p.px(x, y, l, 7, CouleursPixel.noir);
    p.px(x + 1, y + 1, l - 2, 5, CouleursPixel.ambre);
  }

  void _pointille(PinceauPixel p, double x, double y, double l, double h) {
    for (var i = 0.0; i < l; i += 4) {
      p.px(x + i, y, 2, 1, CouleursPixel.noir, opacite: .25);
      p.px(x + i, y + h, 2, 1, CouleursPixel.noir, opacite: .25);
    }
    for (var j = 0.0; j < h; j += 4) {
      p.px(x, y + j, 1, 2, CouleursPixel.noir, opacite: .25);
      p.px(x + l, y + j, 1, 2, CouleursPixel.noir, opacite: .25);
    }
  }

  void _tapis(PinceauPixel p) {
    const y = DimensionsScene.tapis;
    const l = DimensionsScene.largeur;
    p.px(0, y, l, 10, CouleursPixel.metalFonce);
    p.px(0, y, l, 1, CouleursPixel.metalClair);
    p.px(0, y + 10, l, 2, CouleursPixel.noir, opacite: .2);
    p.px(0, y + 12, l, DimensionsScene.hauteur - y - 12, CouleursPixel.noir, opacite: .15);

    final d = (temps * 30) % 10;
    for (var x = -10.0; x < l; x += 10) {
      p.px(x + d, y + 4, 5, 2, CouleursPixel.metal);
    }
    // Quai d'expédition.
    p.px(352, y - 16, 30, 16, CouleursPixel.boisFonce);
    p.px(352, y - 16, 30, 2, CouleursPixel.boisClair);
    p.px(356, y - 12, 10, 8, CouleursPixel.bois);
    p.px(368, y - 12, 10, 8, CouleursPixel.bois);

    for (final c in colis) {
      SpritesGammes.peindre(p, c.gamme, c.x, y - 11);
    }
  }

  @override
  bool shouldRepaint(ScenePeintre ancien) => true;
}
