import 'package:flutter/rendering.dart';

/// La courbe de revenu des soixante dernières secondes : aire discrète,
/// trait franc, point final accentué.
class CourbeRevenuPeintre extends CustomPainter {
  const CourbeRevenuPeintre({
    required this.valeurs,
    required this.accent,
    required this.trait,
    required this.fond,
  });

  final List<double> valeurs;
  final Color accent;
  final Color trait;
  final Color fond;

  @override
  void paint(Canvas canvas, Size size) {
    if (valeurs.length < 2) return;
    const marge = 6.0;
    final maximum = valeurs.fold<double>(1, (a, b) => b > a ? b : a);
    final pas = size.width / (valeurs.length - 1);
    double y(double v) => size.height - marge - (v / maximum) * (size.height - marge * 2);

    final ligneBase = Paint()
      ..color = trait
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - .5),
        Offset(size.width, size.height - .5), ligneBase);

    final chemin = Path()..moveTo(0, size.height);
    for (var i = 0; i < valeurs.length; i++) {
      chemin.lineTo(i * pas, y(valeurs[i]));
    }
    chemin
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(chemin, Paint()..color = accent.withValues(alpha: .14));

    final courbe = Path()..moveTo(0, y(valeurs.first));
    for (var i = 1; i < valeurs.length; i++) {
      courbe.lineTo(i * pas, y(valeurs[i]));
    }
    canvas.drawPath(
      courbe,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    final fin = Offset(size.width - 1, y(valeurs.last));
    canvas.drawCircle(fin, 3.5, Paint()..color = accent);
    canvas.drawCircle(
      fin,
      3.5,
      Paint()
        ..color = fond
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(CourbeRevenuPeintre ancien) => true;
}
