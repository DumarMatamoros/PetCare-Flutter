import 'package:flutter/foundation.dart';

import '../../../core/errores/fallo.dart';
import '../../../core/estado/estado_carga.dart';
import '../../mascotas/domain/mascota_repository.dart';

class InicioViewModel extends ChangeNotifier {
  InicioViewModel(this._repositorio);

  final MascotaRepository _repositorio;
  EstadoCarga<int> _estado = const Cargando();
  int _solicitud = 0;

  EstadoCarga<int> get estado => _estado;

  Future<void> cargar() async {
    final solicitud = ++_solicitud;
    _actualizar(const Cargando());
    EstadoCarga<int> resultado;

    try {
      final mascotas = await _repositorio.obtenerMascotas();
      resultado = mascotas.isEmpty ? const Vacio() : Datos(mascotas.length);
    } on Fallo catch (fallo) {
      resultado = ErrorCarga(fallo.mensaje);
    }

    if (solicitud == _solicitud) _actualizar(resultado);
  }

  void _actualizar(EstadoCarga<int> estado) {
    if (_estado == estado) return;
    _estado = estado;
    notifyListeners();
  }

  @override
  void dispose() {
    _solicitud++;
    super.dispose();
  }
}
