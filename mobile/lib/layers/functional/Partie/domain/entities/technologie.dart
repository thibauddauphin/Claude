/// Une avancée de laboratoire, payée en points de recherche.
class Technologie {
  const Technologie({
    required this.id,
    required this.ere,
    required this.nom,
    required this.cout,
    required this.effet,
    required this.icone,
    this.ouvre,
    this.production,
    this.prix,
    this.conquete,
  });

  final String id;

  /// Ère d'affichage dans la liste de recherche.
  final int ere;
  final String nom;
  final double cout;
  final String effet;
  final String icone;

  /// Indice de la gamme débloquée, le cas échéant.
  final int? ouvre;

  final double? production;
  final double? prix;
  final double? conquete;
}
