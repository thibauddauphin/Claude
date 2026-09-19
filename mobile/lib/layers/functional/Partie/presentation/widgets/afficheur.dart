import 'package:flutter/material.dart';

import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';

/// Un afficheur encastré dans le capot : fond noir, chiffres ambre.
class Afficheur extends StatelessWidget {
  const Afficheur({
    required this.etiquette,
    required this.valeur,
    this.alerte = false,
    super.key,
  });

  final String etiquette;
  final String valeur;

  /// Passe la valeur au rouge : stock épuisé, chaîne à l'arrêt.
  final bool alerte;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 4, 9, 5),
      decoration: BoxDecoration(
        color: p.ecran,
        border: Border.all(color: p.traitFranc),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(etiquette.toUpperCase(),
              style: ThemeAtelier.etiquette(p, couleur: p.encreEcranPale, taille: 8.5)),
          Text(valeur,
              style: ThemeAtelier.chiffres(p,
                  couleur: alerte ? const Color(0xFFFF6A52) : p.encreEcran, taille: 15)),
        ],
      ),
    );
  }
}

/// Un panneau de l'atelier : bandeau sérigraphié, contenu en dessous.
class Panneau extends StatelessWidget {
  const Panneau({
    required this.titre,
    required this.enfant,
    this.indication,
    super.key,
  });

  final String titre;
  final String? indication;
  final Widget enfant;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.panneau,
        border: Border.all(color: p.traitFranc),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: p.panneauCreux,
              border: Border(bottom: BorderSide(color: p.trait)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(titre.toUpperCase(),
                      style: ThemeAtelier.etiquette(p, couleur: p.encreDouce)),
                ),
                if (indication != null)
                  Text(indication!,
                      style: ThemeAtelier.etiquette(p, couleur: p.encrePale)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: enfant),
        ],
      ),
    );
  }
}

/// Une ligne d'achat : palier, description, prix. Grisée si hors de portée.
class LigneAchat extends StatelessWidget {
  const LigneAchat({
    required this.marqueur,
    required this.nom,
    required this.detail,
    required this.prix,
    required this.unite,
    required this.abordable,
    required this.onTap,
    this.possede = false,
    this.acquis = false,
    super.key,
  });

  final Widget marqueur;
  final String nom;
  final String detail;
  final String prix;
  final String unite;
  final bool abordable;
  final bool possede;
  final bool acquis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final actif = abordable && !acquis;
    return Opacity(
      opacity: actif || acquis ? 1 : .5,
      child: Material(
        color: acquis || possede ? p.panneauCreux : Colors.transparent,
        borderRadius: BorderRadius.circular(2),
        child: InkWell(
          onTap: actif ? onTap : null,
          borderRadius: BorderRadius.circular(2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: acquis
                      ? p.accent
                      : possede
                          ? p.accent
                          : abordable
                              ? p.bon
                              : Colors.transparent,
                  width: 4,
                ),
                top: BorderSide(color: p.trait),
                right: BorderSide(color: p.trait),
                bottom: BorderSide(color: p.trait),
              ),
              /* Pas d'arrondi ici : le liseré gauche est volontairement d'une
                 autre couleur et plus épais, et Flutter refuse de peindre un
                 borderRadius sur une bordure non uniforme. */
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                marqueur,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(nom,
                          style: ThemeAtelier.corps(p, taille: 13.5)
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(detail,
                          style: ThemeAtelier.chiffres(p,
                              couleur: p.encreDouce, taille: 10.5,
                              graisse: FontWeight.w400)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(prix,
                        style: ThemeAtelier.chiffres(p,
                            couleur: acquis ? p.accent : p.encre, taille: 13)),
                    Text(unite,
                        style: ThemeAtelier.etiquette(p, couleur: p.encrePale, taille: 9)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Le chiffre en gros, avec son intitulé au-dessus.
class Chiffre extends StatelessWidget {
  const Chiffre({required this.intitule, required this.valeur, this.couleur, super.key});

  final String intitule;
  final String valeur;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(intitule.toUpperCase(),
            style: ThemeAtelier.etiquette(p, taille: 9)),
        Text(valeur, style: ThemeAtelier.chiffres(p, couleur: couleur, taille: 15)),
      ],
    );
  }
}
