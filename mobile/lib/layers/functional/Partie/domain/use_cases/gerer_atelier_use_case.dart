import 'dart:math';

import '../catalogue/gammes.dart';
import '../catalogue/stations.dart';
import '../catalogue/technologies.dart';
import '../entities/etat_partie.dart';
import '../journal.dart';
import '../regles.dart';
import 'avancer_partie_use_case.dart';

/// Ce que change l'achat d'une technologie.
enum EffetRecherche { aucun, acquise, nouvelleEre }

/// Les gestes de l'atelier : assembler, approvisionner, investir, chercher.
class GererAtelierUseCase {
  const GererAtelierUseCase();

  /// Assemble à la main. Renvoie la recette, ou zéro faute de composants.
  double assembler(EtatPartie e) {
    final unites = Regles.forceClic(e);
    if (e.composants < unites * Regles.besoinComposants(e)) return 0;
    return AvancerPartieUseCase.encaisser(e, unites);
  }

  /// Achète un lot de composants, ou autant que la trésorerie le permet.
  ///
  /// Le lot est indivisible dans l'affichage, mais un atelier à sec doit
  /// toujours pouvoir repartir : sans cela, dépenser jusqu'au dernier euro
  /// rendrait la partie irrécupérable.
  bool acheterComposants(EtatPartie e) {
    final prix = Regles.prixComposant(e);
    if (prix <= 0) return false;
    final souhaite = Regles.lotComposants(e);
    final abordable = (e.tresorerie / prix).floorToDouble();
    final quantite = min(souhaite, abordable);
    if (quantite < 1) return false;
    e.tresorerie -= quantite * prix;
    e.composants += quantite;
    return true;
  }

  bool acheterStation(EtatPartie e, int i) {
    final cout = Regles.coutStation(e, i);
    if (e.tresorerie < cout) return false;
    e.tresorerie -= cout;
    e.exemplaires[i]++;
    if (e.exemplaires[i] == 1) {
      journaliser(e, 'Mise en service : ${stations[i].nom.toLowerCase()}.');
    }
    return true;
  }

  EffetRecherche acheterTechnologie(EtatPartie e, int i) {
    final techno = technologies[i];
    final cout = Regles.coutTechnologie(e, i);
    if (e.possede(techno.id) || e.pointsRecherche < cout) return EffetRecherche.aucun;

    e.pointsRecherche -= cout;
    e.technologies.add(techno.id);

    final ouvre = techno.ouvre;
    if (ouvre != null && ouvre > e.gamme) {
      e.gamme = ouvre;
      journaliser(e,
          'Nouvelle gamme : ${gammes[e.gamme].nom.toLowerCase()} (${gammes[e.gamme].annee}).');
      return EffetRecherche.nouvelleEre;
    }
    journaliser(e, 'Brevet déposé : ${techno.nom.toLowerCase()}.');
    return EffetRecherche.acquise;
  }
}
