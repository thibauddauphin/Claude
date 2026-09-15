import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../domain/entities/etat_partie.dart';
import '../../domain/regles.dart';
import '../peintres/dimensions_scene.dart';
import '../peintres/particules.dart';
import '../peintres/scene_peintre.dart';

/// L'atelier animé, et la grande surface où l'on tape pour assembler.
///
/// Anime elle-même colis et particules : le cubit ne s'occupe que des règles.
class SceneAtelier extends StatefulWidget {
  const SceneAtelier({
    required this.etat,
    required this.battement,
    required this.onAssembler,
    super.key,
  });

  final EtatPartie etat;
  final ValueNotifier<int> battement;
  final VoidCallback onAssembler;

  @override
  State<SceneAtelier> createState() => _SceneAtelierState();
}

class _SceneAtelierState extends State<SceneAtelier>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_battre);
  final _particules = Particules();
  final _colis = <Colis>[];
  final _hasard = Random();

  double _temps = 0;
  Duration _precedent = Duration.zero;
  double _depuisColis = 0;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  void _battre(Duration ecoule) {
    final dt = min(.05, (ecoule - _precedent).inMicroseconds / 1e6);
    _precedent = ecoule;
    if (dt <= 0) return;

    _temps += dt;
    _particules.avancer(dt);

    final cadence = Regles.cadence(widget.etat);
    final tourne = cadence > 0 &&
        widget.etat.composants >= Regles.besoinComposants(widget.etat);
    if (tourne) {
      _depuisColis += dt;
      if (_depuisColis > .32) {
        _depuisColis = 0;
        _expedier();
      }
    }

    for (var i = _colis.length - 1; i >= 0; i--) {
      _colis[i].x += (26 + cadence * .08).clamp(26, 90) * dt;
      if (_colis[i].x > 350) {
        for (var e = 0; e < 3; e++) {
          _particules.etincelle(354 + _hasard.nextDouble() * 20, DimensionsScene.tapis - 14);
        }
        _colis.removeAt(i);
      }
    }
  }

  void _expedier() {
    if (_colis.length > 14) return;
    _colis.add(Colis(x: 20, gamme: widget.etat.gamme));
  }

  void _taper() {
    widget.onAssembler();
    _expedier();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Vue de l'atelier. Toucher pour assembler une unité.",
      button: true,
      child: GestureDetector(
        onTap: _taper,
        child: AspectRatio(
          aspectRatio: DimensionsScene.largeur / DimensionsScene.hauteur,
          child: CustomPaint(
            painter: ScenePeintre(
              etat: widget.etat,
              temps: _temps,
              particules: _particules,
              colis: _colis,
              hasard: _hasard,
              battement: widget.battement,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
