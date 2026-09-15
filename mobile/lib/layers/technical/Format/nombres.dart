import 'dart:math';

/// Mise en forme française des grandeurs du jeu.
///
/// Le jeu franchit allègrement le millier de milliards ; au-delà, les suffixes
/// deviennent illisibles et la notation scientifique reprend la main.
class Nombres {
  const Nombres._();

  static const _paliers = [('Md', 1e9), ('M', 1e6), ('k', 1e3)];
  static const _exposants = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];

  static String format(double v) {
    if (!v.isFinite) return '∞';
    final signe = v < 0 ? '−' : '';
    final x = v.abs();

    if (x < 1000) {
      return signe + (x >= 100 ? x.round().toString() : _decimal(x, 1));
    }
    if (x < 1e12) {
      for (final (suffixe, seuil) in _paliers) {
        if (x >= seuil) {
          final n = x / seuil;
          return '$signe${_decimal(n, n < 10 ? 2 : 1)} $suffixe';
        }
      }
    }
    final e = (log(x) / ln10).floor();
    // pow(10, e) entre entiers déborde l'int64 dès 10¹⁹ : on force le flottant.
    return '$signe${_decimal(x / pow(10.0, e), 2)} ×10${_exposant(e)}';
  }

  static String euros(double v) => '${format(v)} €';

  static String pourcent(double v) => '${_decimal(v, 1)} %';

  /// Accorde un nom au pluriel selon la quantité affichée.
  static String pluriel(double quantite, String singulier, [String? pluriel]) =>
      quantite < 2 ? singulier : (pluriel ?? '${singulier}s');

  /// Durées écrites comme on les dit : « 3 h 05 », « 42 minutes ».
  static String duree(Duration d) {
    if (d.inSeconds < 90) return '${d.inSeconds} secondes';
    if (d.inMinutes < 90) return '${d.inMinutes} minutes';
    final heures = d.inHours;
    final minutes = d.inMinutes % 60;
    return minutes == 0
        ? '$heures h'
        : '$heures h ${minutes.toString().padLeft(2, '0')}';
  }

  /// Virgule décimale française, zéros inutiles retirés.
  static String _decimal(double v, int decimales) {
    var s = v.toStringAsFixed(decimales);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s.replaceAll('.', ',');
  }

  static String _exposant(int e) =>
      e.toString().split('').map((c) => c == '-' ? '⁻' : _exposants[int.parse(c)]).join();
}
