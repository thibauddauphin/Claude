import '../entities/station.dart';

const stations = <Station>[
  Station(nom: 'Établi de garage',       detail: 'Votre table de cuisine, réquisitionnée.',            coutBase: 45,           cadence: .15),
  Station(nom: 'Stagiaire en BTS',       detail: 'Soude vite, se trompe parfois.',                     coutBase: 380,          cadence: .7),
  Station(nom: "Technicien d'atelier",   detail: 'Quinze ans de métier, zéro reprise.',                coutBase: 3200,         cadence: 3),
  Station(nom: "Chaîne d'assemblage",    detail: 'Tapis roulant, postes en série.',                    coutBase: 27000,        cadence: 13),
  Station(nom: 'Atelier sous-traité',    detail: 'Trois équipes, deux fuseaux horaires.',              coutBase: 230000,       cadence: 55),
  Station(nom: 'Usine intégrée',         detail: 'Du lingot au carton, sous un seul toit.',            coutBase: 1900000,      cadence: 230),
  Station(nom: 'Robot de pose CMS',      detail: "12 000 composants placés à l'heure.",                coutBase: 16000000,     cadence: 980),
  Station(nom: 'Ligne automatisée',      detail: "Aucune main humaine entre l'entrée et la sortie.",   coutBase: 140000000,    cadence: 4100),
  Station(nom: 'Ferme de serveurs',      detail: 'Provisionnement automatique des baies.',             coutBase: 1200000000,   cadence: 17000),
  Station(nom: 'Fonderie dédiée',        detail: 'Salle blanche, gravure maison.',                     coutBase: 10000000000,  cadence: 72000),
  Station(nom: 'Ordonnanceur autonome',  detail: 'Décide seul de la production du jour.',              coutBase: 85000000000,  cadence: 300000),
  Station(nom: "Essaim d'usines noires", detail: 'Des halls sans lumière, répliqués à la demande.',    coutBase: 720000000000, cadence: 1300000),
];
