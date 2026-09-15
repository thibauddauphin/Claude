/* Silicium & Cie — règles, économie, concurrence. Aucune dépendance au DOM. */
(function(){
"use strict";

var CLE = "silicium-cie-v2";

function neuve(actions){
  return {
    cash:30, comps:12, rnd:0,
    stations:SC.STATIONS.map(function(){ return 0; }),
    techs:{},
    gamme:0,
    marge:1,
    unites:0, ca:0, caVie:0, puissance:0,
    actions:actions || 0,
    rivaux:SC.CONCURRENTS.map(function(r){ return r.p; }),
    buf:0,
    ev:null,
    hist:new Array(60).fill(0),
    journal:[],
    debut:Date.now()
  };
}

/* Partie de démonstration : l'atelier tourne déjà, quelques mois d'activité en 1975. */
function demo(){
  var s = neuve(0);
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

var TECH = SC.TECHS.reduce(function(m,t){ m[t.id] = t; return m; }, {});
function a(S,id){ return !!S.techs[id]; }

function multActions(S){ return 1 + S.actions*.08; }

function multProd(S){
  var m = multActions(S);
  SC.TECHS.forEach(function(t){ if(t.prod && S.techs[t.id]) m *= t.prod; });
  if(S.ev && S.ev.cle === "prod") m *= S.ev.v;
  return m;
}
function multPrix(S){
  var m = multActions(S) * S.marge;
  SC.TECHS.forEach(function(t){ if(t.prix && S.techs[t.id]) m *= t.prix; });
  if(S.ev && S.ev.cle === "prix") m *= S.ev.v;
  return m;
}
function multRnd(S){ return (S.ev && S.ev.cle === "rnd") ? S.ev.v : 1; }
function multCompPrix(S){
  var m = a(S,"logi") ? .8 : 1;
  if(S.ev && S.ev.cle === "comp") m *= S.ev.v;
  return m;
}

function produit(S){ return SC.PRODUITS[S.gamme]; }
function besoinComps(S){ return produit(S).comps * (a(S,"pcb") ? .75 : 1); }
function prixUnite(S){ return produit(S).prix * multPrix(S); }
function prixComp(S){ return produit(S).pc * multCompPrix(S); }

function cadence(S){
  var u = 0;
  for(var i=0;i<SC.STATIONS.length;i++) u += S.stations[i] * SC.STATIONS[i].taux;
  return u * multProd(S);
}
function forceClic(S){ return (a(S,"fer") ? 4 : 1) * multActions(S); }
function coutStation(S,i){ return Math.ceil(SC.STATIONS[i].base * Math.pow(1.16, S.stations[i])); }
function lotComps(S){ return Math.max(25, Math.ceil(besoinComps(S) * Math.max(cadence(S),1) * 30)); }

function ereIndex(S){
  var e = 0;
  SC.TECHS.forEach(function(t){ if(t.ouvre !== undefined && S.techs[t.id]) e = Math.max(e, t.ouvre); });
  return e;
}
/* une marge élevée rapporte davantage mais freine la conquête */
function conquete(S){ return Math.max(.4, Math.min(1.35, 2 - S.marge)); }

function puissanceRivaux(S){
  return S.rivaux.reduce(function(t,p){ return t+p; }, 0);
}
function partMarche(S){
  var tot = S.puissance + puissanceRivaux(S);
  return tot > 0 ? (S.puissance / tot) * 100 : 0;
}
function actionsIPO(S){
  if(S.ca < 25e6) return 0;
  return Math.floor(12 * Math.sqrt(S.ca / 25e6));
}

function noter(S, txt){
  S.journal.push({an:SC.ERES[ereIndex(S)].an, txt:txt});
  if(S.journal.length > 7) S.journal.shift();
}

/* ------------------------------- tour de jeu ------------------------------- */

function encaisser(S, u){
  var gain = u * prixUnite(S);
  S.cash += gain; S.ca += gain; S.caVie += gain;
  S.comps = Math.max(0, S.comps - u*besoinComps(S));
  S.unites += u;
  S.puissance += u * Math.pow(1 + S.gamme, 1.5) * conquete(S);
  S.rnd += u * produit(S).rnd * multRnd(S);
  return gain;
}

function tick(S, dt){
  var res = {faites:0, gain:0, finEvenement:false, debutEvenement:null, bloque:false};

  /* concurrents : ils progressent, que vous dormiez ou non */
  var facteur = 1 + ereIndex(S)*.22;
  for(var r=0;r<S.rivaux.length;r++)
    S.rivaux[r] *= Math.exp(SC.CONCURRENTS[r].c * facteur * dt);

  /* événement en cours */
  if(S.ev){
    S.ev.reste -= dt;
    if(S.ev.reste <= 0){ S.ev = null; res.finEvenement = true; }
  }else{
    S.horlogeEv = (S.horlogeEv === undefined ? 24 + Math.random()*26 : S.horlogeEv) - dt;
    if(S.horlogeEv <= 0){
      var e = SC.EVENEMENTS[Math.floor(Math.random()*SC.EVENEMENTS.length)];
      var v = e.v;
      if(a(S,"sav")){                       /* le SAV amortit les crises */
        if(v < 1) v = 1 - (1-v)/2;
        else if(e.cle === "comp") v = 1 + (v-1)/2;
      }
      S.ev = {n:e.n, e:e.e, cle:e.cle, v:v, bon:e.bon, reste:20 + Math.random()*16};
      S.horlogeEv = 45 + Math.random()*45;
      res.debutEvenement = S.ev;
      noter(S, e.n + " — " + e.e.toLowerCase() + ".");
    }
  }

  /* approvisionnement automatique */
  var besoin = besoinComps(S), cad = cadence(S);
  if(a(S,"appro") && cad > 0){
    var cible = besoin * cad * 20;
    if(S.comps < cible){
      var budget = Math.min(S.cash*.35, (cible - S.comps) * prixComp(S));
      if(budget > 0){ S.comps += budget / prixComp(S); S.cash -= budget; }
    }
  }

  /* production */
  S.buf += cad * dt;
  if(S.buf >= 1){
    var voulu = Math.floor(S.buf);
    var possible = Math.floor(S.comps / besoin);
    res.faites = Math.min(voulu, possible);
    S.buf = Math.max(0, S.buf - voulu);
    if(res.faites > 0) res.gain = encaisser(S, res.faites);
  }
  res.bloque = cad > 0 && S.comps < besoin;
  return res;
}

/* ------------------------------- actions ------------------------------- */

function acheterStation(S,i){
  var c = coutStation(S,i);
  if(S.cash < c) return false;
  S.cash -= c; S.stations[i] += 1;
  if(S.stations[i] === 1) noter(S, "Mise en service : " + SC.STATIONS[i].nom.toLowerCase() + ".");
  return true;
}

function acheterTech(S,i){
  var t = SC.TECHS[i];
  if(a(S,t.id) || S.rnd < t.cout) return false;
  S.rnd -= t.cout; S.techs[t.id] = true;
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

function ipo(S){
  var act = actionsIPO(S);
  if(act <= 0) return null;
  var vie = S.caVie, journal = S.journal.slice(-3), debut = S.debut;
  var n = neuve(S.actions + act);
  n.caVie = vie; n.journal = journal; n.debut = debut;
  /* la concurrence recule un peu devant une société cotée */
  n.rivaux = SC.CONCURRENTS.map(function(r){ return r.p * (1 + S.actions*.35); });
  noter(n, "Introduction en bourse : " + act + " actions émises. On recommence, en plus gros.");
  return n;
}

/* ------------------------------- sauvegarde ------------------------------- */

var stockageOk = true;
function charger(){
  try{
    var brut = localStorage.getItem(CLE);
    if(!brut) return null;
    var o = JSON.parse(brut);
    if(!o || typeof o.cash !== "number") return null;
    var S = Object.assign(neuve(0), o);
    S.stations = SC.STATIONS.map(function(_,i){ return (o.stations && o.stations[i]) || 0; });
    S.rivaux = SC.CONCURRENTS.map(function(r,i){ return (o.rivaux && o.rivaux[i]) || r.p; });
    S.hist = (Array.isArray(o.hist) && o.hist.length === 60) ? o.hist : new Array(60).fill(0);
    S.journal = Array.isArray(o.journal) ? o.journal.slice(-7) : [];
    S.marge = typeof o.marge === "number" ? o.marge : 1;
    S.ev = null;
    return S;
  }catch(e){ stockageOk = false; return null; }
}
function sauver(S){
  if(!stockageOk) return;
  try{ localStorage.setItem(CLE, JSON.stringify(S)); }
  catch(e){ stockageOk = false; }
}

SC.jeu = {
  neuve:neuve, demo:demo, tick:tick,
  multProd:multProd, multPrix:multPrix,
  produit:produit, besoinComps:besoinComps, prixUnite:prixUnite, prixComp:prixComp,
  cadence:cadence, forceClic:forceClic, coutStation:coutStation, lotComps:lotComps,
  ereIndex:ereIndex, partMarche:partMarche, puissanceRivaux:puissanceRivaux,
  conquete:conquete, actionsIPO:actionsIPO, noter:noter,
  acheterStation:acheterStation, acheterTech:acheterTech, assembler:assembler,
  acheterComposants:acheterComposants, ipo:ipo,
  charger:charger, sauver:sauver,
  stockageOk:function(){ return stockageOk; }
};
})();
