# Portage Flutter — état des travaux

Portage Android du jeu web qui vit dans `../jeu/`. La version web reste la
référence : toute règle qui diverge est un bogue du portage.

## Fait

- **Domaine complet et testé** — entités, catalogue, règles, cas d'usage.
  Les neuf tables de `domain/catalogue/` sont **générées** depuis `../jeu/donnees.js`
  (voir « Régénérer les tables » plus bas) : ne pas les éditer à la main.
- **Tests de fidélité** (`test/domain/fidelite_portage_test.dart`) : une partie
  complète simulée dure entre 15 et 30 h, les quinze ères se franchissent dans
  l'ordre en s'allongeant, la part de marché se stabilise entre 35 et 60 %,
  l'équipe reste soudée quand l'atelier est bien tenu et se fait débaucher quand
  on brade. Ce sont ces tests qui garantissent que le portage n'a pas dérivé.

## Reste à faire

1. **Persistance** — `technical/Persistance` + `data/gateways` : sérialiser
   `EtatPartie` en JSON dans `shared_preferences`.
2. **Peintres** — porter `../jeu/dessin.js` en `CustomPainter` :
   quinze décors d'ère, douze vignettes de production, quinze sprites de gamme,
   quarante icônes de recherche, portraits générés depuis une graine, particules.
   La grille logique est 384 × 216, agrandie sans lissage
   (`Paint()..isAntiAlias = false`, `canvas.scale`).
3. **Cubit** — `PartieCubit` : possède l'agrégat mutable, fait tourner un
   `Ticker` à 60 Hz pour la scène, et émet un `PartieState` **immuable** à ~10 Hz
   pour les panneaux. Séparer les deux cadences est délibéré : recopier
   l'agrégat soixante fois par seconde ne servirait à rien.
4. **Écrans** — refonte pour le téléphone : bandeau d'instruments compact,
   scène en haut, navigation basse à cinq onglets (Atelier, Production,
   Recherche, Équipe, Marché). Le bureau à trois colonnes ne se transpose pas.
5. **Cycle de vie Android** — `WidgetsBindingObserver` : sauver en pause,
   rattraper le hors-ligne à la reprise.

## Régénérer les tables du catalogue

Après toute modification de `../jeu/donnees.js` :

```bash
node ../outils/porter_vers_dart.js
```

## Construire l'APK

Impossible depuis l'environnement cloud : `dl.google.com` y est bloqué par la
politique réseau, donc ni SDK Android ni plugin Gradle Android.

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release      # nécessite le SDK Android
```
