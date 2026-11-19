import 'preferencias.dart';

/// Preferencias guardadas en el teléfono.
abstract class PreferenciasRepository {
  Future<Preferencias> leer();

  Future<void> guardar(Preferencias preferencias);
}
