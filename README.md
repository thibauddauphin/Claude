# Silicium & Cie

Un jeu de gestion (*tycoon*) sur l'histoire de l'informatique, du kit à souder
de 1975 aux grappes d'accélérateurs de 2023. Atelier animé dessiné entièrement
au code, aucune image externe.

Ouvrez `jeu/index.html` dans un navigateur. Les seules ressources distantes sont
les fontes IBM Plex servies par Google Fonts ; sans réseau, la page bascule sur
les fontes système.

## Boucle de jeu

- **Atelier** — assemblez à la main (clic sur la scène ou barre d'espace), ou
  laissez produire. Chaque unité consomme des composants : sans stock, la chaîne
  s'arrête net.
- **Moyens de production** — huit paliers, de l'établi de garage à
  l'ordonnanceur autonome. Coût × 1,16 par exemplaire acheté.
- **Recherche & développement** — quinze technologies. Sept ouvrent une nouvelle
  gamme et font basculer l'ère, les autres multiplient production, prix ou
  approvisionnement.
- **Politique de prix** — un curseur arbitre entre recette et conquête : vendre
  cher rapporte davantage mais ralentit la prise de parts de marché.
- **Concurrence** — quatre sociétés rivales progressent en continu, d'autant
  plus vite que l'ère est avancée. Stagner, c'est reculer.
- **Marché** — événements aléatoires (pénurie de mémoire, banc d'essai élogieux,
  guerre des prix…) et courbe de revenu sur 60 s.
- **Introduction en bourse** — à partir de 25 M€ de chiffre d'affaires, tout
  repart de zéro contre des actions : + 8 % de production et de prix par action,
  définitivement.

## Organisation du code

| Fichier | Rôle |
|---|---|
| `jeu/donnees.js`   | Tables : ères, gammes, stations, technologies, événements, concurrents |
| `jeu/jeu.js`       | Simulation pure — économie, concurrence, sauvegarde. Aucun accès au DOM |
| `jeu/dessin.js`    | Pixel-art procédurale : décors des huit ères, vignettes de stations, produits, icônes, particules |
| `jeu/interface.js` | Panneaux, boucle de rendu, son, raccourcis clavier |
| `jeu/style.css`    | Identité visuelle et thèmes clair / sombre |

`maquette-initiale.html` conserve la maquette d'origine, en un seul fichier.

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
