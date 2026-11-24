import '../../../core/errores/fallo.dart';
import '../domain/tipo_cuidado.dart';
import '../domain/tipo_cuidado_repository.dart';
import 'tipo_cuidado_service.dart';

class TipoCuidadoRepositoryImpl implements TipoCuidadoRepository {
  TipoCuidadoRepositoryImpl(this._servicio);

  final TipoCuidadoService _servicio;

  @override
  Future<List<TipoCuidado>> obtenerTipos() async {
    try {
      final filas = await _servicio.obtenerTipos();
      return filas.map(TipoCuidado.fromMap).toList();
    } catch (error) {
      if (esErrorDeRed(error)) {
        throw const FalloRed();
      }

      throw const FalloServidor(
        'No se pudo cargar el catálogo de tipos de cuidado.',
      );
    }
  }
}
