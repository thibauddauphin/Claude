import 'package:flutter/material.dart';

import 'palette.dart';

/// Typographie et thèmes de l'application.
///
/// Les chiffres sont en chasse fixe tabulaire : les colonnes de trésorerie
/// et de cadence doivent s'aligner d'une ligne à l'autre.
class ThemeAtelier {
  const ThemeAtelier._();

  static const familleTitre = 'IBMPlexSansCondensed';
  static const familleTexte = 'IBMPlexSans';
  static const familleChiffres = 'IBMPlexMono';

  static ThemeData clair() => _construire(Palette.clair, Brightness.light);
  static ThemeData sombre() => _construire(Palette.sombre, Brightness.dark);

  static ThemeData _construire(Palette p, Brightness luminosite) {
    final base = ThemeData(brightness: luminosite, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: p.fond,
      colorScheme: ColorScheme.fromSeed(
        seedColor: p.accent,
        brightness: luminosite,
      ).copyWith(
        surface: p.panneau,
        primary: p.accent,
        onPrimary: p.surAccent,
      ),
      extensions: [p],
      textTheme: base.textTheme.apply(
        bodyColor: p.encre,
        displayColor: p.encre,
      ),
      dividerColor: p.trait,
      splashFactory: InkSparkle.splashFactory,
    );
  }

  /// Étiquette en capitales espacées, comme sérigraphiée sur le capot.
  static TextStyle etiquette(Palette p, {Color? couleur, double taille = 10}) => TextStyle(
        fontFamily: familleChiffres,
        fontSize: taille,
        height: 1.2,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
        color: couleur ?? p.encrePale,
      );

  static TextStyle chiffres(Palette p, {Color? couleur, double taille = 14, FontWeight? graisse}) =>
      TextStyle(
        fontFamily: familleChiffres,
        fontSize: taille,
        height: 1.25,
        fontWeight: graisse ?? FontWeight.w600,
        color: couleur ?? p.encre,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle titre(Palette p, {double taille = 19}) => TextStyle(
        fontFamily: familleTitre,
        fontSize: taille,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: p.encre,
      );

  static TextStyle corps(Palette p, {Color? couleur, double taille = 13}) => TextStyle(
        fontFamily: familleTexte,
        fontSize: taille,
        height: 1.35,
        color: couleur ?? p.encre,
      );
}
