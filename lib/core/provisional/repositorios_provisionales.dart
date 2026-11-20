import 'package:image_picker/image_picker.dart' show XFile;

import '../../features/cuidados/domain/cuidado.dart';
import '../../features/cuidados/domain/cuidado_repository.dart';
import '../../features/mascotas/domain/mascota.dart';
import '../../features/mascotas/domain/mascota_repository.dart';
import '../../features/tipos_cuidado/domain/tipo_cuidado.dart';
import '../../features/tipos_cuidado/domain/tipo_cuidado_repository.dart';
import '../errores/fallo.dart';

// Repositorios que permiten compilar y arrancar la app mientras cada persona
// no fusiona su implementación real. Al registrar la tuya en `app.dart`, borra
// aquí la clase provisional; el archivo se elimina cuando quede vacío.

const _pendiente = FalloServidor('Pendiente');

/// Persona B lo reemplaza por `MascotaRepositoryImpl`.
class MascotaRepositoryProvisional implements MascotaRepository {
  @override
  Future<List<Mascota>> obtenerMascotas() async => throw _pendiente;

  @override
  Future<Mascota> obtenerMascota(int id) async => throw _pendiente;

  @override
  Future<Mascota> guardar(Mascota mascota, {XFile? fotoNueva}) async =>
      throw _pendiente;

  @override
  Future<void> eliminar(int id) async => throw _pendiente;

  @override
  Future<String?> urlDeFoto(Mascota mascota) async => throw _pendiente;
}

/// Persona C lo reemplaza por `TipoCuidadoRepositoryImpl`.
class TipoCuidadoRepositoryProvisional implements TipoCuidadoRepository {
  @override
  Future<List<TipoCuidado>> obtenerTipos() async => throw _pendiente;
}

/// Persona C lo reemplaza por `CuidadoRepositoryImpl`.
class CuidadoRepositoryProvisional implements CuidadoRepository {
  @override
  Future<List<Cuidado>> obtenerCuidadosDeMascota(int mascotaId) async =>
      throw _pendiente;

  @override
  Future<Cuidado> registrar(Cuidado cuidado) async => throw _pendiente;

  @override
  Future<void> eliminar(int id) async => throw _pendiente;
}
