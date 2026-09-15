/// Un moyen de production : de l'établi de garage à l'essaim d'usines noires.
class Station {
  const Station({
    required this.nom,
    required this.detail,
    required this.coutBase,
    required this.cadence,
  });

  final String nom;
  final String detail;

  /// Coût du premier exemplaire ; chaque suivant coûte 19 % de plus.
  final double coutBase;

  /// Unités produites par seconde, par exemplaire.
  final double cadence;
}
