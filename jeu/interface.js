/* Silicium & Cie — interface : panneaux, boucle de rendu, son, sauvegarde. */
(function(){
"use strict";

var q = function(id){ return document.getElementById(id); };
var S = SC.jeu.charger() || SC.jeu.demo();

/* ------------------------------ formats ------------------------------ */
var PALIERS = [["Md",1e9],["M",1e6],["k",1e3]];
var EXPOSANTS = ["⁰","¹","²","³","⁴","⁵","⁶","⁷","⁸","⁹"];
function exposant(e){
  return String(e).split("").map(function(c){ return c === "-" ? "⁻" : EXPOSANTS[+c]; }).join("");
}
function n(v){
  if(!isFinite(v)) return "∞";
  var s = v < 0 ? "−" : ""; v = Math.abs(v);
  if(v < 1000) return s + (v >= 100 ? Math.round(v) : Math.round(v*10)/10).toLocaleString("fr-FR");
  if(v < 1e12){
    for(var i=0;i<PALIERS.length;i++){
      if(v >= PALIERS[i][1]){
        var x = v/PALIERS[i][1];
        return s + x.toLocaleString("fr-FR",{maximumFractionDigits: x<10?2:1}) + " " + PALIERS[i][0];
      }
    }
  }
  /* au-delà du millier de milliards, la notation scientifique reste lisible */
  var e = Math.floor(Math.log10(v));
  return s + (v/Math.pow(10,e)).toLocaleString("fr-FR",{maximumFractionDigits:2}) + " ×10" + exposant(e);
}
function eur(v){ return n(v) + " €"; }
function pct(v){ return v.toLocaleString("fr-FR",{maximumFractionDigits:1}) + " %"; }
function duree(s){
  if(s < 90) return Math.round(s) + " secondes";
  if(s < 5400) return Math.round(s/60) + " minutes";
  var hh = Math.floor(s/3600), mm = Math.round((s%3600)/60);
  return hh + " h" + (mm ? " " + String(mm).padStart(2,"0") : "");
}

/* ------------------------------ son ------------------------------ */
var audio = {actif:false, ctx:null};
function ctxAudio(){
  if(!audio.ctx){
    var A = window.AudioContext || window.webkitAudioContext;
    if(A) try{ audio.ctx = new A(); }catch(e){ audio.ctx = null; }
  }
  return audio.ctx;
}
function bip(freq, dur, forme, vol, vers){
  if(!audio.actif) return;
  var c = ctxAudio(); if(!c) return;
  if(c.state === "suspended") c.resume();
  var o = c.createOscillator(), g = c.createGain(), t0 = c.currentTime;
  o.type = forme || "square";
  o.frequency.setValueAtTime(freq, t0);
  if(vers) o.frequency.exponentialRampToValueAtTime(vers, t0 + dur);
  g.gain.setValueAtTime(.0001, t0);
  g.gain.exponentialRampToValueAtTime(vol || .05, t0 + .008);
  g.gain.exponentialRampToValueAtTime(.0001, t0 + dur);
  o.connect(g); g.connect(c.destination);
  o.start(t0); o.stop(t0 + dur + .02);
}
function sonAssemblage(){ bip(760, .06, "square", .045); }
function sonAchat(){ bip(420,.07,"square",.05); setTimeout(function(){ bip(630,.09,"square",.05); }, 60); }
function sonTech(){ [523,659,784,1047].forEach(function(f,i){ setTimeout(function(){ bip(f,.11,"triangle",.05); }, i*70); }); }
function sonEvenement(bon){ bip(bon?520:180, .3, bon?"triangle":"sawtooth", .05, bon?880:110); }
function sonJalon(){ [784,988,1319].forEach(function(f,i){ setTimeout(function(){ bip(f,.13,"triangle",.045); }, i*90); }); }

/* ------------------------------ scène ------------------------------ */
var toile = q("scene"), ctx = toile.getContext("2d");
var vignette = q("vignette");

/* ------------------------------ listes ------------------------------ */
var refStations = [], refTechs = [], refHolding = [], refJalons = [];
var visibleStations = 0, visibleTechs = 0;

function stationsVisibles(){
  var dernier = -1;
  for(var i=0;i<SC.STATIONS.length;i++) if(S.stations[i] > 0) dernier = i;
  return Math.min(SC.STATIONS.length, Math.max(3, dernier + 3));
}
function techsVisibles(){
  var e = SC.jeu.ereIndex(S), k = 0;
  for(var i=0;i<SC.TECHS.length;i++) if(SC.TECHS[i].ere <= e + 1) k = i + 1;
  return k;
}

function construireStations(){
  var ls = q("liste-stations"); ls.textContent = "";
  refStations.length = 0;
  visibleStations = stationsVisibles();
  for(var i=0;i<visibleStations;i++){
    (function(i){
      var b = document.createElement("button");
      b.type = "button"; b.className = "ligne";
      b.innerHTML = '<span class="palier">' + (i+1) + '</span>'
                  + '<span><span class="nom"></span><span class="det"></span></span>'
                  + '<span class="droite"><span class="prix"></span><span class="qte"></span></span>';
      b.addEventListener("click", function(){
        if(SC.jeu.acheterStation(S,i)){ sonAchat(); flash(b); majTout(); }
      });
      ls.appendChild(b);
      refStations.push({i:i, b:b, nom:b.querySelector(".nom"), det:b.querySelector(".det"),
                        prix:b.querySelector(".prix"), qte:b.querySelector(".qte")});
    })(i);
  }
}

function construireTechs(){
  var lt = q("liste-techs"); lt.textContent = "";
  refTechs.length = 0;
  visibleTechs = techsVisibles();
  var ereCourante = -1;
  for(var i=0;i<visibleTechs;i++){
    var tk = SC.TECHS[i];
    if(tk.ere !== ereCourante){
      ereCourante = tk.ere;
      var sep = document.createElement("div");
      sep.className = "separateur";
      var g1 = document.createElement("span"); g1.textContent = SC.ERES[tk.ere].an;
      var g2 = document.createElement("span"); g2.textContent = SC.ERES[tk.ere].nom;
      sep.appendChild(g1); sep.appendChild(g2);
      lt.appendChild(sep);
    }
    (function(i,tk){
      var b = document.createElement("button");
      b.type = "button"; b.className = "ligne";
      b.innerHTML = '<img class="ico" alt="" src="' + SC.dessin.iconeURL(tk.icone) + '">'
                  + '<span><span class="nom"></span><span class="det"></span></span>'
                  + '<span class="droite"><span class="prix"></span><span class="qte"></span></span>';
      b.addEventListener("click", function(){
        var r = SC.jeu.acheterTech(S,i);
        if(!r) return;
        sonTech(); flash(b);
        if(r === "ere") flashEre();
        majProduit(); majTout();
      });
      lt.appendChild(b);
      refTechs.push({i:i, b:b, nom:b.querySelector(".nom"), det:b.querySelector(".det"),
                     prix:b.querySelector(".prix"), qte:b.querySelector(".qte")});
    })(i,tk);
  }
}

function construireHolding(){
  var lh = q("liste-holding"); lh.textContent = "";
  refHolding.length = 0;
  SC.HOLDING.forEach(function(u,i){
    var b = document.createElement("button");
    b.type = "button"; b.className = "ligne";
    b.innerHTML = '<span class="palier">◆</span>'
                + '<span><span class="nom"></span><span class="det"></span></span>'
                + '<span class="droite"><span class="prix"></span><span class="qte">parts</span></span>';
    b.addEventListener("click", function(){
      if(SC.jeu.acheterHolding(S,i)){ sonTech(); flash(b); majTout(); }
    });
    lh.appendChild(b);
    refHolding.push({u:u, b:b, nom:b.querySelector(".nom"), det:b.querySelector(".det"),
                     prix:b.querySelector(".prix"), qte:b.querySelector(".qte")});
  });
}

function construireJalons(){
  var g = q("jalons"); g.textContent = "";
  refJalons.length = 0;
  SC.JALONS.forEach(function(j){
    var d = document.createElement("div");
    d.className = "jalon";
    d.title = j.desc + " — production +" + Math.round(j.bonus*100) + " %";
    var b = document.createElement("b"); b.textContent = j.nom;
    var s = document.createElement("span"); s.textContent = j.desc;
    d.appendChild(b); d.appendChild(s);
    g.appendChild(d);
    refJalons.push({j:j, d:d});
  });
}

function flash(b){ b.classList.remove("neuve"); void b.offsetWidth; b.classList.add("neuve"); }

/* ------------------------------ mises à jour ------------------------------ */
function majLignes(){
  if(stationsVisibles() !== visibleStations) construireStations();
  if(techsVisibles() !== visibleTechs) construireTechs();

  var mp = SC.jeu.multProd(S);
  refStations.forEach(function(r){
    var st = SC.STATIONS[r.i], c = SC.jeu.coutStation(S,r.i), dispo = S.cash >= c;
    r.nom.textContent = st.nom;
    r.det.textContent = st.det + " · " + n(st.taux*mp) + " u/s"
      + (S.stations[r.i] ? " · " + n(S.stations[r.i]*st.taux*mp) + " u/s au total" : "");
    r.prix.textContent = eur(c);
    r.qte.textContent = S.stations[r.i] ? "×" + n(S.stations[r.i]) : "aucun";
    r.b.disabled = !dispo;
    r.b.classList.toggle("abordable", dispo);
    r.b.classList.toggle("possede", S.stations[r.i] > 0);
  });

  refTechs.forEach(function(r){
    var tk = SC.TECHS[r.i], acquis = !!S.techs[tk.id];
    var cout = SC.jeu.coutTech(S,r.i), dispo = S.rnd >= cout;
    r.nom.textContent = tk.nom;
    r.det.textContent = tk.eff;
    r.prix.textContent = acquis ? "acquis" : n(cout);
    r.qte.textContent = acquis ? "" : "points R&D";
    r.b.disabled = acquis || !dispo;
    r.b.classList.toggle("possede", acquis);
    r.b.classList.toggle("abordable", !acquis && dispo);
  });

  refHolding.forEach(function(r){
    var acquis = !!S.holding[r.u.id], dispo = S.parts >= r.u.cout;
    r.nom.textContent = r.u.nom;
    r.det.textContent = r.u.eff;
    r.prix.textContent = acquis ? "actif" : r.u.cout;
    r.qte.textContent = acquis ? "" : "parts";
    r.b.disabled = acquis || !dispo;
    r.b.classList.toggle("possede", acquis);
    r.b.classList.toggle("abordable", !acquis && dispo);
  });

  var acquis = 0;
  refJalons.forEach(function(r){
    var ok = !!S.jalons[r.j.id];
    if(ok) acquis++;
    r.d.classList.toggle("acquis", ok);
  });
  q("h-jalons").textContent = acquis + "/" + SC.JALONS.length
    + " · production +" + Math.round((SC.jeu.bonusJalons(S)-1)*100) + " %";
}

function majProduit(){
  var p = SC.jeu.produit(S);
  q("p-annee").textContent = p.an + " · Gamme phare";
  q("p-nom").textContent = p.nom;
  q("p-desc").textContent = p.desc;
  var e = SC.ERES[SC.jeu.ereIndex(S)];
  q("serie").textContent = e.an + " · " + e.nom;
  majFrise();
}

function majHUD(){
  var cad = SC.jeu.cadence(S), pu = SC.jeu.prixUnite(S), bc = SC.jeu.besoinComps(S);
  q("j-cash").textContent = eur(S.cash);
  q("j-rev").textContent  = eur(cad*pu) + "/s";
  q("j-comp").textContent = n(S.comps);
  q("j-rnd").textContent  = n(S.rnd);
  q("j-part").textContent = pct(SC.jeu.partMarche(S));
  q("j-act-box").hidden = S.actions < 1;
  q("j-act").textContent = n(Math.floor(S.actions));
  q("j-part-h-box").hidden = S.parts < 1;
  q("j-parts").textContent = n(S.parts);

  q("p-prix").textContent  = eur(pu);
  q("p-comps").textContent = n(bc) + " × " + eur(SC.jeu.prixComp(S));
  q("p-marge").textContent = eur(pu - bc*SC.jeu.prixComp(S));

  q("s-cadence").textContent = n(cad);
  q("s-sortie").textContent  = eur(cad*pu);
  q("h-scene").textContent   = n(S.unites) + " unités vendues";
  q("h-atelier").textContent = SC.ERES[SC.jeu.ereIndex(S)].an;
  q("h-prod").textContent    = n(SC.jeu.totalStations(S)) + " en service · " + n(cad) + " u/s";
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

  majConglomerat();
  q("pied-stat").textContent = "Chiffre d'affaires cumulé : " + eur(S.caVie)
    + " · " + duree(S.joue) + " de jeu"
    + " · " + S.ipos + " introduction" + (S.ipos > 1 ? "s" : "") + " en bourse"
    + (SC.jeu.stockageOk() ? " · partie sauvegardée dans ce navigateur" : " · sauvegarde indisponible ici");

  majMarche();
  majEquipe();
  majLignes();
}

function majConglomerat(){
  var pa = SC.jeu.partsConglomerat(S);
  var visible = S.parts > 0 || S.congs > 0 || S.actions >= 100;
  q("bloc-conglomerat").hidden = !visible;
  if(!visible) return;
  q("h-holding").textContent = Object.keys(S.holding).length + "/" + SC.HOLDING.length
    + " · " + n(S.parts) + " part" + (S.parts > 1 ? "s" : "");
  q("conglo-note").textContent = pa > 0
    ? "Solder les actions pour fonder une holding : tout repart de zéro, les parts restent."
    : "Il faut 150 actions pour convertir votre groupe en holding. Vous en détenez "
      + n(Math.floor(S.actions)) + ".";
  q("conglo").hidden = pa <= 0;
  if(pa > 0) q("conglo-p").textContent = pa + " part" + (pa>1?"s":"") + " de holding · production et prix ×1,3 par part";
}

/* ------------------------------ équipe ------------------------------ */
var signatureEquipe = "";

function majEquipe(){
  /* candidature en attente */
  var c = S.candidat;
  q("candidature").hidden = !c;
  if(c){
    var car = SC.jeu.caractere(c.car);
    q("cand-portrait").src = SC.dessin.portraitURL(c.graine, c.age);
    q("cand-portrait").alt = "Portrait de " + c.prenom + " " + c.nom;
    q("cand-nom").textContent = c.prenom + " " + c.nom;
    q("cand-car").textContent = car.nom + " · " + Math.round(c.age) + " ans"
      + (c.origine ? " · vient de chez " + c.origine : " · " + c.poste.toLowerCase());
    q("cand-eff").textContent = car.eff;
    q("cand-part").textContent = (c.indemnite ? "indemnité " + eur(c.indemnite) + " · " : "")
      + (c.part*100).toLocaleString("fr-FR",{maximumFractionDigits:2}) + " % du chiffre d'affaires";
    q("candidature").classList.toggle("debauchage", !!c.origine);
    q("embaucher").disabled = !!c.indemnite && S.cash < c.indemnite;
  }

  /* la liste n'est reconstruite que lorsque l'effectif change */
  var sig = S.equipe.map(function(e){ return e.graine + ":" + (e.binome||0) + ":" + Math.floor(e.age/6); }).join(",");
  if(sig !== signatureEquipe){ construireEquipe(); signatureEquipe = sig; }

  S.equipe.forEach(function(e,i){
    var r = refEquipe[i];
    if(!r) return;
    var m = Math.max(0, Math.min(100, e.moral));
    r.barre.style.width = m + "%";
    r.jauge.classList.toggle("tiede", m < 55 && m >= 25);
    r.jauge.classList.toggle("froid", m < 25);
    r.moral.textContent = Math.round(m) + " % de moral";
    r.part.textContent = (e.part*100).toLocaleString("fr-FR",{maximumFractionDigits:2}) + " % du CA";
    var cp = SC.jeu.coutPrime(S,i);
    r.prime.textContent = "Prime " + eur(cp);
    r.prime.disabled = S.cash < cp || m >= 99;
    r.augmenter.disabled = m >= 99 || e.part >= e.partInitiale*4;
    r.age.textContent = Math.round(e.age) + " ans · "
      + Math.max(0, Math.round(e.anciennete/360)) + " an(s) de maison";
    r.binome.textContent = appairage === e.graine ? "Annuler"
      : appairage ? "Avec " + prenomDe(appairage)
      : e.binome ? "Séparer" : "Binôme";
  });

  var masse = SC.jeu.masseSalariale(S);
  q("h-equipe").textContent = S.equipe.length + "/" + SC.jeu.placesEquipe(S)
    + (S.equipe.length ? " · masse salariale " + pct(masse*100) : "");
  q("j-masse-box").hidden = S.equipe.length === 0;
  q("j-masse").textContent = pct(masse*100);
  q("equipe-note").textContent = S.equipe.length === 0
    ? "Personne à l'atelier. Les candidatures arrivent d'elles-mêmes quand la production tourne."
    : "Le moral suit vos prix, les arrêts de chaîne et les crises. Sous 45 %, la concurrence commence à débaucher.";
}

var appairage = null;
function prenomDe(graine){
  for(var i=0;i<S.equipe.length;i++) if(S.equipe[i].graine === graine) return S.equipe[i].prenom;
  return "…";
}
function clicBinome(i){
  var e = S.equipe[i];
  if(!e) return;
  if(appairage === e.graine){ appairage = null; }
  else if(appairage){
    var j = -1;
    for(var k=0;k<S.equipe.length;k++) if(S.equipe[k].graine === appairage) j = k;
    appairage = null;
    if(j >= 0 && j !== i && SC.jeu.apparier(S, j, i)){ sonTech(); majJournal(); }
  }
  else if(e.binome){ SC.jeu.separer(S, i); }
  else { appairage = e.graine; }
  majHUD();
}

var refEquipe = [];
function construireEquipe(){
  var g = q("equipe"); g.textContent = "";
  refEquipe.length = 0;
  S.equipe.forEach(function(e,i){
    var car = SC.jeu.caractere(e.car);
    var d = document.createElement("div");
    d.className = "fiche-emp";
    d.innerHTML =
      '<img class="portrait" alt="">' +
      '<div class="emp-txt"><b></b><span class="emp-role"></span>' +
        '<span class="emp-age"></span><span class="emp-eff"></span></div>' +
      '<div class="emp-moral"><div class="barre-moral"><i></i></div>' +
        '<div class="emp-chiffres"><span class="m"></span></div>' +
        '<div class="emp-chiffres"><span class="s"></span></div></div>' +
      '<div class="emp-actions"><button type="button" class="prime"></button>' +
        '<button type="button" class="aug">Augmenter</button>' +
        '<button type="button" class="duo"></button></div>';
    var img = d.querySelector(".portrait");
    img.src = SC.dessin.portraitURL(e.graine, e.age);
    img.alt = "Portrait de " + e.prenom + " " + e.nom;
    d.querySelector("b").textContent = e.prenom + " " + e.nom;
    var duo = SC.jeu.partenaire(S, e);
    var y = duo ? SC.jeu.synergie(e, duo) : null;
    d.querySelector(".emp-role").textContent = car.nom + " · " + e.poste.toLowerCase();
    d.querySelector(".emp-eff").textContent = car.eff
      + (duo ? " — en binôme avec " + duo.prenom + (y ? " · " + y.nom + " : " + y.eff : " (effets +50 %)") : "");
    if(duo) d.classList.add("apparie");
    if(e.forme) d.classList.add("forme");
    var bPrime = d.querySelector(".prime"), bAug = d.querySelector(".aug"), bDuo = d.querySelector(".duo");
    bDuo.addEventListener("click", function(){ clicBinome(i); });
    bPrime.addEventListener("click", function(){
      if(SC.jeu.prime(S,i)){ sonAchat(); majHUD(); }
    });
    bAug.addEventListener("click", function(){
      if(SC.jeu.augmenter(S,i)){ sonAchat(); majJournal(); majHUD(); }
    });
    g.appendChild(d);
    refEquipe.push({
      jauge:d.querySelector(".barre-moral"), barre:d.querySelector(".barre-moral i"),
      moral:d.querySelector(".m"), part:d.querySelector(".s"), age:d.querySelector(".emp-age"),
      prime:bPrime, augmenter:bAug, binome:bDuo
    });
  });
}

function annoncerRetraites(liste){
  var d = q("depart");
  d.classList.remove("on");
  d.classList.add("retraite","on");
  d.textContent = liste.map(function(r){
    return r.partant.prenom + " " + r.partant.nom + " part à la retraite ; "
      + r.releve.prenom + " " + r.releve.nom + " prend la suite, formé" + " par ses soins.";
  }).join(" ");
  clearTimeout(minuteurDepart);
  minuteurDepart = setTimeout(function(){ d.classList.remove("on","retraite"); }, 10000);
  sonJalon();
  SC.dessin.confetti();
  majJournal();
}

var minuteurDepart = null;
function annoncerDeparts(partis){
  var d = q("depart");
  d.textContent = partis.map(function(e){ return e.prenom + " " + e.nom; }).join(", ")
    + (partis.length > 1 ? " quittent l'atelier." : " quitte l'atelier.");
  d.classList.remove("retraite");
  d.classList.add("on");
  clearTimeout(minuteurDepart);
  minuteurDepart = setTimeout(function(){ d.classList.remove("on"); }, 9000);
  bip(300, .25, "sawtooth", .05, 140);
  majJournal();
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
    barre.appendChild(i); refBarre.push(i);
    var li = document.createElement("li");
    if(r.moi) li.className = "moi";
    var p = document.createElement("span"); p.className = "pastille"; p.style.background = r.col;
    var nm = document.createElement("span"); nm.textContent = r.nom;
    var v = document.createElement("span"); v.className = "val";
    li.appendChild(p); li.appendChild(nm); li.appendChild(v);
    leg.appendChild(li); refLegende.push(v);
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

/* ------------------------------ courbe ------------------------------ */
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

function confirmationDouble(bouton, libelle, action){
  var arme = false, minuteur = null, txt = bouton.querySelector(".t") || bouton;
  var original = txt.textContent;
  bouton.addEventListener("click", function(){
    if(!arme){
      arme = true; txt.textContent = libelle;
      clearTimeout(minuteur);
      minuteur = setTimeout(function(){ arme = false; txt.textContent = original; }, 4000);
      return;
    }
    arme = false; txt.textContent = original;
    action();
  });
}

function majTout(reconstruire){
  if(reconstruire){
    construireStations(); construireTechs(); construireHolding(); construireJalons();
    signatureEquipe = "\u0000";
  }
  majProduit(); majJournal(); majHUD(); dessinerCourbe();
}

/* ------------------------------ câblage ------------------------------ */
q("assembler").addEventListener("click", assembler);
q("scene-cadre").addEventListener("click", assembler);
q("acheter-comp").addEventListener("click", function(){
  if(SC.jeu.acheterComposants(S)){ sonAchat(); SC.dessin.livrer(); majHUD(); }
});
confirmationDouble(q("ipo"), "Confirmer : tout repart de zéro", function(){
  var neuf = SC.jeu.ipo(S);
  if(neuf){ S = neuf; SC.dessin.confetti(); sonTech(); majTout(true); }
});
confirmationDouble(q("conglo"), "Confirmer : les actions sont soldées", function(){
  var neuf = SC.jeu.conglomerat(S);
  if(neuf){ S = neuf; SC.dessin.confetti(); sonJalon(); majTout(true); }
});
confirmationDouble(q("reset"), "Confirmer l'abandon", function(){
  S = SC.jeu.neuve(null);
  SC.jeu.noter(S, "Nouvelle société fondée dans un garage de banlieue.");
  majTout(true);
});

q("curseur-marge").addEventListener("input", function(){
  S.marge = parseInt(this.value,10)/100;
  majMargeTexte(); majHUD();
});
function majMargeTexte(){
  q("marge-v").textContent = Math.round(S.marge*100) + " %";
  var c = SC.jeu.conquete(S);
  var f = c.toLocaleString("fr-FR",{maximumFractionDigits:2});
  q("marge-effet").textContent = S.marge > 1.02
    ? "Recette en hausse, conquête du marché ralentie (×" + f + ")."
    : (S.marge < .98
      ? "Recette réduite, parts de marché gagnées plus vite (×" + f + ")."
      : "Prix du marché : recette et conquête à l'équilibre (×" + f + ").");
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
q("retour-ok").addEventListener("click", function(){ q("voile-retour").hidden = true; });
q("embaucher").addEventListener("click", function(){
  if(SC.jeu.embaucher(S)){ sonTech(); majJournal(); majHUD(); }
});
q("refuser").addEventListener("click", function(){
  if(SC.jeu.refuser(S)) majHUD();
});

document.addEventListener("keydown", function(e){
  if(e.code === "Space" && !/INPUT|TEXTAREA|BUTTON/.test(document.activeElement.tagName)){
    e.preventDefault(); assembler();
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
  if(res.jalons){ sonJalon(); majJournal(); }
  if(res.partis) annoncerDeparts(res.partis);
  if(res.retraites) annoncerRetraites(res.retraites);

  if(res.faites > 0){
    horlogeColis += dt;
    if(horlogeColis > .32){ horlogeColis = 0; SC.dessin.expedier(S.gamme); }
  }

  SC.dessin.dessiner(ctx, S, t, dt, res.faites > 0 ? SC.jeu.cadence(S) : 0);

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
function montrerRetour(r){
  q("retour-duree").textContent = "L'atelier a tourné au ralenti pendant " + duree(r.duree) + ".";
  q("retour-unites").textContent = n(r.unites);
  q("retour-gain").textContent = eur(r.gain);
  q("retour-note").textContent = r.plafonne
    ? "La production hors ligne est plafonnée à douze heures — au-delà, les équipes s'arrêtent."
    : "Hors ligne, la chaîne tourne à 60 % de sa cadence.";
  q("voile-retour").hidden = false;
}

function demarrer(){
  construireStations(); construireTechs(); construireHolding(); construireJalons();
  construireMarche();
  q("curseur-marge").value = Math.round(S.marge*100);
  majMargeTexte();
  majTout(false);
  var r = SC.jeu.rattraper(S);
  if(r) montrerRetour(r);
  requestAnimationFrame(boucle);
}

var hot = window.claude && window.claude.hot;
if(hot && typeof hot.snapshot === "function") hot.snapshot(function(){ return {etat:S}; });
if(hot && typeof hot.ready === "function"){
  hot.ready(function(d){ if(d && d.etat) S = d.etat; demarrer(); });
}else{
  demarrer();
}
})();
