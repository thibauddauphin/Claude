/// La grille logique de la scène, agrandie sans lissage à l'affichage.
class DimensionsScene {
  const DimensionsScene._();

  static const largeur = 384.0;
  static const hauteur = 216.0;

  /// Ligne de sol : au-dessus le mur et son décor, en dessous l'atelier.
  static const sol = 138.0;

  /// Haut du tapis roulant, qui emporte les produits vers le quai.
  static const tapis = 190.0;

  /// Les vignettes s'alignent sur quatre colonnes et deux rangées ;
  /// la rangée du fond est plus haute que celle du premier plan.
  static const largeurCase = 92.0;
  static const hauteurCase = 46.0;
  static const margeCase = 4.0;
  static const rangees = [sol + 14, tapis - 2];
}
