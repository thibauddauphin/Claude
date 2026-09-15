import '../entities/caractere.dart';

const caracteres = <Caractere>[
  Caractere(
    id: 'soudure', nom: 'Doigts d\'or', effet: 'Production +12 %',
    part: 0.018,
    production: 1.12,
  ),
  Caractere(
    id: 'nego', nom: 'Négociation née', effet: 'Composants −12 %',
    part: 0.016,
    composants: 0.88,
  ),
  Caractere(
    id: 'systeme', nom: 'Tête de système', effet: 'Points R&D +20 %',
    part: 0.02,
    recherche: 1.2,
  ),
  Caractere(
    id: 'commerce', nom: 'Sens du commerce', effet: 'Prix de vente +9 %',
    part: 0.02,
    prix: 1.09,
  ),
  Caractere(
    id: 'logistique', nom: 'Méthode logistique', effet: 'Production +7 %, composants −6 %',
    part: 0.018,
    production: 1.07, composants: 0.94,
  ),
  Caractere(
    id: 'perfection', nom: 'Perfectionnisme', effet: 'Prix +14 %, production −5 %',
    part: 0.018,
    production: 0.95, prix: 1.14,
  ),
  Caractere(
    id: 'formation', nom: 'Goût de transmettre', effet: 'L\'usure du moral de l\'équipe est divisée par deux',
    part: 0.016,
    protectionMoral: 0.5,
  ),
  Caractere(
    id: 'autodidacte', nom: 'Autodidacte', effet: 'Points R&D +12 %, production +5 %',
    part: 0.022,
    production: 1.05, recherche: 1.12,
  ),
  Caractere(
    id: 'endurance', nom: 'Increvable', effet: 'Production +9 %, ne réclame jamais rien',
    part: 0.014,
    production: 1.09, estStoique: true,
  ),
  Caractere(
    id: 'influence', nom: 'Carnet d\'adresses', effet: 'Conquête du marché +15 %',
    part: 0.018,
    conquete: 1.15,
  ),
];

const synergies = <Synergie>[
  Synergie(
    a: 'soudure', b: 'formation', nom: 'Compagnonnage', effet: 'Production +25 %',
    production: 1.25,
  ),
  Synergie(
    a: 'systeme', b: 'autodidacte', nom: 'Veille technologique', effet: 'Points R&D +30 %',
    recherche: 1.3,
  ),
  Synergie(
    a: 'commerce', b: 'influence', nom: 'Force de vente', effet: 'Prix +15 %, conquête +15 %',
    prix: 1.15, conquete: 1.15,
  ),
  Synergie(
    a: 'nego', b: 'logistique', nom: 'Chaîne courte', effet: 'Composants −20 %',
    composants: 0.8,
  ),
  Synergie(
    a: 'perfection', b: 'soudure', nom: 'Atelier d\'exception', effet: 'Prix +12 %, production +10 %',
    production: 1.1, prix: 1.12,
  ),
  Synergie(
    a: 'endurance', b: 'formation', nom: 'École de l\'atelier', effet: 'Le moral du binôme ne tombe plus sous 40',
    plancherMoral: 40,
  ),
  Synergie(
    a: 'systeme', b: 'logistique', nom: 'Ordonnancement fin', effet: 'Production +18 %',
    production: 1.18,
  ),
  Synergie(
    a: 'commerce', b: 'nego', nom: 'Marge arrachée', effet: 'Prix +10 %, composants −10 %',
    prix: 1.1, composants: 0.9,
  ),
];

/// Prénoms par génération : l'atelier recrute dans son époque.
const prenomsParGeneration = <List<String>>[
  ['Jean-Claude', 'Michèle', 'Patrick', 'Martine', 'Gérard', 'Chantal', 'Bernard', 'Nicole', 'Alain', 'Dominique', 'Roland', 'Françoise'],
  ['Sébastien', 'Aurélie', 'Nicolas', 'Céline', 'Julien', 'Sandrine', 'Fabrice', 'Nathalie', 'Karim', 'Stéphanie', 'Laurent', 'Valérie'],
  ['Thomas', 'Marion', 'Kévin', 'Laura', 'Mehdi', 'Élodie', 'Anthony', 'Camille', 'Youssef', 'Charlotte', 'Maxime', 'Inès'],
  ['Lucas', 'Emma', 'Nathan', 'Léa', 'Rayan', 'Jade', 'Enzo', 'Louise', 'Ibrahim', 'Alice', 'Noé', 'Anaïs'],
];

const nomsDeFamille = <String>[
  'Bertrand', 'Lemoine', 'Fontaine', 'Vasseur', 'Marchand', 'Perrot', 'Nguyen', 'Lopes', 'Benali', 'Charrier', 'Delaunay', 'Ruiz', 'Kowalski', 'Mercier', 'Hamon', 'Tessier', 'Bonnet', 'Rey', 'Sow', 'Andrieu', 'Ferreira', 'Chevalier', 'Lagarde', 'Moreau', 'Dufour', 'Barbier', 'Guillon', 'Rousset',
];

const motifsDepart = <String>[
  'a rendu son tablier : « on brade, je ne suis plus payé à ma valeur ».',
  'part chez Béta-Tronic, qui proposait mieux.',
  'claque la porte après trois semaines de chaîne à l\'arrêt.',
  'démissionne : « je passe mes journées à attendre les composants ».',
  's\'en va monter son propre atelier.',
  'prend la porte sans un mot. Le badge est resté sur l\'établi.',
];

const motifsRetraite = <String>[
  'part à la retraite. Pot dans l\'atelier, discours trop long, tout le monde a pleuré.',
  'raccroche le fer après une carrière entière ici.',
  'prend sa retraite et laisse son établi impeccable.',
  's\'en va profiter. Son remplaçant a été formé par ses soins.',
];
