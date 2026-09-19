import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Format/nombres.dart';
import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../../domain/catalogue/eres.dart';
import '../../domain/regles.dart';
import '../cubit/partie_cubit.dart';
import '../cubit/partie_state.dart';
import '../widgets/afficheur.dart';
import '../widgets/annonce_ere.dart';
import '../widgets/banniere_evenement.dart';
import '../widgets/scene_atelier.dart';
import 'atelier_view.dart';
import 'equipe_view.dart';
import 'marche_view.dart';
import 'production_view.dart';
import 'recherche_view.dart';

/// L'écran du jeu : instruments en haut, atelier au milieu, onglets en bas.
///
/// Le bureau à trois colonnes ne se transpose pas sur un téléphone ; la scène
/// reste visible en permanence et les panneaux défilent sous elle.
class PartieView extends StatefulWidget {
  const PartieView({super.key});

  @override
  State<PartieView> createState() => _PartieViewState();
}

class _PartieViewState extends State<PartieView> with WidgetsBindingObserver {
  int _onglet = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState etat) {
    final cubit = context.read<PartieCubit>();
    switch (etat) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        cubit.mettreEnVeille();
      case AppLifecycleState.resumed:
        cubit.reprendre();
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return BlocConsumer<PartieCubit, PartieState>(
      listenWhen: (a, b) =>
          a.bilanHorsLigne != b.bilanHorsLigne ||
          a.dernierDepart != b.dernierDepart ||
          a.derniereRetraite != b.derniereRetraite,
      listener: (context, etat) {
        final bilan = etat.bilanHorsLigne;
        if (bilan != null) _montrerRetour(context, bilan);

        final retraite = etat.derniereRetraite;
        if (retraite != null) {
          _annoncer(
            context,
            '${retraite.partant.nomComplet} part à la retraite. '
            '${retraite.releve.prenom} ${retraite.releve.nom} prend la suite.',
            favorable: true,
          );
          return;
        }
        final departs = etat.dernierDepart;
        if (departs != null && departs.isNotEmpty) {
          _annoncer(
            context,
            departs.length == 1
                ? '${departs.first.nomComplet} quitte l’atelier.'
                : '${departs.map((e) => e.prenom).join(', ')} quittent l’atelier.',
            favorable: false,
          );
        }
      },
      builder: (context, etat) {
        final partie = etat.etat;
        if (partie == null) {
          return Scaffold(
            backgroundColor: p.fond,
            body: Center(
              child: CircularProgressIndicator(color: p.accent),
            ),
          );
        }
        final cubit = context.read<PartieCubit>();
        final ere = eres[Regles.ereCourante(partie)];

        return Scaffold(
          backgroundColor: p.fond,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _BandeauInstruments(etat: partie, ere: '${ere.annee} · ${ere.nom}'),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SceneAtelier(
                      etat: partie,
                      battement: cubit.battement,
                      onAssembler: cubit.assembler,
                    ),
                    BanniereEvenement(evenement: partie.evenement),
                    if (etat.ereAnnoncee != null)
                      Positioned.fill(
                        child: AnnonceEre(
                          key: ValueKey(etat.ereAnnoncee),
                          ere: etat.ereAnnoncee!,
                          onTerminee: cubit.annonceEreTerminee,
                        ),
                      ),
                  ],
                ),
                _BandeauCadence(etat: partie),
                Expanded(
                  child: IndexedStack(
                    index: _onglet,
                    children: [
                      AtelierView(etat: partie),
                      ProductionView(etat: partie),
                      RechercheView(etat: partie),
                      EquipeView(etat: partie, appairage: etat.appairageEnCours),
                      MarcheView(etat: partie),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _onglet,
            onDestinationSelected: (i) => setState(() => _onglet = i),
            backgroundColor: p.panneau,
            indicatorColor: p.accent.withValues(alpha: .2),
            height: 62,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.handyman_outlined), label: 'Atelier'),
              NavigationDestination(icon: Icon(Icons.precision_manufacturing_outlined), label: 'Production'),
              NavigationDestination(icon: Icon(Icons.science_outlined), label: 'R&D'),
              NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Équipe'),
              NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Marché'),
            ],
          ),
        );
      },
    );
  }

  /// Un avis bref en bas d'écran : ni dialogue à refermer, ni ligne noyée
  /// dans le journal.
  void _annoncer(BuildContext context, String texte, {required bool favorable}) {
    final p = context.palette;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(texte, style: ThemeAtelier.corps(p, couleur: p.surAccent)),
        backgroundColor: favorable ? p.bon : p.mauvais,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ));
  }

  void _montrerRetour(BuildContext context, dynamic bilan) {
    final p = context.palette;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogue) => AlertDialog(
        backgroundColor: p.panneau,
        title: Text('Pendant votre absence', style: ThemeAtelier.titre(p, taille: 21)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("L'atelier a tourné au ralenti pendant ${Nombres.duree(bilan.duree)}.",
                style: ThemeAtelier.corps(p, couleur: p.encreDouce)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: Chiffre(
                    intitule: 'Unités produites',
                    valeur: Nombres.format(bilan.unites),
                    couleur: p.accent)),
                Expanded(child: Chiffre(
                    intitule: 'Recette',
                    valeur: Nombres.euros(bilan.recette),
                    couleur: p.accent)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              bilan.estPlafonne
                  ? 'La production hors ligne est plafonnée à douze heures — au-delà, les équipes s’arrêtent.'
                  : 'Hors ligne, la chaîne tourne à 60 % de sa cadence.',
              style: ThemeAtelier.corps(p, couleur: p.encrePale, taille: 12),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.accent, foregroundColor: p.surAccent),
            onPressed: () {
              Navigator.of(dialogue).pop();
              context.read<PartieCubit>().masquerBilanHorsLigne();
            },
            child: const Text("Reprendre l'atelier"),
          ),
        ],
      ),
    );
  }
}

class _BandeauInstruments extends StatelessWidget {
  const _BandeauInstruments({required this.etat, required this.ere});

  final dynamic etat;
  final String ere;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cadence = Regles.cadence(etat);
    final bloquee = cadence > 0 && etat.composants < Regles.besoinComposants(etat);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: p.panneau,
        border: Border(bottom: BorderSide(color: p.traitFranc, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Silicium & Cie', style: ThemeAtelier.titre(p, taille: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(ere,
                    style: ThemeAtelier.etiquette(p, couleur: p.encrePale),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Afficheur(etiquette: 'Trésorerie', valeur: Nombres.euros(etat.tresorerie)),
                const SizedBox(width: 6),
                Afficheur(
                    etiquette: 'Revenu',
                    valeur: '${Nombres.euros(cadence * Regles.prixUnite(etat))}/s'),
                const SizedBox(width: 6),
                Afficheur(
                    etiquette: 'Composants',
                    valeur: Nombres.format(etat.composants),
                    alerte: bloquee),
                const SizedBox(width: 6),
                Afficheur(etiquette: 'Points R&D', valeur: Nombres.format(etat.pointsRecherche)),
                const SizedBox(width: 6),
                Afficheur(
                    etiquette: 'Part de marché',
                    valeur: Nombres.pourcent(Regles.partMarche(etat))),
                if (etat.actions >= 1) ...[
                  const SizedBox(width: 6),
                  Afficheur(etiquette: 'Actions', valeur: Nombres.format(etat.actions.floorToDouble())),
                ],
                if (etat.parts >= 1) ...[
                  const SizedBox(width: 6),
                  Afficheur(etiquette: 'Parts', valeur: '${etat.parts}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BandeauCadence extends StatelessWidget {
  const _BandeauCadence({required this.etat});

  final dynamic etat;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cadence = Regles.cadence(etat);
    final bloquee = cadence > 0 && etat.composants < Regles.besoinComposants(etat);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: p.panneauCreux,
        border: Border(bottom: BorderSide(color: p.trait)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              bloquee
                  ? 'Chaîne à l’arrêt — stock de composants épuisé'
                  : 'Cadence ${Nombres.format(cadence)} u/s · '
                      'sortie ${Nombres.euros(cadence * Regles.prixUnite(etat))}/s',
              style: ThemeAtelier.chiffres(p,
                  couleur: bloquee ? p.mauvais : p.encreDouce,
                  taille: 11,
                  graisse: FontWeight.w400),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // L'indication ne sert qu'au tout début ; elle se retire une fois
          // le geste acquis, et laisse la place aux chiffres.
          if (etat.unitesVendues < 20)
            Text('Touchez l’atelier',
                style: ThemeAtelier.etiquette(p, couleur: p.encrePale, taille: 9)),
        ],
      ),
    );
  }
}
