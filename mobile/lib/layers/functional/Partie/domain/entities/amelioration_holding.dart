/// Une méta-amélioration du conglomérat, payée en parts de holding.
class AmeliorationHolding {
  const AmeliorationHolding({
    required this.id,
    required this.nom,
    required this.cout,
    required this.effet,
  });

  final String id;
  final String nom;
  final int cout;
  final String effet;
}
