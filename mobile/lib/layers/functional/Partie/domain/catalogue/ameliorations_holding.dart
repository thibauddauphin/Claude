import '../entities/amelioration_holding.dart';

const ameliorationsHolding = <AmeliorationHolding>[
  AmeliorationHolding(
    id: 'heritage', nom: 'Héritage industriel', cout: 2,
    effet: 'Chaque partie démarre avec 10 établis et 5 stagiaires.',
  ),
  AmeliorationHolding(
    id: 'carnet', nom: 'Carnet d\'adresses', cout: 3,
    effet: 'Les technologies coûtent 20 % de points R&D en moins.',
  ),
  AmeliorationHolding(
    id: 'guerre', nom: 'Trésorerie de guerre', cout: 5,
    effet: 'Chaque partie démarre avec 1 M€ et 100 000 composants.',
  ),
  AmeliorationHolding(
    id: 'integree', nom: 'Filière intégrée', cout: 8,
    effet: 'Composants 35 % moins chers, définitivement.',
  ),
  AmeliorationHolding(
    id: 'labo', nom: 'Institut de recherche', cout: 11,
    effet: 'Points R&D ×2.',
  ),
  AmeliorationHolding(
    id: 'monopole', nom: 'Position installée', cout: 15,
    effet: 'La concurrence croît 40 % moins vite.',
  ),
  AmeliorationHolding(
    id: 'cadence', nom: 'Doctrine de la cadence', cout: 20,
    effet: 'Production ×3.',
  ),
  AmeliorationHolding(
    id: 'empire', nom: 'Empire industriel', cout: 26,
    effet: 'Production et prix ×2, et une action offerte par minute.',
  ),
];
