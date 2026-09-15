import 'dart:math';

import '../catalogue/ameliorations_holding.dart';
import '../catalogue/concurrents.dart';
import '../entities/etat_partie.dart';
import '../journal.dart';
import '../regles.dart';

/// Les deux remises à zéro : l'introduction en bourse, puis le conglomérat.
class PrestigeUseCase {
  const PrestigeUseCase();

  /// Solde la société contre des actions. Renvoie la partie suivante, ou null.
  EtatPartie? entrerEnBourse(EtatPartie e) {
    final gagnees = Regles.actionsIntroduction(e);
    if (gagnees <= 0) return null;

    final suivante = _repartir(e, actions: e.actions + gagnees, parts: e.parts);
    suivante.introductions++;
    suivante.journal.addAll(e.journal.length > 3 ? e.journal.sublist(e.journal.length - 3) : e.journal);
    journaliser(suivante,
        'Introduction en bourse : $gagnees actions émises. On recommence, en plus gros.');
    return suivante;
  }

  /// Convertit les actions en parts de holding, définitivement acquises.
  EtatPartie? fonderConglomerat(EtatPartie e) {
    final gagnees = Regles.partsConglomerat(e);
    if (gagnees <= 0) return null;

    final suivante = _repartir(e, actions: 0, parts: e.parts + gagnees);
    suivante.conglomerats++;
    journaliser(suivante,
        'Conglomérat fondé : $gagnees part${gagnees > 1 ? 's' : ''} de holding. '
        'Les actions sont soldées.');
    return suivante;
  }

  bool acheterAmelioration(EtatPartie e, int i) {
    final amelioration = ameliorationsHolding[i];
    if (e.holding.contains(amelioration.id) || e.parts < amelioration.cout) return false;
    e.parts -= amelioration.cout;
    e.holding.add(amelioration.id);
    journaliser(e, 'Le conglomérat active : ${amelioration.nom.toLowerCase()}.');
    return true;
  }

  /// Repart de zéro en gardant le patrimoine : actions, parts, jalons, palmarès.
  EtatPartie _repartir(EtatPartie e, {required double actions, required int parts}) {
    final suivante = EtatPartie.neuve(
      actions: actions.floor(),
      parts: parts,
      holding: Set<String>.from(e.holding),
      jalons: Set<String>.from(e.jalonsAtteints),
      chiffreAffairesCumule: e.chiffreAffairesCumule,
      introductions: e.introductions,
      conglomerats: e.conglomerats,
      retraites: e.retraites,
      secondesJouees: e.secondesJouees,
    );
    // Le marché a continué sans vous pendant la réorganisation.
    for (var i = 0; i < concurrents.length; i++) {
      suivante.puissanceRivaux[i] =
          concurrents[i].puissanceInitiale *
              exp(concurrents[i].croissanceDeFond * e.secondesJouees);
    }
    return suivante;
  }

}
