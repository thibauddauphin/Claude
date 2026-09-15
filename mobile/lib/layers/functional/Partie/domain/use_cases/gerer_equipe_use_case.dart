import 'dart:math';

import '../catalogue/caracteres_index.dart';
import '../catalogue/concurrents.dart';
import '../entities/employe.dart';
import '../entities/etat_partie.dart';
import '../journal.dart';
import '../regles.dart';

/// L'encadrement de l'équipe : recruter, retenir, apparier.
class GererEquipeUseCase {
  GererEquipeUseCase({Random? hasard}) : _hasard = hasard ?? Random();

  final Random _hasard;

  /// Embauche le candidat en attente. Échoue si l'indemnité de transfert
  /// dépasse la trésorerie, ou si l'atelier est au complet.
  bool embaucher(EtatPartie e) {
    final candidat = e.candidat;
    if (candidat == null || e.equipe.length >= Regles.placesEquipe(e)) return false;

    final indemnite = candidat.indemnite;
    if (indemnite != null) {
      if (e.tresorerie < indemnite) return false;
      e.tresorerie -= indemnite;
      // Le rival perd une tête.
      final i = _indexRival(candidat.origine);
      if (i != null) e.puissanceRivaux[i] *= .94;
    }

    e.equipe.add(candidat);
    e.candidat = null;
    e.prochainCandidat = 90 + _hasard.nextDouble() * 90;

    final accord = candidat.accordeAuFeminin ? 'e' : '';
    journaliser(
      e,
      candidat.origine != null
          ? '${candidat.nomComplet} est débauché$accord chez ${candidat.origine}.'
          : '${candidat.nomComplet} rejoint l\'atelier — '
              '${caractereParId[candidat.caractereId]!.nom.toLowerCase()}.',
    );
    return true;
  }

  bool refuser(EtatPartie e) {
    if (e.candidat == null) return false;
    e.candidat = null;
    e.prochainCandidat = 60 + _hasard.nextDouble() * 90;
    return true;
  }

  /// Augmente durablement. Plafonné à quatre fois la rémunération d'embauche.
  bool augmenter(EtatPartie e, int i) {
    if (i < 0 || i >= e.equipe.length) return false;
    final membre = e.equipe[i];
    if (membre.part >= membre.partInitiale * 4) return false;
    membre.part = min(membre.partInitiale * 4, membre.part * 1.22);
    membre.confort += 26;
    membre.moral = min(100, membre.moral + 22);
    journaliser(e,
        '${membre.nomComplet} est augmenté${membre.accordeAuFeminin ? 'e' : ''}.');
    return true;
  }

  /// Verse une prime : un coup de pouce ponctuel, payé comptant.
  bool verserPrime(EtatPartie e, int i) {
    if (i < 0 || i >= e.equipe.length) return false;
    final membre = e.equipe[i];
    final cout = Regles.coutPrime(e, membre);
    if (e.tresorerie < cout) return false;
    e.tresorerie -= cout;
    membre.confort += 14;
    membre.moral = min(100, membre.moral + 16);
    return true;
  }

  bool apparier(EtatPartie e, int i, int j) {
    if (i == j || i < 0 || j < 0 || i >= e.equipe.length || j >= e.equipe.length) {
      return false;
    }
    final a = e.equipe[i];
    final b = e.equipe[j];
    _delier(e, a);
    _delier(e, b);
    a.binome = b.graine;
    b.binome = a.graine;
    final synergie = Regles.synergieDe(a, b);
    journaliser(
      e,
      '${a.prenom} et ${b.prenom} travaillent désormais en binôme'
      '${synergie != null ? ' — ${synergie.nom.toLowerCase()}.' : '.'}',
    );
    return true;
  }

  bool separer(EtatPartie e, int i) {
    if (i < 0 || i >= e.equipe.length) return false;
    final membre = e.equipe[i];
    if (membre.binome == null) return false;
    _delier(e, membre);
    return true;
  }

  void _delier(EtatPartie e, Employe membre) {
    final autre = Regles.partenaire(e, membre);
    if (autre != null) autre.binome = null;
    membre.binome = null;
  }

  int? _indexRival(String? nom) {
    if (nom == null) return null;
    for (var i = 0; i < concurrents.length; i++) {
      if (concurrents[i].nom == nom) return i;
    }
    return null;
  }
}
