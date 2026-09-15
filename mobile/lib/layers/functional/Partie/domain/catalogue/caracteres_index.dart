import '../entities/caractere.dart';
import 'equipe.dart';

/// Accès direct à un caractère par son identifiant.
final caractereParId = <String, Caractere>{
  for (final caractere in caracteres) caractere.id: caractere,
};
