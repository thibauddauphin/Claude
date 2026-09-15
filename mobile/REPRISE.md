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

## Fait (suite)

- **Persistance** vérifiée sur une vraie plateforme : aller-retour complet,
  sauvegarde corrompue, stockage indisponible.
- **Peintres** : quinze décors, douze vignettes, quinze sprites, quarante
  icônes, portraits qui vieillissent, particules.
- **Interface téléphone** : bandeau d'instruments, scène tactile, cinq onglets.
- **Cycle de vie Android** : sauvegarde en pause, rattrapage hors ligne au retour.

## Reste à faire

1. **Icône et nom de l'application**, écran de démarrage.
2. **Annonce d'ère** plein écran et bandeau d'événement, présents dans la
   version web et pas encore portés.
3. **Onglet Conglomérat** : le second niveau de prestige n'a pas d'écran.
4. **Notifications** (`POST_NOTIFICATIONS`, Android 13+) — décision de produit
   en attente : rappeler le joueur quand la chaîne s'arrête ou que les douze
   heures hors ligne sont pleines.
5. **Signature de l'APK** pour une distribution hors Play Store.

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
