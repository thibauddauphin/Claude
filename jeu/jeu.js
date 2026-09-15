/* Silicium & Cie — règles, économie, concurrence, prestige. Aucune dépendance au DOM. */
(function(){
"use strict";

var CLE = "silicium-cie-v3";
var PLAFOND_HORS_LIGNE = 12*3600;   /* 12 h de production accumulée au maximum */
var RENDEMENT_HORS_LIGNE = .6;      /* l'atelier tourne au ralenti en votre absence */

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
  if(S.ev && S.ev.cle === "prix") m *= S.ev.v;
  return m;
}
function multRnd(S){
  var m = h(S,"labo") ? 2 : 1;
  if(S.ev && S.ev.cle === "rnd") m *= S.ev.v;
  return m;
}
function multCompPrix(S){
  var m = 1;
  if(a(S,"pcb")) m *= 1;                 /* le gain de pcb porte sur la quantité */
  if(a(S,"logi")) m *= .8;
  if(h(S,"integree")) m *= .65;
  if(S.ev && S.ev.cle === "comp") m *= S.ev.v;
  return m;
}

function produit(S){ return SC.PRODUITS[S.gamme]; }
function besoinComps(S){ return produit(S).comps * (a(S,"pcb") ? .8 : 1); }
function prixUnite(S){ return produit(S).prix * multPrix(S); }
function prixComp(S){ return produit(S).pc * multCompPrix(S); }

function cadence(S){
  var u = 0;
  for(var i=0;i<SC.STATIONS.length;i++) u += S.stations[i] * SC.STATIONS[i].taux;
  return u * multProd(S);
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
  return c;
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

/* ----------------------------- tour de jeu ----------------------------- */

function encaisser(S, u){
  var gain = u * prixUnite(S);
  S.cash += gain; S.ca += gain; S.caVie += gain;
  S.comps = Math.max(0, S.comps - u*besoinComps(S));
  S.unites += u;
  S.puissance += u * Math.pow(1 + S.gamme, 1.5) * conquete(S);
  S.rnd += u * produit(S).rnd * multRnd(S);
  return gain;
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
    var u = Math.min(cadence(S)*RENDEMENT_HORS_LIGNE*pas, S.comps/besoin);
    if(u > 0) encaisser(S, u);
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
function assembler(S){
  var u = forceClic(S);
  if(S.comps < u*besoinComps(S)) return 0;
  return encaisser(S, u);
}
function acheterComposants(S){
  var lot = lotComps(S), c = lot*prixComp(S);
  if(S.cash < c) return false;
  S.cash -= c; S.comps += lot;
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
  charger:charger, sauver:sauver,
  stockageOk:function(){ return stockageOk; },
  PLAFOND_HORS_LIGNE:PLAFOND_HORS_LIGNE
};
})();
