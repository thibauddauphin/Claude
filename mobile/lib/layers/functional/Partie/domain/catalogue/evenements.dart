import '../entities/evenement.dart';

const evenements = <Evenement>[
  Evenement(
    nom: 'Pénurie de mémoire', effet: 'Composants ×2,2',
    cible: CibleEvenement.composants, facteur: 2.2, estFavorable: false,
  ),
  Evenement(
    nom: 'Rentrée scolaire', effet: 'Prix de vente ×1,8',
    cible: CibleEvenement.prix, facteur: 1.8, estFavorable: true,
  ),
  Evenement(
    nom: 'Grève des transporteurs', effet: 'Production ×0,55',
    cible: CibleEvenement.production, facteur: 0.55, estFavorable: false,
  ),
  Evenement(
    nom: 'Banc d\'essai élogieux', effet: 'Prix de vente ×2,2',
    cible: CibleEvenement.prix, facteur: 2.2, estFavorable: true,
  ),
  Evenement(
    nom: 'Salon de l\'informatique', effet: 'Points R&D ×3',
    cible: CibleEvenement.recherche, facteur: 3, estFavorable: true,
  ),
  Evenement(
    nom: 'Faille de sécurité', effet: 'Prix de vente ×0,6',
    cible: CibleEvenement.prix, facteur: 0.6, estFavorable: false,
  ),
  Evenement(
    nom: 'Marché public signé', effet: 'Production ×1,7',
    cible: CibleEvenement.production, facteur: 1.7, estFavorable: true,
  ),
  Evenement(
    nom: 'Guerre des prix', effet: 'Prix de vente ×0,7',
    cible: CibleEvenement.prix, facteur: 0.7, estFavorable: false,
  ),
  Evenement(
    nom: 'Rupture chez le fondeur', effet: 'Production ×0,6',
    cible: CibleEvenement.production, facteur: 0.6, estFavorable: false,
  ),
  Evenement(
    nom: 'Commande d\'un ministère', effet: 'Prix de vente ×1,6',
    cible: CibleEvenement.prix, facteur: 1.6, estFavorable: true,
  ),
  Evenement(
    nom: 'Spéculation sur le cuivre', effet: 'Composants ×1,9',
    cible: CibleEvenement.composants, facteur: 1.9, estFavorable: false,
  ),
  Evenement(
    nom: 'Norme adoptée par le secteur', effet: 'Points R&D ×2,5',
    cible: CibleEvenement.recherche, facteur: 2.5, estFavorable: true,
  ),
  Evenement(
    nom: 'Panne du réseau électrique', effet: 'Production ×0,45',
    cible: CibleEvenement.production, facteur: 0.45, estFavorable: false,
  ),
  Evenement(
    nom: 'Effet de mode', effet: 'Prix de vente ×2,5',
    cible: CibleEvenement.prix, facteur: 2.5, estFavorable: true,
  ),
];
