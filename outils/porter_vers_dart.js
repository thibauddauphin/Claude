/* Génère les tables Dart depuis les données JS, pour éviter toute transcription manuelle. */
global.window = global;
require('../jeu/donnees.js');
const fs = require('fs');
const sortie = '../mobile/lib/layers/functional/Partie/domain/catalogue/';

const txt = s => "'" + String(s).replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\$/g, '\\$') + "'";
const num = v => Number.isInteger(v) ? v : v;

/* ---- technologies ---- */
let d = "import '../entities/technologie.dart';\n\nconst technologies = <Technologie>[\n";
SC.TECHS.forEach(t => {
  const opt = [];
  if (t.ouvre !== undefined) opt.push(`ouvre: ${t.ouvre}`);
  if (t.prod) opt.push(`production: ${t.prod}`);
  if (t.prix) opt.push(`prix: ${t.prix}`);
  if (t.conq) opt.push(`conquete: ${t.conq}`);
  d += `  Technologie(\n    id: ${txt(t.id)}, ere: ${t.ere}, nom: ${txt(t.nom)},\n`
     + `    cout: ${num(t.cout)}, effet: ${txt(t.eff)}, icone: ${txt(t.icone)},\n`
     + (opt.length ? `    ${opt.join(', ')},\n` : '')
     + `  ),\n`;
});
fs.writeFileSync(sortie + 'technologies.dart', d + '];\n');

/* ---- événements ---- */
const cible = {prix:'prix', prod:'production', rnd:'recherche', comp:'composants'};
d = "import '../entities/evenement.dart';\n\nconst evenements = <Evenement>[\n";
SC.EVENEMENTS.forEach(e => {
  d += `  Evenement(\n    nom: ${txt(e.n)}, effet: ${txt(e.e)},\n`
     + `    cible: CibleEvenement.${cible[e.cle]}, facteur: ${e.v}, estFavorable: ${e.bon},\n  ),\n`;
});
fs.writeFileSync(sortie + 'evenements.dart', d + '];\n');

/* ---- concurrents ---- */
d = "import '../entities/concurrent.dart';\n\nconst concurrents = <Concurrent>[\n";
SC.CONCURRENTS.forEach(c => {
  d += `  Concurrent(\n    nom: ${txt(c.nom)}, puissanceInitiale: ${c.p},\n`
     + `    poids: ${c.poids}, rattrapage: ${c.rattrapage}, croissanceDeFond: ${c.c},\n  ),\n`;
});
fs.writeFileSync(sortie + 'concurrents.dart', d + '];\n');

/* ---- jalons ---- */
const mesure = {unites:'unites', ca:'chiffreAffaires', stations:'stations', techs:'technologies',
                part:'partMarche', ere:'ere', ipo:'introductions', actions:'actions', parts:'parts'};
d = "import '../entities/jalon.dart';\n\nconst jalons = <Jalon>[\n";
SC.JALONS.forEach(j => {
  d += `  Jalon(\n    id: ${txt(j.id)}, nom: ${txt(j.nom)},\n    description: ${txt(j.desc)},\n`
     + `    mesure: MesureJalon.${mesure[j.cle]}, seuil: ${j.seuil}, bonus: ${j.bonus},\n  ),\n`;
});
fs.writeFileSync(sortie + 'jalons.dart', d + '];\n');

/* ---- conglomérat ---- */
d = "import '../entities/amelioration_holding.dart';\n\nconst ameliorationsHolding = <AmeliorationHolding>[\n";
SC.HOLDING.forEach(h => {
  d += `  AmeliorationHolding(\n    id: ${txt(h.id)}, nom: ${txt(h.nom)}, cout: ${h.cout},\n    effet: ${txt(h.eff)},\n  ),\n`;
});
fs.writeFileSync(sortie + 'ameliorations_holding.dart', d + '];\n');

/* ---- caractères, synergies, noms ---- */
d = "import '../entities/caractere.dart';\n\nconst caracteres = <Caractere>[\n";
SC.CARACTERES.forEach(c => {
  const opt = [];
  if (c.prod) opt.push(`production: ${c.prod}`);
  if (c.prix) opt.push(`prix: ${c.prix}`);
  if (c.rnd) opt.push(`recherche: ${c.rnd}`);
  if (c.comp) opt.push(`composants: ${c.comp}`);
  if (c.conq) opt.push(`conquete: ${c.conq}`);
  if (c.moral) opt.push(`protectionMoral: ${c.moral}`);
  if (c.stoique) opt.push(`estStoique: true`);
  d += `  Caractere(\n    id: ${txt(c.id)}, nom: ${txt(c.nom)}, effet: ${txt(c.eff)},\n`
     + `    part: ${c.part},\n` + (opt.length ? `    ${opt.join(', ')},\n` : '') + `  ),\n`;
});
d += '];\n\nconst synergies = <Synergie>[\n';
SC.SYNERGIES.forEach(y => {
  const opt = [];
  if (y.prod) opt.push(`production: ${y.prod}`);
  if (y.prix) opt.push(`prix: ${y.prix}`);
  if (y.rnd) opt.push(`recherche: ${y.rnd}`);
  if (y.comp) opt.push(`composants: ${y.comp}`);
  if (y.conq) opt.push(`conquete: ${y.conq}`);
  if (y.plancher) opt.push(`plancherMoral: ${y.plancher}`);
  d += `  Synergie(\n    a: ${txt(y.a)}, b: ${txt(y.b)}, nom: ${txt(y.nom)}, effet: ${txt(y.eff)},\n`
     + (opt.length ? `    ${opt.join(', ')},\n` : '') + `  ),\n`;
});
d += "];\n\n/// Prénoms par génération : l'atelier recrute dans son époque.\nconst prenomsParGeneration = <List<String>>[\n";
SC.PRENOMS.forEach(g => { d += '  [' + g.map(txt).join(', ') + '],\n'; });
d += '];\n\nconst nomsDeFamille = <String>[\n  ' + SC.NOMS.map(txt).join(', ') + ',\n];\n\n';
d += 'const motifsDepart = <String>[\n' + SC.DEPARTS.map(m => '  ' + txt(m) + ',\n').join('') + '];\n\n';
d += 'const motifsRetraite = <String>[\n' + SC.RETRAITES.map(m => '  ' + txt(m) + ',\n').join('') + '];\n';
fs.writeFileSync(sortie + 'equipe.dart', d);

console.log('généré :', fs.readdirSync(sortie).join(', '));
