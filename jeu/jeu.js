/* Silicium & Cie — règles, économie, concurrence, prestige. Aucune dépendance au DOM. */
(function(){
"use strict";

var CLE = "silicium-cie-v3";
var PLAFOND_HORS_LIGNE = 12*3600;   /* 12 h de production accumulée au maximum */
var RENDEMENT_HORS_LIGNE = .6;      /* l'atelier tourne au ralenti en votre absence */
var PART_BRICOLAGE = .3;            /* une unité montée sans composants vaut moins cher */
var PART_MAIN = .5;                 /* ce qu'une paire de mains vaut face à la meilleure machine */

/* Ce qui survit à une remise à zéro : le palmarès et le patrimoine. */
function permanent(S){
  return {
    actions: S ? S.actions : 0,
    parts:   S ? S.parts : 0,
    holding: S ? Object.assign({}, S.holding) : {},
    jalons:  S ? Object.assign({}, S.jalons) : {},
    caVie:   S ? S.caVie : 0,
    ipos:    S ? S.ipos : 0,
    congs:   S ? S.congs : 0,
    debut:   S ? S.debut : Date.now(),
    joue:    S ? S.joue : 0
  };
}

function neuve(perm){
  perm = perm || permanent(null);
  var S = {
    cash:30, comps:12, rnd:0,
    stations:SC.STATIONS.map(function(){ return 0; }),
    techs:{},
    gamme:0,
    marge:1,
    unites:0, ca:0, puissance:0,
    rivaux:SC.CONCURRENTS.map(function(r){ return r.p; }),
    buf:0, ev:null, horlogeEv:24 + Math.random()*26,
    equipe:[], candidat:null, horlogeCandidat:40, retraites:0,
    hist:new Array(60).fill(0),
    journal:[],
    majSauvegarde:Date.now()
  };
  Object.keys(perm).forEach(function(k){ S[k] = perm[k]; });

  /* dotations du conglomérat */
  if(S.holding.heritage){ S.stations[0] = 10; S.stations[1] = 5; }
  if(S.holding.guerre){ S.cash = 1e6; S.comps = 1e5; }
  return S;
}

/* Partie de démonstration : l'atelier tourne déjà, quelques mois d'activité en 1975. */
function demo(){
  var s = neuve(null);
  s.cash = 1240; s.comps = 340; s.rnd = 33;
  s.stations[0] = 4; s.stations[1] = 2;
  s.techs.fer = true;
  s.unites = 465; s.ca = 5910; s.caVie = 5910; s.puissance = 465;
  s.hist = Array.from({length:60}, function(_,i){
    return Math.max(0, 14 + i*.16 + Math.sin(i/4)*3.4 + (i%7===0 ? 2.5 : 0));
  });
  s.journal = [
    {an:"1975", txt:"Première commande groupée d'un club d'informatique : quarante kits."},
    {an:"1975", txt:"Fer thermorégulé acheté d'occasion. Les soudures tiennent."},
    {an:"1975", txt:"Deux stagiaires recrutés : l'établi ne suffisait plus."}
  ];
  return s;
}

function a(S,id){ return !!S.techs[id]; }
function h(S,id){ return !!S.holding[id]; }

var CARACTERE = SC.CARACTERES.reduce(function(m,c){ m[c.id] = c; return m; }, {});
var ANNEES_PAR_SECONDE = 1/360;      /* une année de carrière toutes les six minutes */

/* Les binômes : deux personnes appariées majorent de moitié ce que chacune
   apporte, et certaines paires de caractères ouvrent une synergie nommée. */
function partenaire(S, e){
  if(!e.binome) return null;
  for(var i=0;i<S.equipe.length;i++) if(S.equipe[i].graine === e.binome) return S.equipe[i];
  return null;
}
function synergie(a, b){
  if(!a || !b) return null;
  for(var i=0;i<SC.SYNERGIES.length;i++){
    var y = SC.SYNERGIES[i];
    if((y.a === a.car && y.b === b.car) || (y.a === b.car && y.b === a.car)) return y;
  }
  return null;
}
function paires(S){
  var vues = {}, out = [];
  for(var i=0;i<S.equipe.length;i++){
    var e = S.equipe[i];
    if(!e.binome || vues[e.graine]) continue;
    var p = partenaire(S, e);
    if(!p) continue;
    vues[e.graine] = vues[p.graine] = true;
    out.push([e, p]);
  }
  return out;
}

/* Un employé rend d'autant mieux qu'il a le moral : à plat, il ne donne plus
   que 40 % de ce qu'il apporte. */
function multEquipe(S, cle){
  var m = 1;
  for(var i=0;i<S.equipe.length;i++){
    var e = S.equipe[i], c = CARACTERE[e.car];
    if(!c || !c[cle]) continue;
    var force = (.4 + .6*Math.max(0, Math.min(100, e.moral))/100);
    if(e.binome && partenaire(S, e)) force *= 1.5;
    m *= 1 + (c[cle] - 1) * force;
  }
  var ps = paires(S);
  for(var k=0;k<ps.length;k++){
    var y = synergie(ps[k][0], ps[k][1]);
    if(y && y[cle]) m *= y[cle];
  }
  return m;
}
/* chaque départ à la retraite laisse un savoir-faire derrière lui */
function heritage(S){ return 1 + Math.min(.3, (S.retraites || 0) * .015); }
function masseSalariale(S){
  var t = 0;
  for(var i=0;i<S.equipe.length;i++) t += S.equipe[i].part;
  return Math.min(.6, t);
}
function placesEquipe(S){
  return 3 + Math.floor(ereIndex(S)/2) + (h(S,"empire") ? 3 : 0);
}

/* ----------------------------- multiplicateurs ----------------------------- */

function bonusJalons(S){
  var b = 0;
  for(var i=0;i<SC.JALONS.length;i++) if(S.jalons[SC.JALONS[i].id]) b += SC.JALONS[i].bonus;
  return 1 + b;
}
function multActions(S){ return 1 + S.actions*.08; }
function multParts(S){ return Math.pow(1.3, S.parts); }

function multProd(S){
  var m = multActions(S) * multParts(S) * bonusJalons(S);
  for(var i=0;i<SC.TECHS.length;i++){
    var t = SC.TECHS[i];
    if(t.prod && S.techs[t.id]) m *= t.prod;
  }
  if(h(S,"cadence")) m *= 3;
  if(h(S,"empire")) m *= 2;
  m *= multEquipe(S, "prod") * heritage(S);
  if(S.ev && S.ev.cle === "prod") m *= S.ev.v;
  return m;
}
function multPrix(S){
  var m = multActions(S) * multParts(S) * S.marge;
  for(var i=0;i<SC.TECHS.length;i++){
    var t = SC.TECHS[i];
    if(t.prix && S.techs[t.id]) m *= t.prix;
  }
  if(h(S,"empire")) m *= 2;
  m *= multEquipe(S, "prix");
  if(S.ev && S.ev.cle === "prix") m *= S.ev.v;
  return m;
}
function multRnd(S){
  var m = (h(S,"labo") ? 2 : 1) * multEquipe(S, "rnd");
  if(S.ev && S.ev.cle === "rnd") m *= S.ev.v;
  return m;
}
function multCompPrix(S){
  var m = 1;
  if(a(S,"pcb")) m *= 1;                 /* le gain de pcb porte sur la quantité */
  if(a(S,"logi")) m *= .8;
  if(h(S,"integree")) m *= .65;
  m *= multEquipe(S, "comp");
  if(S.ev && S.ev.cle === "comp") m *= S.ev.v;
  return m;
}

function produit(S){ return SC.PRODUITS[S.gamme]; }
function besoinComps(S){ return produit(S).comps * (a(S,"pcb") ? .8 : 1); }
function prixUnite(S){ return produit(S).prix * multPrix(S); }
function prixComp(S){ return produit(S).pc * multCompPrix(S); }

/* Ce que l'équipe assemble de ses mains, en plus des machines. On embauche
   pour ça : c'est ce qui fait tourner l'atelier quand personne ne clique.
   Le taux suit la meilleure machine en service, donc il reste utile à
   toutes les ères sans courbe inventée pour l'occasion. */
function cadenceEquipe(S){
  if(!S.equipe.length) return 0;
  var meilleure = SC.STATIONS[0].taux;
  for(var i=0;i<SC.STATIONS.length;i++)
    if(S.stations[i] > 0 && SC.STATIONS[i].taux > meilleure) meilleure = SC.STATIONS[i].taux;
  return S.equipe.length * meilleure * PART_MAIN;
}
function cadence(S){
  var u = 0;
  for(var i=0;i<SC.STATIONS.length;i++) u += S.stations[i] * SC.STATIONS[i].taux;
  return (u + cadenceEquipe(S)) * multProd(S);
}
function forceClic(S){ return (a(S,"fer") ? 4 : 1) * multActions(S) * multParts(S); }
function coutStation(S,i){
  var c = SC.STATIONS[i].base * Math.pow(1.19, S.stations[i]);
  if(a(S,"restruct")) c *= .85;
  return Math.ceil(c);
}
function coutTech(S,i){
  var c = SC.TECHS[i].cout;
  if(h(S,"carnet")) c *= .8;
  return Math.ceil(c);
}
function lotComps(S){ return Math.max(25, Math.ceil(besoinComps(S) * Math.max(cadence(S),1) * 30)); }

function ereIndex(S){
  var e = 0;
  for(var i=0;i<SC.TECHS.length;i++){
    var t = SC.TECHS[i];
    if(t.ouvre !== undefined && S.techs[t.id] && t.ouvre > e) e = t.ouvre;
  }
  return e;
}
/* une marge élevée rapporte davantage mais freine la conquête */
function conquete(S){
  var c = Math.max(.4, Math.min(1.35, 2 - S.marge));
  for(var i=0;i<SC.TECHS.length;i++){
    var t = SC.TECHS[i];
    if(t.conq && S.techs[t.id]) c *= t.conq;
  }
  return c * multEquipe(S, "conq");
}
function totalStations(S){
  var n = 0;
  for(var i=0;i<S.stations.length;i++) n += S.stations[i];
  return n;
}
function puissanceRivaux(S){
  var t = 0;
  for(var i=0;i<S.rivaux.length;i++) t += S.rivaux[i];
  return t;
}
function partMarche(S){
  var tot = S.puissance + puissanceRivaux(S);
  return tot > 0 ? (S.puissance/tot)*100 : 0;
}

/* ----------------------------- prestige ----------------------------- */

function actionsIPO(S){
  if(S.ca < 1e10) return 0;
  return Math.floor(10 * Math.pow(S.ca/1e10, .12));
}
function partsConglomerat(S){
  if(S.actions < 150) return 0;
  return Math.floor(3 * Math.pow(S.actions/150, .6));
}

function ipo(S){
  var act = actionsIPO(S);
  if(act <= 0) return null;
  var p = permanent(S);
  p.actions += act;
  p.ipos += 1;
  var n = neuve(p);
  n.journal = S.journal.slice(-3);
  /* le marché a continué sans vous pendant la réorganisation */
  n.rivaux = SC.CONCURRENTS.map(function(r){ return r.p * Math.exp(r.c * p.joue); });
  noter(n, "Introduction en bourse : " + act + " actions émises. On recommence, en plus gros.");
  return n;
}

function conglomerat(S){
  var pa = partsConglomerat(S);
  if(pa <= 0) return null;
  var p = permanent(S);
  p.parts += pa;
  p.actions = 0;
  p.congs += 1;
  var n = neuve(p);
  noter(n, "Conglomérat fondé : " + pa + " part" + (pa>1?"s":"") + " de holding. Les actions sont soldées.");
  return n;
}

function acheterHolding(S,i){
  var u = SC.HOLDING[i];
  if(S.holding[u.id] || S.parts < u.cout) return false;
  S.parts -= u.cout;
  S.holding[u.id] = true;
  noter(S, "Le conglomérat active : " + u.nom.toLowerCase() + ".");
  return true;
}

/* ----------------------------- jalons ----------------------------- */

function valeurJalon(S, cle){
  switch(cle){
    case "unites":   return S.unites;
    case "ca":       return S.caVie;
    case "stations": return totalStations(S);
    case "techs":    return Object.keys(S.techs).length;
    case "part":     return partMarche(S);
    case "ere":      return ereIndex(S);
    case "ipo":      return S.ipos;
    case "actions":  return S.actions;
    case "parts":    return S.parts;
  }
  return 0;
}
function verifierJalons(S){
  var gagnes = null;
  for(var i=0;i<SC.JALONS.length;i++){
    var j = SC.JALONS[i];
    if(S.jalons[j.id]) continue;
    if(valeurJalon(S, j.cle) >= j.seuil){
      S.jalons[j.id] = true;
      noter(S, "Jalon atteint : " + j.nom.toLowerCase() + ".");
      (gagnes = gagnes || []).push(j);
    }
  }
  return gagnes;
}

function noter(S, txt){
  S.journal.push({an:SC.ERES[ereIndex(S)].an, txt:txt});
  if(S.journal.length > 8) S.journal.shift();
}

/* ----------------------------- l'équipe ----------------------------- */

function generationPrenoms(S){
  var e = ereIndex(S);
  return SC.PRENOMS[e <= 3 ? 0 : e <= 7 ? 1 : e <= 11 ? 2 : 3];
}
function tirer(liste){ return liste[Math.floor(Math.random()*liste.length)]; }

function nouveauCandidat(S){
  var car = tirer(SC.CARACTERES);
  var poste = 0;
  for(var i=0;i<SC.STATIONS.length;i++) if(S.stations[i] > 0) poste = i;
  var c = {
    prenom: tirer(generationPrenoms(S)),
    nom: tirer(SC.NOMS),
    car: car.id,
    poste: SC.STATIONS[poste].nom,
    part: car.part * (.85 + Math.random()*.4),
    age: 22 + Math.floor(Math.random()*26),
    retraite: 62 + Math.floor(Math.random()*5),
    graine: Math.floor(Math.random()*100000)
  };
  /* quand vous pesez sur le marché, on vient de chez les concurrents —
     contre une indemnité de transfert, et au détriment du rival. */
  if(partMarche(S) > 40 && Math.random() < .35){
    var r = Math.floor(Math.random()*SC.CONCURRENTS.length);
    c.rival = r;
    c.origine = SC.CONCURRENTS[r].nom;
    c.part *= 1.45;
    c.age = 28 + Math.floor(Math.random()*22);
    c.indemnite = cadence(S) * prixUnite(S) * 600;
  }
  return c;
}

function embaucher(S){
  if(!S.candidat || S.equipe.length >= placesEquipe(S)) return false;
  var e = S.candidat;
  if(e.indemnite){
    if(S.cash < e.indemnite) return false;
    S.cash -= e.indemnite;
    S.rivaux[e.rival] *= .94;          /* le rival perd une tête */
  }
  e.moral = 78;
  e.confort = 0;
  e.partInitiale = e.part;
  e.anciennete = 0;
  e.binome = null;
  S.equipe.push(e);
  S.candidat = null;
  S.horlogeCandidat = 90 + Math.random()*90;
  noter(S, e.prenom + " " + e.nom + (e.origine
    ? " est débauché" + (fem(e) ? "e" : "") + " chez " + e.origine + "."
    : " rejoint l'atelier — " + CARACTERE[e.car].nom.toLowerCase() + "."));
  return true;
}

/* apparier ou séparer deux personnes */
function apparier(S, i, j){
  var a = S.equipe[i], b = S.equipe[j];
  if(!a || !b || a === b) return false;
  delier(S, a); delier(S, b);
  a.binome = b.graine; b.binome = a.graine;
  var y = synergie(a, b);
  noter(S, a.prenom + " et " + b.prenom + " travaillent désormais en binôme"
    + (y ? " — " + y.nom.toLowerCase() + "." : "."));
  return true;
}
function delier(S, e){
  if(!e || !e.binome) return;
  var p = partenaire(S, e);
  if(p) p.binome = null;
  e.binome = null;
}
function separer(S, i){
  var e = S.equipe[i];
  if(!e || !e.binome) return false;
  delier(S, e);
  return true;
}
function refuser(S){
  if(!S.candidat) return false;
  S.candidat = null;
  S.horlogeCandidat = 60 + Math.random()*90;
  return true;
}
function augmenter(S,i){
  var e = S.equipe[i];
  if(!e) return false;
  if(e.part >= e.partInitiale * 4) return false;   /* on ne surenchérit pas indéfiniment */
  e.part = Math.min(e.partInitiale * 4, e.part * 1.22);
  e.confort = (e.confort || 0) + 26;
  e.moral = Math.min(100, e.moral + 22);
  noter(S, e.prenom + " " + e.nom + " est augmenté" + (fem(e) ? "e" : "") + ".");
  return true;
}
function coutPrime(S,i){
  var e = S.equipe[i];
  return e ? e.part * cadence(S) * prixUnite(S) * 180 : 0;
}
function prime(S,i){
  var e = S.equipe[i], c = coutPrime(S,i);
  if(!e || S.cash < c) return false;
  S.cash -= c;
  e.confort = (e.confort || 0) + 14;
  e.moral = Math.min(100, e.moral + 16);
  return true;
}
/* accord du participe : suffit pour le journal */
function fem(e){ return /[ae]$/.test(e.prenom) && e.prenom !== "Noé"; }

/* Le moral ne s'use pas avec le temps : il converge vers ce que valent les
   conditions de travail du moment. Brader, laisser la chaîne à l'arrêt ou
   traverser une crise fait tomber la cible ; un atelier qui tourne la remonte.
   Une augmentation achète du confort, qui s'estompe en une demi-heure. */
function cibleMoral(S, bloque, protection){
  var malus = 0;
  if(S.marge < 1) malus += (1 - S.marge) * 230;
  if(bloque) malus += 30;
  if(S.ev && !S.ev.bon) malus += 12;
  var bonus = 0;
  if(partMarche(S) > 50) bonus += 12;
  if(a(S,"sav")) bonus += 10;
  if(a(S,"marque")) bonus += 6;
  return 66 - malus*protection + bonus;
}

function majEquipe(S, dt, bloque){
  /* une personne qui aime transmettre amortit les mauvaises passes */
  var protection = 1;
  for(var i=0;i<S.equipe.length;i++){
    var c = CARACTERE[S.equipe[i].car];
    if(c && c.moral) protection = Math.min(protection, c.moral);
  }
  var cible = cibleMoral(S, bloque, protection);
  var partis = null, retraites = null;

  for(var k=S.equipe.length-1; k>=0; k--){
    var e = S.equipe[k], car = CARACTERE[e.car];
    e.anciennete += dt;
    e.age = (e.age || 30) + dt*ANNEES_PAR_SECONDE;
    e.confort = (e.confort || 0) * Math.exp(-dt/1800);

    /* départ à la retraite : la personne forme son remplaçant avant de partir */
    if(e.age >= (e.retraite || 64)){
      var ans = Math.max(1, Math.round(e.anciennete*ANNEES_PAR_SECONDE));
      noter(S, e.prenom + " " + e.nom + " " + tirer(SC.RETRAITES)
        + " (" + ans + " an" + (ans>1?"s":"") + " de maison)");
      S.retraites = (S.retraites || 0) + 1;
      var releve = {
        prenom: tirer(generationPrenoms(S)), nom: tirer(SC.NOMS),
        car: e.car, poste: e.poste,
        part: e.partInitiale * .85, partInitiale: e.partInitiale * .85,
        moral: 88, confort: 0, anciennete: 0,
        age: 23 + Math.floor(Math.random()*8), retraite: 62 + Math.floor(Math.random()*5),
        graine: Math.floor(Math.random()*100000), binome: null, forme: true
      };
      delier(S, e);
      S.equipe[k] = releve;
      (retraites = retraites || []).push({partant:e, releve:releve});
      continue;
    }

    var duo = partenaire(S, e);
    var vise = cible + e.confort + (duo ? 10 : 0);
    if(car.stoique) vise = Math.max(vise, 35);
    var yy = duo ? synergie(e, duo) : null;
    if(yy && yy.plancher) vise = Math.max(vise, yy.plancher);
    e.moral += (vise - e.moral) * Math.min(1, .0016*dt);
    if(e.moral > 100) e.moral = 100;

    /* Un moral en berne, et la concurrence appelle : le débauchage guette bien
       avant que le moral ne touche le fond. */
    var debauche = false;
    if(e.moral < 45 && !car.stoique){
      var risque = (45 - Math.max(0,e.moral))/45 * .00022 * dt;
      if(Math.random() < risque) debauche = true;
    }
    if(debauche || e.moral <= 0){
      var motif;
      if(debauche){
        var rival = SC.CONCURRENTS[Math.floor(Math.random()*SC.CONCURRENTS.length)].nom;
        motif = "se laisse débaucher par " + rival + ".";
      }else{
        motif = S.marge < 1 ? SC.DEPARTS[0] : bloque ? SC.DEPARTS[2 + Math.floor(Math.random()*2)]
              : SC.DEPARTS[Math.floor(Math.random()*SC.DEPARTS.length)];
      }
      noter(S, e.prenom + " " + e.nom + " " + motif);
      var orphelin = partenaire(S, e);
      if(orphelin){ orphelin.moral = Math.max(1, orphelin.moral - 25); orphelin.binome = null; }
      delier(S, e);
      S.equipe.splice(k,1);
      (partis = partis || []).push(e);
    }
  }

  /* candidatures spontanées */
  if(!S.candidat && S.equipe.length < placesEquipe(S)){
    S.horlogeCandidat -= dt;
    if(S.horlogeCandidat <= 0) S.candidat = nouveauCandidat(S);
  }
  return {partis:partis, retraites:retraites};
}

/* ----------------------------- tour de jeu ----------------------------- */

/* `part` vaut 1 pour une unité assemblée normalement, PART_BRICOLAGE pour une
   unité montée de bric et de broc, sans composants : moins rentable, mais
   l'atelier n'est jamais à l'arrêt faute de stock. */
function encaisser(S, u, part){
  if(part === undefined) part = 1;
  var gain = u * prixUnite(S) * part;
  var net = gain * (1 - masseSalariale(S));
  S.cash += net; S.ca += gain; S.caVie += gain;
  if(part === 1) S.comps = Math.max(0, S.comps - u*besoinComps(S));
  S.unites += u;
  S.puissance += u * Math.pow(1 + S.gamme, 1.5) * conquete(S);
  S.rnd += u * produit(S).rnd * multRnd(S);
  return net;
}

/* Les rivaux ne croissent pas dans le vide : ils visent une fraction de VOTRE
   puissance, avec un plancher qui progresse lentement. Stagner, c'est les laisser
   revenir ; accélérer, c'est leur prendre des parts. */
function majRivaux(S, dt){
  var ralenti = h(S,"monopole") ? .6 : 1;
  for(var r=0;r<S.rivaux.length;r++){
    var C = SC.CONCURRENTS[r];
    var plancher = C.p * Math.exp(C.c * S.joue * ralenti);
    var cible = Math.max(plancher, S.puissance * C.poids);
    /* ils reviennent vite, ils reculent lentement */
    var vitesse = cible > S.rivaux[r] ? C.rattrapage * ralenti : C.rattrapage/4;
    S.rivaux[r] += (cible - S.rivaux[r]) * Math.min(1, vitesse * dt);
  }
}

function approvisionner(S, dt){
  if(!a(S,"appro")) return;
  var cad = cadence(S);
  if(cad <= 0) return;
  var cible = besoinComps(S) * cad * 20;
  if(S.comps >= cible) return;
  var pc = prixComp(S);
  var budget = Math.min(S.cash*.35, (cible - S.comps) * pc);
  if(budget > 0){ S.comps += budget/pc; S.cash -= budget; }
}

function tick(S, dt){
  var res = {faites:0, gain:0, finEvenement:false, debutEvenement:null, bloque:false, jalons:null};
  S.joue += dt;

  majRivaux(S, dt);

  if(h(S,"empire")) S.actions += dt/60;

  if(S.ev){
    S.ev.reste -= dt;
    if(S.ev.reste <= 0){ S.ev = null; res.finEvenement = true; }
  }else{
    S.horlogeEv -= dt;
    if(S.horlogeEv <= 0){
      var e = SC.EVENEMENTS[Math.floor(Math.random()*SC.EVENEMENTS.length)];
      var v = e.v;
      if(a(S,"sav")){
        if(v < 1) v = 1 - (1-v)/2;
        else if(e.cle === "comp") v = 1 + (v-1)/2;
      }
      S.ev = {n:e.n, e:e.e, cle:e.cle, v:v, bon:e.bon, reste:20 + Math.random()*16};
      S.horlogeEv = 45 + Math.random()*45;
      res.debutEvenement = S.ev;
      noter(S, e.n + " — " + e.e.toLowerCase() + ".");
    }
  }

  approvisionner(S, dt);

  var besoin = besoinComps(S), cad = cadence(S);
  S.buf += cad*dt;
  if(S.buf >= 1){
    var voulu = Math.floor(S.buf);
    var possible = Math.floor(S.comps/besoin);
    res.faites = Math.min(voulu, possible);
    S.buf = Math.max(0, S.buf - voulu);
    if(res.faites > 0) res.gain = encaisser(S, res.faites);
  }
  res.bloque = cad > 0 && S.comps < besoin;
  var vie = majEquipe(S, dt, res.bloque);
  res.partis = vie.partis;
  res.retraites = vie.retraites;
  res.jalons = verifierJalons(S);
  return res;
}

/* ----------------------------- hors ligne ----------------------------- */

function rattraper(S){
  var maintenant = Date.now();
  var ecoule = (maintenant - (S.majSauvegarde || maintenant))/1000;
  S.majSauvegarde = maintenant;
  if(!(ecoule > 90)) return null;

  var duree = Math.min(ecoule, PLAFOND_HORS_LIGNE);
  var pas = duree/120, unites0 = S.unites, cash0 = S.cash, ca0 = S.ca;
  for(var i=0;i<120;i++){
    S.joue += pas;
    approvisionner(S, pas);
    var besoin = besoinComps(S);
    var voulu = cadence(S)*RENDEMENT_HORS_LIGNE*pas;
    var montees = besoin > 0 ? Math.min(voulu, S.comps/besoin) : voulu;
    if(montees > 0) encaisser(S, montees);
    /* Ce que les composants ne couvrent pas, l'équipe le bricole : tant qu'il
       y a quelqu'un à l'atelier, il ne reste jamais à l'arrêt. */
    if(voulu - montees > 0 && S.equipe.length) encaisser(S, voulu - montees, PART_BRICOLAGE);
    majRivaux(S, pas);          /* le marché ne vous attend pas */
  }
  verifierJalons(S);
  var gagne = S.cash - cash0;
  if(S.unites - unites0 < 1) return null;
  noter(S, "Retour à l'atelier : " + Math.round(duree/60) + " minutes de production rattrapées.");
  return {duree:duree, ecoule:ecoule, unites:S.unites - unites0, gain:S.ca - ca0, plafonne:ecoule > PLAFOND_HORS_LIGNE};
}

/* ----------------------------- actions ----------------------------- */

function acheterStation(S,i){
  var c = coutStation(S,i);
  if(S.cash < c) return false;
  S.cash -= c; S.stations[i] += 1;
  if(S.stations[i] === 1) noter(S, "Mise en service : " + SC.STATIONS[i].nom.toLowerCase() + ".");
  return true;
}
function acheterTech(S,i){
  var t = SC.TECHS[i];
  if(a(S,t.id) || S.rnd < coutTech(S,i)) return false;
  S.rnd -= coutTech(S,i); S.techs[t.id] = true;
  if(t.ouvre !== undefined && t.ouvre > S.gamme){
    S.gamme = t.ouvre;
    noter(S, "Nouvelle gamme : " + SC.PRODUITS[S.gamme].nom.toLowerCase() + " (" + SC.PRODUITS[S.gamme].an + ").");
    return "ere";
  }
  noter(S, "Brevet déposé : " + t.nom.toLowerCase() + ".");
  return true;
}
/* Un clic ne reste jamais sans effet : ce que le stock couvre part au prix
   fort, le reste est bricolé. Sans un sou et sans composants, on peut donc
   toujours repartir à la main — acheter des composants garde son intérêt,
   c'est trois fois plus rentable. */
function assembler(S){
  var u = forceClic(S), besoin = besoinComps(S);
  var montees = besoin > 0 ? Math.min(u, S.comps/besoin) : u;
  var net = montees > 0 ? encaisser(S, montees) : 0;
  if(u - montees > 0) net += encaisser(S, u - montees, PART_BRICOLAGE);
  return net;
}
/* Achète un lot, ou autant que la trésorerie le permet : un atelier à sec doit
   toujours pouvoir repartir, sinon dépenser jusqu'au dernier euro rend la
   partie irrécupérable. */
function acheterComposants(S){
  var pc = prixComp(S);
  if(pc <= 0) return false;
  var quantite = Math.min(lotComps(S), Math.floor(S.cash/pc));
  if(quantite < 1) return false;
  S.cash -= quantite*pc; S.comps += quantite;
  return true;
}

/* ----------------------------- sauvegarde ----------------------------- */

var stockageOk = true;
function charger(){
  try{
    var brut = localStorage.getItem(CLE);
    if(!brut) return null;
    var o = JSON.parse(brut);
    if(!o || typeof o.cash !== "number") return null;
    var S = neuve(null);
    Object.keys(o).forEach(function(k){ S[k] = o[k]; });
    S.stations = SC.STATIONS.map(function(_,i){ return (o.stations && o.stations[i]) || 0; });
    S.rivaux   = SC.CONCURRENTS.map(function(r,i){ return (o.rivaux && o.rivaux[i]) || r.p; });
    S.hist     = (Array.isArray(o.hist) && o.hist.length === 60) ? o.hist : new Array(60).fill(0);
    S.journal  = Array.isArray(o.journal) ? o.journal.slice(-8) : [];
    S.techs    = o.techs || {};
    S.holding  = o.holding || {};
    S.jalons   = o.jalons || {};
    S.equipe   = Array.isArray(o.equipe) ? o.equipe.filter(function(e){ return e && CARACTERE[e.car]; }) : [];
    S.retraites = o.retraites || 0;
    S.equipe.forEach(function(e){
      if(!e.partInitiale) e.partInitiale = e.part;
      if(!e.confort) e.confort = 0;
      if(!e.age) e.age = 34;
      if(!e.retraite) e.retraite = 64;
    });
    /* on ne garde que les binômes dont les deux moitiés sont encore là */
    S.equipe.forEach(function(e){
      if(e.binome && !S.equipe.some(function(o){ return o.graine === e.binome; })) e.binome = null;
    });
    S.candidat = (o.candidat && CARACTERE[o.candidat.car]) ? o.candidat : null;
    S.marge    = typeof o.marge === "number" ? o.marge : 1;
    S.parts    = o.parts || 0;
    S.ipos     = o.ipos || 0;
    S.congs    = o.congs || 0;
    S.joue     = o.joue || 0;
    S.ev = null;
    S.horlogeEv = 24 + Math.random()*26;
    return S;
  }catch(e){ stockageOk = false; return null; }
}
function sauver(S){
  if(!stockageOk) return;
  S.majSauvegarde = Date.now();
  try{ localStorage.setItem(CLE, JSON.stringify(S)); }
  catch(e){ stockageOk = false; }
}

SC.jeu = {
  neuve:neuve, demo:demo, tick:tick, rattraper:rattraper,
  multProd:multProd, multPrix:multPrix, multParts:multParts, bonusJalons:bonusJalons,
  produit:produit, besoinComps:besoinComps, prixUnite:prixUnite, prixComp:prixComp,
  cadence:cadence, forceClic:forceClic, coutStation:coutStation, coutTech:coutTech, lotComps:lotComps,
  ereIndex:ereIndex, partMarche:partMarche, puissanceRivaux:puissanceRivaux, totalStations:totalStations,
  conquete:conquete, actionsIPO:actionsIPO, partsConglomerat:partsConglomerat, noter:noter,
  acheterStation:acheterStation, acheterTech:acheterTech, assembler:assembler,
  acheterComposants:acheterComposants, acheterHolding:acheterHolding,
  ipo:ipo, conglomerat:conglomerat, valeurJalon:valeurJalon,
  embaucher:embaucher, refuser:refuser, augmenter:augmenter, prime:prime, coutPrime:coutPrime,
  apparier:apparier, separer:separer, partenaire:partenaire, synergie:synergie, heritage:heritage,
  masseSalariale:masseSalariale, placesEquipe:placesEquipe, cibleMoral:cibleMoral, caractere:function(id){ return CARACTERE[id]; },
  charger:charger, sauver:sauver,
  stockageOk:function(){ return stockageOk; },
  PLAFOND_HORS_LIGNE:PLAFOND_HORS_LIGNE
};
})();
