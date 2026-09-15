import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Format/nombres.dart';
import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../../domain/entities/etat_partie.dart';
import '../../domain/regles.dart';
import '../cubit/partie_cubit.dart';
import '../widgets/afficheur.dart';
import '../widgets/touche_assemblage.dart';

/// L'onglet du geste : la gamme, la touche, l'approvisionnement, les prix.
class AtelierView extends StatelessWidget {
  const AtelierView({required this.etat, super.key});

  final EtatPartie etat;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<PartieCubit>();
    final gamme = Regles.gamme(etat);
    final besoin = Regles.besoinComposants(etat);
    final prixUnite = Regles.prixUnite(etat);
    final prixComposant = Regles.prixComposant(etat);
    final force = Regles.forceClic(etat);
    final lot = Regles.lotComposants(etat);
    final actions = Regles.actionsIntroduction(etat);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        Panneau(
          titre: 'Gamme en production',
          indication: gamme.annee,
          enfant: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gamme.nom, style: ThemeAtelier.titre(p)),
              const SizedBox(height: 6),
              Text(gamme.description,
                  style: ThemeAtelier.corps(p, couleur: p.encreDouce, taille: 12.5)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  Chiffre(intitule: 'Prix de vente', valeur: Nombres.euros(prixUnite)),
                  Chiffre(
                      intitule: 'Composants',
                      valeur: '${Nombres.format(besoin)} × ${Nombres.euros(prixComposant)}'),
                  Chiffre(
                      intitule: 'Marge nette',
                      valeur: Nombres.euros(prixUnite - besoin * prixComposant),
                      couleur: p.bon),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ToucheAssemblage(
          gain: Nombres.euros(force * prixUnite),
          composants: '${Nombres.format(force * besoin)} ${Nombres.pluriel(force * besoin, 'composant')}',
          active: etat.composants >= force * besoin,
          onAppui: cubit.assembler,
        ),
        const SizedBox(height: 12),
        Panneau(
          titre: 'Approvisionnement',
          enfant: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: p.panneauCreux,
                  foregroundColor: p.encre,
                  side: BorderSide(color: p.traitFranc),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: etat.tresorerie >= prixComposant ? cubit.acheterComposants : null,
                child: Column(
                  children: [
                    Text(
                        'Acheter ${Nombres.format(lot)} '
                        "${Nombres.pluriel(lot, 'composant')}",
                        style: ThemeAtelier.corps(p).copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      '${Nombres.euros(lot * prixComposant)} · '
                      '${Nombres.euros(prixComposant)} l’unité'
                      '${etat.possede('appro') ? ' · rachat auto actif' : ''}',
                      style: ThemeAtelier.chiffres(p,
                          couleur: p.encreDouce, taille: 11, graisse: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Panneau(
          titre: 'Politique de prix',
          indication: '${(etat.marge * 100).round()} %',
          enfant: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: etat.marge,
                min: .7,
                max: 1.6,
                divisions: 18,
                activeColor: p.accent,
                onChanged: cubit.changerMarge,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Casser les prix',
                      style: ThemeAtelier.corps(p, couleur: p.encreDouce, taille: 11.5)),
                  Text('Vendre cher',
                      style: ThemeAtelier.corps(p, couleur: p.encreDouce, taille: 11.5)),
                ],
              ),
              const SizedBox(height: 8),
              Text(_effetMarge(etat), style: ThemeAtelier.corps(p, couleur: p.encrePale, taille: 12)),
            ],
          ),
        ),
        if (actions > 0) ...[
          const SizedBox(height: 12),
          _BoutonPrestige(
            titre: 'Entrer en bourse',
            detail: '$actions actions · +${actions * 8} % production et prix, à vie',
            onConfirme: cubit.entrerEnBourse,
          ),
        ],
      ],
    );
  }

  String _effetMarge(EtatPartie etat) {
    final c = Regles.conquete(etat);
    final f = Nombres.format(c);
    if (etat.marge > 1.02) {
      return 'Recette en hausse, conquête du marché ralentie (×$f).';
    }
    if (etat.marge < .98) {
      return 'Recette réduite, parts de marché gagnées plus vite (×$f).';
    }
    return 'Prix du marché : recette et conquête à l’équilibre (×$f).';
  }
}

/// Bouton de remise à zéro : il faut confirmer, on ne solde pas sa société
/// d'une tape involontaire.
class _BoutonPrestige extends StatefulWidget {
  const _BoutonPrestige({
    required this.titre,
    required this.detail,
    required this.onConfirme,
  });

  final String titre;
  final String detail;
  final VoidCallback onConfirme;

  @override
  State<_BoutonPrestige> createState() => _BoutonPrestigeState();
}

class _BoutonPrestigeState extends State<_BoutonPrestige> {
  bool _arme = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: p.surAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () {
        if (!_arme) {
          setState(() => _arme = true);
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) setState(() => _arme = false);
          });
          return;
        }
        setState(() => _arme = false);
        widget.onConfirme();
      },
      child: Column(
        children: [
          Text(_arme ? 'Confirmer : tout repart de zéro' : widget.titre,
              style: ThemeAtelier.corps(p, couleur: p.surAccent)
                  .copyWith(fontWeight: FontWeight.w600)),
          Text(widget.detail,
              style: ThemeAtelier.chiffres(p,
                  couleur: p.surAccent, taille: 11, graisse: FontWeight.w400),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
