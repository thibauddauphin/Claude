# Silicium & Cie

Un jeu de gestion (*tycoon*) sur l'histoire de l'informatique, du kit à souder
de 1975 aux grappes d'accélérateurs de 2023. Atelier animé dessiné entièrement
au code, aucune image externe.

Ouvrez `jeu/index.html` dans un navigateur. Les seules ressources distantes sont
les fontes IBM Plex servies par Google Fonts ; sans réseau, la page bascule sur
les fontes système.

Une première partie complète demande une vingtaine d'heures ; les deux niveaux de
prestige et les 34 jalons portent l'ensemble au-delà de la cinquantaine.

## Boucle de jeu

- **Atelier** — assemblez à la main (clic sur la scène ou barre d'espace), ou
  laissez produire. Chaque unité consomme des composants : sans stock, la chaîne
  s'arrête net.
- **Moyens de production** — douze paliers, de l'établi de garage à l'essaim
  d'usines noires. Coût × 1,19 par exemplaire acheté.
- **Recherche & développement** — quarante-cinq technologies réparties sur les
  quinze ères. Quatorze ouvrent une nouvelle gamme et font basculer l'époque, les
  autres multiplient production, prix, conquête ou approvisionnement.
- **Politique de prix** — un curseur arbitre entre recette et conquête : vendre
  cher rapporte davantage mais ralentit la prise de parts de marché.
- **Concurrence** — quatre sociétés rivales progressent en continu, d'autant
  plus vite que l'ère est avancée. Stagner, c'est reculer.
- **Marché** — événements aléatoires (pénurie de mémoire, banc d'essai élogieux,
  guerre des prix…) et courbe de revenu sur 60 s.
- **Équipe** — des employés nommés, chacun avec un caractère qui multiplie la
  production, les prix, la recherche ou l'approvisionnement, et une rémunération
  prélevée sur le chiffre d'affaires. Leur moral suit vos conditions de travail :
  casser les prix, laisser la chaîne à l'arrêt ou traverser une crise le fait
  tomber. Sous 45 %, les concurrents commencent à les débaucher ; à zéro, ils
  claquent la porte. Une augmentation ou une prime les retient.
- **Jalons** — trente-quatre succès permanents, chacun accordant un bonus de
  production qui survit à toutes les remises à zéro.
- **Progression hors ligne** — l'atelier tourne à 60 % de sa cadence en votre
  absence, jusqu'à douze heures d'affilée. Les concurrents avancent aussi.
- **Introduction en bourse** — premier niveau de prestige : tout repart de zéro
  contre des actions, + 8 % de production et de prix par action.
- **Conglomérat** — second niveau : à 150 actions, on solde le groupe en parts de
  holding (× 1,3 chacune) qui ouvrent huit méta-améliorations permanentes.

## Organisation du code

| Fichier | Rôle |
|---|---|
| `jeu/donnees.js`   | Tables : ères, gammes, stations, technologies, événements, concurrents |
| `jeu/jeu.js`       | Simulation pure — économie, concurrence, sauvegarde. Aucun accès au DOM |
| `jeu/dessin.js`    | Pixel-art procédurale : décors des quinze ères, vignettes de production, produits, icônes, portraits, particules |
| `jeu/interface.js` | Panneaux, boucle de rendu, son, raccourcis clavier |
| `jeu/style.css`    | Identité visuelle et thèmes clair / sombre |
| `outils/calibrage.js`   | Calibre les coûts de recherche pour atteindre une durée cible par ère |
| `outils/equilibrage.js` | Joue une partie sans interface et rend compte du rythme obtenu |

`maquette-initiale.html` conserve la maquette d'origine, en un seul fichier.

## Équilibrage

Le rythme n'est pas réglé à l'instinct. `outils/calibrage.js` fait jouer un joueur
simulé, mesure la durée réelle de chaque ère et corrige le coût des technologies
jusqu'à converger sur une cible — une progression géométrique de 5 minutes pour
1975 à un peu plus de cinq heures pour 2040. `outils/equilibrage.js` rejoue
ensuite la partie et publie le tableau de contrôle :

```
$ node outils/equilibrage.js
1975  Le garage                  atteinte à     1 s                marché  0,2 %
1982  La télématique             atteinte à  12,4 min   6,6 min    marché 76,6 %
2000  L'éclatement de la bulle   atteinte à  1,82 h    32,6 min    marché 47,7 %
2040  Le substrat neuromorphique atteinte à 16,02 h     4,18 h     marché 44,5 %
première partie complète : 22 h
```

Le rythme dépend de la façon dont vous menez l'atelier. Trois parties simulées
avec une équipe bien traitée tombent entre 17 h et 23 h ; une partie menée à
prix cassés sans jamais augmenter personne perd une dizaine d'employés en huit
heures et progresse nettement moins vite.

## Détails techniques

- La scène est rendue sur une grille logique de 384 × 216 puis agrandie sans
  lissage (`image-rendering: pixelated`) : tout est dessiné au rectangle, il n'y
  a aucun fichier d'image.
- Boucle à `requestAnimationFrame` ; interface rafraîchie à 8 Hz, courbe et
  sauvegarde une fois par seconde.
- Sons synthétisés en WebAudio, coupés par défaut.
- Sauvegarde dans `localStorage`, encapsulée : la partie reste jouable si le
  stockage est refusé.
- Thèmes clair et sombre : palette complète sur `:root`, redéfinie par
  `prefers-color-scheme` puis par l'attribut `data-theme`.
- La palette des parts de marché a été validée (bandes de luminosité, plancher
  de chroma, séparation pour les daltonismes, contraste) dans les deux thèmes.
