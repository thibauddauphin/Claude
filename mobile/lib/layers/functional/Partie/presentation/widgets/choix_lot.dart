import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../cubit/partie_cubit.dart';

/// Combien un achat prend d'un coup.
///
/// Acheter une machine à la fois devient vite une corvée : passé la première
/// heure, on en installe des centaines. Zéro veut dire « tout ce que la
/// trésorerie permet ».
class ChoixLot extends StatelessWidget {
  const ChoixLot({required this.lot, super.key});

  static const lots = <int, String>{1: '×1', 10: '×10', 100: '×100', 0: 'max'};

  final int lot;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<PartieCubit>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entree in lots.entries)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: InkWell(
              onTap: () => cubit.changerLotAchat(entree.key),
              borderRadius: BorderRadius.circular(2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: entree.key == lot ? p.accent : p.panneauCreux,
                  border: Border.all(color: p.trait),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  entree.value,
                  style: ThemeAtelier.chiffres(p,
                      couleur: entree.key == lot ? p.surAccent : p.encreDouce,
                      taille: 11.5,
                      graisse: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
