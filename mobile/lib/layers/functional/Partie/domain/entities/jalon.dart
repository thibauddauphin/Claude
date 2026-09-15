enum MesureJalon {
  unites, chiffreAffaires, stations, technologies,
  partMarche, ere, introductions, actions, parts,
}

/// Un succès permanent : une fois atteint, son bonus ne se perd plus.
class Jalon {
  const Jalon({
    required this.id,
    required this.nom,
    required this.description,
    required this.mesure,
    required this.seuil,
    required this.bonus,
  });

  final String id;
  final String nom;
  final String description;
  final MesureJalon mesure;
  final double seuil;

  /// Bonus de production accordé, en fraction (0.02 = +2 %).
  final double bonus;
}
