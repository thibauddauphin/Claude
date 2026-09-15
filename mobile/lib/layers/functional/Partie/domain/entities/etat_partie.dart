import '../catalogue/concurrents.dart';
import '../catalogue/stations.dart';
import 'employe.dart';
import 'entree_journal.dart';
import 'evenement.dart';

/// L'agrégat de la partie en cours.
///
/// Volontairement mutable : la simulation avance soixante fois par seconde et
/// recopier l'agrégat à chaque image n'apporterait rien. L'immuabilité est tenue
/// au niveau de l'état de présentation, que le cubit émet à cadence réduite.
class EtatPartie {
  EtatPartie({
    required this.tresorerie,
    required this.composants,
    required this.pointsRecherche,
    required this.exemplaires,
    required this.technologies,
    required this.gamme,
    required this.marge,
    required this.unitesVendues,
    required this.chiffreAffaires,
    required this.chiffreAffairesCumule,
    required this.puissance,
    required this.puissanceRivaux,
    required this.actions,
    required this.parts,
    required this.holding,
    required this.jalonsAtteints,
    required this.introductions,
    required this.conglomerats,
    required this.retraites,
    required this.secondesJouees,
    required this.equipe,
    required this.journal,
    required this.historiqueRevenu,
    required this.derniereSauvegarde,
    this.candidat,
    this.evenement,
    this.tampon = 0,
    this.prochainEvenement = 40,
    this.prochainCandidat = 40,
  });

  /// Une partie neuve : un garage, trente euros et douze composants.
  factory EtatPartie.neuve({
    int actions = 0,
    int parts = 0,
    Set<String>? holding,
    Set<String>? jalons,
    double chiffreAffairesCumule = 0,
    int introductions = 0,
    int conglomerats = 0,
    int retraites = 0,
    double secondesJouees = 0,
  }) {
    final ameliorations = holding ?? <String>{};
    final etat = EtatPartie(
      tresorerie: ameliorations.contains('guerre') ? 1e6 : 30,
      composants: ameliorations.contains('guerre') ? 1e5 : 12,
      pointsRecherche: 0,
      exemplaires: List<int>.filled(stations.length, 0),
      technologies: <String>{},
      gamme: 0,
      marge: 1,
      unitesVendues: 0,
      chiffreAffaires: 0,
      chiffreAffairesCumule: chiffreAffairesCumule,
      puissance: 0,
      puissanceRivaux: concurrents.map((c) => c.puissanceInitiale).toList(),
      actions: actions.toDouble(),
      parts: parts,
      holding: ameliorations,
      jalonsAtteints: jalons ?? <String>{},
      introductions: introductions,
      conglomerats: conglomerats,
      retraites: retraites,
      secondesJouees: secondesJouees,
      equipe: <Employe>[],
      journal: <EntreeJournal>[],
      historiqueRevenu: List<double>.filled(60, 0, growable: true),
      derniereSauvegarde: DateTime.now(),
    );
    if (ameliorations.contains('heritage')) {
      etat.exemplaires[0] = 10;
      etat.exemplaires[1] = 5;
    }
    return etat;
  }

  double tresorerie;
  double composants;
  double pointsRecherche;

  /// Nombre d'exemplaires possédés de chaque moyen de production.
  final List<int> exemplaires;

  final Set<String> technologies;
  int gamme;

  /// Politique de prix, de 0,70 à 1,60.
  double marge;

  double unitesVendues;
  double chiffreAffaires;
  double chiffreAffairesCumule;

  /// Puissance commerciale : ce qui décide de la part de marché.
  double puissance;
  final List<double> puissanceRivaux;

  double actions;
  int parts;
  final Set<String> holding;
  final Set<String> jalonsAtteints;
  int introductions;
  int conglomerats;
  int retraites;
  double secondesJouees;

  final List<Employe> equipe;
  Employe? candidat;

  final List<EntreeJournal> journal;
  final List<double> historiqueRevenu;

  DateTime derniereSauvegarde;
  EvenementActif? evenement;

  /// Fraction d'unité en cours de fabrication, reportée d'une image à l'autre.
  double tampon;

  double prochainEvenement;
  double prochainCandidat;

  bool possede(String technologie) => technologies.contains(technologie);
  bool aHolding(String amelioration) => holding.contains(amelioration);

  int get totalExemplaires => exemplaires.fold(0, (a, b) => a + b);
}
