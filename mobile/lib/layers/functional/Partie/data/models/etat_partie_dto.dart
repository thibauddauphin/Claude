import '../../domain/catalogue/concurrents.dart';
import '../../domain/catalogue/stations.dart';
import '../../domain/entities/employe.dart';
import '../../domain/regles.dart';
import '../../domain/entities/entree_journal.dart';
import '../../domain/entities/etat_partie.dart';

/// Traduction JSON de la partie.
///
/// Tolérante à la relecture : toute valeur absente ou aberrante retombe sur
/// celle d'une partie neuve, pour qu'une sauvegarde d'une version antérieure
/// n'empêche jamais de jouer.
class EtatPartieDto {
  const EtatPartieDto._();

  static const version = 1;

  static Map<String, dynamic> versJson(EtatPartie e) => {
        'version': version,
        'tresorerie': e.tresorerie,
        'composants': e.composants,
        'pointsRecherche': e.pointsRecherche,
        'exemplaires': e.exemplaires,
        'technologies': e.technologies.toList(),
        'gamme': e.gamme,
        'marge': e.marge,
        'unitesVendues': e.unitesVendues,
        'chiffreAffaires': e.chiffreAffaires,
        'chiffreAffairesCumule': e.chiffreAffairesCumule,
        'puissance': e.puissance,
        'puissanceRivaux': e.puissanceRivaux,
        'actions': e.actions,
        'parts': e.parts,
        'holding': e.holding.toList(),
        'jalons': e.jalonsAtteints.toList(),
        'introductions': e.introductions,
        'conglomerats': e.conglomerats,
        'retraites': e.retraites,
        'secondesJouees': e.secondesJouees,
        'resultatExercice': e.resultatExercice,
        'chargesExercice': e.chargesExercice,
        'prochainExercice': e.prochainExercice,
        'dernierImpot': e.dernierImpot,
        'impotReporte': e.impotReporte,
        'dernierResultat': e.dernierResultat,
        'equipe': e.equipe.map(_employeVersJson).toList(),
        'candidat': e.candidat == null ? null : _employeVersJson(e.candidat!),
        'journal': e.journal
            .map((l) => {'annee': l.annee, 'texte': l.texte})
            .toList(),
        'historiqueRevenu': e.historiqueRevenu,
        'derniereSauvegarde': e.derniereSauvegarde.millisecondsSinceEpoch,
      };

  static EtatPartie depuisJson(Map<String, dynamic> j) {
    final etat = EtatPartie.neuve(
      actions: _entier(j['actions']),
      parts: _entier(j['parts']),
      holding: _ensemble(j['holding']),
      jalons: _ensemble(j['jalons']),
      chiffreAffairesCumule: _reel(j['chiffreAffairesCumule']),
      introductions: _entier(j['introductions']),
      conglomerats: _entier(j['conglomerats']),
      retraites: _entier(j['retraites']),
      secondesJouees: _reel(j['secondesJouees']),
    );

    etat.resultatExercice = _reel(j['resultatExercice']);
    etat.chargesExercice = _reel(j['chargesExercice']);
    /* Une sauvegarde d'avant les exercices comptables n'a pas d'échéance : on
       en ouvre un à partir de maintenant plutôt que d'en réclamer un arriéré
       de quinze ères d'un coup. */
    etat.prochainExercice = _reel(j['prochainExercice'],
        defaut: _reel(j['secondesJouees']) + Regles.secondesParAnnee);
    etat.dernierImpot = _reel(j['dernierImpot']);
    etat.impotReporte = _reel(j['impotReporte']);
    etat.dernierResultat = _reel(j['dernierResultat']);

    etat.tresorerie = _reel(j['tresorerie'], defaut: 30);
    etat.composants = _reel(j['composants'], defaut: 12);
    etat.pointsRecherche = _reel(j['pointsRecherche']);
    etat.gamme = _entier(j['gamme']).clamp(0, 14);
    etat.marge = _reel(j['marge'], defaut: 1).clamp(.7, 1.6);
    etat.unitesVendues = _reel(j['unitesVendues']);
    etat.chiffreAffaires = _reel(j['chiffreAffaires']);
    etat.puissance = _reel(j['puissance']);

    final exemplaires = j['exemplaires'];
    for (var i = 0; i < stations.length; i++) {
      etat.exemplaires[i] =
          exemplaires is List && i < exemplaires.length ? _entier(exemplaires[i]) : 0;
    }

    final rivaux = j['puissanceRivaux'];
    for (var i = 0; i < concurrents.length; i++) {
      etat.puissanceRivaux[i] = rivaux is List && i < rivaux.length
          ? _reel(rivaux[i], defaut: concurrents[i].puissanceInitiale)
          : concurrents[i].puissanceInitiale;
    }

    etat.technologies.addAll(_ensemble(j['technologies']));

    final equipe = j['equipe'];
    if (equipe is List) {
      for (final membre in equipe) {
        final personne = _employeDepuisJson(membre);
        if (personne != null) etat.equipe.add(personne);
      }
    }
    // On ne garde que les binômes dont les deux moitiés sont encore là.
    final graines = etat.equipe.map((m) => m.graine).toSet();
    for (final membre in etat.equipe) {
      if (membre.binome != null && !graines.contains(membre.binome)) {
        membre.binome = null;
      }
    }

    etat.candidat = _employeDepuisJson(j['candidat']);

    final journal = j['journal'];
    if (journal is List) {
      for (final ligne in journal.take(8)) {
        if (ligne is Map) {
          etat.journal.add(EntreeJournal(
            annee: '${ligne['annee'] ?? ''}',
            texte: '${ligne['texte'] ?? ''}',
          ));
        }
      }
    }

    final historique = j['historiqueRevenu'];
    if (historique is List && historique.length == 60) {
      for (var i = 0; i < 60; i++) {
        etat.historiqueRevenu[i] = _reel(historique[i]);
      }
    }

    final instant = j['derniereSauvegarde'];
    etat.derniereSauvegarde = instant is int
        ? DateTime.fromMillisecondsSinceEpoch(instant)
        : DateTime.now();

    return etat;
  }

  static Map<String, dynamic> _employeVersJson(Employe e) => {
        'prenom': e.prenom,
        'nom': e.nom,
        'caractere': e.caractereId,
        'poste': e.poste,
        'part': e.part,
        'partInitiale': e.partInitiale,
        'age': e.age,
        'ageRetraite': e.ageRetraite,
        'graine': e.graine,
        'moral': e.moral,
        'confort': e.confort,
        'anciennete': e.ancienneteSecondes,
        'binome': e.binome,
        'origine': e.origine,
        'indemnite': e.indemnite,
        'forme': e.estForme,
      };

  static Employe? _employeDepuisJson(dynamic brut) {
    if (brut is! Map) return null;
    final caractere = brut['caractere'];
    if (caractere is! String) return null;
    return Employe(
      prenom: '${brut['prenom'] ?? '?'}',
      nom: '${brut['nom'] ?? '?'}',
      caractereId: caractere,
      poste: '${brut['poste'] ?? ''}',
      part: _reel(brut['part'], defaut: .01),
      partInitiale: _reel(brut['partInitiale'], defaut: _reel(brut['part'], defaut: .01)),
      age: _reel(brut['age'], defaut: 34),
      ageRetraite: _entier(brut['ageRetraite'], defaut: 64),
      graine: _entier(brut['graine']),
      moral: _reel(brut['moral'], defaut: 70),
      confort: _reel(brut['confort']),
      ancienneteSecondes: _reel(brut['anciennete']),
      binome: brut['binome'] is int ? brut['binome'] as int : null,
      origine: brut['origine'] is String ? brut['origine'] as String : null,
      indemnite: brut['indemnite'] is num ? (brut['indemnite'] as num).toDouble() : null,
      estForme: brut['forme'] == true,
    );
  }

  static double _reel(dynamic v, {double defaut = 0}) {
    if (v is num && v.isFinite) return v.toDouble();
    return defaut;
  }

  static int _entier(dynamic v, {int defaut = 0}) {
    if (v is num && v.isFinite) return v.toInt();
    return defaut;
  }

  static Set<String> _ensemble(dynamic v) =>
      v is List ? v.whereType<String>().toSet() : <String>{};
}
