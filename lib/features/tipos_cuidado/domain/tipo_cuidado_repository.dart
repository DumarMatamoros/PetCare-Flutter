import 'tipo_cuidado.dart';

/// Catálogo de tipos de cuidado (solo lectura). Lanza un `Fallo`.
abstract class TipoCuidadoRepository {
  Future<List<TipoCuidado>> obtenerTipos();
}
