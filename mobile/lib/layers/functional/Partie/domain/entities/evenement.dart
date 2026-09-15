enum CibleEvenement { prix, production, recherche, composants }

/// Une secousse de marché, bonne ou mauvaise, qui dure quelques secondes.
class Evenement {
  const Evenement({
    required this.nom,
    required this.effet,
    required this.cible,
    required this.facteur,
    required this.estFavorable,
  });

  final String nom;
  final String effet;
  final CibleEvenement cible;
  final double facteur;
  final bool estFavorable;
}

/// Un événement en cours, avec son temps restant.
class EvenementActif {
  EvenementActif({required this.evenement, required this.resteSecondes});

  final Evenement evenement;
  double resteSecondes;
}
