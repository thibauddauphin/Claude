import 'package:shared_preferences/shared_preferences.dart';

import '../../functional/Partie/data/gateways/sauvegarde_partie_locale.dart';

/// Adaptateur du greffon `shared_preferences` vers la surface attendue
/// par la couche de données.
class PreferencesPartagees implements PreferencesAsync {
  PreferencesPartagees([SharedPreferencesAsync? preferences])
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> getString(String cle) => _preferences.getString(cle);

  @override
  Future<void> setString(String cle, String valeur) =>
      _preferences.setString(cle, valeur);

  @override
  Future<void> remove(String cle) => _preferences.remove(cle);
}
