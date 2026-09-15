enum Decor {
  garage, salon, minitel, bureau, openspace, multimedia, loft, bulle,
  habitat, showroom, datacenter, objets, hall, quantique, neuro,
}

class Ere {
  const Ere({required this.annee, required this.nom, required this.decor});

  final String annee;
  final String nom;
  final Decor decor;
}
