import 'dart:math';
import 'dart:ui';

/// Outillage commun à tous les peintres du jeu.
///
/// Tout est tracé au rectangle sur une grille logique, puis agrandi sans
/// lissage : c'est ce qui donne les bords francs du pixel-art. L'anticrénelage
/// est coupé une fois pour toutes, sans quoi chaque arête se retrouve floue.
class PinceauPixel {
  PinceauPixel(this.canvas);

  final Canvas canvas;
  final Paint _pinceau = Paint()..isAntiAlias = false;

  /// Un rectangle plein, aux coordonnées de la grille logique.
  void px(num x, num y, num l, num h, Color couleur, {double opacite = 1}) {
    _pinceau.color = opacite >= 1 ? couleur : couleur.withValues(alpha: couleur.a * opacite);
    canvas.drawRect(
      Rect.fromLTWH(x.roundToDouble(), y.roundToDouble(), l.roundToDouble(), h.roundToDouble()),
      _pinceau,
    );
  }

  /// Un trait épais tracé pixel par pixel, pour les bras articulés.
  void segment(num x1, num y1, num x2, num y2, Color couleur, num epaisseur) {
    final pas = max((x2 - x1).abs(), (y2 - y1).abs()).ceil();
    if (pas == 0) {
      px(x1, y1, epaisseur, epaisseur, couleur);
      return;
    }
    for (var i = 0; i <= pas; i++) {
      px(x1 + (x2 - x1) * i / pas, y1 + (y2 - y1) * i / pas, epaisseur, epaisseur, couleur);
    }
  }
}

/// Mélange deux couleurs, pour les cheveux qui grisonnent et les ombres.
Color melange(Color a, Color b, double t) => Color.lerp(a, b, t)!;

/// Générateur déterministe : même graine, même visage.
class Alea {
  Alea(int graine) : _etat = graine == 0 ? 7 : graine;

  int _etat;

  double suivant() {
    _etat = (_etat * 1103515245 + 12345) & 0x7fffffff;
    return _etat / 0x7fffffff;
  }

  int entier(int max) => (suivant() * max).floor();
}
