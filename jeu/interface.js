/* Silicium & Cie — interface : panneaux, boucle de rendu, son, sauvegarde. */
(function(){
"use strict";

var q = function(id){ return document.getElementById(id); };
var S = SC.jeu.charger() || SC.jeu.demo();

/* ------------------------------ formats ------------------------------ */
var PALIERS = [["Md",1e9],["M",1e6],["k",1e3]];
function n(v){
  if(!isFinite(v)) return "—";
  var s = v < 0 ? "−" : ""; v = Math.abs(v);
  for(var i=0;i<PALIERS.length;i++){
    if(v >= PALIERS[i][1]){
      var x = v/PALIERS[i][1];
      return s + x.toLocaleString("fr-FR",{maximumFractionDigits: x<10?2:1}) + " " + PALIERS[i][0];
    }
  }
  if(v >= 100) return s + Math.round(v).toLocaleString("fr-FR");
  return s + (Math.round(v*10)/10).toLocaleString("fr-FR");
}
function eur(v){ return n(v) + " €"; }
function pct(v){ return v.toLocaleString("fr-FR",{maximumFractionDigits:1}) + " %"; }

/* ------------------------------ son ------------------------------ */
var audio = {actif:false, ctx:null};
function ctxAudio(){
  if(!audio.ctx){
    var A = window.AudioContext || window.webkitAudioContext;
    if(A) try{ audio.ctx = new A(); }catch(e){ audio.ctx = null; }
  }
  return audio.ctx;
}
function bip(freq, duree, forme, vol, vers){
  if(!audio.actif) return;
  var c = ctxAudio(); if(!c) return;
  if(c.state === "suspended") c.resume();
  var o = c.createOscillator(), g = c.createGain(), t0 = c.currentTime;
  o.type = forme || "square";
  o.frequency.setValueAtTime(freq, t0);
  if(vers) o.frequency.exponentialRampToValueAtTime(vers, t0 + duree);
  g.gain.setValueAtTime(.0001, t0);
  g.gain.exponentialRampToValueAtTime(vol || .05, t0 + .008);
  g.gain.exponentialRampToValueAtTime(.0001, t0 + duree);
  o.connect(g); g.connect(c.destination);
  o.start(t0); o.stop(t0 + duree + .02);
}
var sonAssemblage = function(){ bip(760, .06, "square", .045); };
var sonAchat      = function(){ bip(420, .07, "square", .05); setTimeout(function(){ bip(630,.09,"square",.05); }, 60); };
var sonTech       = function(){ [523,659,784,1047].forEach(function(f,i){ setTimeout(function(){ bip(f,.11,"triangle",.05); }, i*70); }); };
var sonEvenement  = function(bon){ bip(bon?520:180, .3, bon?"triangle":"sawtooth", .05, bon?880:110); };

/* ------------------------------ scène ------------------------------ */
var toile = q("scene"), ctx = toile.getContext("2d");
var vignette = q("vignette");

/* ------------------------------ listes ------------------------------ */
var refStations = [], refTechs = [];

function construireListes(){
  var ls = q("liste-stations"); ls.textContent = "";
  refStations.length = 0;
  SC.STATIONS.forEach(function(st,i){
    var b = document.createElement("button");
    b.type = "button"; b.className = "ligne";
    b.innerHTML = '<span class="palier">' + (i+1) + '</span>'
                + '<span><span class="nom"></span><span class="det"></span></span>'
                + '<span class="droite"><span class="prix"></span><span class="qte"></span></span>';
    b.addEventListener("click", function(){
      if(SC.jeu.acheterStation(S,i)){ sonAchat(); majTout(); flashLigne(b); }
    });
    ls.appendChild(b);
    refStations.push({b:b, nom:b.querySelector(".nom"), det:b.querySelector(".det"),
                      prix:b.querySelector(".prix"), qte:b.querySelector(".qte")});
  });

  var lt = q("liste-techs"); lt.textContent = "";
  refTechs.length = 0;
  SC.TECHS.forEach(function(tk,i){
    var b = document.createElement("button");
    b.type = "button"; b.className = "ligne";
    b.innerHTML = '<img class="ico" alt="" src="' + SC.dessin.iconeURL(tk.icone) + '">'
                + '<span><span class="nom"></span><span class="det"></span></span>'
                + '<span class="droite"><span class="prix"></span><span class="qte"></span></span>';
    b.addEventListener("click", function(){
      var r = SC.jeu.acheterTech(S,i);
      if(!r) return;
      sonTech(); flashLigne(b);
      if(r === "ere") flashEre();
      majProduit(); majTout();
    });
    lt.appendChild(b);
    refTechs.push({b:b, nom:b.querySelector(".nom"), det:b.querySelector(".det"),
                   prix:b.querySelector(".prix"), qte:b.querySelector(".qte")});
  });
}

function flashLigne(b){
  b.classList.remove("neuve");
  void b.offsetWidth;
  b.classList.add("neuve");
}

function majLignes(){
  SC.STATIONS.forEach(function(st,i){
    var r = refStations[i], c = SC.jeu.coutStation(S,i), dispo = S.cash >= c;
    var mp = SC.jeu.multProd(S);
    r.nom.textContent = st.nom;
    r.det.textContent = st.det + " · " + n(st.taux*mp) + " u/s"
      + (S.stations[i] ? " · " + n(S.stations[i]*st.taux*mp) + " u/s au total" : "");
    r.prix.textContent = eur(c);
    r.qte.textContent = S.stations[i] ? "×" + S.stations[i] : "aucun";
    r.b.disabled = !dispo;
    r.b.classList.toggle("abordable", dispo);
    r.b.classList.toggle("possede", S.stations[i] > 0);
  });
  SC.TECHS.forEach(function(tk,i){
    var r = refTechs[i], acquis = !!S.techs[tk.id], dispo = S.rnd >= tk.cout;
    r.nom.textContent = tk.nom;
    r.det.textContent = tk.eff;
    r.prix.textContent = acquis ? "acquis" : n(tk.cout);
    r.qte.textContent = acquis ? "" : "points R&D";
    r.b.disabled = acquis || !dispo;
    r.b.classList.toggle("possede", acquis);
    r.b.classList.toggle("abordable", !acquis && dispo);
  });
}

/* ------------------------------ panneaux ------------------------------ */
function majProduit(){
  var p = SC.jeu.produit(S);
  q("p-annee").textContent = p.an + " · Gamme phare";
  q("p-nom").textContent = p.nom;
  q("p-desc").textContent = p.desc;
  majFrise();
  var e = SC.ERES[SC.jeu.ereIndex(S)];
  q("serie").textContent = e.an + " · " + e.nom;
}

function majHUD(){
  var cad = SC.jeu.cadence(S), pu = SC.jeu.prixUnite(S), bc = SC.jeu.besoinComps(S);
  q("j-cash").textContent = eur(S.cash);
  q("j-rev").textContent  = eur(cad*pu) + "/s";
  q("j-comp").textContent = n(S.comps);
  q("j-rnd").textContent  = n(S.rnd);
  q("j-part").textContent = pct(SC.jeu.partMarche(S));

  q("p-prix").textContent  = eur(pu);
  q("p-comps").textContent = n(bc) + " × " + eur(SC.jeu.prixComp(S));
  q("p-marge").textContent = eur(pu - bc*SC.jeu.prixComp(S));

  q("s-cadence").textContent = n(cad);
  q("s-sortie").textContent  = eur(cad*pu);
  q("h-scene").textContent   = n(S.unites) + " unités vendues";
  q("h-atelier").textContent = SC.ERES[SC.jeu.ereIndex(S)].an;
  q("h-prod").textContent    = n(cad) + " u/s";
  q("h-rnd").textContent     = Object.keys(S.techs).length + "/" + SC.TECHS.length;

  var fc = SC.jeu.forceClic(S);
  q("assembler-sub").textContent = "+" + eur(fc*pu) + " · " + n(fc*bc) + " composants";
  q("assembler").disabled = S.comps < fc*bc;

  var lot = SC.jeu.lotComps(S), coutLot = lot*SC.jeu.prixComp(S);
  q("acheter-comp-t").textContent = "Acheter " + n(lot) + " composants";
  q("acheter-comp-p").textContent = eur(coutLot) + " · " + eur(SC.jeu.prixComp(S)) + " l'unité"
    + (S.techs.appro ? " · rachat auto actif" : "");
  q("acheter-comp").disabled = S.cash < coutLot;

  var bloque = cad > 0 && S.comps < bc;
  q("alerte").classList.toggle("on", bloque);
  q("j-comp-box").classList.toggle("alerte", bloque);

  var act = SC.jeu.actionsIPO(S);
  q("ipo").hidden = act <= 0;
  if(act > 0) q("ipo-p").textContent = act + " actions · +" + (act*8) + " % production et prix, à vie";

  q("pied-stat").textContent = "Chiffre d'affaires cumulé : " + eur(S.caVie)
    + " · " + S.actions + " action" + (S.actions > 1 ? "s" : "")
    + (SC.jeu.stockageOk() ? " · partie sauvegardée dans ce navigateur" : " · sauvegarde indisponible ici");

  majMarche();
  majLignes();
}

/* ------------------------------ marché ------------------------------ */
var refBarre = [], refLegende = [];
function construireMarche(){
  var barre = q("part-barre"), leg = q("legende");
  barre.textContent = ""; leg.textContent = "";
  refBarre.length = 0; refLegende.length = 0;
  var rangs = [{nom:"Silicium & Cie", col:"var(--vous)", moi:true}].concat(
    SC.CONCURRENTS.map(function(c,i){ return {nom:c.nom, col:"var(--rival-" + (i+1) + ")"}; }));
  rangs.forEach(function(r){
    var i = document.createElement("i");
    i.style.background = r.col;
    barre.appendChild(i);
    refBarre.push(i);

    var li = document.createElement("li");
    if(r.moi) li.className = "moi";
    var p = document.createElement("span"); p.className = "pastille"; p.style.background = r.col;
    var nm = document.createElement("span"); nm.textContent = r.nom;
    var v  = document.createElement("span"); v.className = "val";
    li.appendChild(p); li.appendChild(nm); li.appendChild(v);
    leg.appendChild(li);
    refLegende.push(v);
  });
}
function majMarche(){
  var tot = S.puissance + SC.jeu.puissanceRivaux(S);
  var vals = [S.puissance].concat(S.rivaux);
  for(var i=0;i<vals.length;i++){
    var p = tot > 0 ? vals[i]/tot*100 : 0;
    refBarre[i].style.width = p + "%";
    refLegende[i].textContent = pct(p);
  }
}

/* ------------------------------ courbe de revenu ------------------------------ */
function dessinerCourbe(){
  var c = q("courbe"), r = c.getBoundingClientRect();
  if(r.width < 4) return;
  var dpr = Math.min(window.devicePixelRatio || 1, 2);
  c.width = Math.round(r.width*dpr); c.height = Math.round(76*dpr);
  var g = c.getContext("2d");
  g.setTransform(dpr,0,0,dpr,0,0);
  var W = r.width, H = 76, P = 6;
  var css = getComputedStyle(document.body);
  var encre = css.getPropertyValue("--accent").trim();
  var trait = css.getPropertyValue("--line").trim();
  var fond  = css.getPropertyValue("--panel").trim();

  g.clearRect(0,0,W,H);
  var max = Math.max.apply(null, S.hist.concat([1]));
  q("courbe-max").textContent = "maximum " + eur(max) + "/s";

  g.strokeStyle = trait; g.lineWidth = 1;
  g.beginPath(); g.moveTo(0,H-.5); g.lineTo(W,H-.5); g.stroke();
  g.setLineDash([2,4]);
  g.beginPath(); g.moveTo(0,H/2); g.lineTo(W,H/2); g.stroke();
  g.setLineDash([]);

  var pas = W/(S.hist.length-1);
  var py = function(v){ return H - P - (v/max)*(H-P*2); };

  g.beginPath(); g.moveTo(0,H);
  S.hist.forEach(function(v,i){ g.lineTo(i*pas, py(v)); });
  g.lineTo(W,H); g.closePath();
  g.fillStyle = encre; g.globalAlpha = .14; g.fill(); g.globalAlpha = 1;

  g.beginPath();
  S.hist.forEach(function(v,i){ i ? g.lineTo(i*pas,py(v)) : g.moveTo(0,py(v)); });
  g.strokeStyle = encre; g.lineWidth = 2; g.lineJoin = "round"; g.stroke();

  var fin = S.hist[S.hist.length-1];
  g.beginPath(); g.arc(W-1, py(fin), 3.5, 0, Math.PI*2);
  g.fillStyle = encre; g.fill();
  g.strokeStyle = fond; g.lineWidth = 2; g.stroke();
}

/* ------------------------------ journal & frise ------------------------------ */
function majJournal(){
  var u = q("journal"); u.textContent = "";
  S.journal.slice().reverse().forEach(function(l){
    var li = document.createElement("li");
    var t = document.createElement("time"); t.textContent = l.an;
    var s = document.createElement("span"); s.textContent = l.txt;
    li.appendChild(t); li.appendChild(s); u.appendChild(li);
  });
}
function majFrise(){
  var r = q("rail"), e = SC.jeu.ereIndex(S);
  r.textContent = "";
  SC.ERES.forEach(function(x,i){
    var d = document.createElement("div");
    d.className = "etape" + (i < e ? " faite" : "") + (i === e ? " active" : "");
    var an = document.createElement("div"); an.className = "an"; an.textContent = x.an;
    var ti = document.createElement("div"); ti.className = "titre"; ti.textContent = x.nom;
    d.appendChild(an); d.appendChild(ti); r.appendChild(d);
  });
}

/* ------------------------------ événements & ères ------------------------------ */
function montrerEvenement(ev){
  var b = q("banniere");
  q("ev-nom").textContent = ev.n;
  q("ev-eff").textContent = ev.e;
  b.classList.remove("bon","mauvais");
  b.classList.add("on", ev.bon ? "bon" : "mauvais");
  sonEvenement(ev.bon);
  majJournal();
}
function cacherEvenement(){ q("banniere").classList.remove("on"); }

function flashEre(){
  var e = SC.ERES[SC.jeu.ereIndex(S)];
  q("flash-an").textContent = e.an;
  q("flash-t").textContent  = e.nom;
  var el = q("ere-flash");
  el.classList.remove("on"); void el.offsetWidth; el.classList.add("on");
  SC.dessin.confetti();
  bip(440,.14,"square",.05,880);
  setTimeout(function(){ bip(660,.2,"square",.05,1320); }, 150);
  majJournal();
}

/* ------------------------------ actions ------------------------------ */
function assembler(){
  var gain = SC.jeu.assembler(S);
  if(gain <= 0) return;
  sonAssemblage();
  SC.dessin.expedier(S.gamme);
  var b = document.createElement("span");
  b.className = "bulle"; b.textContent = "+" + eur(gain);
  q("assembler").appendChild(b);
  setTimeout(function(){ b.remove(); }, 950);
  var k = q("assembler");
  k.classList.add("enfonce");
  setTimeout(function(){ k.classList.remove("enfonce"); }, 70);
  majHUD();
}

var ipoArme = false, ipoMinuteur = null;
function ipo(){
  if(SC.jeu.actionsIPO(S) <= 0) return;
  if(!ipoArme){
    ipoArme = true;
    q("ipo-t").textContent = "Confirmer : tout repart de zéro";
    clearTimeout(ipoMinuteur);
    ipoMinuteur = setTimeout(function(){ ipoArme = false; q("ipo-t").textContent = "Entrer en bourse"; }, 4000);
    return;
  }
  ipoArme = false;
  q("ipo-t").textContent = "Entrer en bourse";
  var neuf = SC.jeu.ipo(S);
  if(neuf){ S = neuf; SC.dessin.confetti(); sonTech(); majTout(true); }
}

function majTout(reconstruire){
  if(reconstruire) construireListes();
  majProduit();
  majJournal();
  majHUD();
  dessinerCourbe();
}

/* ------------------------------ câblage ------------------------------ */
q("assembler").addEventListener("click", assembler);
q("scene-cadre").addEventListener("click", assembler);
q("acheter-comp").addEventListener("click", function(){
  if(SC.jeu.acheterComposants(S)){ sonAchat(); SC.dessin.livrer(); majHUD(); }
});
q("ipo").addEventListener("click", ipo);
q("reset").addEventListener("click", function(){
  S = SC.jeu.neuve(0);
  SC.jeu.noter(S, "Nouvelle société fondée dans un garage de banlieue.");
  majTout(true);
});

q("curseur-marge").addEventListener("input", function(){
  S.marge = parseInt(this.value,10)/100;
  majMargeTexte();
  majHUD();
});
function majMargeTexte(){
  q("marge-v").textContent = Math.round(S.marge*100) + " %";
  var c = SC.jeu.conquete(S);
  q("marge-effet").textContent = S.marge > 1.02
    ? "Recette en hausse, conquête du marché ralentie (×" + c.toLocaleString("fr-FR",{maximumFractionDigits:2}) + ")."
    : (S.marge < .98
      ? "Recette réduite, parts de marché gagnées plus vite (×" + c.toLocaleString("fr-FR",{maximumFractionDigits:2}) + ")."
      : "Prix du marché : recette et conquête à l'équilibre.");
}

q("theme").addEventListener("click", function(){
  var r = document.documentElement;
  var actuel = r.getAttribute("data-theme");
  var sombre = window.matchMedia("(prefers-color-scheme: dark)").matches;
  r.setAttribute("data-theme", actuel ? (actuel === "dark" ? "light" : "dark") : (sombre ? "light" : "dark"));
  dessinerCourbe();
});
q("son").addEventListener("click", function(){
  audio.actif = !audio.actif;
  this.setAttribute("aria-pressed", audio.actif ? "true" : "false");
  this.textContent = audio.actif ? "🔊" : "🔇";
  this.setAttribute("aria-label", audio.actif ? "Couper le son" : "Activer le son");
  if(audio.actif){ ctxAudio(); bip(880,.08,"square",.04); }
});

document.addEventListener("keydown", function(e){
  if(e.code === "Space" && !/INPUT|TEXTAREA|BUTTON/.test(document.activeElement.tagName)){
    e.preventDefault();
    assembler();
  }
});
window.addEventListener("resize", dessinerCourbe);

/* ------------------------------ boucle ------------------------------ */
var dernier = performance.now(), t = 0, depuisRendu = 0, horlogeSec = 0, caSeconde = 0, horlogeColis = 0;

function boucle(now){
  var dt = (now - dernier)/1000;
  dernier = now;
  if(dt > .5) dt = .5;
  t += dt;

  var res = SC.jeu.tick(S, dt);
  if(res.gain > 0) caSeconde += res.gain;
  if(res.debutEvenement) montrerEvenement(res.debutEvenement);
  if(res.finEvenement) cacherEvenement();

  var cad = SC.jeu.cadence(S);
  if(res.faites > 0){
    horlogeColis += dt;
    if(horlogeColis > .32){ horlogeColis = 0; SC.dessin.expedier(S.gamme); }
  }

  SC.dessin.dessiner(ctx, S, t, dt, res.faites > 0 ? cad : 0);

  depuisRendu += dt;
  if(depuisRendu >= .12){
    depuisRendu = 0;
    majHUD();
    SC.dessin.vignetteProduit(vignette, S.gamme, t);
  }
  horlogeSec += dt;
  if(horlogeSec >= 1){
    horlogeSec -= 1;
    S.hist.push(caSeconde); S.hist.shift(); caSeconde = 0;
    dessinerCourbe();
    SC.jeu.sauver(S);
  }
  requestAnimationFrame(boucle);
}

/* ------------------------------ démarrage ------------------------------ */
function demarrer(){
  construireListes();
  construireMarche();
  q("curseur-marge").value = Math.round(S.marge*100);
  majMargeTexte();
  majTout(false);
  requestAnimationFrame(boucle);
}

var hot = window.claude && window.claude.hot;
if(hot && typeof hot.snapshot === "function") hot.snapshot(function(){ return {etat:S}; });
if(hot && typeof hot.ready === "function"){
  hot.ready(function(d){
    if(d && d.etat) S = d.etat;
    demarrer();
  });
}else{
  demarrer();
}
})();
