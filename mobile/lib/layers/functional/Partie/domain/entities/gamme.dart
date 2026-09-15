/// Une génération de produit : ce que l'atelier fabrique et vend.
class Gamme {
  const Gamme({
    required this.annee,
    required this.nom,
    required this.prix,
    required this.composants,
    required this.prixComposant,
    required this.pointsRecherche,
    required this.description,
  });

  final String annee;
  final String nom;

  /// Prix de vente unitaire, avant multiplicateurs.
  final double prix;

  /// Composants consommés par unité produite.
  final double composants;

  /// Prix d'achat d'un composant.
  final double prixComposant;

  /// Points de recherche gagnés par unité vendue.
  final double pointsRecherche;

  final String description;
}
