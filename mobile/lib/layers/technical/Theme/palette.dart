import 'package:flutter/material.dart';

/// L'identité du jeu : boîtier plastique beige, afficheurs ambre encastrés,
/// touches biseautées. La même en clair et en sombre — le second thème est
/// le même atelier, lumières éteintes.
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.fond,
    required this.panneau,
    required this.panneauCreux,
    required this.enfonce,
    required this.ecran,
    required this.encreEcran,
    required this.encreEcranPale,
    required this.encre,
    required this.encreDouce,
    required this.encrePale,
    required this.trait,
    required this.traitFranc,
    required this.accent,
    required this.surAccent,
    required this.bon,
    required this.attention,
    required this.mauvais,
    required this.toucheHaut,
    required this.toucheCote,
    required this.vous,
    required this.rivaux,
  });

  final Color fond;
  final Color panneau;
  final Color panneauCreux;
  final Color enfonce;

  /// Le noir des afficheurs, et l'ambre qui s'y allume.
  final Color ecran;
  final Color encreEcran;
  final Color encreEcranPale;

  final Color encre;
  final Color encreDouce;
  final Color encrePale;
  final Color trait;
  final Color traitFranc;
  final Color accent;
  final Color surAccent;
  final Color bon;
  final Color attention;
  final Color mauvais;
  final Color toucheHaut;
  final Color toucheCote;

  /// Parts de marché : palette catégorielle validée (écarts pour les
  /// daltonismes et contraste sur les deux fonds).
  final Color vous;
  final List<Color> rivaux;

  static const clair = Palette(
    fond: Color(0xFFCEC7B6),
    panneau: Color(0xFFE9E4D7),
    panneauCreux: Color(0xFFDDD6C4),
    enfonce: Color(0xFFC3BBA7),
    ecran: Color(0xFF1B1D19),
    encreEcran: Color(0xFFFFB347),
    encreEcranPale: Color(0xFF8A6A34),
    encre: Color(0xFF241F18),
    encreDouce: Color(0xFF605847),
    encrePale: Color(0xFF8B8371),
    trait: Color(0xFFB3AA93),
    traitFranc: Color(0xFF968C74),
    accent: Color(0xFFA63F1A),
    surAccent: Color(0xFFFFF6EE),
    bon: Color(0xFF2F6B4C),
    attention: Color(0xFF8A6100),
    mauvais: Color(0xFF9C2B21),
    toucheHaut: Color(0xFFEFEBDF),
    toucheCote: Color(0xFFB9B09A),
    vous: Color(0xFFD55E00),
    rivaux: [Color(0xFF009E73), Color(0xFF0072B2), Color(0xFFCC79A7), Color(0xFF8F7400)],
  );

  static const sombre = Palette(
    fond: Color(0xFF14150F),
    panneau: Color(0xFF1F211B),
    panneauCreux: Color(0xFF272A22),
    enfonce: Color(0xFF171912),
    ecran: Color(0xFF0B0C09),
    encreEcran: Color(0xFFFFB347),
    encreEcranPale: Color(0xFF7A5E2C),
    encre: Color(0xFFECE6D6),
    encreDouce: Color(0xFFA79E88),
    encrePale: Color(0xFF7D745F),
    trait: Color(0xFF3A3D31),
    traitFranc: Color(0xFF4B4F40),
    accent: Color(0xFFFF7F45),
    surAccent: Color(0xFF1A1209),
    bon: Color(0xFF63C795),
    attention: Color(0xFFDFAD45),
    mauvais: Color(0xFFE8705F),
    toucheHaut: Color(0xFF2E3129),
    toucheCote: Color(0xFF16180F),
    vous: Color(0xFFE06A12),
    rivaux: [Color(0xFF17A882), Color(0xFF3A8FCA), Color(0xFFC26A9A), Color(0xFFA98C1E)],
  );

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(ThemeExtension<Palette>? autre, double t) =>
      autre is Palette && t >= .5 ? autre : this;
}

extension LecturePalette on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
}
