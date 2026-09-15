/* Calibrage automatique : ajuste le coût des technologies jusqu'à ce que chaque ère
   dure le temps visé. Affiche la table de coûts à recopier dans donnees.js.
   Usage : node outils/calibrage.js [iterations] */
global.window = global;
require("../jeu/donnees.js");
require("../jeu/jeu.js");

/* Durée visée de chaque ère lors de la première partie, en minutes.
   Progression géométrique : les dernières ères deviennent des paliers que
   l'on franchit en partie hors ligne, ou après une introduction en bourse. */
var CIBLES = [5, 6.8, 9.1, 12.3, 16.6, 22.4, 30.3, 40.9, 55.2, 74.5, 100.6, 135.8, 183.3, 247.5, 334.1]
             .map(function(m){ return m*60; });

var DT = 2, PERIODE_DECISION = 4, LIMITE = 60*3600;
var ITERATIONS = parseInt(process.argv[2] || "12", 10);

function decider(S){
  if(SC.jeu.cadence(S) < 3){
    for(var c=0;c<3*PERIODE_DECISION;c++) SC.jeu.assembler(S);
  }
  for(var i=0;i<SC.TECHS.length;i++){
    if(S.techs[SC.TECHS[i].id]) continue;
    if(S.rnd >= SC.jeu.coutTech(S,i)) SC.jeu.acheterTech(S,i);
  }
  var besoin = SC.jeu.besoinComps(S), cad = SC.jeu.cadence(S), pc = SC.jeu.prixComp(S);
  var cible = besoin*Math.max(cad,1)*90;
  for(var n=0; n<30 && S.comps < cible; n++){
    if(S.cash < SC.jeu.lotComps(S)*pc) break;
    if(!SC.jeu.acheterComposants(S)) break;
  }
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

/* renvoie l'instant d'arrivée dans chaque ère */
function partie(){
  var S = SC.jeu.neuve(), t = 0, arrivee = {0:0}, prochaine = 0;
  while(t < LIMITE){
    if(t >= prochaine){ decider(S); prochaine = t + PERIODE_DECISION; }
    SC.jeu.tick(S, DT);
    t += DT;
    var e = SC.jeu.ereIndex(S);
    if(arrivee[e] === undefined) arrivee[e] = t;
    if(e === SC.ERES.length-1 && Object.keys(S.techs).length === SC.TECHS.length){
      arrivee[SC.ERES.length] = t;   /* fin de la dernière ère : toutes les technologies acquises */
      break;
    }
  }
  return {arrivee:arrivee, fin:t, S:S};
}

function durees(arrivee){
  var d = [];
  for(var e=0;e<SC.ERES.length;e++){
    if(arrivee[e] === undefined || arrivee[e+1] === undefined){ d.push(null); continue; }
    d.push(arrivee[e+1] - arrivee[e]);
  }
  return d;
}
function fmt(s){
  if(s === null) return "   —   ";
  if(s < 5400) return (s/60).toFixed(1).padStart(6) + "m";
  return (s/3600).toFixed(2).padStart(6) + "h";
}

/* --------------------------------- boucle --------------------------------- */
var techsParEre = {};
SC.TECHS.forEach(function(t,i){ (techsParEre[t.ere] = techsParEre[t.ere] || []).push(i); });

for(var it=1; it<=ITERATIONS; it++){
  var r = partie();
  var d = durees(r.arrivee);
  var ecartMax = 0;
  for(var e=0;e<SC.ERES.length;e++){
    var cible = CIBLES[e];
    var reel = d[e];
    var facteur;
    if(reel === null){
      /* ère jamais atteinte : on allège fortement */
      facteur = .35;
    }else{
      facteur = Math.pow(cible/Math.max(reel,1), .65);
      facteur = Math.max(.25, Math.min(4, facteur));
      ecartMax = Math.max(ecartMax, Math.abs(Math.log(cible/Math.max(reel,1))));
    }
    techsParEre[e].forEach(function(i){
      SC.TECHS[i].cout = Math.max(6, SC.TECHS[i].cout*facteur);
    });
  }
  console.log("itération " + String(it).padStart(2) + " · fin de partie " + (r.fin/3600).toFixed(2)
    + " h · écart max " + ecartMax.toFixed(2)
    + " · durées " + d.map(fmt).join("|"));
  if(ecartMax < .12) break;
}

/* --------------------------------- rapport --------------------------------- */
function arrondi(v){
  if(v < 100) return Math.round(v);
  var e = Math.floor(Math.log10(v)) - 1;
  return Math.round(v/Math.pow(10,e))*Math.pow(10,e);
}
console.log("\n=== COÛTS CALIBRÉS ===");
SC.TECHS.forEach(function(t){
  console.log('  {id:"' + t.id + '", ere:' + t.ere + ', cout:' + arrondi(t.cout) + '},');
});

var fin = partie();
var d = durees(fin.arrivee);
console.log("\n=== VÉRIFICATION ===");
var total = 0;
SC.ERES.forEach(function(e,i){
  if(d[i] !== null) total += d[i];
  console.log(e.an + "  " + e.nom.padEnd(30) + " visé " + fmt(CIBLES[i]) + "   obtenu " + fmt(d[i]));
});
console.log("\npremière partie complète : " + (fin.fin/3600).toFixed(1) + " h");
console.log("chiffre d'affaires final : " + fin.S.ca.toExponential(2) + " €");
console.log("cadence finale : " + SC.jeu.cadence(fin.S).toExponential(2) + " u/s");
