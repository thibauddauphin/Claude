import 'package:flutter_test/flutter_test.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/gammes.dart';
import 'package:silicium_et_cie/layers/functional/Partie/domain/catalogue/stations.dart';

/// Les peintres s'appuient sur l'indice du catalogue, sans table de
/// correspondance : si l'ordre change d'un côté, il doit changer de l'autre.
void main() {
  test('les moyens de production sont dans l’ordre attendu par les vignettes', () {
    expect(stations.map((s) => s.nom).toList(), [
      'Établi de garage', 'Stagiaire en BTS', "Technicien d'atelier",
      "Chaîne d'assemblage", 'Atelier sous-traité', 'Usine intégrée',
      'Robot de pose CMS', 'Ligne automatisée', 'Ferme de serveurs',
      'Fonderie dédiée', 'Ordonnanceur autonome', "Essaim d'usines noires",
    ]);
  });

  test('les gammes sont dans l’ordre attendu par les sprites', () {
    expect(gammes, hasLength(15));
    expect(gammes.first.nom, 'Kit à souder 8 bits');
    expect(gammes[2].nom, 'Terminal télématique');
    expect(gammes[7].nom, "Baie d'hébergement");
    expect(gammes.last.nom, 'Substrat neuromorphique');
  });
}
