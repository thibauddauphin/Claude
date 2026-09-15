# Silicium & Cie

Maquette jouable d'un jeu de gestion (*tycoon*) sur l'histoire de l'informatique,
du kit à souder de 1975 aux grappes d'accélérateurs de 2023.

Un seul fichier, `index.html`, sans dépendance à installer : ouvrez-le dans un
navigateur. Les seules ressources externes sont les fontes IBM Plex servies par
Google Fonts ; sans réseau, la page bascule sur les fontes système.

## Boucle de jeu

- **Atelier** — assemblez à la main, ou laissez produire. Chaque unité consomme
  des composants : sans stock, la chaîne s'arrête.
- **Moyens de production** — huit paliers, de l'établi de garage à
  l'ordonnanceur autonome. Coût × 1,16 par exemplaire.
- **Recherche & développement** — treize technologies. Certaines multiplient la
  production ou les prix, six ouvrent une nouvelle gamme et font avancer l'ère.
- **Marché** — part de marché dérivée du volume vendu, courbe de revenu sur
  60 s, et des événements aléatoires (pénurie de mémoire, banc d'essai élogieux,
  guerre des prix…) qui modifient temporairement prix, production ou R&D.
- **Introduction en bourse** — à partir de 25 M€ de chiffre d'affaires, tout
  repart de zéro contre des actions : + 8 % de production et de prix par action,
  définitivement.

## Détails techniques

- Boucle à `requestAnimationFrame`, interface redessinée à 10 Hz, courbe et
  sauvegarde une fois par seconde.
- Sauvegarde dans `localStorage` (encapsulée : la partie reste jouable si le
  stockage est refusé).
- Thèmes clair et sombre : palette complète sur `:root`, redéfinie par
  `prefers-color-scheme` et par l'attribut `data-theme` que pose le sélecteur.
- Courbe de revenu dessinée en Canvas, couleurs lues sur les jetons CSS.
