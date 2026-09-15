/* Simulateur d'équilibrage : joue la partie sans interface et mesure le rythme.
   Usage : node outils/equilibrage.js [heures_max] */
global.window = global;
require("../jeu/donnees.js");
require("../jeu/jeu.js");

var HEURES_MAX = parseFloat(process.argv[2] || "300");
var DT = 1;                       /* pas de simulation, en secondes */
var PERIODE_DECISION = 3;         /* le joueur n'agit pas à chaque seconde */

function fmt(s){
  if(s < 90) return Math.round(s) + " s";
  if(s < 5400) return (s/60).toFixed(1) + " min";
  return (s/3600).toFixed(2) + " h";
}
function num(v){
  if(v >= 1e12) return (v/1e12).toFixed(1) + " Bn";
  if(v >= 1e9) return (v/1e9).toFixed(1) + " Md";
  if(v >= 1e6) return (v/1e6).toFixed(1) + " M";
  if(v >= 1e3) return (v/1e3).toFixed(1) + " k";
  return Math.round(v) + "";
}

/* --------- politique d'achat d'un joueur appliqué mais pas optimal --------- */
function decider(S){
  /* on clique pour amorcer tant que l'atelier ne tourne pas seul */
  if(SC.jeu.cadence(S) < 3){
    for(var c=0;c<3*PERIODE_DECISION;c++) SC.jeu.assembler(S);
  }
  /* recrutement : on accepte toute candidature, on augmente avant la démission */
  if(S.candidat) SC.jeu.embaucher(S);
  for(var e=0;e<S.equipe.length;e++) if(S.equipe[e].moral < 35) SC.jeu.augmenter(S,e);
  /* technologies : de la moins chère à la plus chère */
  for(var i=0;i<SC.TECHS.length;i++){
    if(S.techs[SC.TECHS[i].id]) continue;
    if(S.rnd >= SC.jeu.coutTech(S,i)) SC.jeu.acheterTech(S,i);
  }
  var besoin = SC.jeu.besoinComps(S), cad = SC.jeu.cadence(S), pc = SC.jeu.prixComp(S);
  /* composants d'abord : une chaîne à l'arrêt ne rapporte rien */
  var cible = besoin*Math.max(cad,1)*90;
  for(var n=0; n<30 && S.comps < cible; n++){
    if(S.cash < SC.jeu.lotComps(S)*pc) break;
    if(!SC.jeu.acheterComposants(S)) break;
  }
  /* moyens de production : seulement le surplus au-delà de trois minutes d'approvisionnement */
  var reserve = S.techs.appro ? besoin*cad*pc*60 : besoin*cad*pc*180;
  for(var tour=0; tour<8; tour++){
    var meilleur = -1, note = 0;
    for(var k=0;k<SC.STATIONS.length;k++){
      var cout = SC.jeu.coutStation(S,k);
      if(cout > S.cash - reserve) continue;
      var r = SC.STATIONS[k].taux/cout;
      if(r > note){ note = r; meilleur = k; }
    }
    if(meilleur < 0) break;
    SC.jeu.acheterStation(S, meilleur);
  }
}

/* --------------------------------- partie --------------------------------- */
function jouer(etiquette, S, limiteSecondes, surEre){
  var t = 0, prochaineDecision = 0;
  while(t < limiteSecondes){
    if(t >= prochaineDecision){ decider(S); prochaineDecision = t + PERIODE_DECISION; }
    SC.jeu.tick(S, DT);
    t += DT;
    if(surEre) surEre(S, t);
    if(SC.jeu.ereIndex(S) === SC.ERES.length-1 &&
       Object.keys(S.techs).length === SC.TECHS.length) break;
  }
  return t;
}

var S = SC.jeu.neuve();
var jalonsEre = {}, jalonsTech = {}, partAtteinte = {};
var limite = HEURES_MAX*3600;

var t = jouer("run 1", S, limite, function(S, t){
  var e = SC.jeu.ereIndex(S);
  if(jalonsEre[e] === undefined){ jalonsEre[e] = t; partAtteinte[e] = SC.jeu.partMarche(S); }
  var nt = Object.keys(S.techs).length;
  if(jalonsTech[nt] === undefined) jalonsTech[nt] = t;
});

console.log("\n=== RYTHME DE LA PREMIÈRE PARTIE ===\n");
console.log("ère".padEnd(6) + "année".padEnd(8) + "nom".padEnd(32) + "atteinte à".padStart(10) + "durée".padStart(12) + "marché".padStart(9));
var prec = 0;
SC.ERES.forEach(function(e,i){
  if(jalonsEre[i] === undefined){
    console.log(String(i).padEnd(6) + e.an.padEnd(8) + e.nom.padEnd(32) + "jamais".padStart(10));
    return;
  }
  console.log(String(i).padEnd(6) + e.an.padEnd(8) + e.nom.padEnd(32)
    + fmt(jalonsEre[i]).padStart(10) + fmt(jalonsEre[i]-prec).padStart(12)
    + (partAtteinte[i] !== undefined ? (partAtteinte[i].toFixed(1) + " %").padStart(9) : ""));
  prec = jalonsEre[i];
});

console.log("\n=== ÉTAT FINAL ===");
console.log("temps simulé        " + fmt(t));
console.log("technologies        " + Object.keys(S.techs).length + "/" + SC.TECHS.length);
console.log("moyens de production " + SC.jeu.totalStations(S));
console.log("unités vendues      " + num(S.unites));
console.log("chiffre d'affaires  " + num(S.ca) + " €");
console.log("part de marché      " + SC.jeu.partMarche(S).toFixed(1) + " %");
console.log("actions à l'IPO     " + SC.jeu.actionsIPO(S));
console.log("jalons              " + Object.keys(S.jalons).length + "/" + SC.JALONS.length);

/* première IPO possible */
var tIPO = null;
var S2 = SC.jeu.neuve(), t2 = 0;
while(t2 < limite){
  if(t2 % PERIODE_DECISION === 0) decider(S2);
  SC.jeu.tick(S2, DT); t2 += DT;
  if(SC.jeu.actionsIPO(S2) > 0){ tIPO = t2; break; }
}
console.log("première IPO possible après " + (tIPO ? fmt(tIPO) : "jamais"));
