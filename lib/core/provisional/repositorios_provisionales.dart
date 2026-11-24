import 'package:image_picker/image_picker.dart' show XFile;

import '../../features/ajustes/domain/preferencias.dart';
import '../../features/ajustes/domain/preferencias_repository.dart';
import '../../features/mascotas/domain/mascota.dart';
import '../../features/mascotas/domain/mascota_repository.dart';
import '../errores/fallo.dart';

// Repositorios provisionales que permiten compilar y arrancar la app mientras
// no se fusionan las implementaciones reales.

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

/// Persona D lo reemplaza por `PreferenciasRepositoryImpl`. Mientras tanto
/// devuelve los valores por defecto y no guarda nada.
class PreferenciasRepositoryProvisional implements PreferenciasRepository {
  @override
  Future<Preferencias> leer() async => Preferencias.porDefecto;

  @override
  Future<void> guardar(Preferencias preferencias) async {}
}
