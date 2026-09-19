import 'package:flutter/material.dart';

import '../../../../technical/Format/nombres.dart';
import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../../domain/entities/etat_partie.dart';
import '../../domain/regles.dart';
import 'afficheur.dart';

/// Ce que gagne et ce que dépense la société, à la seconde.
///
/// C'est le tableau que regarde un dirigeant : pas le chiffre d'affaires, mais
/// ce qui reste une fois tout payé. Les charges tombent que l'atelier tourne
/// ou non, et c'est là qu'on s'en aperçoit.
class CompteResultat extends StatelessWidget {
  const CompteResultat({required this.etat, super.key});

  final EtatPartie etat;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final recette = Regles.recetteBrute(etat);
    final composants = Regles.besoinComposants(etat) *
        Regles.cadence(etat) *
        Regles.prixComposant(etat);
    final salaires = Regles.masseSalariale(etat);
    final entretien = Regles.entretienParc(etat);
    final resultat = Regles.resultatParSeconde(etat);
    final decouvert = etat.tresorerie < 0;

    return Panneau(
      titre: 'Compte de résultat',
      indication: 'par seconde',
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Ligne(intitule: 'Recette', montant: recette, couleur: p.bon),
          if (composants > 0)
            _Ligne(intitule: 'Composants', montant: -composants),
          if (salaires > 0) _Ligne(intitule: 'Salaires', montant: -salaires),
          if (entretien > 0) _Ligne(intitule: 'Entretien du parc', montant: -entretien),
          Divider(color: p.trait, height: 18),
          _Ligne(
            intitule: 'Résultat',
            montant: resultat,
            couleur: resultat < 0 ? p.mauvais : p.bon,
            gras: true,
          ),
          const SizedBox(height: 10),
          Text(
            _commentaire(resultat, salaires + entretien),
            style: ThemeAtelier.corps(p, couleur: p.encrePale, taille: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              Chiffre(
                intitule: 'Exercice en cours',
                valeur: Nombres.euros(etat.resultatExercice),
                couleur: etat.resultatExercice < 0 ? p.mauvais : null,
              ),
              if (etat.dernierImpot > 0)
                Chiffre(
                  intitule: 'Dernier impôt',
                  valeur: Nombres.euros(etat.dernierImpot),
                ),
            ],
          ),
          if (decouvert) ...[
            const SizedBox(height: 10),
            Text(
              'Découvert de ${Nombres.euros(-etat.tresorerie)}. '
              'La banque tolère ${Nombres.euros(Regles.decouvertTolere(etat))} ; '
              'au-delà elle vous fera vendre.',
              style: ThemeAtelier.corps(p, couleur: p.mauvais, taille: 12),
            ),
          ],
        ],
      ),
    );
  }

  String _commentaire(double resultat, double charges) {
    if (charges <= 0) return 'Aucune charge fixe : rien ne tombe quand l’atelier s’arrête.';
    if (resultat < 0) {
      return 'Vous perdez de l’argent : les charges dépassent ce que l’atelier '
          'rapporte. Produire plus, vendre plus cher ou alléger le parc.';
    }
    return 'Les charges tombent même à l’arrêt : une chaîne stoppée coûte '
        '${Nombres.euros(charges)} par seconde.';
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.intitule,
    required this.montant,
    this.couleur,
    this.gras = false,
  });

  final String intitule;
  final double montant;
  final Color? couleur;
  final bool gras;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(intitule,
              style: ThemeAtelier.corps(p,
                  couleur: gras ? p.encre : p.encreDouce, taille: 12.5)),
          Text(
            Nombres.euros(montant),
            style: ThemeAtelier.chiffres(p,
                couleur: couleur ?? p.encre,
                taille: 12.5,
                graisse: gras ? FontWeight.w600 : FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
