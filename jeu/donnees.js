/* Silicium & Cie — tables de données du jeu */
window.SC = window.SC || {};

SC.ERES = [
  {an:"1975", nom:"Le garage",                decor:"garage"},
  {an:"1979", nom:"Le micro au foyer",        decor:"salon"},
  {an:"1982", nom:"La télématique",           decor:"minitel"},
  {an:"1984", nom:"Guerre des compatibles",   decor:"bureau"},
  {an:"1991", nom:"L'informatique nomade",    decor:"openspace"},
  {an:"1995", nom:"Le multimédia",            decor:"multimedia"},
  {an:"1997", nom:"La ruée vers le Web",      decor:"loft"},
  {an:"2000", nom:"L'éclatement de la bulle", decor:"bulle"},
  {an:"2004", nom:"Le haut débit",            decor:"habitat"},
  {an:"2007", nom:"Tout dans la poche",       decor:"showroom"},
  {an:"2012", nom:"Le nuage",                 decor:"datacenter"},
  {an:"2016", nom:"L'objet connecté",         decor:"objets"},
  {an:"2023", nom:"L'âge des modèles",        decor:"hall"},
  {an:"2031", nom:"Le calcul quantique",      decor:"quantique"},
  {an:"2040", nom:"Le substrat neuromorphique", decor:"neuro"}
];

/* prix : prix de vente · comps : composants par unité · pc : prix du composant · rnd : points R&D par unité · img : sprite */
SC.PRODUITS = [
  {an:"1975", nom:"Kit à souder 8 bits", prix:14, comps:1, pc:5, rnd:.1, img:0,
   desc:"Un sachet de circuits, une notice ronéotypée. Le client soude lui-même — et adore ça."},
  {an:"1979", nom:"Micro familial", prix:110, comps:4, pc:10, rnd:.18, img:1,
   desc:"Clavier intégré, sortie télé, 4 ko de mémoire. Vendu au rayon hi-fi des grands magasins."},
  {an:"1982", nom:"Terminal télématique", prix:850, comps:9, pc:33, rnd:.32, img:2,
   desc:"Distribué gratuitement, facturé à la minute. L'annuaire devient un marché."},
  {an:"1984", nom:"Compatible PC", prix:6400, comps:20, pc:112, rnd:.58, img:3,
   desc:"Le même bus, le même jeu d'instructions, moitié prix. Les services achats adorent."},
  {an:"1991", nom:"Portable à écran LCD", prix:48000, comps:45, pc:373, rnd:1.05, img:4,
   desc:"6,8 kg, deux heures d'autonomie, une poignée renforcée. On appelle ça la mobilité."},
  {an:"1995", nom:"Station multimédia", prix:360000, comps:110, pc:1145, rnd:1.9, img:5,
   desc:"Carte son, lecteur de disques, encyclopédie offerte. La machine familiale sait parler."},
  {an:"1997", nom:"Serveur web 1U", prix:2700000, comps:260, pc:3635, rnd:3.4, img:6,
   desc:"Vendu par baies entières à des jeunes pousses qui n'ont pas encore de chiffre d'affaires."},
  {an:"2000", nom:"Baie d'hébergement", prix:20000000, comps:620, pc:11290, rnd:6.1, img:7,
   desc:"Les jeunes pousses ont disparu, les baies restent. On les reloue au mètre."},
  {an:"2004", nom:"Box haut débit", prix:150000000, comps:1500, pc:35000, rnd:11, img:8,
   desc:"Un boîtier par foyer, un abonnement par boîtier. Le modèle a changé de camp."},
  {an:"2007", nom:"Téléphone à dalle tactile", prix:1100000000, comps:3600, pc:107000, rnd:20, img:9,
   desc:"Lot revendeur de quarante unités. La marge se fait désormais sur la boutique d'applications."},
  {an:"2012", nom:"Offre cloud (baie louée)", prix:8000000000, comps:8600, pc:325000, rnd:36, img:10,
   desc:"On ne vend plus des machines, on vend des heures. Contrat annuel, facturé à la seconde."},
  {an:"2016", nom:"Capteur connecté", prix:60000000000, comps:21000, pc:1000000, rnd:64, img:11,
   desc:"Quatre euros pièce, cent millions de pièces. La valeur est dans ce qu'ils racontent."},
  {an:"2023", nom:"Grappe d'accélérateurs", prix:450000000000, comps:50000, pc:3150000, rnd:115, img:12,
   desc:"Huit cartes, une baie, une facture d'électricité de PME. Livraison en dix-huit mois."},
  {an:"2031", nom:"Calculateur quantique", prix:3400000000000, comps:120000, pc:9900000, rnd:208, img:13,
   desc:"Un lustre de cuivre à quinze millikelvins. On loue la milliseconde, pas la machine."},
  {an:"2040", nom:"Substrat neuromorphique", prix:25000000000000, comps:290000, pc:30000000, rnd:375, img:14,
   desc:"Ni processeur ni mémoire : un matériau qui apprend. On le cultive plus qu'on ne le fabrique."}
];

/* base : coût du premier exemplaire · taux : unités par seconde · img : vignette de scène */
SC.STATIONS = [
  {nom:"Établi de garage",       det:"Votre table de cuisine, réquisitionnée.",    base:45,           taux:.15,     img:0},
  {nom:"Stagiaire en BTS",       det:"Soude vite, se trompe parfois.",             base:380,          taux:.7,      img:1},
  {nom:"Technicien d'atelier",   det:"Quinze ans de métier, zéro reprise.",        base:3200,         taux:3,       img:2},
  {nom:"Chaîne d'assemblage",    det:"Tapis roulant, postes en série.",            base:27000,        taux:13,      img:3},
  {nom:"Atelier sous-traité",    det:"Trois équipes, deux fuseaux horaires.",      base:230000,       taux:55,      img:4},
  {nom:"Usine intégrée",         det:"Du lingot au carton, sous un seul toit.",    base:1900000,      taux:230,     img:5},
  {nom:"Robot de pose CMS",      det:"12 000 composants placés à l'heure.",        base:16000000,     taux:980,     img:6},
  {nom:"Ligne automatisée",      det:"Aucune main humaine entre l'entrée et la sortie.", base:140000000, taux:4100, img:7},
  {nom:"Ferme de serveurs",      det:"Provisionnement automatique des baies.",     base:1200000000,   taux:17000,   img:8},
  {nom:"Fonderie dédiée",        det:"Salle blanche, gravure maison.",             base:10000000000,  taux:72000,   img:9},
  {nom:"Ordonnanceur autonome",  det:"Décide seul de la production du jour.",      base:85000000000,  taux:300000,  img:10},
  {nom:"Essaim d'usines noires", det:"Des halls sans lumière, répliqués à la demande.", base:720000000000, taux:1300000, img:11}
];

/* ere : rangée d'affichage · ouvre : gamme débloquée · prod/prix : multiplicateurs · conq : conquête */
SC.TECHS = [
  {id:"fer",        ere:0,  nom:"Fer thermorégulé",          cout:13,        eff:"Assemblage manuel ×4",            icone:"fer"},
  {id:"pcb",        ere:0,  nom:"Circuit imprimé double face",cout:54,      eff:"−20 % de composants par unité",   icone:"carte"},
  {id:"mos",        ere:0,  nom:"Transistor MOS",            cout:130,       eff:"Micro familial · production ×1,25", icone:"puce", ouvre:1, prod:1.25},

  {id:"appro",      ere:1,  nom:"Approvisionnement automatique", cout:1200,  eff:"Rachète les composants toute seule", icone:"carton"},
  {id:"clavier",    ere:1,  nom:"Clavier mécanique",         cout:2900,      eff:"Prix ×1,2",                       icone:"clavier", prix:1.2},
  {id:"v23",        ere:1,  nom:"Modem V.23",                cout:6200,      eff:"Terminal télématique",            icone:"modem",  ouvre:2},

  {id:"annuaire",   ere:2,  nom:"Annuaire électronique",     cout:1900000,     eff:"Conquête du marché ×1,2",         icone:"livre",  conq:1.2},
  {id:"logi",       ere:2,  nom:"Entrepôt central",          cout:3400000,     eff:"−20 % de composants",             icone:"palette"},
  {id:"bus16",      ere:2,  nom:"Bus 16 bits",               cout:6700000,     eff:"Compatible PC · production ×1,3", icone:"bus",    ouvre:3, prod:1.3},

  {id:"gui",        ere:3,  nom:"Interface graphique",       cout:2200000000,     eff:"Prix ×1,3",                       icone:"souris", prix:1.3},
  {id:"lan",        ere:3,  nom:"Réseau local",              cout:4200000000,    eff:"Production ×1,4",                 icone:"reseau", prod:1.4},
  {id:"lcd",        ere:3,  nom:"Écran à cristaux liquides", cout:8000000000,    eff:"Portable à écran LCD",            icone:"ecran",  ouvre:4},

  {id:"lithium",    ere:4,  nom:"Batterie lithium-ion",      cout:52000000000,    eff:"Prix ×1,25",                      icone:"pile",   prix:1.25},
  {id:"sav",        ere:4,  nom:"Service après-vente",       cout:91000000000,   eff:"Crises de marché deux fois moins dures", icone:"casque"},
  {id:"cdrom",      ere:4,  nom:"Lecteur de disques optiques", cout:160000000000, eff:"Station multimédia",              icone:"disque", ouvre:5},

  {id:"accel3d",    ere:5,  nom:"Accélérateur 3D",           cout:250000000000,   eff:"Production ×1,5",                 icone:"gpu",    prod:1.5},
  {id:"marque",     ere:5,  nom:"Campagne de marque",        cout:440000000000,   eff:"Prix ×1,5 · conquête ×1,25",      icone:"megaphone", prix:1.5, conq:1.25},
  {id:"tcpip",      ere:5,  nom:"Pile TCP/IP",               cout:750000000000,  eff:"Serveur web 1U",                  icone:"prise",  ouvre:6},

  {id:"colo",       ere:6,  nom:"Hébergement en colocation", cout:1400000000000,  eff:"Production ×1,4",                 icone:"baie",   prod:1.4},
  {id:"ssl",        ere:6,  nom:"Chiffrement de bout en bout", cout:2600000000000,eff:"Prix ×1,3",                       icone:"cadenas",prix:1.3},
  {id:"cotation",   ere:6,  nom:"Cotation au nouveau marché",cout:4700000000000,  eff:"Baie d'hébergement",              icone:"courbe", ouvre:7},

  {id:"restruct",   ere:7,  nom:"Plan de restructuration",   cout:5400000000000, eff:"Moyens de production −15 %",      icone:"ciseaux"},
  {id:"fibre",      ere:7,  nom:"Fibre optique",             cout:10000000000000, eff:"Production ×1,5",                 icone:"fibre",  prod:1.5},
  {id:"degroupage", ere:7,  nom:"Dégroupage de la boucle locale", cout:18000000000000, eff:"Box haut débit",             icone:"prise",  ouvre:8},

  {id:"cdn",        ere:8,  nom:"Réseau de distribution",    cout:21000000000000, eff:"Conquête du marché ×1,3",         icone:"globe",  conq:1.3},
  {id:"wifi",       ere:8,  nom:"Puce sans fil",             cout:36000000000000,eff:"Prix ×1,3",                       icone:"onde",   prix:1.3},
  {id:"arm",        ere:8,  nom:"Puce à faible consommation",cout:63000000000000,eff:"Téléphone à dalle tactile",       icone:"puce2",  ouvre:9},

  {id:"boutique",   ere:9,  nom:"Boutique d'applications",   cout:69000000000000,eff:"Prix ×1,6",                       icone:"sac",    prix:1.6},
  {id:"capacitif",  ere:9,  nom:"Dalle capacitive multipoint",cout:120000000000000,eff:"Production ×1,5",                icone:"doigt",  prod:1.5},
  {id:"virtu",      ere:9,  nom:"Virtualisation",            cout:220000000000000, eff:"Offre cloud",                   icone:"nuage",  ouvre:10},

  {id:"conteneur",  ere:10, nom:"Conteneurisation",          cout:370000000000000, eff:"Production ×1,6",               icone:"boite",  prod:1.6},
  {id:"edge",       ere:10, nom:"Calcul en périphérie",      cout:680000000000000, eff:"Prix ×1,4",                     icone:"antenne",prix:1.4},
  {id:"lpwan",      ere:10, nom:"Radio basse consommation",  cout:1200000000000000, eff:"Capteur connecté",              icone:"onde",   ouvre:11},

  {id:"flotte",     ere:11, nom:"Gestion de flotte",         cout:2100000000000000, eff:"Production ×1,5",              icone:"carte2", prod:1.5},
  {id:"gpu",        ere:11, nom:"Calcul parallèle",          cout:3800000000000000, eff:"Production ×2",                icone:"gpu",    prod:2},
  {id:"nn",         ere:11, nom:"Réseaux de neurones",       cout:7000000000000000, eff:"Grappe d'accélérateurs",       icone:"neurone",ouvre:12},

  {id:"inference",  ere:12, nom:"Optimisation de l'inférence", cout:13000000000000000, eff:"Prix ×1,5",                  icone:"eclair", prix:1.5},
  {id:"immersion",  ere:12, nom:"Refroidissement immersif",  cout:24000000000000000, eff:"Production ×1,7",             icone:"goutte", prod:1.7},
  {id:"qubit",      ere:12, nom:"Qubit supraconducteur",     cout:40000000000000000, eff:"Calculateur quantique",       icone:"atome",  ouvre:13},

  {id:"correction", ere:13, nom:"Correction d'erreurs",      cout:82000000000000000, eff:"Production ×2",               icone:"bouclier", prod:2},
  {id:"cryo",       ere:13, nom:"Cryogénie industrielle",    cout:140000000000000000, eff:"Prix ×1,6",                   icone:"flocon", prix:1.6},
  {id:"memristor",  ere:13, nom:"Memristor",                 cout:270000000000000000, eff:"Substrat neuromorphique",    icone:"spirale",ouvre:14},

  {id:"plasticite", ere:14, nom:"Plasticité synthétique",    cout:530000000000000000, eff:"Production ×2,2",            icone:"neurone",prod:2.2},
  {id:"autoconcep", ere:14, nom:"Conception autonome",       cout:960000000000000000, eff:"Prix ×1,8",                  icone:"oeil",   prix:1.8},
  {id:"recursif",   ere:14, nom:"Auto-amélioration",         cout:1700000000000000000, eff:"Production ×3",              icone:"spirale",prod:3}
];

/* cle : prix · prod · rnd · comp — v : multiplicateur pendant la durée */
SC.EVENEMENTS = [
  {n:"Pénurie de mémoire",         e:"Composants ×2,2",    cle:"comp", v:2.2, bon:false},
  {n:"Rentrée scolaire",           e:"Prix de vente ×1,8", cle:"prix", v:1.8, bon:true},
  {n:"Grève des transporteurs",    e:"Production ×0,55",   cle:"prod", v:.55, bon:false},
  {n:"Banc d'essai élogieux",      e:"Prix de vente ×2,2", cle:"prix", v:2.2, bon:true},
  {n:"Salon de l'informatique",    e:"Points R&D ×3",      cle:"rnd",  v:3,   bon:true},
  {n:"Faille de sécurité",         e:"Prix de vente ×0,6", cle:"prix", v:.6,  bon:false},
  {n:"Marché public signé",        e:"Production ×1,7",    cle:"prod", v:1.7, bon:true},
  {n:"Guerre des prix",            e:"Prix de vente ×0,7", cle:"prix", v:.7,  bon:false},
  {n:"Rupture chez le fondeur",    e:"Production ×0,6",    cle:"prod", v:.6,  bon:false},
  {n:"Commande d'un ministère",    e:"Prix de vente ×1,6", cle:"prix", v:1.6, bon:true},
  {n:"Spéculation sur le cuivre",  e:"Composants ×1,9",    cle:"comp", v:1.9, bon:false},
  {n:"Norme adoptée par le secteur", e:"Points R&D ×2,5",  cle:"rnd",  v:2.5, bon:true},
  {n:"Panne du réseau électrique", e:"Production ×0,45",   cle:"prod", v:.45, bon:false},
  {n:"Effet de mode",              e:"Prix de vente ×2,5", cle:"prix", v:2.5, bon:true}
];

/* p : puissance de départ · poids : part visée de votre propre puissance
   rattrapage : vitesse à laquelle le rival comble son retard · c : croissance de fond */
SC.CONCURRENTS = [
  {nom:"Béta-Tronic",    p:2100, poids:.55, rattrapage:.0035, c:.00008},
  {nom:"Mégabit SA",     p:1400, poids:.38, rattrapage:.0030, c:.00007},
  {nom:"Nordisk Data",   p:800,  poids:.22, rattrapage:.0026, c:.00006},
  {nom:"Cortex Systems", p:400,  poids:.12, rattrapage:.0045, c:.00010}
];

/* Jalons : chaque succès accorde un bonus permanent de production. */
SC.JALONS = [
  {id:"u1",   nom:"Premier client",          desc:"Vendre 100 unités",              cle:"unites", seuil:1e2,  bonus:.02},
  {id:"u2",   nom:"Bouche-à-oreille",        desc:"Vendre 10 000 unités",           cle:"unites", seuil:1e4,  bonus:.02},
  {id:"u3",   nom:"Catalogue par correspondance", desc:"Vendre 1 million d'unités", cle:"unites", seuil:1e6,  bonus:.03},
  {id:"u4",   nom:"Référencé en grande surface", desc:"Vendre 100 millions d'unités", cle:"unites", seuil:1e8, bonus:.03},
  {id:"u5",   nom:"Standard du marché",      desc:"Vendre 10 milliards d'unités",   cle:"unites", seuil:1e10, bonus:.04},
  {id:"u6",   nom:"Équipementier mondial",   desc:"Vendre 1 000 milliards d'unités",cle:"unites", seuil:1e12, bonus:.04},
  {id:"u7",   nom:"Infrastructure planétaire", desc:"Vendre 10¹⁵ unités",           cle:"unites", seuil:1e15, bonus:.05},

  {id:"c1",   nom:"Premier bilan à l'équilibre", desc:"10 000 € de chiffre d'affaires", cle:"ca", seuil:1e4,  bonus:.02},
  {id:"c2",   nom:"Premier million",         desc:"1 M€ de chiffre d'affaires",     cle:"ca",     seuil:1e6,  bonus:.02},
  {id:"c3",   nom:"Entrée au classement",    desc:"1 Md€ de chiffre d'affaires",    cle:"ca",     seuil:1e9,  bonus:.03},
  {id:"c4",   nom:"Poids lourd du secteur",  desc:"1 000 Md€ de chiffre d'affaires",cle:"ca",     seuil:1e12, bonus:.04},
  {id:"c5",   nom:"Première capitalisation mondiale", desc:"10¹⁵ € de chiffre d'affaires", cle:"ca", seuil:1e15, bonus:.05},
  {id:"c6",   nom:"Hors catégorie",          desc:"10¹⁸ € de chiffre d'affaires",   cle:"ca",     seuil:1e18, bonus:.06},

  {id:"s1",   nom:"L'atelier s'agrandit",    desc:"25 moyens de production",        cle:"stations", seuil:25,  bonus:.02},
  {id:"s2",   nom:"Directeur industriel",    desc:"100 moyens de production",       cle:"stations", seuil:100, bonus:.03},
  {id:"s3",   nom:"Parc intégré",            desc:"250 moyens de production",       cle:"stations", seuil:250, bonus:.04},
  {id:"s4",   nom:"Capacité continentale",   desc:"500 moyens de production",       cle:"stations", seuil:500, bonus:.05},
  {id:"s5",   nom:"Tout est automatisé",     desc:"1 000 moyens de production",     cle:"stations", seuil:1000,bonus:.06},

  {id:"t1",   nom:"Premier brevet",          desc:"5 technologies acquises",        cle:"techs",  seuil:5,    bonus:.02},
  {id:"t2",   nom:"Département recherche",   desc:"15 technologies acquises",       cle:"techs",  seuil:15,   bonus:.03},
  {id:"t3",   nom:"Laboratoire central",     desc:"30 technologies acquises",       cle:"techs",  seuil:30,   bonus:.04},
  {id:"t4",   nom:"État de l'art",           desc:"Les 45 technologies",            cle:"techs",  seuil:45,   bonus:.08},

  {id:"p1",   nom:"On nous remarque",        desc:"25 % de part de marché",         cle:"part",   seuil:25,   bonus:.03},
  {id:"p2",   nom:"Leader du secteur",       desc:"50 % de part de marché",         cle:"part",   seuil:50,   bonus:.04},
  {id:"p3",   nom:"Position dominante",      desc:"75 % de part de marché",         cle:"part",   seuil:75,   bonus:.05},
  {id:"p4",   nom:"Enquête de la Commission",desc:"90 % de part de marché",         cle:"part",   seuil:90,   bonus:.06},

  {id:"e1",   nom:"Le micro entre au foyer", desc:"Atteindre 1979",                 cle:"ere",    seuil:1,    bonus:.02},
  {id:"e2",   nom:"Compatible et fier",      desc:"Atteindre 1984",                 cle:"ere",    seuil:3,    bonus:.03},
  {id:"e3",   nom:"Survivre à la bulle",     desc:"Atteindre 2000",                 cle:"ere",    seuil:7,    bonus:.04},
  {id:"e4",   nom:"Le nuage nous appartient",desc:"Atteindre 2012",                 cle:"ere",    seuil:10,   bonus:.05},
  {id:"e5",   nom:"Au-delà du silicium",     desc:"Atteindre 2040",                 cle:"ere",    seuil:14,   bonus:.08},

  {id:"a1",   nom:"Première cotation",       desc:"Une introduction en bourse",     cle:"ipo",    seuil:1,    bonus:.04},
  {id:"a2",   nom:"Actionnaire de référence",desc:"500 actions détenues",           cle:"actions",seuil:500,  bonus:.06},
  {id:"a3",   nom:"Fondateur de conglomérat",desc:"Une part de holding",            cle:"parts",  seuil:1,    bonus:.10}
];

/* Méta-améliorations du conglomérat, payées en parts de holding. */
SC.HOLDING = [
  {id:"heritage", nom:"Héritage industriel", cout:2,  eff:"Chaque partie démarre avec 10 établis et 5 stagiaires."},
  {id:"carnet",   nom:"Carnet d'adresses",   cout:3,  eff:"Les technologies coûtent 20 % de points R&D en moins."},
  {id:"guerre",   nom:"Trésorerie de guerre",cout:5,  eff:"Chaque partie démarre avec 1 M€ et 100 000 composants."},
  {id:"integree", nom:"Filière intégrée",    cout:8, eff:"Composants 35 % moins chers, définitivement."},
  {id:"labo",     nom:"Institut de recherche",cout:11,eff:"Points R&D ×2."},
  {id:"monopole", nom:"Position installée",  cout:15, eff:"La concurrence croît 40 % moins vite."},
  {id:"cadence",  nom:"Doctrine de la cadence", cout:20, eff:"Production ×3."},
  {id:"empire",   nom:"Empire industriel",   cout:26, eff:"Production et prix ×2, et une action offerte par minute."}
];

/* Prénoms par génération : l'atelier recrute dans son époque. */
SC.PRENOMS = [
  ["Jean-Claude","Michèle","Patrick","Martine","Gérard","Chantal","Bernard","Nicole","Alain","Dominique","Roland","Françoise"],
  ["Sébastien","Aurélie","Nicolas","Céline","Julien","Sandrine","Fabrice","Nathalie","Karim","Stéphanie","Laurent","Valérie"],
  ["Thomas","Marion","Kévin","Laura","Mehdi","Élodie","Anthony","Camille","Youssef","Charlotte","Maxime","Inès"],
  ["Lucas","Emma","Nathan","Léa","Rayan","Jade","Enzo","Louise","Ibrahim","Alice","Noé","Anaïs"]
];
SC.NOMS = [
  "Bertrand","Lemoine","Fontaine","Vasseur","Marchand","Perrot","Nguyen","Lopes","Benali","Charrier",
  "Delaunay","Ruiz","Kowalski","Mercier","Hamon","Tessier","Bonnet","Rey","Sow","Andrieu",
  "Ferreira","Chevalier","Lagarde","Moreau","Dufour","Barbier","Guillon","Rousset"
];

/* Caractères : ce que la personne apporte, et ce qu'elle coûte.
   part : sa rémunération, en fraction du chiffre d'affaires. */
SC.CARACTERES = [
  {id:"soudure",     nom:"Doigts d'or",            eff:"Production +12 %",                        prod:1.12, part:0.018},
  {id:"nego",        nom:"Négociation née",        eff:"Composants −12 %",                        comp:.88,  part:0.016},
  {id:"systeme",     nom:"Tête de système",        eff:"Points R&D +20 %",                        rnd:1.20,  part:0.02},
  {id:"commerce",    nom:"Sens du commerce",       eff:"Prix de vente +9 %",                      prix:1.09, part:0.02},
  {id:"logistique",  nom:"Méthode logistique",     eff:"Production +7 %, composants −6 %",        prod:1.07, comp:.94, part:0.018},
  {id:"perfection",  nom:"Perfectionnisme",        eff:"Prix +14 %, production −5 %",             prix:1.14, prod:.95, part:0.018},
  {id:"formation",   nom:"Goût de transmettre",    eff:"L'usure du moral de l'équipe est divisée par deux", moral:.5, part:0.016},
  {id:"autodidacte", nom:"Autodidacte",            eff:"Points R&D +12 %, production +5 %",       rnd:1.12,  prod:1.05, part:0.022},
  {id:"endurance",   nom:"Increvable",             eff:"Production +9 %, ne réclame jamais rien", prod:1.09, stoique:true, part:0.014},
  {id:"influence",   nom:"Carnet d'adresses",      eff:"Conquête du marché +15 %",                conq:1.15, part:0.018}
];

/* Motifs de départ, tirés selon les conditions du moment. */
SC.DEPARTS = [
  "a rendu son tablier : « on brade, je ne suis plus payé à ma valeur ».",
  "part chez Béta-Tronic, qui proposait mieux.",
  "claque la porte après trois semaines de chaîne à l'arrêt.",
  "démissionne : « je passe mes journées à attendre les composants ».",
  "s'en va monter son propre atelier.",
  "prend la porte sans un mot. Le badge est resté sur l'établi."
];
