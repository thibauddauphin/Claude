import '../entities/jalon.dart';

const jalons = <Jalon>[
  Jalon(
    id: 'u1', nom: 'Premier client',
    description: 'Vendre 100 unités',
    mesure: MesureJalon.unites, seuil: 100, bonus: 0.02,
  ),
  Jalon(
    id: 'u2', nom: 'Bouche-à-oreille',
    description: 'Vendre 10 000 unités',
    mesure: MesureJalon.unites, seuil: 10000, bonus: 0.02,
  ),
  Jalon(
    id: 'u3', nom: 'Catalogue par correspondance',
    description: 'Vendre 1 million d\'unités',
    mesure: MesureJalon.unites, seuil: 1000000, bonus: 0.03,
  ),
  Jalon(
    id: 'u4', nom: 'Référencé en grande surface',
    description: 'Vendre 100 millions d\'unités',
    mesure: MesureJalon.unites, seuil: 100000000, bonus: 0.03,
  ),
  Jalon(
    id: 'u5', nom: 'Standard du marché',
    description: 'Vendre 10 milliards d\'unités',
    mesure: MesureJalon.unites, seuil: 10000000000, bonus: 0.04,
  ),
  Jalon(
    id: 'u6', nom: 'Équipementier mondial',
    description: 'Vendre 1 000 milliards d\'unités',
    mesure: MesureJalon.unites, seuil: 1000000000000, bonus: 0.04,
  ),
  Jalon(
    id: 'u7', nom: 'Infrastructure planétaire',
    description: 'Vendre 10¹⁵ unités',
    mesure: MesureJalon.unites, seuil: 1000000000000000, bonus: 0.05,
  ),
  Jalon(
    id: 'c1', nom: 'Premier bilan à l\'équilibre',
    description: '10 000 € de chiffre d\'affaires',
    mesure: MesureJalon.chiffreAffaires, seuil: 10000, bonus: 0.02,
  ),
  Jalon(
    id: 'c2', nom: 'Premier million',
    description: '1 M€ de chiffre d\'affaires',
    mesure: MesureJalon.chiffreAffaires, seuil: 1000000, bonus: 0.02,
  ),
  Jalon(
    id: 'c3', nom: 'Entrée au classement',
    description: '1 Md€ de chiffre d\'affaires',
    mesure: MesureJalon.chiffreAffaires, seuil: 1000000000, bonus: 0.03,
  ),
  Jalon(
    id: 'c4', nom: 'Poids lourd du secteur',
    description: '1 000 Md€ de chiffre d\'affaires',
    mesure: MesureJalon.chiffreAffaires, seuil: 1000000000000, bonus: 0.04,
  ),
  Jalon(
    id: 'c5', nom: 'Première capitalisation mondiale',
    description: '10¹⁵ € de chiffre d\'affaires',
    mesure: MesureJalon.chiffreAffaires, seuil: 1000000000000000, bonus: 0.05,
  ),
  Jalon(
    id: 'c6', nom: 'Hors catégorie',
    description: '10¹⁸ € de chiffre d\'affaires',
    mesure: MesureJalon.chiffreAffaires, seuil: 1000000000000000000, bonus: 0.06,
  ),
  Jalon(
    id: 's1', nom: 'L\'atelier s\'agrandit',
    description: '25 moyens de production',
    mesure: MesureJalon.stations, seuil: 25, bonus: 0.02,
  ),
  Jalon(
    id: 's2', nom: 'Directeur industriel',
    description: '100 moyens de production',
    mesure: MesureJalon.stations, seuil: 100, bonus: 0.03,
  ),
  Jalon(
    id: 's3', nom: 'Parc intégré',
    description: '250 moyens de production',
    mesure: MesureJalon.stations, seuil: 250, bonus: 0.04,
  ),
  Jalon(
    id: 's4', nom: 'Capacité continentale',
    description: '500 moyens de production',
    mesure: MesureJalon.stations, seuil: 500, bonus: 0.05,
  ),
  Jalon(
    id: 's5', nom: 'Tout est automatisé',
    description: '1 000 moyens de production',
    mesure: MesureJalon.stations, seuil: 1000, bonus: 0.06,
  ),
  Jalon(
    id: 't1', nom: 'Premier brevet',
    description: '5 technologies acquises',
    mesure: MesureJalon.technologies, seuil: 5, bonus: 0.02,
  ),
  Jalon(
    id: 't2', nom: 'Département recherche',
    description: '15 technologies acquises',
    mesure: MesureJalon.technologies, seuil: 15, bonus: 0.03,
  ),
  Jalon(
    id: 't3', nom: 'Laboratoire central',
    description: '30 technologies acquises',
    mesure: MesureJalon.technologies, seuil: 30, bonus: 0.04,
  ),
  Jalon(
    id: 't4', nom: 'État de l\'art',
    description: 'Les 45 technologies',
    mesure: MesureJalon.technologies, seuil: 45, bonus: 0.08,
  ),
  Jalon(
    id: 'p1', nom: 'On nous remarque',
    description: '25 % de part de marché',
    mesure: MesureJalon.partMarche, seuil: 25, bonus: 0.03,
  ),
  Jalon(
    id: 'p2', nom: 'Leader du secteur',
    description: '50 % de part de marché',
    mesure: MesureJalon.partMarche, seuil: 50, bonus: 0.04,
  ),
  Jalon(
    id: 'p3', nom: 'Position dominante',
    description: '75 % de part de marché',
    mesure: MesureJalon.partMarche, seuil: 75, bonus: 0.05,
  ),
  Jalon(
    id: 'p4', nom: 'Enquête de la Commission',
    description: '90 % de part de marché',
    mesure: MesureJalon.partMarche, seuil: 90, bonus: 0.06,
  ),
  Jalon(
    id: 'e1', nom: 'Le micro entre au foyer',
    description: 'Atteindre 1979',
    mesure: MesureJalon.ere, seuil: 1, bonus: 0.02,
  ),
  Jalon(
    id: 'e2', nom: 'Compatible et fier',
    description: 'Atteindre 1984',
    mesure: MesureJalon.ere, seuil: 3, bonus: 0.03,
  ),
  Jalon(
    id: 'e3', nom: 'Survivre à la bulle',
    description: 'Atteindre 2000',
    mesure: MesureJalon.ere, seuil: 7, bonus: 0.04,
  ),
  Jalon(
    id: 'e4', nom: 'Le nuage nous appartient',
    description: 'Atteindre 2012',
    mesure: MesureJalon.ere, seuil: 10, bonus: 0.05,
  ),
  Jalon(
    id: 'e5', nom: 'Au-delà du silicium',
    description: 'Atteindre 2040',
    mesure: MesureJalon.ere, seuil: 14, bonus: 0.08,
  ),
  Jalon(
    id: 'a1', nom: 'Première cotation',
    description: 'Une introduction en bourse',
    mesure: MesureJalon.introductions, seuil: 1, bonus: 0.04,
  ),
  Jalon(
    id: 'a2', nom: 'Actionnaire de référence',
    description: '500 actions détenues',
    mesure: MesureJalon.actions, seuil: 500, bonus: 0.06,
  ),
  Jalon(
    id: 'a3', nom: 'Fondateur de conglomérat',
    description: 'Une part de holding',
    mesure: MesureJalon.parts, seuil: 1, bonus: 0.1,
  ),
];
