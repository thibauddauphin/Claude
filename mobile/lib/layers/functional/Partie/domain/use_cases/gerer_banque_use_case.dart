import 'dart:math';

import '../../../../technical/Format/nombres.dart';
import '../entities/etat_partie.dart';
import '../journal.dart';
import '../regles.dart';

/// Emprunter et rembourser.
///
/// C'est le levier du créateur d'entreprise : on achète la machine avant
/// d'avoir les moyens, puis on vit avec l'échéance. Elle tombe dans les
/// charges, tous les mois, que l'atelier tourne ou non.
class GererBanqueUseCase {
  const GererBanqueUseCase();

  /// Emprunte [montant], ou ce que la banque consent encore.
  ///
  /// Renvoie ce qui a réellement été débloqué, zéro si la banque refuse.
  double emprunter(EtatPartie e, double montant) {
    if (montant <= 0) return 0;
    final accorde = min(montant, Regles.empruntDisponible(e));
    if (accorde <= 0) return 0;
    e.emprunt += accorde;
    e.tresorerie += accorde;
    journaliser(e,
        'Emprunt de ${Nombres.euros(accorde)} accordé, remboursable sur '
        'cinq ans.');
    return accorde;
  }

  /// Rembourse par anticipation, dans la limite de la caisse et du capital dû.
  ///
  /// Renvoie ce qui a été remboursé. Solder tôt supprime l'échéance, donc
  /// allège les charges : c'est l'arbitrage entre investir et se désendetter.
  double rembourser(EtatPartie e, double montant) {
    if (montant <= 0) return 0;
    final paye = min(montant, min(e.emprunt, max(0.0, e.tresorerie)));
    if (paye <= 0) return 0;
    e.emprunt -= paye;
    e.tresorerie -= paye;
    if (e.emprunt < 1) {
      e.emprunt = 0;
      journaliser(e, 'Emprunt soldé. Plus une échéance à payer.');
    }
    return paye;
  }
}
