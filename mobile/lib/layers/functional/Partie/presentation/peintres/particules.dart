import 'dart:math';
import 'dart:ui';

import 'palette_pixel.dart';
import 'pinceau_pixel.dart';

/// Étincelles de soudure, fumée d'usine, confettis d'ère nouvelle.
class Particule {
  Particule({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.vie,
    required this.couleur,
    this.taille = 1,
    this.gravite = 0,
    this.estFumee = false,
  });

  double x;
  double y;
  double vx;
  double vy;
  final double vie;
  final Color couleur;
  final double taille;
  final double gravite;
  final bool estFumee;
  double age = 0;
}

/// Le nuage de particules de la scène, plafonné pour ne jamais coûter cher.
class Particules {
  Particules({Random? hasard}) : _hasard = hasard ?? Random();

  static const _plafond = 160;

  final Random _hasard;
  final List<Particule> _particules = [];

  int get nombre => _particules.length;

  void etincelle(double x, double y) {
    _ajouter(Particule(
      x: x, y: y,
      vx: (_hasard.nextDouble() - .5) * 26,
      vy: -8 - _hasard.nextDouble() * 18,
      vie: .35 + _hasard.nextDouble() * .25,
      couleur: _hasard.nextBool() ? CouleursPixel.ambre : CouleursPixel.jaune,
    ));
  }

  void fumee(double x, double y) {
    _ajouter(Particule(
      x: x, y: y,
      vx: (_hasard.nextDouble() - .5) * 6,
      vy: -10,
      vie: 1.1,
      couleur: const Color(0xFFB9B4AA),
      taille: 2,
      estFumee: true,
    ));
  }

  void confettis() {
    for (var i = 0; i < 90; i++) {
      _ajouter(Particule(
        x: _hasard.nextDouble() * 384,
        y: 40 + _hasard.nextDouble() * 40,
        vx: (_hasard.nextDouble() - .5) * 70,
        vy: -40 - _hasard.nextDouble() * 50,
        gravite: 60,
        vie: 2.2,
        taille: 2,
        couleur: const [
          CouleursPixel.ambre, CouleursPixel.rouge, CouleursPixel.vertClair,
          CouleursPixel.bleuClair, CouleursPixel.blanc,
        ][_hasard.nextInt(5)],
      ));
    }
  }

  void _ajouter(Particule p) {
    if (_particules.length < _plafond) _particules.add(p);
  }

  void avancer(double dt) {
    for (var i = _particules.length - 1; i >= 0; i--) {
      final p = _particules[i];
      p.age += dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      if (p.gravite != 0) p.vy += p.gravite * dt;
      if (p.age >= p.vie) _particules.removeAt(i);
    }
  }

  void peindre(PinceauPixel pinceau) {
    for (final p in _particules) {
      final reste = 1 - p.age / p.vie;
      if (p.estFumee && reste < .5) continue;
      pinceau.px(p.x, p.y, p.taille, p.taille, p.couleur);
    }
  }
}
