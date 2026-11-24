import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errores/fallo.dart';
import '../../../core/estado/estado_carga.dart';
import '../domain/guardar_mascota_use_case.dart';
import '../domain/mascota.dart';
import '../domain/mascota_repository.dart';

class MascotaFormViewModel extends ChangeNotifier {
  MascotaFormViewModel(this._repositorio, this._guardar, this.id);
  final MascotaRepository _repositorio;
  final GuardarMascotaUseCase _guardar;
  final int? id;
  EstadoCarga<Mascota> estado = const Cargando();
  bool guardando = false;
  String? error;
  Map<String, String> errores = {};
  bool _cerrado = false;

  @override
  void dispose() {
    _cerrado = true;
    super.dispose();
  }

  Future<void> cargar() async {
    if (id == null) return;
    estado = const Cargando();
    notifyListeners();
    try {
      estado = Datos(await _repositorio.obtenerMascota(id!));
    } on Fallo catch (e) {
      estado = ErrorCarga(e.mensaje);
    } catch (_) {
      estado = const ErrorCarga('No se pudo cargar la mascota');
    }
    if (!_cerrado) notifyListeners();
  }

  Future<bool> guardar(Mascota mascota, {XFile? fotoNueva}) async {
    if (guardando) return false;
    errores = _guardar.validar(mascota);
    error = null;
    if (errores.isNotEmpty) {
      if (!_cerrado) notifyListeners();
      return false;
    }
    guardando = true;
    notifyListeners();
    try {
      await _guardar.guardar(mascota, fotoNueva: fotoNueva);
      return true;
    } on Fallo catch (e) {
      error = e.mensaje;
      return false;
    } catch (_) {
      error = 'No se pudo guardar la mascota';
      return false;
    } finally {
      guardando = false;
      if (!_cerrado) notifyListeners();
    }
  }
}
