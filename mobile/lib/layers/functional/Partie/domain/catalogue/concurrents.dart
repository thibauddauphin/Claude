import '../entities/concurrent.dart';

const concurrents = <Concurrent>[
  Concurrent(
    nom: 'Béta-Tronic', puissanceInitiale: 2100,
    poids: 0.55, rattrapage: 0.0035, croissanceDeFond: 0.00008,
  ),
  Concurrent(
    nom: 'Mégabit SA', puissanceInitiale: 1400,
    poids: 0.38, rattrapage: 0.003, croissanceDeFond: 0.00007,
  ),
  Concurrent(
    nom: 'Nordisk Data', puissanceInitiale: 800,
    poids: 0.22, rattrapage: 0.0026, croissanceDeFond: 0.00006,
  ),
  Concurrent(
    nom: 'Cortex Systems', puissanceInitiale: 400,
    poids: 0.12, rattrapage: 0.0045, croissanceDeFond: 0.0001,
  ),
];
