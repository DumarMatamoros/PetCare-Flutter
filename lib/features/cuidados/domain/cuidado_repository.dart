import 'cuidado.dart';

/// Cuidados de las mascotas del usuario. Los métodos lanzan un `Fallo`.
abstract class CuidadoRepository {
  Future<List<Cuidado>> obtenerCuidadosDeMascota(int mascotaId);

  /// Inserta el cuidado y lo devuelve con su `id` y `tipoNombre`.
  Future<Cuidado> registrar(Cuidado cuidado);

  Future<void> eliminar(int id);
}
