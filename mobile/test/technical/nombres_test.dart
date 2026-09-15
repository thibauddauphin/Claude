import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/technical/Format/nombres.dart';

void main() {
  group('la mise en forme des grandeurs', () {
    test('les petits nombres gardent une décimale', () {
      expect(Nombres.format(0), '0');
      expect(Nombres.format(14.5), '14,5');
      expect(Nombres.format(340), '340');
    });

    test('les paliers courants prennent un suffixe', () {
      expect(Nombres.format(1320), '1,32 k');
      expect(Nombres.format(2.4e6), '2,4 M');
      expect(Nombres.format(8e9), '8 Md');
    });

    test('au-delà du millier de milliards, la notation scientifique reprend', () {
      expect(Nombres.format(1.24e12), '1,24 ×10¹²');
      expect(Nombres.format(5.3e30), '5,3 ×10³⁰');
    });

    test('les négatifs portent un vrai signe moins', () {
      expect(Nombres.format(-42), '−42');
    });

    test('les durées se lisent comme on les dit', () {
      expect(Nombres.duree(const Duration(seconds: 45)), '45 secondes');
      expect(Nombres.duree(const Duration(minutes: 42)), '42 minutes');
      expect(Nombres.duree(const Duration(hours: 3, minutes: 5)), '3 h 05');
      expect(Nombres.duree(const Duration(hours: 12)), '12 h');
    });
  });
}
