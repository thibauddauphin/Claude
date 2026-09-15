import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Format/nombres.dart';
import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../../domain/catalogue/caracteres_index.dart';
import '../../domain/entities/employe.dart';
import '../../domain/entities/etat_partie.dart';
import '../../domain/regles.dart';
import '../cubit/partie_cubit.dart';
import '../peintres/portrait_peintre.dart';
import '../widgets/afficheur.dart';

/// L'onglet des gens : la candidature en attente, puis chacun avec son moral.
class EquipeView extends StatelessWidget {
  const EquipeView({required this.etat, this.appairage, super.key});

  final EtatPartie etat;

  /// Graine de la personne en attente d'un binôme.
  final int? appairage;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<PartieCubit>();
    final candidat = etat.candidat;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        if (candidat != null) ...[
          _Candidature(candidat: candidat, tresorerie: etat.tresorerie),
          const SizedBox(height: 12),
        ],
        Panneau(
          titre: 'Équipe',
          indication: '${etat.equipe.length}/${Regles.placesEquipe(etat)} · '
              'paie ${Nombres.pourcent(Regles.masseSalariale(etat) * 100)}',
          enfant: etat.equipe.isEmpty
              ? Text(
                  "Personne à l'atelier. Les candidatures arrivent d'elles-mêmes "
                  'quand la production tourne.',
                  style: ThemeAtelier.corps(p, couleur: p.encrePale, taille: 12))
              : Column(
                  children: [
                    for (final (i, membre) in etat.equipe.indexed) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _FicheEmploye(
                        etat: etat,
                        membre: membre,
                        index: i,
                        enAttente: appairage == membre.graine,
                        appairageActif: appairage != null,
                        onPrime: () => cubit.verserPrime(i),
                        onAugmenter: () => cubit.augmenter(i),
                        onBinome: () => cubit.toucherBinome(i),
                      ),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 10),
        Text(
          'Le moral suit vos prix, les arrêts de chaîne et les crises. '
          'Sous 45 %, la concurrence commence à débaucher.',
          style: ThemeAtelier.corps(p, couleur: p.encrePale, taille: 11.5),
        ),
      ],
    );
  }
}

class _Candidature extends StatelessWidget {
  const _Candidature({required this.candidat, required this.tresorerie});

  final Employe candidat;
  final double tresorerie;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<PartieCubit>();
    final caractere = caractereParId[candidat.caractereId]!;
    final indemnite = candidat.indemnite;
    final payable = indemnite == null || tresorerie >= indemnite;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.panneauCreux,
        border: Border(
          left: BorderSide(color: candidat.origine != null ? p.rivaux[2] : p.accent, width: 4),
          top: BorderSide(color: p.traitFranc),
          right: BorderSide(color: p.traitFranc),
          bottom: BorderSide(color: p.traitFranc),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Portrait(membre: candidat),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(candidat.nomComplet,
                        style: ThemeAtelier.corps(p).copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      '${caractere.nom} · ${candidat.age.round()} ans'
                      '${candidat.origine != null ? ' · vient de chez ${candidat.origine}' : ''}',
                      style: ThemeAtelier.chiffres(p,
                          couleur: candidat.origine != null ? p.rivaux[2] : p.accent,
                          taille: 10.5,
                          graisse: FontWeight.w400),
                    ),
                    Text(caractere.effet,
                        style: ThemeAtelier.corps(p, couleur: p.encreDouce, taille: 11.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${indemnite != null ? 'Indemnité ${Nombres.euros(indemnite)} · ' : ''}'
            'demande ${Nombres.pourcent(candidat.part * 100)} du chiffre d’affaires',
            style: ThemeAtelier.chiffres(p,
                couleur: p.encreDouce, taille: 11, graisse: FontWeight.w400),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: p.surAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  ),
                  onPressed: payable ? cubit.embaucher : null,
                  child: const Text('Embaucher'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: p.encreDouce,
                  side: BorderSide(color: p.traitFranc),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                ),
                onPressed: cubit.refuserCandidat,
                child: const Text('Refuser'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FicheEmploye extends StatelessWidget {
  const _FicheEmploye({
    required this.etat,
    required this.membre,
    required this.index,
    required this.enAttente,
    required this.appairageActif,
    required this.onPrime,
    required this.onAugmenter,
    required this.onBinome,
  });

  final EtatPartie etat;
  final Employe membre;
  final int index;
  final bool enAttente;
  final bool appairageActif;
  final VoidCallback onPrime;
  final VoidCallback onAugmenter;
  final VoidCallback onBinome;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final caractere = caractereParId[membre.caractereId]!;
    final duo = Regles.partenaire(etat, membre);
    final synergie = duo != null ? Regles.synergieDe(membre, duo) : null;
    final moral = membre.moral.clamp(0, 100).toDouble();
    final couleurMoral = moral < 25 ? p.mauvais : (moral < 55 ? p.attention : p.bon);
    final prime = Regles.coutPrime(etat, membre);

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: duo != null ? p.rivaux[1] : p.trait, width: duo != null ? 4 : 1),
          top: BorderSide(color: p.trait),
          right: BorderSide(color: p.trait),
          bottom: BorderSide(color: p.trait),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Portrait(membre: membre),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(membre.nomComplet,
                        style: ThemeAtelier.corps(p, taille: 13)
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text('${caractere.nom} · ${membre.poste.toLowerCase()}',
                        style: ThemeAtelier.chiffres(p,
                            couleur: p.encrePale, taille: 10, graisse: FontWeight.w400)),
                    Text(
                      '${membre.age.round()} ans · ${membre.anneesDeMaison} an(s) de maison',
                      style: ThemeAtelier.chiffres(p,
                          couleur: p.encrePale, taille: 9.5, graisse: FontWeight.w400),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      synergie != null
                          ? '${caractere.effet} — ${synergie.nom} : ${synergie.effet}'
                          : duo != null
                              ? '${caractere.effet} — en binôme avec ${duo.prenom} (effets +50 %)'
                              : caractere.effet,
                      style: ThemeAtelier.corps(p, couleur: p.encreDouce, taille: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: moral / 100,
                        minHeight: 8,
                        backgroundColor: p.enfonce,
                        valueColor: AlwaysStoppedAnimation(couleurMoral),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${moral.round()} % de moral · '
                      '${Nombres.pourcent(membre.part * 100)} du CA',
                      style: ThemeAtelier.chiffres(p,
                          couleur: p.encrePale, taille: 9.5, graisse: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _PetitBouton(
                  libelle: 'Prime ${Nombres.euros(prime)}',
                  actif: etat.tresorerie >= prime && moral < 99,
                  onTap: onPrime),
              const SizedBox(width: 6),
              _PetitBouton(
                  libelle: 'Augmenter',
                  actif: moral < 99 && membre.part < membre.partInitiale * 4,
                  onTap: onAugmenter),
              const SizedBox(width: 6),
              _PetitBouton(
                libelle: enAttente
                    ? 'Annuler'
                    : appairageActif
                        ? 'Associer'
                        : duo != null
                            ? 'Séparer'
                            : 'Binôme',
                actif: true,
                accentue: enAttente || appairageActif,
                onTap: onBinome,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Portrait extends StatelessWidget {
  const _Portrait({required this.membre});

  final Employe membre;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 34,
      height: 38,
      decoration: BoxDecoration(
        color: p.enfonce,
        border: Border.all(color: p.trait),
        borderRadius: BorderRadius.circular(2),
      ),
      child: CustomPaint(
        painter: PortraitWidgetPeintre(graine: membre.graine, age: membre.age),
      ),
    );
  }
}

class _PetitBouton extends StatelessWidget {
  const _PetitBouton({
    required this.libelle,
    required this.actif,
    required this.onTap,
    this.accentue = false,
  });

  final String libelle;
  final bool actif;
  final bool accentue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Opacity(
        opacity: actif ? 1 : .4,
        child: Material(
          color: accentue ? p.accent : p.panneauCreux,
          borderRadius: BorderRadius.circular(2),
          child: InkWell(
            onTap: actif ? onTap : null,
            borderRadius: BorderRadius.circular(2),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(color: accentue ? p.accent : p.traitFranc),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(libelle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ThemeAtelier.corps(p,
                      couleur: accentue ? p.surAccent : p.encre, taille: 11)),
            ),
          ),
        ),
      ),
    );
  }
}
