/* Vérifie les trois garanties de l'économie du jeu :
   le clic rapporte toujours, les composants restent nettement plus rentables,
   et l'atelier produit hors ligne tant qu'il reste quelqu'un dedans.
   Usage : node outils/verif_economie.js */
global.window = global;
require("../jeu/donnees.js");
require("../jeu/jeu.js");
var J = SC.jeu;

var S = J.neuve(); S.cash = 0; S.comps = 0;
var gains = 0;
for (var i = 0; i < 10; i++) gains += J.assembler(S);
console.log('1) Atelier à sec (0 € / 0 composant), 10 clics : +' + gains.toFixed(2) + ' €');
console.log('   rachat de composants ensuite : ' + (J.acheterComposants(S) ? 'possible' : 'impossible'));

var T = J.neuve(); T.comps = 100; T.cash = 0;
var avec = J.assembler(T);
var U = J.neuve(); U.comps = 0; U.cash = 0;
var sans = J.assembler(U);
console.log('2) Un clic avec composants ' + avec.toFixed(2) + ' € · sans ' + sans.toFixed(2)
          + ' € · rapport ×' + (avec / sans).toFixed(2));

function horsLigne(avecEquipe) {
  var V = J.neuve();
  V.cash = 0; V.comps = 0;
  V.stations = V.stations.map(function () { return 0; });
  if (avecEquipe) {
    V.equipe = [{ car: SC.CARACTERES ? SC.CARACTERES[0].id : 'meticuleux', part: .05, partInitiale: .05,
                  moral: 80, graine: 1, age: 30, retraite: 64, confort: 0, nom: 'Test' }];
  } else V.equipe = [];
  V.majSauvegarde = Date.now() - 4 * 3600 * 1000;
  var avant = V.cash;
  var r = J.rattraper(V);
  return { gain: V.cash - avant, unites: r ? r.unites : 0 };
}
var a = horsLigne(true), b = horsLigne(false);
console.log('3) 4 h hors ligne, 0 station, 0 composant :');
console.log('   avec 1 employé  → +' + a.gain.toFixed(2) + ' € (' + a.unites.toFixed(1) + ' unités)');
console.log('   sans personne   → +' + b.gain.toFixed(2) + ' € (' + b.unites.toFixed(1) + ' unités)');
