import '../entities/technologie.dart';

const technologies = <Technologie>[
  Technologie(
    id: 'fer', ere: 0, nom: 'Fer thermorégulé',
    cout: 11.0, effet: 'Assemblage manuel ×4', icone: 'fer',
  ),
  Technologie(
    id: 'pcb', ere: 0, nom: 'Circuit imprimé double face',
    cout: 49.0, effet: '−20 % de composants par unité', icone: 'carte',
  ),
  Technologie(
    id: 'mos', ere: 0, nom: 'Transistor MOS',
    cout: 119.0, effet: 'Micro familial · production ×1,25', icone: 'puce',
    ouvre: 1, production: 1.25,
  ),
  Technologie(
    id: 'appro', ere: 1, nom: 'Approvisionnement automatique',
    cout: 196.0, effet: 'Rachète les composants toute seule', icone: 'carton',
  ),
  Technologie(
    id: 'clavier', ere: 1, nom: 'Clavier mécanique',
    cout: 479.0, effet: 'Prix ×1,2', icone: 'clavier',
    prix: 1.2,
  ),
  Technologie(
    id: 'v23', ere: 1, nom: 'Modem V.23',
    cout: 1024.0, effet: 'Terminal télématique', icone: 'modem',
    ouvre: 2,
  ),
  Technologie(
    id: 'annuaire', ere: 2, nom: 'Annuaire électronique',
    cout: 6708.0, effet: 'Conquête du marché ×1,2', icone: 'livre',
    conquete: 1.2,
  ),
  Technologie(
    id: 'logi', ere: 2, nom: 'Entrepôt central',
    cout: 11994.0, effet: '−20 % de composants', icone: 'palette',
  ),
  Technologie(
    id: 'bus16', ere: 2, nom: 'Bus 16 bits',
    cout: 23646.0, effet: 'Compatible PC · production ×1,3', icone: 'bus',
    ouvre: 3, production: 1.3,
  ),
  Technologie(
    id: 'gui', ere: 3, nom: 'Interface graphique',
    cout: 188049.0, effet: 'Prix ×1,3', icone: 'souris',
    prix: 1.3,
  ),
  Technologie(
    id: 'lan', ere: 3, nom: 'Réseau local',
    cout: 359003.0, effet: 'Production ×1,4', icone: 'reseau',
    production: 1.4,
  ),
  Technologie(
    id: 'lcd', ere: 3, nom: 'Écran à cristaux liquides',
    cout: 683821.0, effet: 'Portable à écran LCD', icone: 'ecran',
    ouvre: 4,
  ),
  Technologie(
    id: 'lithium', ere: 4, nom: 'Batterie lithium-ion',
    cout: 13947558.0, effet: 'Prix ×1,25', icone: 'pile',
    prix: 1.25,
  ),
  Technologie(
    id: 'sav', ere: 4, nom: 'Service après-vente',
    cout: 24408228.0, effet: 'Crises de marché deux fois moins dures', icone: 'casque',
  ),
  Technologie(
    id: 'cdrom', ere: 4, nom: 'Lecteur de disques optiques',
    cout: 42915567.0, effet: 'Station multimédia', icone: 'disque',
    ouvre: 5,
  ),
  Technologie(
    id: 'accel3d', ere: 5, nom: 'Accélérateur 3D',
    cout: 2107429369.0, effet: 'Production ×1,5', icone: 'gpu',
    production: 1.5,
  ),
  Technologie(
    id: 'marque', ere: 5, nom: 'Campagne de marque',
    cout: 3709075692.0, effet: 'Prix ×1,5 · conquête ×1,25', icone: 'megaphone',
    prix: 1.5, conquete: 1.25,
  ),
  Technologie(
    id: 'tcpip', ere: 5, nom: 'Pile TCP/IP',
    cout: 6322288109.0, effet: 'Serveur web 1U', icone: 'prise',
    ouvre: 6,
  ),
  Technologie(
    id: 'colo', ere: 6, nom: 'Hébergement en colocation',
    cout: 144248324600.0, effet: 'Production ×1,4', icone: 'baie',
    production: 1.4,
  ),
  Technologie(
    id: 'ssl', ere: 6, nom: 'Chiffrement de bout en bout',
    cout: 267889745688.0, effet: 'Prix ×1,3', icone: 'cadenas',
    prix: 1.3,
  ),
  Technologie(
    id: 'cotation', ere: 6, nom: 'Cotation au nouveau marché',
    cout: 484262232589.0, effet: 'Baie d\'hébergement', icone: 'courbe',
    ouvre: 7,
  ),
  Technologie(
    id: 'restruct', ere: 7, nom: 'Plan de restructuration',
    cout: 4095148493057.0, effet: 'Moyens de production −15 %', icone: 'ciseaux',
  ),
  Technologie(
    id: 'fibre', ere: 7, nom: 'Fibre optique',
    cout: 7583608320475.0, effet: 'Production ×1,5', icone: 'fibre',
    production: 1.5,
  ),
  Technologie(
    id: 'degroupage', ere: 7, nom: 'Dégroupage de la boucle locale',
    cout: 13650494976857.0, effet: 'Box haut débit', icone: 'prise',
    ouvre: 8,
  ),
  Technologie(
    id: 'cdn', ere: 8, nom: 'Réseau de distribution',
    cout: 24256214999673.0, effet: 'Conquête du marché ×1,3', icone: 'globe',
    conquete: 1.3,
  ),
  Technologie(
    id: 'wifi', ere: 8, nom: 'Puce sans fil',
    cout: 41582082856584.0, effet: 'Prix ×1,3', icone: 'onde',
    prix: 1.3,
  ),
  Technologie(
    id: 'arm', ere: 8, nom: 'Puce à faible consommation',
    cout: 72768644999017.0, effet: 'Téléphone à dalle tactile', icone: 'puce2',
    ouvre: 9,
  ),
  Technologie(
    id: 'boutique', ere: 9, nom: 'Boutique d\'applications',
    cout: 82176549541233.0, effet: 'Prix ×1,6', icone: 'sac',
    prix: 1.6,
  ),
  Technologie(
    id: 'capacitif', ere: 9, nom: 'Dalle capacitive multipoint',
    cout: 142915738332578.0, effet: 'Production ×1,5', icone: 'doigt',
    production: 1.5,
  ),
  Technologie(
    id: 'virtu', ere: 9, nom: 'Virtualisation',
    cout: 262012186943061.0, effet: 'Offre cloud', icone: 'nuage',
    ouvre: 10,
  ),
  Technologie(
    id: 'conteneur', ere: 10, nom: 'Conteneurisation',
    cout: 461950848294643.0, effet: 'Production ×1,6', icone: 'boite',
    production: 1.6,
  ),
  Technologie(
    id: 'edge', ere: 10, nom: 'Calcul en périphérie',
    cout: 848990748217183.0, effet: 'Prix ×1,4', icone: 'antenne',
    prix: 1.4,
  ),
  Technologie(
    id: 'lpwan', ere: 10, nom: 'Radio basse consommation',
    cout: 1.498218967442e15, effet: 'Capteur connecté', icone: 'onde',
    ouvre: 11,
  ),
  Technologie(
    id: 'flotte', ere: 11, nom: 'Gestion de flotte',
    cout: 2.725423071251e15, effet: 'Production ×1,5', icone: 'carte2',
    production: 1.5,
  ),
  Technologie(
    id: 'gpu', ere: 11, nom: 'Calcul parallèle',
    cout: 4.931717938454e15, effet: 'Production ×2', icone: 'gpu',
    production: 2,
  ),
  Technologie(
    id: 'nn', ere: 11, nom: 'Réseaux de neurones',
    cout: 9.084743570836e15, effet: 'Grappe d\'accélérateurs', icone: 'neurone',
    ouvre: 12,
  ),
  Technologie(
    id: 'inference', ere: 12, nom: 'Optimisation de l\'inférence',
    cout: 1.836295051523e16, effet: 'Prix ×1,5', icone: 'eclair',
    prix: 1.5,
  ),
  Technologie(
    id: 'immersion', ere: 12, nom: 'Refroidissement immersif',
    cout: 3.390083172043e16, effet: 'Production ×1,7', icone: 'goutte',
    production: 1.7,
  ),
  Technologie(
    id: 'qubit', ere: 12, nom: 'Qubit supraconducteur',
    cout: 5.650138620071e16, effet: 'Calculateur quantique', icone: 'atome',
    ouvre: 13,
  ),
  Technologie(
    id: 'correction', ere: 13, nom: 'Correction d\'erreurs',
    cout: 1.207015713976e17, effet: 'Production ×2', icone: 'bouclier',
    production: 2,
  ),
  Technologie(
    id: 'cryo', ere: 13, nom: 'Cryogénie industrielle',
    cout: 2.060758536056e17, effet: 'Prix ×1,6', icone: 'flocon',
    prix: 1.6,
  ),
  Technologie(
    id: 'memristor', ere: 13, nom: 'Memristor',
    cout: 3.974320033822e17, effet: 'Substrat neuromorphique', icone: 'spirale',
    ouvre: 14,
  ),
  Technologie(
    id: 'plasticite', ere: 14, nom: 'Plasticité synthétique',
    cout: 5.300000000000e17, effet: 'Production ×2,2', icone: 'neurone',
    production: 2.2,
  ),
  Technologie(
    id: 'autoconcep', ere: 14, nom: 'Conception autonome',
    cout: 9.600000000000e17, effet: 'Prix ×1,8', icone: 'oeil',
    prix: 1.8,
  ),
  Technologie(
    id: 'recursif', ere: 14, nom: 'Auto-amélioration',
    cout: 1.700000000000e18, effet: 'Production ×3', icone: 'spirale',
    production: 3,
  ),
];
