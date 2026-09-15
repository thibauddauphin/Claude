/// Une personne de l'atelier : un caractère, un moral, une carrière.
class Employe {
  Employe({
    required this.prenom,
    required this.nom,
    required this.caractereId,
    required this.poste,
    required this.part,
    required this.partInitiale,
    required this.age,
    required this.ageRetraite,
    required this.graine,
    this.moral = 78,
    this.confort = 0,
    this.ancienneteSecondes = 0,
    this.binome,
    this.origine,
    this.indemnite,
    this.estForme = false,
  });

  final String prenom;
  final String nom;
  final String caractereId;
  final String poste;

  /// Rémunération actuelle, en fraction du chiffre d'affaires.
  double part;

  /// Rémunération à l'embauche ; les augmentations plafonnent à quatre fois.
  final double partInitiale;

  double age;
  final int ageRetraite;

  /// Identifiant stable, qui sert aussi de graine au portrait.
  final int graine;

  double moral;

  /// Bien-être acheté par une augmentation ou une prime ; s'estompe en une demi-heure.
  double confort;

  double ancienneteSecondes;

  /// Graine du partenaire de binôme, le cas échéant.
  int? binome;

  /// Nom du concurrent chez qui la personne a été débauchée.
  final String? origine;

  /// Indemnité de transfert réclamée par ce concurrent.
  final double? indemnite;

  /// Vrai lorsque la personne a été formée par celui qui part à la retraite.
  final bool estForme;

  String get nomComplet => '$prenom $nom';

  /// Années de présence dans la maison.
  int get anneesDeMaison => (ancienneteSecondes / 360).floor();

  /// Accord du participe passé dans le journal ; suffisant pour l'usage.
  bool get accordeAuFeminin =>
      RegExp(r'[ae]$').hasMatch(prenom) && prenom != 'Noé';

  Employe copie() => Employe(
        prenom: prenom, nom: nom, caractereId: caractereId, poste: poste,
        part: part, partInitiale: partInitiale, age: age, ageRetraite: ageRetraite,
        graine: graine, moral: moral, confort: confort,
        ancienneteSecondes: ancienneteSecondes, binome: binome,
        origine: origine, indemnite: indemnite, estForme: estForme,
      );
}
