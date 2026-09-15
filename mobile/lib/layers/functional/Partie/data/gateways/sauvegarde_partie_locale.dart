import 'dart:convert';

import '../../domain/entities/etat_partie.dart';
import '../../domain/gateways/sauvegarde_partie_gateway.dart';
import '../models/etat_partie_dto.dart';

/// Stockage de la partie dans les préférences de l'application.
///
/// Toute panne de lecture est avalée : mieux vaut repartir d'une partie neuve
/// que refuser de démarrer.
class SauvegardePartieLocale implements SauvegardePartieGateway {
  const SauvegardePartieLocale(this._preferences);

  static const cle = 'silicium_et_cie_partie';

  final PreferencesAsync _preferences;

  @override
  Future<EtatPartie?> lire() async {
    try {
      final brut = await _preferences.getString(cle);
      if (brut == null || brut.isEmpty) return null;
      final json = jsonDecode(brut);
      if (json is! Map<String, dynamic>) return null;
      return EtatPartieDto.depuisJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> ecrire(EtatPartie etat) async {
    etat.derniereSauvegarde = DateTime.now();
    try {
      await _preferences.setString(cle, jsonEncode(EtatPartieDto.versJson(etat)));
    } catch (_) {
      // Une sauvegarde manquée ne doit pas interrompre la partie.
    }
  }

  @override
  Future<void> effacer() async {
    try {
      await _preferences.remove(cle);
    } catch (_) {}
  }
}

/// Surface minimale dont la passerelle a besoin, pour rester testable
/// sans dépendre du greffon dans les tests unitaires.
abstract interface class PreferencesAsync {
  Future<String?> getString(String cle);
  Future<void> setString(String cle, String valeur);
  Future<void> remove(String cle);
}
