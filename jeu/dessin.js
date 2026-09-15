/* Silicium & Cie — pixel-art procédurale : décors, stations, produits, particules.
   Tout est dessiné au rectangle sur une grille logique de 384 × 216. */
(function(){
"use strict";

var L_W = 384, L_H = 216;          /* résolution logique */
var SOL  = 138;                    /* ligne de sol */
var TAPIS = 190;                   /* haut du tapis roulant */

var C = {
  noir:"#0e0c11", nuit:"#171320", ombre:"#2a2230",
  bois:"#8a5f33", boisF:"#63451f", boisC:"#b2814a",
  metal:"#7f8695", metalF:"#4c525e", metalC:"#b9c0cd",
  beige:"#d9cfb2", beigeF:"#ab9f80", beigeC:"#efe7d0",
  peau:["#e3a877","#c98a5c","#8d5a36"], peauF:"#a9754a",
  bleu:"#3d6fa6", bleuF:"#27476d", bleuC:"#74a6d8",
  rouge:"#b8402c", rougeC:"#e06a4e",
  ambre:"#ffb347", ambreF:"#c2761c",
  vert:"#4f9a5f", vertPCB:"#2c6b4a", vertC:"#8ed08a",
  blanc:"#f3edde", gris:"#6d6757", grisC:"#9c957f",
  violet:"#7a5bb5", cyan:"#57c8d6", jaune:"#f2d16b"
};

var DECORS = {
  garage:     {mur:"#b9ab8e", murF:"#98886a", sol:"#7d6e55", solF:"#5f5340", ciel:"#8fb8d8"},
  salon:      {mur:"#c3a67f", murF:"#a08560", sol:"#8a6547", solF:"#6b4d35", ciel:"#a8c8e0"},
  minitel:    {mur:"#b7bfae", murF:"#949c8b", sol:"#6f7468", solF:"#565b50", ciel:"#9fc0d6"},
  bureau:     {mur:"#cdc4ac", murF:"#a79f89", sol:"#4d5b72", solF:"#3a4557", ciel:"#b9d2e6"},
  openspace:  {mur:"#d5d1c1", murF:"#aeab9d", sol:"#8e8e8a", solF:"#6e6e6b", ciel:"#c6dced"},
  multimedia: {mur:"#7f6f9a", murF:"#63567a", sol:"#6d5a48", solF:"#53442f", ciel:"#4a5f92"},
  loft:       {mur:"#9d6150", murF:"#7b4a3c", sol:"#6f7073", solF:"#54555a", ciel:"#d0d8de"},
  bulle:      {mur:"#c8c3b4", murF:"#a29d8f", sol:"#8d8779", solF:"#6c6759", ciel:"#a9b4bd"},
  habitat:    {mur:"#d3c3a6", murF:"#ac9d82", sol:"#8d6f4f", solF:"#6c5339", ciel:"#93b6d4"},
  showroom:   {mur:"#e6e3dc", murF:"#c4c1b9", sol:"#c9c7c2", solF:"#a5a39e", ciel:"#dfeaf2"},
  datacenter: {mur:"#2c3b4c", murF:"#1f2b38", sol:"#243240", solF:"#18222c", ciel:"#1b4a63"},
  objets:     {mur:"#5c6470", murF:"#464d57", sol:"#3e444d", solF:"#2d323a", ciel:"#7f93a8"},
  hall:       {mur:"#1b1a24", murF:"#131219", sol:"#14131c", solF:"#0d0c12", ciel:"#2a2340"},
  quantique:  {mur:"#16232e", murF:"#101a23", sol:"#0e1720", solF:"#091018", ciel:"#1d5a70"},
  neuro:      {mur:"#1a1420", murF:"#120e17", sol:"#140f1a", solF:"#0c0812", ciel:"#37205a"}
};

function px(g,x,y,w,h,c){ g.fillStyle=c; g.fillRect(Math.round(x),Math.round(y),Math.round(w),Math.round(h)); }
function ligneH(g,x,y,w,c){ px(g,x,y,w,1,c); }

/* ============================ personnages ============================ */

var TENUES = ["#b8402c","#3d6fa6","#4f9a5f","#7a5bb5","#c2761c","#57738a"];

/* ouvrier debout, 9 × 15, (x,y) = coin haut gauche de la tête */
function ouvrier(g,x,y,i,anim){
  var tenue = TENUES[i % TENUES.length], peau = C.peau[i % C.peau.length];
  var br = anim ? (Math.sin(anim)>0 ? 0 : 2) : 0;
  px(g,x+2,y,5,1,C.noir);
  px(g,x+1,y+1,1,2,C.noir);  px(g,x+7,y+1,1,2,C.noir);
  px(g,x+2,y+1,5,4,peau);
  px(g,x+3,y+2,1,1,C.noir);  px(g,x+5,y+2,1,1,C.noir);
  px(g,x+1,y+5,7,6,tenue);
  px(g,x,y+6,1,4,tenue);
  px(g,x+8,y+6+br,1,3,tenue);
  px(g,x+8,y+9+br,1,1,peau);
  px(g,x+1,y+11,3,3,C.metalF);
  px(g,x+5,y+11,3,3,C.metalF);
  px(g,x,y+14,4,1,C.noir);  px(g,x+5,y+14,4,1,C.noir);
  return {mx:x+8, my:y+9+br};
}

/* personnage assis, 9 × 12 */
function assis(g,x,y,i,anim){
  var tenue = TENUES[(i+2) % TENUES.length], peau = C.peau[(i+1) % C.peau.length];
  var br = anim ? (Math.sin(anim)>0 ? 0 : 1) : 0;
  px(g,x+2,y,5,1,C.noir);
  px(g,x+2,y+1,5,4,peau);
  px(g,x+3,y+2,1,1,C.noir); px(g,x+5,y+2,1,1,C.noir);
  px(g,x+1,y+5,7,5,tenue);
  px(g,x+8,y+6+br,2,2,tenue);
  px(g,x+1,y+10,7,2,C.metalF);
  return {mx:x+9, my:y+7+br};
}

/* ============================ particules ============================ */

var parts = [];
function part(o){ if(parts.length < 160) parts.push(o); }

function etincelle(x,y){
  part({x:x, y:y, vx:(Math.random()-.5)*26, vy:-8-Math.random()*18,
        v:.35+Math.random()*.25, t:0, c:Math.random()<.5?C.ambre:C.jaune, r:1});
}
function fumee(x,y,c){
  part({x:x, y:y, vx:(Math.random()-.5)*6, vy:-10, v:1.1, t:0, c:c||"#b9b4aa", r:2, flou:1});
}
function confetti(x,y){
  part({x:x, y:y, vx:(Math.random()-.5)*70, vy:-40-Math.random()*50, g:60,
        v:2.2, t:0, c:[C.ambre,C.rouge,C.vertC,C.bleuC,C.blanc][Math.floor(Math.random()*5)], r:2});
}

function majParticules(dt){
  for(var i=parts.length-1;i>=0;i--){
    var p = parts[i];
    p.t += dt;
    p.x += p.vx*dt; p.y += p.vy*dt;
    if(p.g) p.vy += p.g*dt;
    if(p.t >= p.v) parts.splice(i,1);
  }
}
function dessinerParticules(g){
  for(var i=0;i<parts.length;i++){
    var p = parts[i], reste = 1 - p.t/p.v;
    if(p.flou && reste < .5) continue;
    px(g, p.x, p.y, p.r, p.r, p.c);
  }
}

/* ============================ décor ============================ */

function fond(g, ere, t){
  var d = DECORS[SC.ERES[ere].decor];
  px(g,0,0,L_W,SOL,d.mur);
  px(g,0,SOL-3,L_W,3,d.murF);
  px(g,0,SOL,L_W,L_H-SOL,d.sol);
  for(var x=0;x<L_W;x+=24) px(g,x,SOL,1,L_H-SOL,d.solF);
  ligneH(g,0,SOL,L_W,d.solF);

  switch(SC.ERES[ere].decor){
    case "garage":     decorGarage(g,d,t); break;
    case "salon":      decorSalon(g,d,t); break;
    case "minitel":    decorMinitel(g,d,t); break;
    case "bureau":     decorBureau(g,d,t); break;
    case "openspace":  decorOpenspace(g,d,t); break;
    case "multimedia": decorMultimedia(g,d,t); break;
    case "loft":       decorLoft(g,d,t); break;
    case "bulle":      decorBulle(g,d,t); break;
    case "habitat":    decorHabitat(g,d,t); break;
    case "showroom":   decorShowroom(g,d,t); break;
    case "datacenter": decorDatacenter(g,d,t); break;
    case "objets":     decorObjets(g,d,t); break;
    case "hall":       decorHall(g,d,t); break;
    case "quantique":  decorQuantique(g,d,t); break;
    case "neuro":      decorNeuro(g,d,t); break;
  }
}

function fenetre(g,x,y,w,h,d){
  px(g,x-2,y-2,w+4,h+4,C.boisF);
  px(g,x,y,w,h,d.ciel);
  px(g,x,y+h-4,w,4,"#6f8f5f");
  px(g,x+w/2-1,y,2,h,C.boisF);
  ligneH(g,x,y+Math.round(h/2),w,C.boisF);
  px(g,x+2,y+2,4,3,"#ffffff22");
}
function ampoule(g,x,y,t,allumee){
  var osc = Math.sin(t*.7)*1.5;
  px(g,x+2,0,1,y,C.metalF);
  px(g,x+osc,y,5,4,allumee?C.jaune:C.grisC);
  if(allumee){
    px(g,x-3+osc,y+4,11,2,"#ffe08a33");
    px(g,x-6+osc,y+6,17,3,"#ffe08a18");
  }
}
function etagere(g,x,y,w){
  px(g,x,y,w,2,C.bois);
  px(g,x,y+2,2,3,C.boisF); px(g,x+w-2,y+2,2,3,C.boisF);
  for(var i=0;i<Math.floor(w/9);i++){
    var h = 5 + (i*7)%6;
    px(g,x+3+i*9, y-h, 7, h, i%2 ? C.bois : C.boisC);
    px(g,x+4+i*9, y-h+2, 5, 1, C.beigeF);
  }
}
function affiche(g,x,y,fondC,motif){
  px(g,x,y,18,24,C.beigeC);
  px(g,x+1,y+1,16,22,fondC);
  px(g,x+3,y+4,12,10,motif);
  px(g,x+3,y+17,12,1,C.beigeC);
  px(g,x+3,y+19,8,1,C.beigeC);
}
function plante(g,x,y){
  px(g,x+2,y-6,2,6,"#4a7a3a");
  px(g,x,y-10,3,5,"#5d9448"); px(g,x+4,y-12,3,7,"#6ba553"); px(g,x+2,y-14,2,5,"#5d9448");
  px(g,x,y,7,5,"#a8613c"); px(g,x,y,7,1,"#c07a4e");
}
function horloge(g,x,y,t){
  px(g,x,y,11,11,C.beigeC); px(g,x+1,y+1,9,9,C.blanc);
  var a = t*.35;
  px(g,x+5+Math.cos(a)*3, y+5+Math.sin(a)*3, 1,1, C.noir);
  px(g,x+5+Math.cos(a*12)*4, y+5+Math.sin(a*12)*4, 1,1, C.rouge);
  px(g,x+5,y+5,1,1,C.noir);
}

function decorGarage(g,d,t){
  /* porte de garage à droite */
  px(g,250,26,124,SOL-26,"#a8a094");
  for(var y=30;y<SOL-4;y+=9){ px(g,250,y,124,2,"#8b8378"); }
  px(g,250,26,124,2,C.metalF);
  fenetre(g,40,34,44,30,d);
  etagere(g,120,74,70);
  ampoule(g,180,0,t,true);
  affiche(g,104,26,C.bleu,C.ambre);
  plante(g,232,SOL);
}
function decorSalon(g,d,t){
  for(var x=0;x<L_W;x+=8) px(g,x,0,3,SOL-3,"#00000010");
  fenetre(g,34,30,50,34,d);
  etagere(g,110,70,84);
  affiche(g,212,24,C.rouge,C.jaune);
  horloge(g,252,30,t);
  ampoule(g,150,0,t,true);
  plante(g,286,SOL);
  /* poste de télévision */
  px(g,306,SOL-30,46,30,C.boisF);
  px(g,310,SOL-26,34,20,C.noir);
  px(g,311,SOL-25,32,18, (Math.floor(t*3)%2) ? "#2d4a66" : "#38597a");
  px(g,346,SOL-24,4,4,C.ambre);
}
function decorBureau(g,d,t){
  fenetre(g,24,26,64,40,d);
  fenetre(g,108,26,64,40,d);
  ligneH(g,0,SOL-26,L_W,d.murF);
  affiche(g,194,30,C.vertPCB,C.beigeC);
  horloge(g,226,32,t);
  etagere(g,254,76,60);
  px(g,330,SOL-34,38,34,C.metal);       /* armoire à dossiers */
  px(g,333,SOL-30,32,8,C.metalF); px(g,333,SOL-19,32,8,C.metalF);
  px(g,346,SOL-27,6,2,C.metalC); px(g,346,SOL-16,6,2,C.metalC);
}
function decorOpenspace(g,d,t){
  px(g,0,18,L_W,4,C.metalC);
  for(var x=16;x<L_W;x+=64){ px(g,x,20,40,5,"#f6f4ec"); px(g,x,25,40,1,"#00000018"); }
  fenetre(g,36,34,80,44,d);
  fenetre(g,140,34,80,44,d);
  affiche(g,244,36,C.bleu,C.blanc);
  plante(g,300,SOL);
  px(g,322,SOL-40,44,40,C.metalC);      /* distributeur */
  px(g,326,SOL-36,36,22,C.noir);
  px(g,328,SOL-34,32,18,"#3a4a58");
  px(g,338,SOL-12,12,6,C.rouge);
}
function decorLoft(g,d,t){
  for(var y=8;y<SOL-3;y+=7)
    for(var x=(y%14?0:-8); x<L_W; x+=17) px(g,x,y,15,5,"#00000012");
  fenetre(g,26,22,90,56,d);
  px(g,140,20,60,26,C.noir); px(g,143,23,54,20,C.vertC);   /* enseigne */
  px(g,146,28,6,10,C.noir); px(g,155,28,6,10,C.noir); px(g,164,28,6,10,C.noir);
  etagere(g,222,72,60);
  plante(g,300,SOL);
  px(g,318,SOL-24,52,24,C.boisF);       /* canapé de start-up */
  px(g,318,SOL-30,52,8,C.rouge);
  px(g,322,SOL-22,44,4,C.rougeC);
}
function decorShowroom(g,d,t){
  px(g,0,10,L_W,6,"#ffffff");
  for(var x=20;x<L_W;x+=56) px(g,x,16,28,3,"#ffffffcc");
  px(g,30,30,110,60,"#dcd9d2"); px(g,34,34,102,52,"#ffffff");
  for(var i=0;i<3;i++) px(g,44+i*32,46,20,28,"#c9c6c0");   /* mur de présentation */
  affiche(g,170,34,C.noir,C.blanc);
  px(g,214,SOL-54,68,54,"#ffffff");     /* podium vitré */
  px(g,214,SOL-54,68,2,"#d2cfc8");
  px(g,240,SOL-40,16,26,C.noir);
  px(g,242,SOL-38,12,22,(Math.floor(t*2)%2)?"#4aa3d8":"#6fbde8");
  plante(g,306,SOL);
}
function decorDatacenter(g,d,t){
  for(var x=8;x<L_W-8;x+=26){
    px(g,x,24,20,SOL-30,"#1a242e");
    px(g,x,24,20,2,"#33465a");
    for(var y=30;y<SOL-10;y+=6){
      var on = ((Math.floor(t*4)+x+y) % 7) < 4;
      px(g,x+3,y,3,2, on ? C.cyan : "#1d3240");
      px(g,x+13,y,3,2, on ? "#3f7f9a" : "#1d3240");
    }
  }
  px(g,0,6,L_W,4,"#2a4a5e");
  for(var i=0;i<L_W;i+=48) px(g,i,10,24,2,"#5fd0e0aa");
}
function decorHall(g,d,t){
  px(g,0,0,L_W,SOL,"#1b1a24");
  for(var x=0;x<L_W;x+=48){
    var pulse = .4 + .6*Math.abs(Math.sin(t*.8 + x*.03));
    px(g,x+6,12,36,2,C.violet);
    g.globalAlpha = pulse; px(g,x+6,14,36,1,C.cyan); g.globalAlpha = 1;
  }
  for(var i=0;i<6;i++){
    var bx = 14 + i*62;
    px(g,bx,34,44,SOL-42,"#101019");
    px(g,bx,34,44,2,"#2c2a3e");
    for(var j=0;j<5;j++){
      var a = .25 + .75*Math.abs(Math.sin(t*1.6 + i + j*.7));
      g.globalAlpha = a;
      px(g,bx+5,42+j*14,34,3, j%2 ? C.ambre : C.violet);
      g.globalAlpha = 1;
    }
  }
}


/* ---- 1982 : l'agence des télécommunications ---- */
function decorMinitel(g,d,t){
  ligneH(g,0,SOL-30,L_W,d.murF);
  fenetre(g,20,26,52,34,d);
  /* mur d'annuaires */
  for(var r=0;r<3;r++)
    for(var i=0;i<9;i++)
      px(g,92+i*7, 44+r*16, 5, 14, i%3 ? "#c9b98e" : "#a8823f");
  px(g,90,58,66,2,C.metalF); px(g,90,74,66,2,C.metalF); px(g,90,90,66,2,C.metalF);
  affiche(g,172,30,"#2f5f7a",C.beigeC);
  horloge(g,204,32,t);
  /* guichet avec terminal */
  px(g,240,SOL-26,84,26,"#9a8d72");
  px(g,240,SOL-30,84,4,"#b7a98c");
  px(g,262,SOL-48,30,22,"#d8d2bd");
  px(g,265,SOL-45,22,14,"#1d2a1e");
  var l = Math.floor(t*4)%4;
  for(var k=0;k<3;k++) px(g,267, SOL-43+k*4, (k===l?18:11), 2, "#7fd08a");
  px(g,262,SOL-26,30,4,"#c2bca7");
  plante(g,336,SOL);
}

/* ---- 1995 : la chambre multimédia ---- */
function decorMultimedia(g,d,t){
  for(var x=0;x<L_W;x+=6) px(g,x,0,2,SOL-3,"#ffffff08");
  affiche(g,26,24,"#1e2a52","#d8a23f");
  affiche(g,52,30,"#5a1e2a","#e0d060");
  fenetre(g,96,28,44,30,d);
  /* étagère à disques */
  px(g,160,52,78,3,C.boisF);
  for(var i=0;i<13;i++) px(g,163+i*6, 38, 4, 14, i%2 ? "#d8d8e0" : "#8f8fa8");
  px(g,160,84,78,3,C.boisF);
  for(var j=0;j<13;j++) px(g,163+j*6, 70, 4, 14, j%3 ? "#c0c8d8" : "#c05a5a");
  /* chaîne hi-fi */
  px(g,258,SOL-40,52,40,"#26262e");
  px(g,262,SOL-36,44,10,"#15151a");
  px(g,265,SOL-33,8,4, (Math.floor(t*3)%2) ? "#7fd08a" : "#2a5a36");
  px(g,276,SOL-33,26,4,"#3a5a7a");
  px(g,264,SOL-22,20,20,"#1a1a20"); px(g,288,SOL-22,20,20,"#1a1a20");
  px(g,270,SOL-16,8,8,"#3a3a46"); px(g,294,SOL-16,8,8,"#3a3a46");
  plante(g,330,SOL);
}

/* ---- 2000 : les bureaux après le krach ---- */
function decorBulle(g,d,t){
  /* rectangles clairs : les affiches décrochées */
  px(g,34,28,30,38,"#d6d1c2"); px(g,78,34,24,30,"#d6d1c2");
  px(g,120,26,40,26,"#d6d1c2");
  fenetre(g,190,26,58,36,d);
  px(g,262,30,44,20,C.beigeC); px(g,264,32,40,16,"#b8352a");
  px(g,268,36,32,3,C.beigeC); px(g,268,41,20,3,C.beigeC);
  /* cartons empilés et chaise seule */
  for(var i=0;i<7;i++){
    var cx = 24 + (i%4)*15, cy = SOL - 11 - Math.floor(i/4)*11;
    px(g,cx,cy,13,11,C.bois); px(g,cx,cy,13,2,C.boisC); px(g,cx+6,cy+2,2,9,C.boisF);
  }
  px(g,300,SOL-24,4,24,C.metalF);
  px(g,288,SOL-26,28,3,"#4a4a52");
  px(g,288,SOL-44,4,18,C.metalF); px(g,288,SOL-44,24,3,"#4a4a52");
  px(g,296,SOL-2,14,2,"#00000033");
}

/* ---- 2004 : le salon raccordé ---- */
function decorHabitat(g,d,t){
  for(var x=0;x<L_W;x+=14) px(g,x,0,6,SOL-3,"#00000008");
  fenetre(g,28,28,50,34,d);
  affiche(g,100,30,"#2a5a4a",C.beigeC);
  /* meuble télé + box */
  px(g,150,SOL-34,84,34,C.boisF);
  px(g,150,SOL-38,84,4,C.boisC);
  px(g,158,SOL-70,58,32,"#1c1c22");
  px(g,161,SOL-67,52,26, (Math.floor(t*2)%2) ? "#2f5f8a" : "#3a6f9a");
  px(g,222,SOL-52,20,14,"#e4e0d6");
  for(var k=0;k<4;k++){
    var on = ((Math.floor(t*5)+k)%5) < 3;
    px(g,225+k*4, SOL-48, 2, 2, on ? "#5fc07a" : "#3a5a42");
  }
  px(g,238,SOL-56,1,6,C.metalC); px(g,241,SOL-58,1,8,C.metalC);
  /* canapé */
  px(g,264,SOL-26,74,26,"#7a5f6a");
  px(g,264,SOL-36,74,10,"#8d6f7c");
  px(g,264,SOL-24,10,24,"#6b5260"); px(g,328,SOL-24,10,24,"#6b5260");
  plante(g,352,SOL);
}

/* ---- 2016 : l'entrepôt de capteurs ---- */
function decorObjets(g,d,t){
  for(var c=0;c<7;c++){
    var bx = 6 + c*54;
    px(g,bx,20,46,SOL-26,"#4a515c");
    for(var r=0;r<4;r++){
      px(g,bx,26+r*24,46,3,"#6a7381");
      for(var i=0;i<7;i++){
        var on = ((Math.floor(t*6)+c*3+r*2+i) % 9) < 3;
        px(g,bx+3+i*6, 30+r*24, 4, 4, on ? "#6fd8c0" : "#39424d");
      }
    }
    px(g,bx+3,24,18,2,"#c9d2dd");
  }
  /* navette au sol */
  var nx = (t*26) % (L_W+60) - 30;
  px(g,nx,SOL+10,30,10,"#d8a23f");
  px(g,nx+4,SOL+6,22,4,"#b9822a");
  px(g,nx+3,SOL+20,6,4,"#1a1a20"); px(g,nx+21,SOL+20,6,4,"#1a1a20");
}

/* ---- 2031 : le laboratoire cryogénique ---- */
function decorQuantique(g,d,t){
  px(g,0,0,L_W,SOL,"#16232e");
  for(var i=0;i<L_W;i+=64) px(g,i+8,6,48,2,"#3f8fa8");
  /* lustre : étages de cuivre suspendus */
  var cx = 192, brille = .55 + .45*Math.abs(Math.sin(t*1.1));
  px(g,cx-1,0,3,18,"#8a7a4a");
  for(var e=0;e<6;e++){
    var w = 66 - e*9, y = 18 + e*17;
    px(g,cx-w/2, y, w, 4, "#c9962f");
    px(g,cx-w/2, y+4, w, 2, "#8a6a1f");
    for(var k=-2;k<=2;k++) px(g,cx+k*(w/6), y+6, 2, 11, "#a8802a");
  }
  g.globalAlpha = brille;
  px(g,cx-10,SOL-22,20,20,"#6fd8ec");
  px(g,cx-16,SOL-14,32,10,"#6fd8ec33");
  g.globalAlpha = 1;
  px(g,cx-6,SOL-16,12,12,"#d8f6ff");
  /* bâtis latéraux */
  px(g,14,40,54,SOL-46,"#1d2b38"); px(g,14,40,54,2,"#31526a");
  px(g,316,40,54,SOL-46,"#1d2b38"); px(g,316,40,54,2,"#31526a");
  for(var j=0;j<5;j++){
    px(g,20,48+j*14,42,6,"#16222c");
    px(g,322,48+j*14,42,6,"#16222c");
    px(g,56,50+j*14,4,2,"#6fd8ec"); px(g,358,50+j*14,4,2,"#6fd8ec");
  }
}

/* ---- 2040 : la salle de culture neuromorphique ---- */
function decorNeuro(g,d,t){
  px(g,0,0,L_W,SOL,"#1a1420");
  /* colonnes de substrat */
  for(var c=0;c<6;c++){
    var x = 16 + c*62, pulse = .3 + .7*Math.abs(Math.sin(t*.9 + c*.9));
    px(g,x,22,34,SOL-30,"#241a2e");
    px(g,x,22,34,2,"#4a3a60");
    g.globalAlpha = pulse;
    px(g,x+5,30,24,SOL-46,"#8a5fd8");
    px(g,x+9,36,16,SOL-58,"#c89ff0");
    g.globalAlpha = 1;
    /* filaments */
    for(var k=0;k<5;k++){
      var y = 36 + k*16;
      var ondul = Math.sin(t*1.3 + k + c)*4;
      segment(g, x+9, y, x+25, y+ondul, "#e0c0ff", 1);
    }
    px(g,x+2,SOL-10,30,8,"#191222");
  }
  for(var i=0;i<L_W;i+=8){
    var a = .1 + .25*Math.abs(Math.sin(t*.6 + i*.05));
    g.globalAlpha = a; px(g,i,8,5,2,"#a87fe8"); g.globalAlpha = 1;
  }
}

/* ============================ stations ============================ */
/* chaque vignette occupe une cellule de 92 × 46, base = bas de cellule */

function badge(g,x,y,n){
  if(n<=0) return;
  var etiquette = n >= 1000 ? "×" + (n/1000).toFixed(1).replace(".",",") + "k" : "×" + n;
  var s = etiquette, w = 4 + s.length*4;
  px(g,x,y,w,7,C.noir);
  px(g,x+1,y+1,w-2,5,C.ambre);
  g.fillStyle = C.noir;
  g.font = "6px monospace";
  g.textBaseline = "top";
  g.fillText(s, x+2, y+1);
}

var STATION_BASE = [
/* 0 — établi de garage */
function(g,x,b,n,t,act){
  var a = act ? t*7 : 0;
  var m = ouvrier(g, x+38, b-31, 0, a);
  px(g,x+16,b-14,52,3,C.boisC);          /* plateau */
  px(g,x+16,b-11,52,2,C.boisF);
  px(g,x+18,b-9,4,9,C.bois); px(g,x+62,b-9,4,9,C.bois);
  px(g,x+24,b-18,16,4,C.vertPCB);        /* carte en cours */
  px(g,x+26,b-17,3,2,C.metalC); px(g,x+33,b-17,4,2,C.metalC);
  px(g,x+50,b-19,6,5,C.rouge);           /* bobine d'étain */
  if(act && Math.random()<.5) etincelle(m.mx, m.my);
},
/* 1 — stagiaire en BTS */
function(g,x,b,n,t,act){
  var a = act ? t*6 : 0;
  px(g,x+14,b-16,56,3,C.beigeF);         /* bureau */
  px(g,x+16,b-13,3,13,C.metalF); px(g,x+66,b-13,3,13,C.metalF);
  assis(g,x+26,b-29,1,a);
  px(g,x+22,b-26,4,10,C.metalF);         /* dossier de chaise */
  px(g,x+40,b-24,18,8,C.beige);          /* écran */
  px(g,x+42,b-22,14,4,"#2f5a3c");
  px(g,x+46,b-16,6,2,C.beigeF);
  px(g,x+56,b-19,10,3,C.beigeC);         /* clavier */
  px(g,x+18,b-21,8,5,C.vertPCB);         /* pile de cartes */
  px(g,x+18,b-24,8,3,C.vert);
},
/* 2 — technicien d'atelier */
function(g,x,b,n,t,act){
  var a = act ? t*8 : 0;
  px(g,x+12,b-18,60,3,C.metalC);
  px(g,x+14,b-15,3,15,C.metalF); px(g,x+68,b-15,3,15,C.metalF);
  ouvrier(g,x+22,b-35,2,a);
  /* oscilloscope */
  px(g,x+42,b-36,28,18,C.beigeF);
  px(g,x+45,b-33,17,12,"#0d2418");
  var pc = C.vertC;
  for(var i=0;i<16;i++){
    var yy = b-27 + Math.sin(t*6 + i*.8)*4;
    px(g,x+45+i, yy, 1,1, pc);
  }
  px(g,x+64,b-33,4,3,C.ambre); px(g,x+64,b-27,4,3,C.rouge);
  px(g,x+20,b-22,14,4,C.vertPCB);
},
/* 3 — chaîne d'assemblage */
function(g,x,b,n,t,act){
  var d = act ? (t*26)%8 : 0;
  px(g,x+8,b-14,76,6,C.metalF);          /* tapis */
  px(g,x+8,b-14,76,1,C.metalC);
  for(var i=-1;i<11;i++) px(g,x+10+i*8+d, b-12, 3, 2, C.metal);
  px(g,x+10,b-8,4,8,C.metalF); px(g,x+78,b-8,4,8,C.metalF);
  for(var j=0;j<4;j++) px(g,x+14+((j*22+d*2)%74), b-18, 10, 4, C.vertPCB);
  /* presse qui monte et descend */
  var h = act ? Math.abs(Math.sin(t*3))*6 : 3;
  px(g,x+40,b-40,16,6,C.rouge);
  px(g,x+46,b-34,4,10-h,C.metalC);
  px(g,x+42,b-24-h,12,6,C.metalF);
  assis(g,x+64,b-30,3,act?t*5:0);
},
/* 4 — usine sous-traitée */
function(g,x,b,n,t,act){
  px(g,x+10,b-34,64,34,C.beigeF);        /* bâtiment */
  px(g,x+10,b-34,64,3,C.metalF);
  for(var i=0;i<5;i++)
    for(var j=0;j<2;j++){
      var on = act && ((Math.floor(t*2)+i*3+j) % 5) < 3;
      px(g,x+15+i*12, b-28+j*12, 8, 7, on ? C.ambre : "#5c5646");
    }
  px(g,x+62,b-52,8,18,C.beigeF);         /* cheminée */
  px(g,x+62,b-52,8,2,C.metalF);
  px(g,x+30,b-8,14,8,C.noir);            /* porte */
  if(act && Math.random()<.2) fumee(x+64, b-54);
},
/* 5 — robot de pose CMS */
function(g,x,b,n,t,act){
  px(g,x+10,b-12,72,4,C.metalF);
  px(g,x+14,b-16,20,4,C.vertPCB);
  px(g,x+52,b-16,20,4,C.vertPCB);
  px(g,x+38,b-10,16,10,C.metalC);        /* socle */
  var a1 = act ? Math.sin(t*2.2)*.7 : .3;
  var a2 = act ? Math.sin(t*2.2+1.3)*.9 : -.4;
  var px0 = x+46, py0 = b-10;
  var x1 = px0 + Math.cos(a1-1.2)*16, y1 = py0 + Math.sin(a1-1.2)*16;
  var x2 = x1 + Math.cos(a2-.4)*14,  y2 = y1 + Math.sin(a2-.4)*14;
  segment(g,px0,py0,x1,y1,C.ambreF,3);
  segment(g,x1,y1,x2,y2,C.ambre,2);
  px(g,x2-1,y2-1,3,3,C.rouge);
  if(act && Math.random()<.25) etincelle(x2,y2);
},
/* 6 — ferme de serveurs */
function(g,x,b,n,t,act){
  for(var r=0;r<3;r++){
    var rx = x+12 + r*24;
    px(g,rx,b-42,20,42,"#1f2a34");
    px(g,rx,b-42,20,2,"#3d5163");
    for(var i=0;i<7;i++){
      var on = act && ((Math.floor(t*5)+r*2+i) % 6) < 4;
      px(g,rx+3, b-38+i*5, 10, 3, on ? "#2f4d5f" : "#233542");
      px(g,rx+15, b-38+i*5, 2, 3, on ? C.cyan : "#1c2b36");
    }
  }
  px(g,x+8,b-46,72,4,C.metalF);
},
/* 7 — ordonnanceur autonome */
function(g,x,b,n,t,act){
  px(g,x+26,b-48,40,48,"#13121c");
  px(g,x+26,b-48,40,2,C.violet);
  var pulse = act ? .45 + .55*Math.abs(Math.sin(t*1.7)) : .3;
  g.globalAlpha = pulse;
  px(g,x+34,b-38,24,24,C.violet);
  px(g,x+38,b-34,16,16,C.cyan);
  g.globalAlpha = 1;
  px(g,x+42,b-30,8,8,C.blanc);
  for(var i=0;i<6;i++){
    var an = t*1.1 + i*1.05;
    px(g, x+46 + Math.cos(an)*22, b-26 + Math.sin(an)*13, 2,2, i%2?C.ambre:C.cyan);
  }
}
];

/* ---- 5 : usine intégrée ---- */
function usineIntegree(g,x,b,n,t,act){
  px(g,x+6,b-40,52,40,"#a89a7c");
  px(g,x+6,b-40,52,3,C.metalF);
  px(g,x+6,b-30,52,2,"#8d8065");
  for(var e=0;e<2;e++)
    for(var i=0;i<4;i++){
      var on = act && ((Math.floor(t*2)+i*2+e)%5) < 3;
      px(g,x+11+i*12, b-26+e*13, 8, 8, on ? C.ambre : "#5c5646");
    }
  /* pont roulant */
  px(g,x+4,b-48,72,3,C.metalF);
  var gx = x + 10 + (act ? (Math.sin(t*.9)*.5+.5)*52 : 26);
  px(g,gx,b-45,3,10,C.metalC);
  px(g,gx-3,b-35,9,6,C.rouge);
  /* quai et camion */
  px(g,x+60,b-14,22,14,"#7b6d55");
  px(g,x+62,b-12,18,3,C.boisC);
  if(act && Math.random()<.12) fumee(x+16,b-44);
  px(g,x+14,b-52,7,12,"#9a8d72"); px(g,x+14,b-52,7,2,C.metalF);
}

/* ---- 7 : ligne automatisée ---- */
function ligneAutomatisee(g,x,b,n,t,act){
  px(g,x+4,b-30,76,22,"#4f5560");
  px(g,x+4,b-30,76,2,"#79808d");
  px(g,x+4,b-8,76,8,"#3a3f48");
  /* hublots : les cartes défilent derrière la vitre */
  var d = act ? (t*30)%14 : 0;
  for(var i=0;i<5;i++){
    px(g,x+9+i*15, b-26, 11, 12, "#1b2029");
    var px0 = x+9+i*15 + ((d + i*4) % 14) - 3;
    px(g,px0, b-22, 6, 3, C.vertPCB);
  }
  /* bras de transfert */
  var h = act ? Math.abs(Math.sin(t*2.6))*5 : 2;
  px(g,x+36,b-44,12,5,"#79808d");
  px(g,x+41,b-39,3,8-h,C.metalC);
  px(g,x+37,b-31-h,10,4,C.ambreF);
  for(var k=0;k<4;k++){
    var on = act && ((Math.floor(t*4)+k)%4) < 2;
    px(g,x+10+k*18, b-6, 5, 3, on ? C.vertC : "#2c313a");
  }
}

/* ---- 9 : fonderie dédiée ---- */
function fonderie(g,x,b,n,t,act){
  px(g,x+6,b-44,74,44,"#dfe3e6");
  px(g,x+6,b-44,74,3,"#b6bcc2");
  px(g,x+6,b-12,74,2,"#c4c9ce");
  /* deux opérateurs en combinaison */
  for(var i=0;i<2;i++){
    var ox = x + 16 + i*34;
    px(g,ox+2,b-34,7,1,"#eef1f3");
    px(g,ox+2,b-33,7,5,"#f4f6f8");
    px(g,ox+3,b-31,5,2,"#38506a");
    px(g,ox+1,b-28,9,12,"#f4f6f8");
    px(g,ox+1,b-16,3,4,"#d8dde2"); px(g,ox+6,b-16,3,4,"#d8dde2");
  }
  /* galette en cours de gravure */
  var lueur = act ? .4 + .6*Math.abs(Math.sin(t*2.1)) : .25;
  px(g,x+30,b-24,24,10,"#9aa3ab");
  g.globalAlpha = lueur;
  px(g,x+34,b-22,16,6,"#7fe0ff");
  px(g,x+30,b-30,24,6,"#7fe0ff55");
  g.globalAlpha = 1;
  px(g,x+6,b-54,74,10,"#c9ced3");
  for(var k=0;k<4;k++) px(g,x+12+k*18, b-52, 10, 6, act && (Math.floor(t*3)+k)%3 ? "#eef6fa" : "#c4d2da");
}

/* ---- 11 : essaim d'usines noires ---- */
function essaim(g,x,b,n,t,act){
  for(var i=0;i<4;i++){
    var cx = x + 6 + (i%2)*40, cy = b - 40 + Math.floor(i/2)*22;
    px(g,cx,cy,34,20,"#0f0f16");
    px(g,cx,cy,34,2,"#2a2a3a");
    var a = act ? .25 + .75*Math.abs(Math.sin(t*1.4 + i*1.1)) : .2;
    g.globalAlpha = a;
    px(g,cx+4,cy+6,26,2,i%2 ? C.violet : C.cyan);
    px(g,cx+4,cy+12,18,2,i%2 ? C.cyan : C.violet);
    g.globalAlpha = 1;
  }
  /* drones de navette */
  for(var k=0;k<3;k++){
    var an = t*1.6 + k*2.1;
    var dx = x + 44 + Math.cos(an)*34, dy = b - 30 + Math.sin(an)*16;
    px(g,dx,dy,3,2,C.ambre);
    px(g,dx-1,dy-1,1,1,"#ffffff88"); px(g,dx+3,dy-1,1,1,"#ffffff88");
  }
}

/* ordre d'affichage aligné sur SC.STATIONS */
var STATION_DESSIN = [
  STATION_BASE[0], STATION_BASE[1], STATION_BASE[2], STATION_BASE[3],
  STATION_BASE[4], usineIntegree, STATION_BASE[5], ligneAutomatisee,
  STATION_BASE[6], fonderie, STATION_BASE[7], essaim
];

function segment(g,x1,y1,x2,y2,c,ep){
  var n = Math.max(Math.abs(x2-x1), Math.abs(y2-y1));
  for(var i=0;i<=n;i++) px(g, x1+(x2-x1)*i/n, y1+(y2-y1)*i/n, ep, ep, c);
}

/* ============================ produits ============================ */

var PRODUIT_BASE = [
/* 0 kit à souder */ function(g,x,y){
  px(g,x,y+2,14,7,C.vertPCB); px(g,x,y+2,14,1,C.vert);
  px(g,x+2,y+4,4,3,C.noir); px(g,x+8,y+4,3,2,C.metalC); px(g,x+8,y+7,4,1,C.ambre);
},
/* 1 micro familial */ function(g,x,y){
  px(g,x+1,y,12,6,C.beige); px(g,x+3,y+1,8,3,"#2f5a3c");
  px(g,x,y+6,14,4,C.beigeF); px(g,x+1,y+7,12,1,C.beigeC);
},
/* 2 compatible PC */ function(g,x,y){
  px(g,x,y,7,7,C.beige); px(g,x+1,y+1,5,4,"#28425a");
  px(g,x+8,y+1,5,9,C.beigeF); px(g,x+9,y+3,3,1,C.noir); px(g,x+9,y+6,3,1,C.ambre);
  px(g,x,y+8,7,2,C.beigeF);
},
/* 3 portable LCD */ function(g,x,y){
  px(g,x,y,13,6,"#3a3a3e"); px(g,x+1,y+1,11,4,"#6f9ea8");
  px(g,x,y+6,14,3,"#4a4a50"); px(g,x+2,y+7,10,1,"#6a6a72");
},
/* 4 serveur 1U */ function(g,x,y){
  px(g,x,y+2,14,6,"#2b3540"); px(g,x,y+2,14,1,"#49607a");
  px(g,x+2,y+4,6,2,"#1c2530");
  px(g,x+10,y+4,1,2,C.cyan); px(g,x+12,y+4,1,2,C.vertC);
},
/* 5 téléphone tactile */ function(g,x,y){
  px(g,x+4,y,6,11,"#22222a"); px(g,x+5,y+1,4,8,"#4aa3d8"); px(g,x+6,y+10,2,1,"#5a5a66");
},
/* 6 offre cloud */ function(g,x,y){
  px(g,x+1,y,12,11,"#1d2833");
  for(var i=0;i<4;i++){ px(g,x+3,y+1+i*3,6,2,"#33465a"); px(g,x+10,y+1+i*3,2,2,C.cyan); }
},
/* 7 grappe d'accélérateurs */ function(g,x,y){
  px(g,x,y+1,14,9,"#191a24"); px(g,x,y+1,14,1,C.violet);
  px(g,x+2,y+3,4,4,"#2c2c3a"); px(g,x+8,y+3,4,4,"#2c2c3a");
  px(g,x+3,y+4,2,2,C.cyan); px(g,x+9,y+4,2,2,C.cyan);
  px(g,x+2,y+8,10,1,C.ambre);
}
];

/* sprites des gammes ajoutées */
function pTelematique(g,x,y){
  px(g,x+1,y,11,7,"#d8d2bd"); px(g,x+3,y+1,7,4,"#1d2a1e");
  px(g,x+4,y+2,5,1,"#7fd08a"); px(g,x+4,y+4,3,1,"#7fd08a");
  px(g,x,y+7,13,3,"#c2bca7"); px(g,x+2,y+8,9,1,"#8d8873");
}
function pMultimedia(g,x,y){
  px(g,x,y,6,11,C.beige); px(g,x+1,y+2,4,1,"#3a3a44"); px(g,x+1,y+5,4,2,"#5a5a66");
  px(g,x+7,y+1,7,9,"#2a2a34"); px(g,x+8,y+2,5,5,"#5a8fbf");
  px(g,x+9,y+8,3,1,"#c8c8d4");
}
function pBaie(g,x,y){
  px(g,x+2,y,10,11,"#242e38"); px(g,x+2,y,10,1,"#46607a");
  for(var i=0;i<4;i++){ px(g,x+4,y+2+i*2,4,1,"#16202a"); px(g,x+9,y+2+i*2,2,1,i%2?C.cyan:C.vertC); }
}
function pBox(g,x,y){
  px(g,x+1,y+4,12,6,"#e8e4da"); px(g,x+1,y+4,12,1,"#f4f2ec");
  px(g,x+3,y+7,2,1,C.vertC); px(g,x+6,y+7,2,1,C.ambre); px(g,x+9,y+7,2,1,"#4a9fd8");
  px(g,x+2,y,1,4,C.metalC); px(g,x+11,y+1,1,3,C.metalC);
}
function pCapteur(g,x,y){
  px(g,x+3,y+5,8,4,"#3a4450"); px(g,x+3,y+5,8,1,"#5f6d7c");
  px(g,x+6,y+6,2,2,C.vertC);
  px(g,x+7,y+1,1,4,C.metalC); px(g,x+6,y,3,1,C.metalC);
}
function pQuantique(g,x,y){
  px(g,x+6,y,2,2,"#8a7a4a");
  for(var e=0;e<4;e++){ var w=11-e*2; px(g,x+7-w/2, y+2+e*2, w, 1, "#c9962f"); }
  px(g,x+5,y+10,5,1,"#6fd8ec");
  px(g,x+6,y+9,3,1,"#d8f6ff");
}
function pNeuro(g,x,y){
  px(g,x+1,y+2,12,8,"#241a2e"); px(g,x+1,y+2,12,1,"#4a3a60");
  px(g,x+3,y+4,8,4,"#8a5fd8"); px(g,x+5,y+5,4,2,"#c89ff0");
  px(g,x+2,y+9,10,1,"#a87fe8");
}

var PRODUIT_DESSIN = [
  PRODUIT_BASE[0], PRODUIT_BASE[1], pTelematique, PRODUIT_BASE[2], PRODUIT_BASE[3],
  pMultimedia, PRODUIT_BASE[4], pBaie, pBox, PRODUIT_BASE[5],
  PRODUIT_BASE[6], pCapteur, PRODUIT_BASE[7], pQuantique, pNeuro
];

/* ============================ icônes R&D (12 × 12) ============================ */

var ICONES = {
  fer:      function(g,x,y){ px(g,x+2,y+8,6,2,C.bois); segment(g,x+3,y+7,x+9,y+2,C.metalC,2); px(g,x+9,y+1,2,2,C.ambre); },
  puce:     function(g,x,y){ px(g,x+2,y+2,8,8,C.noir); px(g,x+3,y+3,6,6,"#3a5a48");
                             for(var i=0;i<3;i++){ px(g,x,y+3+i*3,2,1,C.metalC); px(g,x+10,y+3+i*3,2,1,C.metalC); } },
  carte:    function(g,x,y){ px(g,x+1,y+2,10,8,C.vertPCB); px(g,x+3,y+4,3,3,C.noir); px(g,x+7,y+4,2,2,C.metalC); px(g,x+3,y+8,6,1,C.ambre); },
  carton:   function(g,x,y){ px(g,x+1,y+3,10,7,C.bois); px(g,x+1,y+3,10,2,C.boisC); px(g,x+5,y+3,2,7,C.boisF); },
  souris:   function(g,x,y){ px(g,x+3,y+2,6,8,C.beige); px(g,x+3,y+2,6,3,C.beigeF); px(g,x+5,y+2,2,3,C.metalF); },
  palette:  function(g,x,y){ px(g,x+1,y+7,10,2,C.bois); px(g,x+2,y+2,8,5,C.boisC); px(g,x+2,y+9,2,2,C.boisF); px(g,x+8,y+9,2,2,C.boisF); },
  disque:   function(g,x,y){ px(g,x+1,y+3,10,6,C.metal); px(g,x+1,y+3,10,1,C.metalC); px(g,x+4,y+5,4,2,C.noir); px(g,x+9,y+7,1,1,C.ambre); },
  bus:      function(g,x,y){ px(g,x+1,y+4,10,4,C.vertPCB); for(var i=0;i<5;i++) px(g,x+1+i*2,y+8,1,2,C.ambre); px(g,x+3,y+1,6,3,C.noir); },
  casque:   function(g,x,y){ px(g,x+2,y+2,8,2,C.noir); px(g,x+1,y+3,2,5,C.noir); px(g,x+9,y+3,2,5,C.noir); px(g,x+9,y+8,3,1,C.metalC); },
  modem:    function(g,x,y){ px(g,x+1,y+5,10,5,C.beigeF); px(g,x+2,y+7,2,1,C.vert); px(g,x+5,y+7,2,1,C.ambre);
                             px(g,x+9,y+1,1,4,C.metalC); px(g,x+7,y+2,1,1,C.cyan); px(g,x+5,y+1,1,1,C.cyan); },
  megaphone:function(g,x,y){ px(g,x+2,y+4,3,4,C.rouge); px(g,x+5,y+2,4,8,C.rougeC); px(g,x+10,y+3,1,2,C.ambre); px(g,x+10,y+7,1,2,C.ambre); },
  puce2:    function(g,x,y){ px(g,x+2,y+2,8,8,"#2a2a34"); px(g,x+4,y+4,4,4,C.cyan); px(g,x+1,y+5,1,2,C.metalC); px(g,x+10,y+5,1,2,C.metalC); },
  nuage:    function(g,x,y){ px(g,x+2,y+5,8,4,C.blanc); px(g,x+4,y+3,5,3,C.blanc); px(g,x+1,y+6,2,3,C.beigeF); px(g,x+9,y+6,2,3,C.beigeF); },
  gpu:      function(g,x,y){ px(g,x+1,y+3,10,7,"#22222c"); px(g,x+2,y+4,3,3,C.cyan); px(g,x+6,y+4,3,3,C.cyan); px(g,x+2,y+8,8,1,C.ambre); },
  reseau:   function(g,x,y){ segment(g,x+2,y+2,x+9,y+6,C.violet,1); segment(g,x+2,y+9,x+9,y+6,C.violet,1); segment(g,x+2,y+2,x+2,y+9,C.violet,1);
                             px(g,x+1,y+1,3,3,C.cyan); px(g,x+1,y+8,3,3,C.cyan); px(g,x+8,y+5,3,3,C.ambre); },
  clavier:  function(g,x,y){ px(g,x+1,y+4,10,6,C.beige); px(g,x+1,y+4,10,1,C.beigeC);
                             for(var i=0;i<4;i++){ px(g,x+2+i*2,y+6,1,1,C.gris); px(g,x+3+i*2,y+8,1,1,C.gris); } },
  livre:    function(g,x,y){ px(g,x+2,y+1,8,10,"#a8823f"); px(g,x+3,y+2,6,8,C.beigeC); px(g,x+2,y+1,2,10,"#7b5f2c"); px(g,x+5,y+4,3,1,C.gris); },
  ecran:    function(g,x,y){ px(g,x+1,y+2,10,6,"#3a3a44"); px(g,x+2,y+3,8,4,"#6f9ea8"); px(g,x+4,y+8,4,2,C.metalF); px(g,x+2,y+10,8,1,C.metalF); },
  pile:     function(g,x,y){ px(g,x+4,y+1,4,1,C.metalC); px(g,x+3,y+2,6,9,"#3a6b4a"); px(g,x+4,y+4,4,2,C.vertC); px(g,x+4,y+7,4,1,"#1e3a2a"); },
  prise:    function(g,x,y){ px(g,x+3,y+1,6,5,C.beige); px(g,x+4,y+2,1,3,C.noir); px(g,x+7,y+2,1,3,C.noir); px(g,x+5,y+6,2,5,C.gris); },
  baie:     function(g,x,y){ px(g,x+2,y+1,8,10,"#242e38"); for(var i=0;i<4;i++){ px(g,x+3,y+2+i*2,4,1,"#16202a"); px(g,x+8,y+2+i*2,1,1,C.cyan); } },
  cadenas:  function(g,x,y){ px(g,x+4,y+1,4,1,C.metalC); px(g,x+3,y+2,1,3,C.metalC); px(g,x+8,y+2,1,3,C.metalC); px(g,x+2,y+5,8,6,C.ambreF); px(g,x+5,y+7,2,2,C.noir); },
  courbe:   function(g,x,y){ px(g,x+1,y+10,10,1,C.gris); segment(g,x+2,y+8,x+5,y+5,C.vertC,1); segment(g,x+5,y+5,x+7,y+7,C.vertC,1); segment(g,x+7,y+7,x+10,y+2,C.vertC,1); px(g,x+9,y+1,3,3,C.vertC); },
  ciseaux:  function(g,x,y){ segment(g,x+2,y+1,x+8,y+7,C.metalC,1); segment(g,x+9,y+1,x+3,y+7,C.metalC,1); px(g,x+1,y+8,3,3,C.rouge); px(g,x+8,y+8,3,3,C.rouge); },
  fibre:    function(g,x,y){ segment(g,x+1,y+9,x+10,y+2,"#6fd8ec",2); px(g,x+9,y+1,3,3,C.blanc); px(g,x,y+8,3,3,C.metalF); },
  globe:    function(g,x,y){ px(g,x+2,y+2,8,8,"#2f6b8f"); px(g,x+2,y+5,8,1,"#8fd0e8"); px(g,x+5,y+2,2,8,"#8fd0e8"); px(g,x+3,y+3,2,2,C.vertC); },
  onde:     function(g,x,y){ px(g,x+5,y+7,2,4,C.metalF); for(var i=0;i<3;i++){ px(g,x+3-i,y+5-i*2,1,2,C.cyan); px(g,x+8+i,y+5-i*2,1,2,C.cyan); } px(g,x+5,y+4,2,2,C.ambre); },
  sac:      function(g,x,y){ px(g,x+2,y+3,8,8,"#3a6b8f"); px(g,x+4,y+1,1,3,C.metalC); px(g,x+7,y+1,1,3,C.metalC); px(g,x+4,y+6,4,2,C.beigeC); },
  doigt:    function(g,x,y){ px(g,x+5,y+1,2,6,C.peau[0]); px(g,x+4,y+7,5,4,C.peau[1]); px(g,x+2,y+2,2,1,C.ambre); px(g,x+8,y+2,2,1,C.ambre); },
  boite:    function(g,x,y){ px(g,x+1,y+3,10,7,"#2f6b8f"); px(g,x+1,y+3,10,2,"#57a3c8"); px(g,x+5,y+3,2,7,"#1d4a66"); px(g,x+2,y+6,2,2,C.beigeC); },
  antenne:  function(g,x,y){ px(g,x+5,y+5,2,6,C.metalF); segment(g,x+2,y+1,x+6,y+5,C.metalC,1); segment(g,x+10,y+1,x+6,y+5,C.metalC,1); px(g,x+4,y+3,4,1,C.ambre); },
  carte2:   function(g,x,y){ px(g,x+1,y+2,10,8,"#3a6b4a"); px(g,x+2,y+3,3,3,"#6fbf86"); px(g,x+7,y+6,3,3,"#6fbf86"); px(g,x+5,y+2,1,8,C.beigeC); },
  neurone:  function(g,x,y){ px(g,x+4,y+4,4,4,"#a87fe8"); for(var k=0;k<4;k++){ var a=k*1.57+.4; segment(g,x+6,y+6, x+6+Math.cos(a)*5, y+6+Math.sin(a)*5, "#c89ff0",1); } px(g,x+5,y+5,2,2,C.blanc); },
  eclair:   function(g,x,y){ px(g,x+6,y+1,3,4,C.ambre); px(g,x+4,y+4,4,2,C.ambre); px(g,x+3,y+6,3,5,C.jaune); px(g,x+5,y+5,3,2,C.jaune); },
  goutte:   function(g,x,y){ px(g,x+5,y+1,2,3,"#6fd8ec"); px(g,x+4,y+4,4,3,"#6fd8ec"); px(g,x+3,y+7,6,4,"#3fa8d8"); px(g,x+5,y+8,2,2,C.blanc); },
  atome:    function(g,x,y){ px(g,x+5,y+5,2,2,C.ambre); px(g,x+1,y+5,10,1,"#6fd8ec"); px(g,x+5,y+1,1,10,"#6fd8ec"); px(g,x+2,y+2,2,2,C.cyan); px(g,x+8,y+8,2,2,C.cyan); },
  bouclier: function(g,x,y){ px(g,x+2,y+1,8,6,"#3a6b8f"); px(g,x+3,y+7,6,2,"#3a6b8f"); px(g,x+5,y+9,2,2,"#3a6b8f"); px(g,x+4,y+3,4,1,C.blanc); px(g,x+5,y+4,2,3,C.blanc); },
  flocon:   function(g,x,y){ px(g,x+5,y+1,2,10,"#a8e0f0"); px(g,x+1,y+5,10,2,"#a8e0f0"); segment(g,x+2,y+2,x+9,y+9,"#7fc8e0",1); segment(g,x+9,y+2,x+2,y+9,"#7fc8e0",1); },
  spirale:  function(g,x,y){ for(var k=0;k<14;k++){ var a=k*.55, r=1+k*.32; px(g, x+6+Math.cos(a)*r, y+6+Math.sin(a)*r, 1,1, k<7?"#c89ff0":"#8a5fd8"); } },
  oeil:     function(g,x,y){ px(g,x+1,y+4,10,4,C.beigeC); px(g,x+2,y+3,8,6,C.beigeC); px(g,x+4,y+4,4,4,"#3a6b8f"); px(g,x+5,y+5,2,2,C.noir); }
};

/* ============================ tapis & stocks ============================ */

var colis = [];
function expedier(gamme){
  if(colis.length > 14) return;
  colis.push({x:20, g:gamme});
}

function tapis(g, t, cadence){
  px(g,0,TAPIS,L_W,10,C.metalF);
  px(g,0,TAPIS,L_W,1,C.metalC);
  px(g,0,TAPIS+10,L_W,2,"#00000033");
  px(g,0,TAPIS+12,L_W,L_H-TAPIS-12,"#00000026");
  var d = (t*30) % 10;
  for(var x=-10;x<L_W;x+=10) px(g,x+d,TAPIS+4,5,2,C.metal);
  /* quai d'expédition */
  px(g,352,TAPIS-16,30,16,C.boisF);
  px(g,352,TAPIS-16,30,2,C.boisC);
  px(g,356,TAPIS-12,10,8,C.bois);
  px(g,368,TAPIS-12,10,8,C.bois);
}

function cartons(g, comps, besoin){
  var piles = Math.max(0, Math.min(9, Math.round(Math.log10(1 + comps/Math.max(besoin,1)) * 4)));
  for(var i=0;i<piles;i++){
    var cx = 4 + (i%3)*13, cy = SOL - 10 - Math.floor(i/3)*10;
    px(g,cx,cy,12,10,C.bois);
    px(g,cx,cy,12,2,C.boisC);
    px(g,cx+5,cy+2,2,8,C.boisF);
  }
  if(piles === 0){
    px(g,4,SOL-4,12,4,"#00000022");
  }
}

/* camion de livraison */
var camion = {actif:false, x:-40, t:0};
function livrer(){ camion.actif = true; camion.x = -44; camion.t = 0; }
function dessinerCamion(g,dt){
  if(!camion.actif) return;
  camion.t += dt;
  var cible = 26;
  if(camion.t < 3.2) camion.x += (cible - camion.x) * Math.min(1, dt*3);
  else camion.x -= 70*dt;
  if(camion.x < -46){ camion.actif = false; return; }
  var x = camion.x, b = SOL + 14;
  px(g,x,b-20,26,14,C.rouge);
  px(g,x+26,b-16,12,10,C.rougeC);
  px(g,x+28,b-14,7,5,"#8fb8d8");
  px(g,x+2,b-18,20,4,"#ffffff55");
  px(g,x+4,b-6,7,7,C.noir); px(g,x+6,b-4,3,3,C.metalC);
  px(g,x+26,b-6,7,7,C.noir); px(g,x+28,b-4,3,3,C.metalC);
}

/* ============================ rendu principal ============================ */

var lo = document.createElement("canvas");
lo.width = L_W; lo.height = L_H;
var lg = lo.getContext("2d");

var CELL_W = 92, CELL_H = 46, CELL_X = 4;
var RANGEES = [SOL + 14, TAPIS - 2];      /* base de chaque rangée : fond, puis premier plan */

function dessiner(ctx, S, t, dt, cadence){
  lg.imageSmoothingEnabled = false;
  fond(lg, SC.jeu.ereIndex(S), t);
  cartons(lg, S.comps, SC.jeu.besoinComps(S));

  /* la scène montre les huit paliers les plus avancés que vous possédez,
     plus le prochain à débloquer, en pointillés */
  var montre = [];
  for(var i=0;i<SC.STATIONS.length;i++) if(S.stations[i] > 0) montre.push(i);
  var suivant = premiereLibre(S);
  if(suivant < SC.STATIONS.length) montre.push(suivant);
  if(montre.length > 8) montre = montre.slice(montre.length - 8);
  for(var c=0;c<montre.length;c++){
    var idx = montre[c];
    var col = c % 4, rang = c < 4 ? 0 : 1;
    var x = CELL_X + col*CELL_W, b = RANGEES[rang];
    if(S.stations[idx] > 0){
      STATION_DESSIN[SC.STATIONS[idx].img](lg, x, b, S.stations[idx], t, cadence > 0);
      badge(lg, x + CELL_W - 26, b - CELL_H + 2, S.stations[idx]);
    }else{
      pointille(lg, x+14, b-20, 62, 18);
    }
  }

  tapis(lg, t, cadence);
  for(var k=colis.length-1;k>=0;k--){
    var c = colis[k];
    c.x += (26 + cadence*0.08) * dt;
    PRODUIT_DESSIN[c.g](lg, c.x, TAPIS - 11);
    if(c.x > 350){
      colis.splice(k,1);
      for(var e=0;e<3;e++) etincelle(354 + Math.random()*20, TAPIS - 14);
    }
  }
  dessinerCamion(lg, dt);
  majParticules(dt);
  dessinerParticules(lg);

  /* mise à l'échelle sans lissage */
  var r = ctx.canvas.getBoundingClientRect();
  var dpr = Math.min(window.devicePixelRatio || 1, 2);
  var w = Math.max(1, Math.round(r.width*dpr)), h = Math.max(1, Math.round(r.width*dpr*L_H/L_W));
  if(ctx.canvas.width !== w || ctx.canvas.height !== h){ ctx.canvas.width = w; ctx.canvas.height = h; }
  ctx.imageSmoothingEnabled = false;
  ctx.clearRect(0,0,w,h);
  ctx.drawImage(lo, 0, 0, w, h);
}

function premiereLibre(S){
  for(var i=0;i<8;i++) if(S.stations[i] === 0) return i;
  return 8;
}
function pointille(g,x,y,w,h){
  g.globalAlpha = .25;
  for(var i=0;i<w;i+=4){ px(g,x+i,y,2,1,C.noir); px(g,x+i,y+h,2,1,C.noir); }
  for(var j=0;j<h;j+=4){ px(g,x,y+j,1,2,C.noir); px(g,x+w,y+j,1,2,C.noir); }
  g.globalAlpha = 1;
}

/* vignette du produit courant, pour le panneau Atelier */
function vignetteProduit(canvas, gamme, t){
  var g = canvas.getContext("2d");
  var W = 64, H = 40;
  if(canvas._lo === undefined){
    canvas._lo = document.createElement("canvas");
    canvas._lo.width = W; canvas._lo.height = H;
  }
  var lg2 = canvas._lo.getContext("2d");
  lg2.clearRect(0,0,W,H);
  px(lg2,W/2-15,H-5,30,3,"#00000018");
  px(lg2,W/2-11,H-6,22,1,"#00000012");
  var flotte = Math.round(Math.sin(t*1.6));
  lg2.save();
  lg2.translate(W/2 - 14, H/2 - 11 + flotte);
  lg2.scale(2,2);
  PRODUIT_DESSIN[gamme](lg2, 0, 0);
  lg2.restore();
  if(Math.floor(t*2)%2 === 0) px(lg2, W/2+12, H/2-8+flotte, 2, 2, C.ambre);
  var r = canvas.getBoundingClientRect();
  var dpr = Math.min(window.devicePixelRatio || 1, 2);
  var w = Math.max(1,Math.round(r.width*dpr)), h = Math.max(1,Math.round(r.width*dpr*H/W));
  if(canvas.width !== w || canvas.height !== h){ canvas.width = w; canvas.height = h; }
  g.imageSmoothingEnabled = false;
  g.clearRect(0,0,w,h);
  g.drawImage(canvas._lo, 0,0,w,h);
}

/* icône R&D rendue une fois en data-URL */
function iconeURL(nom){
  var c = document.createElement("canvas");
  c.width = 12; c.height = 12;
  var g = c.getContext("2d");
  (ICONES[nom] || ICONES.puce)(g, 0, 0);
  return c.toDataURL();
}

/* ============================ portraits ============================ */
/* Un visage de 16 × 18 composé depuis une graine : même employé, même tête. */

var PEAUX    = ["#e8b088","#d9a074","#c08a58","#a06e40","#7d4f2c","#5a3820"];
var CHEVEUX  = ["#2b1f18","#4a3524","#7a5a32","#a8813f","#c9a86a","#8f8f92","#b8403a","#1a1a22"];
var COLS     = ["#b8402c","#3d6fa6","#4f9a5f","#7a5bb5","#c2761c","#57738a","#8d5a7a","#3f4a58"];

function alea(graine){
  var x = (graine|0) || 7;
  return function(){ x = (x*1103515245 + 12345) & 0x7fffffff; return x/0x7fffffff; };
}

function portrait(g, x, y, graine, lunettesForcees){
  var r = alea(graine);
  var peau = PEAUX[Math.floor(r()*PEAUX.length)];
  var chev = CHEVEUX[Math.floor(r()*CHEVEUX.length)];
  var col  = COLS[Math.floor(r()*COLS.length)];
  var style = Math.floor(r()*5);
  var lunettes = lunettesForcees || r() < .32;
  var barbe = r() < .26;
  var ombre = melange(peau, "#000000", .22);

  /* épaules */
  px(g,x+1,y+14,14,4,col);
  px(g,x+1,y+14,14,1,melange(col,"#ffffff",.18));
  px(g,x+6,y+14,4,2,melange(col,"#ffffff",.3));
  /* cou */
  px(g,x+6,y+12,4,2,ombre);
  /* visage */
  px(g,x+4,y+3,8,10,peau);
  px(g,x+3,y+5,1,6,peau);
  px(g,x+12,y+5,1,6,peau);
  px(g,x+11,y+4,1,8,ombre);
  /* oreilles */
  px(g,x+2,y+7,1,2,peau); px(g,x+13,y+7,1,2,peau);
  /* cheveux */
  if(style === 0){ px(g,x+3,y+1,10,3,chev); px(g,x+3,y+4,1,2,chev); px(g,x+12,y+4,1,2,chev); }
  if(style === 1){ px(g,x+3,y+1,10,3,chev); px(g,x+2,y+3,2,8,chev); px(g,x+12,y+3,2,8,chev); }
  if(style === 2){ px(g,x+3,y+3,2,3,chev); px(g,x+11,y+3,2,3,chev); px(g,x+5,y+2,6,1,chev); }
  if(style === 3){ px(g,x+2,y+0,12,4,chev); px(g,x+2,y+4,1,3,chev); px(g,x+13,y+4,1,3,chev); }
  if(style === 4){ px(g,x+3,y+2,10,2,chev); px(g,x+6,y+0,4,2,chev); px(g,x+3,y+4,1,2,chev); px(g,x+12,y+4,1,2,chev); }
  /* yeux */
  px(g,x+5,y+7,2,2,"#ffffff"); px(g,x+9,y+7,2,2,"#ffffff");
  px(g,x+6,y+7,1,2,"#20202a"); px(g,x+9,y+7,1,2,"#20202a");
  /* sourcils */
  px(g,x+5,y+6,2,1,chev); px(g,x+9,y+6,2,1,chev);
  /* nez et bouche */
  px(g,x+7,y+9,1,1,ombre);
  px(g,x+6,y+11,4,1,melange(peau,"#8a3a3a",.45));
  if(barbe){ px(g,x+5,y+10,6,3,melange(chev,peau,.25)); px(g,x+6,y+11,4,1,"#7a2f2f"); }
  if(lunettes){
    px(g,x+4,y+6,3,3,"#2a2a34"); px(g,x+9,y+6,3,3,"#2a2a34");
    px(g,x+5,y+7,1,1,"#a8d8e8"); px(g,x+10,y+7,1,1,"#a8d8e8");
    px(g,x+7,y+7,2,1,"#2a2a34");
    px(g,x+2,y+6,2,1,"#2a2a34"); px(g,x+12,y+6,2,1,"#2a2a34");
  }
}

function melange(a,b,t){
  function d(c){ return [parseInt(c.substr(1,2),16),parseInt(c.substr(3,2),16),parseInt(c.substr(5,2),16)]; }
  var x = d(a), y = d(b);
  function h(v){ return ("0"+Math.round(v).toString(16)).slice(-2); }
  return "#" + h(x[0]+(y[0]-x[0])*t) + h(x[1]+(y[1]-x[1])*t) + h(x[2]+(y[2]-x[2])*t);
}

function portraitURL(graine, savant){
  var c = document.createElement("canvas");
  c.width = 16; c.height = 18;
  portrait(c.getContext("2d"), 0, 0, graine, savant);
  return c.toDataURL();
}

SC.dessin = {
  dessiner: dessiner,
  vignetteProduit: vignetteProduit,
  iconeURL: iconeURL,
  portraitURL: portraitURL,
  expedier: expedier,
  livrer: livrer,
  confetti: function(){
    for(var i=0;i<90;i++) confetti(Math.random()*L_W, 40 + Math.random()*40);
  },
  etincelle: etincelle,
  C: C
};
})();
