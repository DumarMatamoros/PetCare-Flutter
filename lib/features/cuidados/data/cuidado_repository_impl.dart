import '../../../core/errores/fallo.dart';
import '../domain/cuidado.dart';
import '../domain/cuidado_repository.dart';
import 'cuidado_service.dart';

class CuidadoRepositoryImpl implements CuidadoRepository {
  CuidadoRepositoryImpl(this._servicio);

  final CuidadoService _servicio;

  @override
  Future<List<Cuidado>> obtenerCuidadosDeMascota(int mascotaId) {
    return _traducir(() async {
      final filas = await _servicio.obtenerPorMascota(mascotaId);
      return filas.map(Cuidado.fromMap).toList();
    }, 'No se pudo cargar el historial de cuidados.');
  }

  @override
  Future<Cuidado> registrar(Cuidado cuidado) {
    return _traducir(() async {
      final fila = await _servicio.registrar(cuidado.toMap());
      return Cuidado.fromMap(fila);
    }, 'No se pudo registrar el cuidado.');
  }

  @override
  Future<void> eliminar(int id) {
    return _traducir(
      () => _servicio.eliminar(id),
      'No se pudo eliminar el cuidado.',
    );
  }

  Future<T> _traducir<T>(Future<T> Function() accion, String mensaje) async {
    try {
      return await accion();
    } catch (error) {
      if (error is Fallo) rethrow;
      if (esErrorDeRed(error)) throw const FalloRed();
      throw FalloServidor(mensaje);
    }
  }
}
