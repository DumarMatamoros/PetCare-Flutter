import 'package:flutter/foundation.dart';

import '../../../core/errores/fallo.dart';
import '../../../core/estado/estado_carga.dart';
import '../../mascotas/domain/mascota.dart';
import '../../mascotas/domain/mascota_repository.dart';
import '../domain/cuidado.dart';
import '../domain/cuidado_repository.dart';

class DetalleMascotaDatos {
  const DetalleMascotaDatos({
    required this.mascota,
    required this.urlFoto,
    required this.cuidados,
  });

  final Mascota mascota;
  final String? urlFoto;
  final List<Cuidado> cuidados;
}

class DetalleMascotaViewModel extends ChangeNotifier {
  DetalleMascotaViewModel(
    this.mascotaId,
    this._mascotasRepositorio,
    this._cuidadosRepositorio,
  );

  final int mascotaId;
  final MascotaRepository _mascotasRepositorio;
  final CuidadoRepository _cuidadosRepositorio;

  EstadoCarga<DetalleMascotaDatos> _estado = const Cargando();
  EstadoCarga<DetalleMascotaDatos> get estado => _estado;

  int _solicitud = 0;

  Future<void> cargar() async {
    final solicitud = ++_solicitud;
    _estado = const Cargando();
    notifyListeners();

    EstadoCarga<DetalleMascotaDatos> resultado;

    try {
      final mascota = await _mascotasRepositorio.obtenerMascota(mascotaId);
      final urlFoto = await _mascotasRepositorio.urlDeFoto(mascota);
      final cuidados = await _cuidadosRepositorio.obtenerCuidadosDeMascota(
        mascotaId,
      );

      resultado = Datos(
        DetalleMascotaDatos(
          mascota: mascota,
          urlFoto: urlFoto,
          cuidados: cuidados,
        ),
      );
    } on Fallo catch (fallo) {
      resultado = ErrorCarga(fallo.mensaje);
    }

    if (solicitud == _solicitud) {
      _estado = resultado;
      notifyListeners();
    }
  }

  Future<String?> eliminarCuidado(int cuidadoId) async {
    try {
      await _cuidadosRepositorio.eliminar(cuidadoId);
      await cargar();
      return null;
    } on Fallo catch (fallo) {
      return fallo.mensaje;
    }
  }

  Future<String?> eliminarMascota() async {
    try {
      await _mascotasRepositorio.eliminar(mascotaId);
      return null;
    } on Fallo catch (fallo) {
      return fallo.mensaje;
    }
  }

  @override
  void dispose() {
    _solicitud++;
    super.dispose();
  }
}
