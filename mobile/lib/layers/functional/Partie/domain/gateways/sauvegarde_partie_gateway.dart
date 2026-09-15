import '../entities/etat_partie.dart';

/// Conserve la partie entre deux lancements.
abstract interface class SauvegardePartieGateway {
  Future<EtatPartie?> lire();
  Future<void> ecrire(EtatPartie etat);
  Future<void> effacer();
}
