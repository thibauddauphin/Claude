import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/technical/Format/nombres.dart';

void main() {
  test('l’accord suit la quantité affichée', () {
    expect(Nombres.pluriel(1, 'composant'), 'composant');
    expect(Nombres.pluriel(1.4, 'composant'), 'composant');
    expect(Nombres.pluriel(2, 'composant'), 'composants');
    expect(Nombres.pluriel(30, 'composant'), 'composants');
    expect(Nombres.pluriel(3, 'part', 'parts'), 'parts');
  });
}
