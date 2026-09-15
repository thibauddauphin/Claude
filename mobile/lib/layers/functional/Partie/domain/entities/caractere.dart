/// Ce qui multiplie les grandeurs de la partie. Partagé par les caractères
/// individuels et par les synergies de binôme, pour que le calcul les traite
/// de la même façon.
abstract interface class EffetsChiffres {
  double? get production;
  double? get prix;
  double? get recherche;
  double? get composants;
  double? get conquete;
}

/// Ce qu'une personne apporte à l'atelier, et ce qu'elle coûte.
class Caractere implements EffetsChiffres {
  const Caractere({
    required this.id,
    required this.nom,
    required this.effet,
    required this.part,
    this.production,
    this.prix,
    this.recherche,
    this.composants,
    this.conquete,
    this.protectionMoral,
    this.estStoique = false,
  });

  final String id;
  final String nom;
  final String effet;

  /// Rémunération demandée, en fraction du chiffre d'affaires.
  final double part;

  @override
  final double? production;
  @override
  final double? prix;
  @override
  final double? recherche;
  @override
  final double? composants;
  @override
  final double? conquete;

  /// Divise l'usure du moral de toute l'équipe.
  final double? protectionMoral;

  /// Ne réclame jamais rien et ne se laisse pas débaucher.
  final bool estStoique;
}

/// Deux caractères qui, mis en binôme, font mieux qu'additionner.
class Synergie implements EffetsChiffres {
  const Synergie({
    required this.a,
    required this.b,
    required this.nom,
    required this.effet,
    this.production,
    this.prix,
    this.recherche,
    this.composants,
    this.conquete,
    this.plancherMoral,
  });

  final String a;
  final String b;
  final String nom;
  final String effet;

  @override
  final double? production;
  @override
  final double? prix;
  @override
  final double? recherche;
  @override
  final double? composants;
  @override
  final double? conquete;

  /// Le moral du binôme ne descend pas sous cette valeur.
  final double? plancherMoral;
}
