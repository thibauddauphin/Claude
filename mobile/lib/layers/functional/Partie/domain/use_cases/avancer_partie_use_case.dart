import 'dart:math';

import '../../../../technical/Format/nombres.dart';
import '../catalogue/caracteres_index.dart';
import '../catalogue/concurrents.dart';
import '../catalogue/equipe.dart';
import '../catalogue/evenements.dart';
import '../catalogue/gammes.dart';
import '../catalogue/jalons.dart';
import '../catalogue/stations.dart';
import '../entities/employe.dart';
import '../entities/etat_partie.dart';
import '../entities/evenement.dart';
import '../entities/jalon.dart';
import '../journal.dart';
import '../regles.dart';

/// Ce qu'une image de simulation a produit, pour que la présentation réagisse.
class ResultatTour {
  const ResultatTour({
    this.unitesProduites = 0,
    this.recette = 0,
    this.estBloquee = false,
    this.evenementCommence,
    this.evenementTermine = false,
    this.jalonsAtteints = const [],
    this.departs = const [],
    this.retraites = const [],
  });

  final double unitesProduites;
  final double recette;

  /// Vrai quand la chaîne tourne à vide, faute de composants.
  final bool estBloquee;

  final EvenementActif? evenementCommence;
  final bool evenementTermine;
  final List<Jalon> jalonsAtteints;
  final List<Employe> departs;
  final List<({Employe partant, Employe releve})> retraites;
}

/// Fait avancer la partie d'un intervalle de temps.
class AvancerPartieUseCase {
  AvancerPartieUseCase({Random? hasard}) : _hasard = hasard ?? Random();

  final Random _hasard;

  ResultatTour call(EtatPartie e, double dt) {
    e.secondesJouees += dt;

    avancerRivaux(e, dt);
    if (e.aHolding('empire')) e.actions += dt / 60;

    final evenementTermine = _majEvenement(e, dt);
    final evenementCommence = declencherEvenement(e);

    _approvisionner(e, dt);

    final besoin = Regles.besoinComposants(e);
    final cadence = Regles.cadenceVendue(e);
    var produites = 0.0;
    var recette = 0.0;

    e.tampon += cadence * dt;
    if (e.tampon >= 1) {
      final voulu = e.tampon.floor();
      final montees = min(voulu, (e.composants / besoin).floor()).toDouble();
      e.tampon = max(0, e.tampon - voulu);
      if (montees > 0) recette = encaisser(e, montees);
      /* Tant qu'il reste quelqu'un à l'atelier, il ne s'arrête pas : ce que
         les composants ne couvrent pas part en bricolage. */
      final bricolees = e.equipe.isEmpty
          ? 0.0
          : min(voulu - montees, cadence * Regles.capaciteBricolage * dt);
      if (bricolees > 0) {
        recette += encaisser(e, bricolees, Regles.partBricolage);
      }
      produites = montees + bricolees;
    }

    final charges = Regles.chargesParSeconde(e) * dt;
    e.tresorerie -= charges;
    /* L'échéance est comptée dans les charges ci-dessus ; il reste à en
       déduire la part de capital, sinon la dette ne s'éteindrait jamais. */
    if (e.emprunt > 0) {
      e.emprunt = max(0, e.emprunt - e.emprunt / Regles.dureeEmprunt * dt);
      if (e.emprunt < 1) e.emprunt = 0;
    }
    e.chargesExercice += charges;
    e.resultatExercice += recette - charges;
    _cloturerExercice(e);
    _tenirLaBanque(e, dt);

    final estBloquee = cadence > 0 && e.composants < besoin;
    final vie = _majEquipe(e, dt, estBloquee);
    final jalons = verifierJalons(e);

    return ResultatTour(
      unitesProduites: produites,
      recette: recette,
      estBloquee: estBloquee,
      evenementCommence: evenementCommence,
      evenementTermine: evenementTermine,
      jalonsAtteints: jalons,
      departs: vie.departs,
      retraites: vie.retraites,
    );
  }

  /// Encaisse la vente et crédite recherche et conquête.
  ///
  /// [part] vaut 1 pour une unité assemblée normalement, [Regles.partBricolage]
  /// pour une unité montée sans composants : moins rentable, mais l'atelier
  /// n'est jamais à l'arrêt faute de stock.
  static double encaisser(EtatPartie e, double unites, [double part = 1]) {
    final brut = unites * Regles.prixUnite(e) * part;
    /* La recette entre entière. Les salaires et l'entretien sortent de la
       caisse à part, à chaque seconde, qu'on ait vendu ou non : c'est toute
       la différence entre une commission et une charge. */
    final net = brut;
    e.tresorerie += net;
    e.chiffreAffaires += brut;
    e.chiffreAffairesCumule += brut;
    if (part == 1) {
      e.composants = max(0, e.composants - unites * Regles.besoinComposants(e));
    }
    e.unitesVendues += unites;
    e.puissance += unites * pow(1 + e.gamme, 1.5) * Regles.conquete(e);
    e.pointsRecherche += unites * gammes[e.gamme].pointsRecherche * Regles.multRecherche(e);
    return net;
  }

  /// Le découvert coûte, et finit par se payer en machines et en gens.
  ///
  /// Une faillite qui efface tout après vingt heures de partie serait
  /// gratuite : ici la banque coupe le robinet, on solde ce qu'il faut pour
  /// rentrer dans les clous, et on repart amputé. La trace reste au journal.
  void _tenirLaBanque(EtatPartie e, double dt) {
    if (e.tresorerie >= 0) return;
    e.tresorerie += e.tresorerie * Regles.tauxAgios * dt;
    if (e.tresorerie > -Regles.decouvertTolere(e)) return;

    /* Une coupe à la fois, pas un plan social en un instant : le joueur doit
       voir venir et pouvoir redresser. On se sépare d'abord du salaire le plus
       lourd, puis de la machine la plus chère à entretenir. */
    if (e.equipe.isNotEmpty) {
      var pire = 0;
      for (var i = 1; i < e.equipe.length; i++) {
        if (e.equipe[i].part > e.equipe[pire].part) pire = i;
      }
      final parti = e.equipe.removeAt(pire);
      _delier(e, parti);
      journaliser(e,
          'Trésorerie au plus bas : ${parti.nomComplet} est '
          "licencié${parti.accordeAuFeminin ? 'e' : ''}.");
      /* Voir partir un collègue pour raison économique marque ceux qui
         restent. */
      for (final membre in e.equipe) {
        membre.moral = max(0, membre.moral - 18);
      }
    }
    if (e.equipe.isEmpty) {
      var pire = -1;
      for (var i = stations.length - 1; i >= 0; i--) {
        if (e.exemplaires[i] > 0) {
          pire = i;
          break;
        }
      }
      if (pire >= 0) {
        e.exemplaires[pire]--;
        e.tresorerie += stations[pire].coutBase * .4;
        journaliser(e, 'Vente forcée : ${stations[pire].nom.toLowerCase()}.');
      }
    }
    /* Le dépôt de bilan est le dernier recours, pas le premier : tant qu'il
       reste quelqu'un ou une machine, on solde et on continue. */
    if (e.equipe.isNotEmpty || e.exemplaires.any((n) => n > 0)) return;

    /* Plus rien à vendre et toujours dans le rouge : c'est le dépôt de bilan.
       La dette est effacée avec ce qui restait de la société, et on rouvre un
       atelier. Ce qu'on a bâti au-dessus — actions, parts, jalons — survit :
       une partie de vingt heures ne doit pas s'effacer d'un coup. */
    if (e.tresorerie < -Regles.decouvertTolere(e)) {
      e.tresorerie = 30;
      e.composants = 12;
      e.resultatExercice = 0;
      e.chargesExercice = 0;
      journaliser(e,
          'Dépôt de bilan. La société est liquidée ; vous rouvrez un atelier.');
    }
  }

  /// Arrête les comptes de l'année et prélève l'impôt sur les bénéfices.
  ///
  /// Garder du cash dormant coûte ; réinvestir avant la clôture ne coûte rien.
  /// C'est l'arbitrage que fait tout dirigeant en fin d'exercice.
  void _cloturerExercice(EtatPartie e) {
    if (e.secondesJouees < e.prochainExercice) return;
    e.prochainExercice += Regles.secondesParAnnee;
    final resultat = e.resultatExercice;
    final du = (resultat > 0 ? resultat * Regles.tauxImpot : 0.0) + e.impotReporte;
    /* On ne paie pas ce qu'on n'a pas. Le fisc prend ce que la caisse permet
       et reporte le reste sur l'exercice suivant : un rappel étalé plutôt
       qu'un découvert qu'on n'a pas vu venir. */
    final impot = min(du, max(0.0, e.tresorerie));
    e.impotReporte = du - impot;
    e.tresorerie -= impot;
    e.dernierImpot = impot;
    if (e.impotReporte > 0) {
      journaliser(e,
          'Impôt reporté : ${Nombres.euros(e.impotReporte)} restent dus.');
    }
    e.dernierResultat = resultat;
    e.resultatExercice = 0;
    e.chargesExercice = 0;
  }

  /// Les rivaux visent une fraction de VOTRE puissance, avec un plancher qui
  /// progresse lentement. Ils reviennent vite et reculent lentement.
  void avancerRivaux(EtatPartie e, double dt) {
    final ralenti = e.aHolding('monopole') ? .6 : 1.0;
    for (var i = 0; i < e.puissanceRivaux.length; i++) {
      final rival = concurrents[i];
      final plancher =
          rival.puissanceInitiale * exp(rival.croissanceDeFond * e.secondesJouees * ralenti);
      final cible = max(plancher, e.puissance * rival.poids);
      final vitesse =
          cible > e.puissanceRivaux[i] ? rival.rattrapage * ralenti : rival.rattrapage / 4;
      e.puissanceRivaux[i] += (cible - e.puissanceRivaux[i]) * min(1, vitesse * dt);
    }
  }

  bool _majEvenement(EtatPartie e, double dt) {
    final actif = e.evenement;
    if (actif != null) {
      actif.resteSecondes -= dt;
      if (actif.resteSecondes <= 0) {
        e.evenement = null;
        return true;
      }
      return false;
    }
    e.prochainEvenement -= dt;
    return false;
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

  ({List<Employe> departs, List<({Employe partant, Employe releve})> retraites})
      _majEquipe(EtatPartie e, double dt, bool estBloquee) {
    var protection = 1.0;
    for (final membre in e.equipe) {
      final valeur = caractereParId[membre.caractereId]?.protectionMoral;
      if (valeur != null) protection = min(protection, valeur);
    }
    final cible = Regles.cibleMoral(e, estBloquee: estBloquee, protection: protection);

    final departs = <Employe>[];
    final retraites = <({Employe partant, Employe releve})>[];

    for (var k = e.equipe.length - 1; k >= 0; k--) {
      final membre = e.equipe[k];
      final caractere = caractereParId[membre.caractereId]!;
      membre.ancienneteSecondes += dt;
      membre.age += dt * Regles.anneesParSeconde;
      membre.confort *= exp(-dt / 1800);

      if (membre.age >= membre.ageRetraite) {
        final releve = _formerReleve(e, membre);
        journaliser(e,
            '${membre.nomComplet} ${_tirer(motifsRetraite)} '
            '(${max(1, membre.anneesDeMaison)} an${membre.anneesDeMaison > 1 ? 's' : ''} de maison)');
        e.retraites++;
        _delier(e, membre);
        e.equipe[k] = releve;
        retraites.add((partant: membre, releve: releve));
        continue;
      }

      final duo = Regles.partenaire(e, membre);
      var vise = cible + membre.confort + (duo != null ? 10 : 0);
      if (caractere.estStoique) vise = max(vise, 35);
      final synergie = duo != null ? Regles.synergieDe(membre, duo) : null;
      final plancher = synergie?.plancherMoral;
      if (plancher != null) vise = max(vise, plancher);

      membre.moral += (vise - membre.moral) * min(1, .0016 * dt);
      if (membre.moral > 100) membre.moral = 100;

      // Un moral en berne, et la concurrence appelle.
      var estDebauche = false;
      if (membre.moral < 45 && !caractere.estStoique) {
        final risque = (45 - max(0, membre.moral)) / 45 * .00022 * dt;
        if (_hasard.nextDouble() < risque) estDebauche = true;
      }

      if (estDebauche || membre.moral <= 0) {
        final motif = estDebauche
            ? 'se laisse débaucher par ${_tirer(concurrents.map((c) => c.nom).toList())}.'
            : e.marge < 1
                ? motifsDepart[0]
                : estBloquee
                    ? motifsDepart[2 + _hasard.nextInt(2)]
                    : _tirer(motifsDepart);
        journaliser(e, '${membre.nomComplet} $motif');
        final orphelin = Regles.partenaire(e, membre);
        if (orphelin != null) {
          orphelin.moral = max(1, orphelin.moral - 25);
          orphelin.binome = null;
        }
        _delier(e, membre);
        e.equipe.removeAt(k);
        departs.add(membre);
      }
    }

    if (e.candidat == null && e.equipe.length < Regles.placesEquipe(e)) {
      e.prochainCandidat -= dt;
      if (e.prochainCandidat <= 0) e.candidat = creerCandidat(e, _hasard);
    }

    return (departs: departs, retraites: retraites);
  }

  Employe _formerReleve(EtatPartie e, Employe partant) => Employe(
        prenom: _tirer(prenomsDeLEpoque(e)),
        nom: _tirer(nomsDeFamille),
        caractereId: partant.caractereId,
        poste: partant.poste,
        part: partant.partInitiale * .85,
        partInitiale: partant.partInitiale * .85,
        age: (23 + _hasard.nextInt(8)).toDouble(),
        ageRetraite: 62 + _hasard.nextInt(5),
        graine: _hasard.nextInt(100000),
        moral: 88,
        estForme: true,
      );

  void _delier(EtatPartie e, Employe membre) {
    final autre = Regles.partenaire(e, membre);
    if (autre != null) autre.binome = null;
    membre.binome = null;
  }

  T _tirer<T>(List<T> liste) => liste[_hasard.nextInt(liste.length)];

  /// Déclenche une secousse de marché quand l'horloge est échue.
  EvenementActif? declencherEvenement(EtatPartie e) {
    if (e.evenement != null || e.prochainEvenement > 0) return null;
    final modele = _tirer(evenements);
    var facteur = modele.facteur;
    if (e.possede('sav')) {
      // Le service après-vente amortit les crises.
      if (facteur < 1) {
        facteur = 1 - (1 - facteur) / 2;
      } else if (modele.cible == CibleEvenement.composants) {
        facteur = 1 + (facteur - 1) / 2;
      }
    }
    final actif = EvenementActif(
      evenement: Evenement(
        nom: modele.nom,
        effet: modele.effet,
        cible: modele.cible,
        facteur: facteur,
        estFavorable: modele.estFavorable,
      ),
      resteSecondes: 20 + _hasard.nextDouble() * 16,
    );
    e.evenement = actif;
    e.prochainEvenement = 45 + _hasard.nextDouble() * 45;
    journaliser(e, '${modele.nom} — ${modele.effet.toLowerCase()}.');
    return actif;
  }

  static List<Jalon> verifierJalons(EtatPartie e) {
    final atteints = <Jalon>[];
    for (final jalon in jalons) {
      if (e.jalonsAtteints.contains(jalon.id)) continue;
      if (Regles.mesureJalon(e, jalon.mesure) >= jalon.seuil) {
        e.jalonsAtteints.add(jalon.id);
        journaliser(e, 'Jalon atteint : ${jalon.nom.toLowerCase()}.');
        atteints.add(jalon);
      }
    }
    return atteints;
  }
}

/// Prénoms de la génération qui postule à cette époque.
List<String> prenomsDeLEpoque(EtatPartie e) {
  final ere = Regles.ereCourante(e);
  return prenomsParGeneration[ere <= 3 ? 0 : ere <= 7 ? 1 : ere <= 11 ? 2 : 3];
}

/// Fabrique une candidature ; passé 40 % de part de marché, elle vient
/// parfois de chez un concurrent, contre indemnité de transfert.
Employe creerCandidat(EtatPartie e, Random hasard) {
  final caractere = caracteres[hasard.nextInt(caracteres.length)];
  var poste = 0;
  for (var i = 0; i < stations.length; i++) {
    if (e.exemplaires[i] > 0) poste = i;
  }
  final prenoms = prenomsDeLEpoque(e);
  var part = caractere.part * (.85 + hasard.nextDouble() * .4);
  String? origine;
  double? indemnite;
  var age = 22 + hasard.nextInt(26);

  if (Regles.partMarche(e) > 40 && hasard.nextDouble() < .35) {
    final rival = concurrents[hasard.nextInt(concurrents.length)];
    origine = rival.nom;
    part *= 1.45;
    age = 28 + hasard.nextInt(22);
    indemnite = Regles.cadence(e) * Regles.prixUnite(e) * 600;
  }

  return Employe(
    prenom: prenoms[hasard.nextInt(prenoms.length)],
    nom: nomsDeFamille[hasard.nextInt(nomsDeFamille.length)],
    caractereId: caractere.id,
    poste: stations[poste].nom,
    part: part,
    partInitiale: part,
    age: age.toDouble(),
    ageRetraite: 62 + hasard.nextInt(5),
    graine: hasard.nextInt(100000),
    origine: origine,
    indemnite: indemnite,
  );
}
