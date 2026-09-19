import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/entities/etat_partie.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/gateways/sauvegarde_partie_gateway.dart';
import 'package:silicium_et_cie/layers/functional/Partie/presentation/cubit/partie_cubit.dart';
import 'package:silicium_et_cie/layers/technical/Theme/theme_atelier.dart';

/// Une sauvegarde qui n'écrit nulle part : les tests d'affichage n'ont pas à
/// dépendre du stockage de la plateforme.
class SauvegardeMuette implements SauvegardePartieGateway {
  @override
  Future<EtatPartie?> lire() async => null;

  @override
  Future<void> ecrire(EtatPartie etat) async {}

  @override
  Future<void> effacer() async {}
}

/// Le décor minimal d'une vue du jeu : thème, cubit, surface défilante.
///
/// Les vues lisent la palette par le contexte et appellent le cubit sur les
/// gestes ; sortie de là, aucune ne se construit.
Widget hotePartie(Widget vue) => MaterialApp(
      theme: ThemeAtelier.clair(),
      home: BlocProvider(
        create: (_) => PartieCubit(sauvegarde: SauvegardeMuette()),
        child: Scaffold(body: vue),
      ),
    );
