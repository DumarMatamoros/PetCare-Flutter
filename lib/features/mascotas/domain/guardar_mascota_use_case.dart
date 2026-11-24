import 'package:image_picker/image_picker.dart';

import 'mascota.dart';
import 'mascota_repository.dart';

/// Validaciones compartidas al registrar o editar una mascota.
class GuardarMascotaUseCase {
  const GuardarMascotaUseCase(this._repositorio);
  final MascotaRepository _repositorio;

  Map<String, String> validar(Mascota mascota) {
    final errores = <String, String>{};
    if (mascota.nombre.trim().isEmpty) errores['nombre'] = 'Ingresa un nombre';
    if (mascota.especie.trim().isEmpty) {
      errores['especie'] = 'Ingresa una especie';
    }
    final fecha = mascota.fechaNacimiento;
    final hoy = DateTime.now();
    if (fecha != null &&
        DateTime(
          fecha.year,
          fecha.month,
          fecha.day,
        ).isAfter(DateTime(hoy.year, hoy.month, hoy.day))) {
      errores['fechaNacimiento'] = 'La fecha no puede ser futura';
    }
    if (mascota.pesoKg != null &&
        (!mascota.pesoKg!.isFinite || mascota.pesoKg! <= 0)) {
      errores['pesoKg'] = 'El peso debe ser mayor que cero';
    }
    return errores;
  }

  Future<Mascota> guardar(Mascota mascota, {XFile? fotoNueva}) {
    final errores = validar(mascota);
    if (errores.isNotEmpty) throw ValidacionMascotaException(errores);
    return _repositorio.guardar(mascota, fotoNueva: fotoNueva);
  }
}

class ValidacionMascotaException implements Exception {
  const ValidacionMascotaException(this.errores);
  final Map<String, String> errores;
}
