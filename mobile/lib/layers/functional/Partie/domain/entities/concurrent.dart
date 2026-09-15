/// Une société rivale. Sa puissance vise une fraction de la vôtre :
/// stagner, c'est la laisser revenir.
class Concurrent {
  const Concurrent({
    required this.nom,
    required this.puissanceInitiale,
    required this.poids,
    required this.rattrapage,
    required this.croissanceDeFond,
  });

  final String nom;
  final double puissanceInitiale;

  /// Fraction de votre puissance que ce rival vise.
  final double poids;

  /// Vitesse à laquelle il comble son retard.
  final double rattrapage;

  final double croissanceDeFond;
}
