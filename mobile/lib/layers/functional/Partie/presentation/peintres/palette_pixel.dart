import 'dart:ui';

import '../../domain/entities/ere.dart';

/// Les couleurs du pixel-art, indépendantes du thème de l'interface :
/// l'atelier a ses propres teintes, qu'il fasse jour ou nuit dans l'application.
class CouleursPixel {
  const CouleursPixel._();

  static const noir = Color(0xFF0E0C11);
  static const nuit = Color(0xFF171320);
  static const ombre = Color(0xFF2A2230);

  static const bois = Color(0xFF8A5F33);
  static const boisFonce = Color(0xFF63451F);
  static const boisClair = Color(0xFFB2814A);

  static const metal = Color(0xFF7F8695);
  static const metalFonce = Color(0xFF4C525E);
  static const metalClair = Color(0xFFB9C0CD);

  static const beige = Color(0xFFD9CFB2);
  static const beigeFonce = Color(0xFFAB9F80);
  static const beigeClair = Color(0xFFEFE7D0);

  static const peaux = [
    Color(0xFFE8B088), Color(0xFFD9A074), Color(0xFFC08A58),
    Color(0xFFA06E40), Color(0xFF7D4F2C), Color(0xFF5A3820),
  ];
  static const cheveux = [
    Color(0xFF2B1F18), Color(0xFF4A3524), Color(0xFF7A5A32), Color(0xFFA8813F),
    Color(0xFFC9A86A), Color(0xFF8F8F92), Color(0xFFB8403A), Color(0xFF1A1A22),
  ];
  static const tenues = [
    Color(0xFFB8402C), Color(0xFF3D6FA6), Color(0xFF4F9A5F), Color(0xFF7A5BB5),
    Color(0xFFC2761C), Color(0xFF57738A), Color(0xFF8D5A7A), Color(0xFF3F4A58),
  ];

  static const bleu = Color(0xFF3D6FA6);
  static const bleuClair = Color(0xFF74A6D8);
  static const rouge = Color(0xFFB8402C);
  static const rougeClair = Color(0xFFE06A4E);
  static const ambre = Color(0xFFFFB347);
  static const ambreFonce = Color(0xFFC2761C);
  static const vert = Color(0xFF4F9A5F);
  static const vertCircuit = Color(0xFF2C6B4A);
  static const vertClair = Color(0xFF8ED08A);
  static const blanc = Color(0xFFF3EDDE);
  static const gris = Color(0xFF6D6757);
  static const grisClair = Color(0xFF9C957F);
  static const violet = Color(0xFF7A5BB5);
  static const cyan = Color(0xFF57C8D6);
  static const jaune = Color(0xFFF2D16B);
}

/// Les teintes d'un décor d'ère : mur, sol et ciel aperçu par la fenêtre.
class TeinteDecor {
  const TeinteDecor({
    required this.mur,
    required this.murFonce,
    required this.sol,
    required this.solFonce,
    required this.ciel,
  });

  final Color mur;
  final Color murFonce;
  final Color sol;
  final Color solFonce;
  final Color ciel;
}

const teintesDecor = <Decor, TeinteDecor>{
  Decor.garage: TeinteDecor(
      mur: Color(0xFFB9AB8E), murFonce: Color(0xFF98886A),
      sol: Color(0xFF7D6E55), solFonce: Color(0xFF5F5340), ciel: Color(0xFF8FB8D8)),
  Decor.salon: TeinteDecor(
      mur: Color(0xFFC3A67F), murFonce: Color(0xFFA08560),
      sol: Color(0xFF8A6547), solFonce: Color(0xFF6B4D35), ciel: Color(0xFFA8C8E0)),
  Decor.minitel: TeinteDecor(
      mur: Color(0xFFB7BFAE), murFonce: Color(0xFF949C8B),
      sol: Color(0xFF6F7468), solFonce: Color(0xFF565B50), ciel: Color(0xFF9FC0D6)),
  Decor.bureau: TeinteDecor(
      mur: Color(0xFFCDC4AC), murFonce: Color(0xFFA79F89),
      sol: Color(0xFF4D5B72), solFonce: Color(0xFF3A4557), ciel: Color(0xFFB9D2E6)),
  Decor.openspace: TeinteDecor(
      mur: Color(0xFFD5D1C1), murFonce: Color(0xFFAEAB9D),
      sol: Color(0xFF8E8E8A), solFonce: Color(0xFF6E6E6B), ciel: Color(0xFFC6DCED)),
  Decor.multimedia: TeinteDecor(
      mur: Color(0xFF7F6F9A), murFonce: Color(0xFF63567A),
      sol: Color(0xFF6D5A48), solFonce: Color(0xFF53442F), ciel: Color(0xFF4A5F92)),
  Decor.loft: TeinteDecor(
      mur: Color(0xFF9D6150), murFonce: Color(0xFF7B4A3C),
      sol: Color(0xFF6F7073), solFonce: Color(0xFF54555A), ciel: Color(0xFFD0D8DE)),
  Decor.bulle: TeinteDecor(
      mur: Color(0xFFC8C3B4), murFonce: Color(0xFFA29D8F),
      sol: Color(0xFF8D8779), solFonce: Color(0xFF6C6759), ciel: Color(0xFFA9B4BD)),
  Decor.habitat: TeinteDecor(
      mur: Color(0xFFD3C3A6), murFonce: Color(0xFFAC9D82),
      sol: Color(0xFF8D6F4F), solFonce: Color(0xFF6C5339), ciel: Color(0xFF93B6D4)),
  Decor.showroom: TeinteDecor(
      mur: Color(0xFFE6E3DC), murFonce: Color(0xFFC4C1B9),
      sol: Color(0xFFC9C7C2), solFonce: Color(0xFFA5A39E), ciel: Color(0xFFDFEAF2)),
  Decor.datacenter: TeinteDecor(
      mur: Color(0xFF2C3B4C), murFonce: Color(0xFF1F2B38),
      sol: Color(0xFF243240), solFonce: Color(0xFF18222C), ciel: Color(0xFF1B4A63)),
  Decor.objets: TeinteDecor(
      mur: Color(0xFF5C6470), murFonce: Color(0xFF464D57),
      sol: Color(0xFF3E444D), solFonce: Color(0xFF2D323A), ciel: Color(0xFF7F93A8)),
  Decor.hall: TeinteDecor(
      mur: Color(0xFF1B1A24), murFonce: Color(0xFF131219),
      sol: Color(0xFF14131C), solFonce: Color(0xFF0D0C12), ciel: Color(0xFF2A2340)),
  Decor.quantique: TeinteDecor(
      mur: Color(0xFF16232E), murFonce: Color(0xFF101A23),
      sol: Color(0xFF0E1720), solFonce: Color(0xFF091018), ciel: Color(0xFF1D5A70)),
  Decor.neuro: TeinteDecor(
      mur: Color(0xFF1A1420), murFonce: Color(0xFF120E17),
      sol: Color(0xFF140F1A), solFonce: Color(0xFF0C0812), ciel: Color(0xFF37205A)),
};
