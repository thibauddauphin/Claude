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

## Fait (fin du portage)

- **Icône et nom de l'application**.
- **Annonce d'ère** plein écran, **bandeau d'événement**, messages de départ
  et de retraite.
- **Panneau Conglomérat** : le second niveau de prestige a son écran, avec
  ses huit améliorations et un bouton à double appui.
- **Polices IBM Plex embarquées** : le jeu s'affiche pareil hors ligne, et les
  exposants de la notation scientifique ne sont plus des carrés vides.
- **Tests d'affichage** (`test/presentation/rendu_onglets_test.dart`) : les
  cinq onglets sont peints sur une partie simulée de quatre heures. C'est ce
  qui manquait quand un liseré non uniforme arrondi faisait lever la peinture
  de toutes les listes d'achat sans qu'aucun test ne s'en aperçoive.

## Attention : Flutter est désormais la référence

L'économie (charges fixes, salaires en euros, impôt, découvert) n'existe que
côté Dart. `../jeu/` garde l'ancienne économie et **ne mesure plus le même
jeu** : `outils/calibrage.js` et `outils/equilibrage.js` sont donc périmés
pour l'équilibrage. Le rythme se mesure maintenant avec :

```bash
dart run tool/rythme.dart 40
```

Le joueur simulé de `tool/joueur_simule.dart` est partagé avec les tests de
fidélité : une seule copie, sinon les deux finissent par mesurer deux jeux
différents. `donnees.js` reste la source des tables de catalogue.

## Reste à faire

1. **Notifications** (`POST_NOTIFICATIONS`, Android 13+) — décision de produit
   en attente : rappeler le joueur quand la chaîne s'arrête ou que les douze
   heures hors ligne sont pleines. Aucune autre permission n'est nécessaire.
2. **Signature de l'APK** pour une distribution hors Play Store.

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
