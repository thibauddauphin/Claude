import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Format/nombres.dart';
import '../../../../technical/Theme/palette.dart';
import '../../../../technical/Theme/theme_atelier.dart';
import '../../domain/catalogue/eres.dart';
import '../../domain/catalogue/technologies.dart';
import '../../domain/entities/etat_partie.dart';
import '../../domain/regles.dart';
import '../cubit/partie_cubit.dart';
import '../peintres/icone_recherche.dart';
import '../widgets/afficheur.dart';

/// Les quarante-cinq technologies, groupées par ère.
/// Seules l'ère courante et la suivante sont montrées : le reste viendra.
class RechercheView extends StatelessWidget {
  const RechercheView({required this.etat, super.key});

  final EtatPartie etat;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<PartieCubit>();
    final ere = Regles.ereCourante(etat);

    var visibles = 0;
    for (var i = 0; i < technologies.length; i++) {
      if (technologies[i].ere <= ere + 1) visibles = i + 1;
    }

    final lignes = <Widget>[];
    var ereAffichee = -1;
    for (var i = 0; i < visibles; i++) {
      final techno = technologies[i];
      if (techno.ere != ereAffichee) {
        ereAffichee = techno.ere;
        lignes.add(Padding(
          padding: EdgeInsets.only(top: lignes.isEmpty ? 0 : 12, bottom: 6),
          child: Row(
            children: [
              Text(eres[techno.ere].annee,
                  style: ThemeAtelier.etiquette(p, couleur: p.accent)),
              const SizedBox(width: 8),
              Expanded(child: Divider(color: p.trait, height: 1)),
              const SizedBox(width: 8),
              Text(eres[techno.ere].nom.toUpperCase(),
                  style: ThemeAtelier.etiquette(p, couleur: p.encrePale, taille: 9)),
            ],
          ),
        ));
      }
      final acquise = etat.possede(techno.id);
      final cout = Regles.coutTechnologie(etat, i);
      lignes.add(Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: LigneAchat(
          marqueur: SizedBox(
            width: 26,
            height: 26,
            child: CustomPaint(painter: IconeRecherchePeintre(nom: techno.icone)),
          ),
          nom: techno.nom,
          detail: techno.effet,
          prix: acquise ? 'acquise' : Nombres.format(cout),
          unite: acquise ? '' : 'points R&D',
          abordable: etat.pointsRecherche >= cout,
          acquis: acquise,
          onTap: () => cubit.acheterTechnologie(i),
        ),
      ));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        Panneau(
          titre: 'Recherche & développement',
          indication: '${etat.technologies.length}/${technologies.length}',
          enfant: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: lignes),
        ),
      ],
    );
  }
}
