import 'package:flutter/foundation.dart';

import '../../../core/errores/fallo.dart';
import '../../../core/estado/estado_carga.dart';
import '../domain/tipo_cuidado.dart';
import '../domain/tipo_cuidado_repository.dart';

class TiposCuidadoViewModel extends ChangeNotifier {
  TiposCuidadoViewModel(this._repositorio);

  final TipoCuidadoRepository _repositorio;

  EstadoCarga<List<TipoCuidado>> _estado = const Cargando();

  EstadoCarga<List<TipoCuidado>> get estado => _estado;

  Future<void> cargar() async {
    _estado = const Cargando();
    notifyListeners();

    try {
      final tipos = await _repositorio.obtenerTipos();
      _estado = tipos.isEmpty ? const Vacio() : Datos(tipos);
    } on Fallo catch (fallo) {
      _estado = ErrorCarga(fallo.mensaje);
    }

    notifyListeners();
  }
}
