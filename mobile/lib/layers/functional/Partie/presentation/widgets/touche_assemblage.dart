import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';

/// La grosse touche de clavier biseautée : elle s'enfonce sous le doigt.
class ToucheAssemblage extends StatefulWidget {
  const ToucheAssemblage({
    required this.gain,
    required this.composants,
    required this.active,
    required this.onAppui,
    super.key,
  });

  final String gain;
  final String composants;
  final bool active;
  final VoidCallback onAppui;

  @override
  State<ToucheAssemblage> createState() => _ToucheAssemblageState();
}

class _ToucheAssemblageState extends State<ToucheAssemblage> {
  bool _enfoncee = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final decalage = _enfoncee ? 4.0 : 0.0;

    return GestureDetector(
      onTapDown: widget.active ? (_) => setState(() => _enfoncee = true) : null,
      onTapCancel: () => setState(() => _enfoncee = false),
      onTap: widget.active
          ? () {
              setState(() => _enfoncee = false);
              HapticFeedback.selectionClick();
              widget.onAppui();
            }
          : null,
      child: Opacity(
        opacity: widget.active ? 1 : .55,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          transform: Matrix4.translationValues(0, decalage, 0),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [p.toucheHaut, p.panneauCreux],
            ),
            border: Border.all(color: p.traitFranc),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: p.toucheCote,
                offset: Offset(0, 5 - decalage),
              ),
            ],
          ),
          child: Column(
            children: [
              Text('ASSEMBLER',
                  style: ThemeAtelier.titre(p, taille: 20).copyWith(letterSpacing: 1.6)),
              const SizedBox(height: 3),
              Text('+${widget.gain} · ${widget.composants}',
                  style: ThemeAtelier.chiffres(p,
                      couleur: p.encreDouce, taille: 11, graisse: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}
