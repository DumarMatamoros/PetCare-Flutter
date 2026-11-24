import 'package:image_picker/image_picker.dart';

import '../../../core/errores/fallo.dart';
import '../domain/mascota.dart';
import '../domain/mascota_repository.dart';
import 'mascota_service.dart';

class MascotaRepositoryImpl implements MascotaRepository {
  MascotaRepositoryImpl(this._servicio);
  final MascotaService _servicio;

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on Fallo {
      rethrow;
    } catch (error) {
      if (esErrorDeRed(error)) throw const FalloRed();
      throw const FalloServidor();
    }
  }

  @override
  Future<List<Mascota>> obtenerMascotas() => _traducir(
    () async => (await _servicio.listar()).map(Mascota.fromMap).toList(),
  );

  @override
  Future<Mascota> obtenerMascota(int id) =>
      _traducir(() async => Mascota.fromMap(await _servicio.obtener(id)));

  @override
  Future<Mascota> guardar(Mascota mascota, {XFile? fotoNueva}) => _traducir(
    () async {
      final fotoAnterior = mascota.fotoPath;
      String? fotoSubida;
      if (fotoNueva != null) fotoSubida = await _servicio.subirFoto(fotoNueva);
      late final Mascota guardada;
      try {
        guardada = Mascota.fromMap(
          await _servicio.guardar(
            mascota.copyWith(fotoPath: fotoSubida).toMap(),
            mascota.id,
          ),
        );
      } catch (_) {
        if (fotoSubida != null) {
          try {
            await _servicio.eliminarFoto(fotoSubida);
          } catch (_) {
            /* limpieza best effort */
          }
        }
        rethrow;
      }
      if (fotoSubida != null &&
          fotoAnterior != null &&
          fotoAnterior != fotoSubida) {
        try {
          await _servicio.eliminarFoto(fotoAnterior);
        } catch (_) {
          /* la fila ya se guardó */
        }
      }
      return guardada;
    },
  );

  @override
  Future<void> eliminar(int id) => _traducir(() async {
    final mascota = Mascota.fromMap(await _servicio.obtener(id));
    await _servicio.eliminar(id);
    if (mascota.fotoPath != null) {
      await _servicio.eliminarFoto(mascota.fotoPath!);
    }
  });

  @override
  Future<String?> urlDeFoto(Mascota mascota) => _traducir(
    () async =>
        mascota.fotoPath == null ? null : _servicio.urlFoto(mascota.fotoPath!),
  );
}
