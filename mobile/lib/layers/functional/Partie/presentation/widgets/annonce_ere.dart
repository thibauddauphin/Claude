import 'package:flutter/material.dart';

import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../../domain/catalogue/eres.dart';

/// Le passage d'époque, annoncé plein cadre sur la scène.
///
/// Se joue une fois puis se retire d'elle-même : c'est une ponctuation, pas un
/// écran de plus à refermer.
class AnnonceEre extends StatefulWidget {
  const AnnonceEre({required this.ere, required this.onTerminee, super.key});

  final int ere;
  final VoidCallback onTerminee;

  @override
  State<AnnonceEre> createState() => _AnnonceEreState();
}

class _AnnonceEreState extends State<AnnonceEre> with SingleTickerProviderStateMixin {
  late final AnimationController _controleur = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward().whenComplete(widget.onTerminee);

  late final Animation<double> _opacite = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 58),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
  ]).animate(_controleur);

  late final Animation<double> _echelle = Tween(begin: 1.08, end: 1.0).animate(
    CurvedAnimation(parent: _controleur, curve: const Interval(0, .12, curve: Curves.easeOut)),
  );

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ere = eres[widget.ere];
    final reduire = MediaQuery.of(context).disableAnimations;

    return IgnorePointer(
      child: FadeTransition(
        opacity: _opacite,
        child: ScaleTransition(
          scale: reduire ? const AlwaysStoppedAnimation(1) : _echelle,
          child: ColoredBox(
            color: p.encreEcran.withValues(alpha: .92),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ere.annee,
                      style: ThemeAtelier.chiffres(p,
                          couleur: const Color(0xFF241F18), taille: 34)
                          .copyWith(letterSpacing: 3)),
                  Text(ere.nom,
                      textAlign: TextAlign.center,
                      style: ThemeAtelier.titre(p, taille: 20)
                          .copyWith(color: const Color(0xFF241F18))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
