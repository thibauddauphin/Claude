import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/employe.dart';
import '../../domain/entities/etat_partie.dart';
import '../../domain/entities/jalon.dart';
import '../../domain/gateways/sauvegarde_partie_gateway.dart';
import '../../domain/regles.dart';
import '../../domain/use_cases/avancer_partie_use_case.dart';
import '../../domain/use_cases/gerer_atelier_use_case.dart';
import '../../domain/use_cases/gerer_equipe_use_case.dart';
import '../../domain/use_cases/prestige_use_case.dart';
import '../../domain/use_cases/rattraper_hors_ligne_use_case.dart';
import 'partie_state.dart';

/// Pilote la partie : fait avancer la simulation, encaisse les gestes du
/// joueur, sauve régulièrement.
///
/// Deux cadences délibérément séparées. La simulation et la scène tournent à
/// l'image ; les panneaux ne sont rafraîchis que dix fois par seconde, ce qui
/// suffit à l'œil et évite de reconstruire l'arbre soixante fois par seconde.
class PartieCubit extends Cubit<PartieState> {
  PartieCubit({
    required SauvegardePartieGateway sauvegarde,
    AvancerPartieUseCase? avancer,
    GererAtelierUseCase? atelier,
    GererEquipeUseCase? equipe,
    PrestigeUseCase? prestige,
    RattraperHorsLigneUseCase? rattrapage,
    // ignore: prefer_initializing_formals — un paramètre nommé ne peut pas être privé
  })  : _sauvegarde = sauvegarde,
        _avancer = avancer ?? AvancerPartieUseCase(),
        _atelier = atelier ?? const GererAtelierUseCase(),
        _equipe = equipe ?? GererEquipeUseCase(),
        _prestige = prestige ?? const PrestigeUseCase(),
        _rattrapage = rattrapage ?? const RattraperHorsLigneUseCase(),
        super(const PartieState.chargement());

  final SauvegardePartieGateway _sauvegarde;
  final AvancerPartieUseCase _avancer;
  final GererAtelierUseCase _atelier;
  final GererEquipeUseCase _equipe;
  final PrestigeUseCase _prestige;
  final RattraperHorsLigneUseCase _rattrapage;

  /// Repeint la scène sans reconstruire les panneaux.
  final battement = ValueNotifier<int>(0);

  EtatPartie? _partie;
  Timer? _horloge;
  Duration _dernierInstant = Duration.zero;
  double _depuisPanneaux = 0;
  double _depuisSeconde = 0;
  double _recetteDeLaSeconde = 0;
  int _revision = 0;

  EtatPartie? get partie => _partie;

  Future<void> demarrer() async {
    final reprise = await _sauvegarde.lire();
    final partie = reprise ?? EtatPartie.neuve();
    _partie = partie;

    final bilan = reprise == null ? null : _rattrapage(partie);
    _emettre(bilan: bilan);
    _lancerHorloge();
  }

  void _lancerHorloge() {
    _horloge?.cancel();
    final depart = DateTime.now();
    _dernierInstant = Duration.zero;
    _horloge = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final maintenant = DateTime.now().difference(depart);
      final dt = min(.5, (maintenant - _dernierInstant).inMicroseconds / 1e6);
      _dernierInstant = maintenant;
      if (dt > 0) _avancerDe(dt);
    });
  }

  void _avancerDe(double dt) {
    final partie = _partie;
    if (partie == null) return;

    final resultat = _avancer(partie, dt);
    _recetteDeLaSeconde += resultat.recette;
    battement.value++;

    _depuisPanneaux += dt;
    _depuisSeconde += dt;

    final aDuNouveau = resultat.departs.isNotEmpty ||
        resultat.retraites.isNotEmpty ||
        resultat.jalonsAtteints.isNotEmpty ||
        resultat.evenementCommence != null ||
        resultat.evenementTermine;

    if (_depuisPanneaux >= .1 || aDuNouveau) {
      _depuisPanneaux = 0;
      _emettre(
        evenement: resultat.evenementCommence?.evenement.nom,
        effacerEvenement: resultat.evenementTermine,
        departs: resultat.departs.isEmpty ? null : resultat.departs,
        retraite: resultat.retraites.isEmpty ? null : resultat.retraites.first,
        jalon: resultat.jalonsAtteints.isEmpty ? null : resultat.jalonsAtteints.first,
      );
    }

    if (_depuisSeconde >= 1) {
      _depuisSeconde -= 1;
      partie.historiqueRevenu
        ..removeAt(0)
        ..add(_recetteDeLaSeconde);
      _recetteDeLaSeconde = 0;
      unawaited(_sauvegarde.ecrire(partie));
    }
  }

  // ------------------------------- les gestes -------------------------------

  void assembler() {
    final partie = _partie;
    if (partie == null) return;
    if (_atelier.assembler(partie) > 0) _emettre();
  }

  void acheterComposants() {
    final partie = _partie;
    if (partie != null && _atelier.acheterComposants(partie)) _emettre();
  }

  void acheterStation(int i) {
    final partie = _partie;
    if (partie != null && _atelier.acheterStation(partie, i)) _emettre();
  }

  void acheterTechnologie(int i) {
    final partie = _partie;
    if (partie == null) return;
    final effet = _atelier.acheterTechnologie(partie, i);
    if (effet == EffetRecherche.aucun) return;
    _emettre(ere: effet == EffetRecherche.nouvelleEre ? Regles.ereCourante(partie) : null);
  }

  void changerMarge(double marge) {
    final partie = _partie;
    if (partie == null) return;
    partie.marge = marge.clamp(.7, 1.6);
    _emettre();
  }

  void embaucher() {
    final partie = _partie;
    if (partie != null && _equipe.embaucher(partie)) _emettre();
  }

  void refuserCandidat() {
    final partie = _partie;
    if (partie != null && _equipe.refuser(partie)) _emettre();
  }

  void augmenter(int i) {
    final partie = _partie;
    if (partie != null && _equipe.augmenter(partie, i)) _emettre();
  }

  void verserPrime(int i) {
    final partie = _partie;
    if (partie != null && _equipe.verserPrime(partie, i)) _emettre();
  }

  /// Premier appui : on met la personne en attente. Second : on apparie.
  void toucherBinome(int i) {
    final partie = _partie;
    if (partie == null || i >= partie.equipe.length) return;
    final membre = partie.equipe[i];
    final enAttente = state.appairageEnCours;

    if (enAttente == membre.graine) {
      _emettre(effacerAppairage: true);
      return;
    }
    if (enAttente != null) {
      final j = partie.equipe.indexWhere((m) => m.graine == enAttente);
      if (j >= 0) _equipe.apparier(partie, j, i);
      _emettre(effacerAppairage: true);
      return;
    }
    if (membre.binome != null) {
      _equipe.separer(partie, i);
      _emettre();
      return;
    }
    _emettre(appairage: membre.graine);
  }

  void entrerEnBourse() {
    final partie = _partie;
    if (partie == null) return;
    final suivante = _prestige.entrerEnBourse(partie);
    if (suivante == null) return;
    _partie = suivante;
    _emettre();
  }

  void fonderConglomerat() {
    final partie = _partie;
    if (partie == null) return;
    final suivante = _prestige.fonderConglomerat(partie);
    if (suivante == null) return;
    _partie = suivante;
    _emettre();
  }

  void acheterAmelioration(int i) {
    final partie = _partie;
    if (partie != null && _prestige.acheterAmelioration(partie, i)) _emettre();
  }

  void recommencer() {
    _partie = EtatPartie.neuve();
    _emettre();
  }

  void masquerBilanHorsLigne() => _emettre(effacerBilan: true);
  void annonceEreTerminee() => _emettre(effacerEre: true);

  // ----------------------------- cycle de vie -----------------------------

  /// Appelé quand l'application passe en arrière-plan.
  Future<void> mettreEnVeille() async {
    _horloge?.cancel();
    _horloge = null;
    final partie = _partie;
    if (partie != null) await _sauvegarde.ecrire(partie);
  }

  /// Appelé au retour au premier plan : on rattrape l'absence.
  void reprendre() {
    final partie = _partie;
    if (partie == null || _horloge != null) return;
    final bilan = _rattrapage(partie);
    _emettre(bilan: bilan);
    _lancerHorloge();
  }

  void _emettre({
    BilanHorsLigne? bilan,
    bool effacerBilan = false,
    String? evenement,
    bool effacerEvenement = false,
    List<Employe>? departs,
    ({Employe partant, Employe releve})? retraite,
    Jalon? jalon,
    int? ere,
    bool effacerEre = false,
    int? appairage,
    bool effacerAppairage = false,
  }) {
    final partie = _partie;
    if (partie == null) return;
    emit(state.copyWith(
      statut: StatutPartie.enCours,
      etat: partie,
      revision: ++_revision,
      bilanHorsLigne: bilan,
      effacerBilan: effacerBilan,
      evenementAffiche: evenement,
      effacerEvenement: effacerEvenement,
      dernierDepart: departs,
      derniereRetraite: retraite,
      dernierJalon: jalon,
      ereAnnoncee: ere,
      effacerEre: effacerEre,
      appairageEnCours: appairage,
      effacerAppairage: effacerAppairage,
    ));
  }

  @override
  Future<void> close() {
    _horloge?.cancel();
    battement.dispose();
    return super.close();
  }
}
