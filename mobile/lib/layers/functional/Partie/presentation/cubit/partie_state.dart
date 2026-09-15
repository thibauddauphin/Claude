import 'package:equatable/equatable.dart';

import '../../domain/entities/employe.dart';
import '../../domain/entities/etat_partie.dart';
import '../../domain/entities/jalon.dart';
import '../../domain/use_cases/rattraper_hors_ligne_use_case.dart';

enum StatutPartie { chargement, enCours }

/// Ce que les panneaux affichent.
///
/// Immuable et émis à cadence réduite : l'agrégat, lui, avance soixante fois
/// par seconde et n'est lu que par la scène, qui se repeint seule.
class PartieState extends Equatable {
  const PartieState({
    required this.statut,
    required this.etat,
    required this.revision,
    this.bilanHorsLigne,
    this.evenementAffiche,
    this.dernierDepart,
    this.derniereRetraite,
    this.dernierJalon,
    this.ereAnnoncee,
    this.appairageEnCours,
  });

  const PartieState.chargement()
      : statut = StatutPartie.chargement,
        etat = null,
        revision = 0,
        bilanHorsLigne = null,
        evenementAffiche = null,
        dernierDepart = null,
        derniereRetraite = null,
        dernierJalon = null,
        ereAnnoncee = null,
        appairageEnCours = null;

  final StatutPartie statut;

  /// L'agrégat vivant. Volontairement partagé plutôt que recopié.
  final EtatPartie? etat;

  /// Incrémentée à chaque émission : c'est elle qui déclenche les reconstructions.
  final int revision;

  final BilanHorsLigne? bilanHorsLigne;
  final String? evenementAffiche;
  final List<Employe>? dernierDepart;
  final ({Employe partant, Employe releve})? derniereRetraite;
  final Jalon? dernierJalon;

  /// Ère dont il faut jouer l'annonce plein écran.
  final int? ereAnnoncee;

  /// Graine de la personne en attente d'un binôme.
  final int? appairageEnCours;

  PartieState copyWith({
    StatutPartie? statut,
    EtatPartie? etat,
    int? revision,
    BilanHorsLigne? bilanHorsLigne,
    bool effacerBilan = false,
    String? evenementAffiche,
    bool effacerEvenement = false,
    List<Employe>? dernierDepart,
    ({Employe partant, Employe releve})? derniereRetraite,
    Jalon? dernierJalon,
    int? ereAnnoncee,
    bool effacerEre = false,
    int? appairageEnCours,
    bool effacerAppairage = false,
  }) =>
      PartieState(
        statut: statut ?? this.statut,
        etat: etat ?? this.etat,
        revision: revision ?? this.revision,
        bilanHorsLigne: effacerBilan ? null : (bilanHorsLigne ?? this.bilanHorsLigne),
        evenementAffiche:
            effacerEvenement ? null : (evenementAffiche ?? this.evenementAffiche),
        dernierDepart: dernierDepart ?? this.dernierDepart,
        derniereRetraite: derniereRetraite ?? this.derniereRetraite,
        dernierJalon: dernierJalon ?? this.dernierJalon,
        ereAnnoncee: effacerEre ? null : (ereAnnoncee ?? this.ereAnnoncee),
        appairageEnCours:
            effacerAppairage ? null : (appairageEnCours ?? this.appairageEnCours),
      );

  @override
  List<Object?> get props => [statut, revision, bilanHorsLigne, evenementAffiche,
        ereAnnoncee, appairageEnCours];
}
