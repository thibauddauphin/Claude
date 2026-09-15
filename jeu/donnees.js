/* Silicium & Cie — tables de données du jeu */
window.SC = window.SC || {};

SC.ERES = [
  {an:"1975", nom:"Le garage",              decor:"garage"},
  {an:"1979", nom:"Le micro au foyer",      decor:"salon"},
  {an:"1984", nom:"Guerre des compatibles", decor:"bureau"},
  {an:"1991", nom:"L'informatique nomade",  decor:"openspace"},
  {an:"1997", nom:"La ruée vers le Web",    decor:"loft"},
  {an:"2007", nom:"Tout dans la poche",     decor:"showroom"},
  {an:"2012", nom:"Le nuage",               decor:"datacenter"},
  {an:"2023", nom:"L'âge des modèles",      decor:"hall"}
];

/* prix : prix de vente unitaire · comps : composants consommés · pc : prix du composant · rnd : points R&D par unité */
SC.PRODUITS = [
  {an:"1975", nom:"Kit à souder 8 bits", prix:14, comps:1, pc:3, rnd:.12,
   desc:"Un sachet de circuits, une notice ronéotypée. Le client soude lui-même — et adore ça."},
  {an:"1979", nom:"Micro familial", prix:110, comps:4, pc:8, rnd:.3,
   desc:"Clavier intégré, sortie télé, 4 ko de mémoire. Vendu au rayon hi-fi des grands magasins."},
  {an:"1984", nom:"Compatible PC", prix:720, comps:10, pc:22, rnd:.8,
   desc:"Le même bus, le même jeu d'instructions, moitié prix. Les services achats adorent."},
  {an:"1991", nom:"Portable à écran LCD", prix:3800, comps:24, pc:48, rnd:2,
   desc:"6,8 kg, deux heures d'autonomie, une poignée renforcée. On appelle ça la mobilité."},
  {an:"1997", nom:"Serveur web 1U", prix:21000, comps:70, pc:120, rnd:6,
   desc:"Vendu par baies entières à des jeunes pousses qui n'ont pas encore de chiffre d'affaires."},
  {an:"2007", nom:"Téléphone à dalle tactile", prix:120000, comps:180, pc:300, rnd:16,
   desc:"Lot revendeur de quarante unités. La marge se fait désormais sur la boutique d'applications."},
  {an:"2012", nom:"Offre cloud (baie louée)", prix:750000, comps:480, pc:700, rnd:45,
   desc:"On ne vend plus des machines, on vend des heures. Contrat annuel, facturé à la seconde."},
  {an:"2023", nom:"Grappe d'accélérateurs", prix:5200000, comps:1400, pc:1800, rnd:130,
   desc:"Huit cartes, une baie, une facture d'électricité de PME. Livraison en dix-huit mois."}
];

SC.STATIONS = [
  {nom:"Établi de garage",      det:"Votre table de cuisine, réquisitionnée.",   base:45,       taux:.15},
  {nom:"Stagiaire en BTS",      det:"Soude vite, se trompe parfois.",            base:320,      taux:.8},
  {nom:"Technicien d'atelier",  det:"Quinze ans de métier, zéro reprise.",       base:2600,     taux:3.5},
  {nom:"Chaîne d'assemblage",   det:"Tapis roulant, postes en série.",           base:21000,    taux:15},
  {nom:"Usine sous-traitée",    det:"Trois équipes, deux fuseaux horaires.",     base:170000,   taux:65},
  {nom:"Robot de pose CMS",     det:"12 000 composants placés à l'heure.",       base:1400000,  taux:280},
  {nom:"Ferme de serveurs",     det:"Provisionnement automatique des baies.",    base:12000000, taux:1200},
  {nom:"Ordonnanceur autonome", det:"Décide seul de la production du jour.",     base:95000000, taux:5000}
];

/* ouvre : indice de gamme débloquée · prod/prix/rnd : multiplicateurs permanents */
SC.TECHS = [
  {id:"fer",    nom:"Fer thermorégulé",       cout:6,     eff:"Assemblage manuel ×4",              icone:"fer"},
  {id:"mos",    nom:"Transistor MOS",         cout:26,    eff:"Micro familial · production ×1,25", icone:"puce",   ouvre:1, prod:1.25},
  {id:"pcb",    nom:"Circuit double face",    cout:70,    eff:"−25 % de composants par unité",     icone:"carte"},
  {id:"appro",  nom:"Approvisionnement auto", cout:150,   eff:"Rachète les composants toute seule",icone:"carton"},
  {id:"gui",    nom:"Interface graphique",    cout:280,   eff:"Compatible PC · prix ×1,3",         icone:"souris", ouvre:2, prix:1.3},
  {id:"logi",   nom:"Entrepôt central",       cout:420,   eff:"Composants −20 %",                  icone:"palette"},
  {id:"hdd",    nom:"Disque dur 10 Mo",       cout:620,   eff:"Portable à écran LCD",              icone:"disque", ouvre:3},
  {id:"bus",    nom:"Bus d'extension",        cout:950,   eff:"Production ×1,4",                   icone:"bus",    prod:1.4},
  {id:"sav",    nom:"Service après-vente",    cout:1300,  eff:"Crises de marché deux fois moins dures", icone:"casque"},
  {id:"modem",  nom:"Modem 56 k",             cout:1700,  eff:"Serveur web 1U",                    icone:"modem",  ouvre:4},
  {id:"marque", nom:"Campagne de marque",     cout:2600,  eff:"Prix ×1,5 · conquête accélérée",    icone:"megaphone", prix:1.5},
  {id:"arm",    nom:"Puce à faible conso",    cout:4800,  eff:"Téléphone à dalle tactile",         icone:"puce2",  ouvre:5},
  {id:"virtu",  nom:"Virtualisation",         cout:12000, eff:"Offre cloud",                       icone:"nuage",  ouvre:6},
  {id:"gpu",    nom:"Calcul parallèle",       cout:22000, eff:"Production ×2",                     icone:"gpu",    prod:2},
  {id:"nn",     nom:"Réseaux de neurones",    cout:48000, eff:"Grappe d'accélérateurs",            icone:"reseau", ouvre:7}
];

/* cle : prix · prod · rnd · comp — v : multiplicateur appliqué pendant la durée */
SC.EVENEMENTS = [
  {n:"Pénurie de mémoire",      e:"Composants ×2,2",     cle:"comp", v:2.2, bon:false},
  {n:"Rentrée scolaire",        e:"Prix de vente ×1,8",  cle:"prix", v:1.8, bon:true},
  {n:"Grève des transporteurs", e:"Production ×0,55",    cle:"prod", v:.55, bon:false},
  {n:"Banc d'essai élogieux",   e:"Prix de vente ×2,2",  cle:"prix", v:2.2, bon:true},
  {n:"Salon de l'informatique", e:"Points R&D ×3",       cle:"rnd",  v:3,   bon:true},
  {n:"Faille de sécurité",      e:"Prix de vente ×0,6",  cle:"prix", v:.6,  bon:false},
  {n:"Marché public signé",     e:"Production ×1,7",     cle:"prod", v:1.7, bon:true},
  {n:"Guerre des prix",         e:"Prix de vente ×0,7",  cle:"prix", v:.7,  bon:false},
  {n:"Rupture chez le fondeur", e:"Production ×0,6",     cle:"prod", v:.6,  bon:false},
  {n:"Commande d'un ministère", e:"Prix de vente ×1,6",  cle:"prix", v:1.6, bon:true}
];

/* p : puissance commerciale initiale · c : croissance par seconde */
SC.CONCURRENTS = [
  {nom:"Béta-Tronic",   p:2100, c:.0034, col:"--rival-1"},
  {nom:"Mégabit SA",    p:1400, c:.0031, col:"--rival-2"},
  {nom:"Nordisk Data",  p:800,  c:.0029, col:"--rival-3"},
  {nom:"Cortex Systems",p:400,  c:.0040, col:"--rival-4"}
];
