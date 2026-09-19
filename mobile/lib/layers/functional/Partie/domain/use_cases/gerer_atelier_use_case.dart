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

  /// Assemble à la main. Un clic ne reste jamais sans effet.
  ///
  /// Ce que le stock couvre part au prix fort, le reste est bricolé. Sans un
  /// sou et sans composants on peut donc toujours repartir à la main, et
  /// acheter des composants garde tout son intérêt : c'est trois fois plus
  /// rentable.
  double assembler(EtatPartie e) {
    final unites = Regles.forceClic(e);
    final besoin = Regles.besoinComposants(e);
    final montees = besoin > 0 ? min(unites, e.composants / besoin) : unites;
    var recette = montees > 0 ? AvancerPartieUseCase.encaisser(e, montees) : 0.0;
    if (unites - montees > 0) {
      recette += AvancerPartieUseCase.encaisser(
          e, unites - montees, Regles.partBricolage);
    }
    return recette;
  }

  /// Achète un lot de composants, ou autant que la trésorerie le permet.
  ///
  /// Le lot est indivisible dans l'affichage, mais un atelier à sec doit
  /// toujours pouvoir repartir : sans cela, dépenser jusqu'au dernier euro
  /// rendrait la partie irrécupérable.
  bool acheterComposants(EtatPartie e) {
    final prix = Regles.prixComposant(e);
    if (prix <= 0) return false;
    /* Le joueur choisit combien de lots partent d'un coup ; zéro veut dire
       « autant que la caisse permet ». */
    final lots = e.lotAchat > 0 ? e.lotAchat : 1000000;
    final souhaite = Regles.lotComposants(e) * lots;
    final abordable = (e.tresorerie / prix).floorToDouble();
    final quantite = min(souhaite, abordable);
    if (quantite < 1) return false;
    e.tresorerie -= quantite * prix;
    e.composants += quantite;
    return true;
  }

  /// Achète des exemplaires d'un moyen de production.
  ///
  /// La quantité suit le lot choisi par le joueur, ramenée à ce que la
  /// trésorerie permet : demander dix machines et n'en payer que six vaut
  /// mieux que ne rien acheter du tout.
  bool acheterStation(EtatPartie e, int i) {
    final voulu = e.lotAchat > 0 ? e.lotAchat : Regles.quantiteAbordable(e, i);
    final quantite = min(voulu, Regles.quantiteAbordable(e, i));
    if (quantite < 1) return false;
    final cout = Regles.coutStations(e, i, quantite);
    e.tresorerie -= cout;
    final avant = e.exemplaires[i];
    e.exemplaires[i] += quantite;
    if (avant == 0) {
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
