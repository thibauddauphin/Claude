import 'catalogue/eres.dart';
import 'entities/entree_journal.dart';
import 'entities/etat_partie.dart';
import 'regles.dart';

/// Ajoute une ligne au journal de bord, datée de l'ère en cours.
void journaliser(EtatPartie e, String texte) {
  e.journal.add(EntreeJournal(annee: eres[Regles.ereCourante(e)].annee, texte: texte));
  if (e.journal.length > 8) e.journal.removeAt(0);
}
