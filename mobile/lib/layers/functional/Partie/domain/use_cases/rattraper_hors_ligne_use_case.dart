import 'dart:math';

import '../entities/etat_partie.dart';
import '../journal.dart';
import '../regles.dart';
import 'avancer_partie_use_case.dart';

/// Ce que l'atelier a produit pendant votre absence.
class BilanHorsLigne {
  const BilanHorsLigne({
    required this.duree,
    required this.absence,
    required this.unites,
    required this.recette,
    required this.estPlafonne,
  });

  /// Durée effectivement rattrapée, plafonnée à douze heures.
  final Duration duree;

  /// Durée réelle de l'absence.
  final Duration absence;

  final double unites;
  final double recette;
  final bool estPlafonne;
}

/// Rattrape la production accumulée hors ligne, au ralenti.
///
/// Les concurrents avancent aussi : le marché ne vous attend pas.
class RattraperHorsLigneUseCase {
  const RattraperHorsLigneUseCase();

  BilanHorsLigne? call(EtatPartie e, {DateTime? maintenant}) {
    final instant = maintenant ?? DateTime.now();
    final absence = instant.difference(e.derniereSauvegarde);
    e.derniereSauvegarde = instant;
    if (absence.inSeconds <= 90) return null;

    final plafonne = absence > Regles.plafondHorsLigne;
    final duree = plafonne ? Regles.plafondHorsLigne : absence;

    final avancer = AvancerPartieUseCase();
    final pas = duree.inMilliseconds / 1000 / 120;
    final unitesAvant = e.unitesVendues;
    final caAvant = e.chiffreAffaires;

    for (var i = 0; i < 120; i++) {
      e.secondesJouees += pas;
      _approvisionner(e, pas);
      final besoin = Regles.besoinComposants(e);
      final unites = min(
        Regles.cadence(e) * Regles.rendementHorsLigne * pas,
        e.composants / besoin,
      );
      if (unites > 0) AvancerPartieUseCase.encaisser(e, unites);
      avancer.avancerRivaux(e, pas);
    }
    AvancerPartieUseCase.verifierJalons(e);

    if (e.unitesVendues - unitesAvant < 1) return null;
    journaliser(e,
        "Retour à l'atelier : ${(duree.inMinutes)} minutes de production rattrapées.");

    return BilanHorsLigne(
      duree: duree,
      absence: absence,
      unites: e.unitesVendues - unitesAvant,
      recette: e.chiffreAffaires - caAvant,
      estPlafonne: plafonne,
    );
  }

  void _approvisionner(EtatPartie e, double dt) {
    if (!e.possede('appro')) return;
    final cadence = Regles.cadence(e);
    if (cadence <= 0) return;
    final cible = Regles.besoinComposants(e) * cadence * 20;
    if (e.composants >= cible) return;
    final prix = Regles.prixComposant(e);
    final budget = min(e.tresorerie * .35, (cible - e.composants) * prix);
    if (budget <= 0) return;
    e.composants += budget / prix;
    e.tresorerie -= budget;
  }
}
