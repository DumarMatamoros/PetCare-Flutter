import 'package:flutter/foundation.dart';

import '../../../core/errores/fallo.dart';
import '../../../core/estado/estado_carga.dart';
import '../../tipos_cuidado/domain/tipo_cuidado.dart';
import '../../tipos_cuidado/domain/tipo_cuidado_repository.dart';
import '../domain/cuidado.dart';
import '../domain/cuidado_repository.dart';

class CuidadoFormViewModel extends ChangeNotifier {
  CuidadoFormViewModel(
    this.mascotaId,
    this._tiposRepositorio,
    this._cuidadosRepositorio,
  );

  final int mascotaId;
  final TipoCuidadoRepository _tiposRepositorio;
  final CuidadoRepository _cuidadosRepositorio;

  EstadoCarga<List<TipoCuidado>> _estadoTipos = const Cargando();
  EstadoCarga<List<TipoCuidado>> get estadoTipos => _estadoTipos;

  int? _tipoCuidadoId;
  int? get tipoCuidadoId => _tipoCuidadoId;

  DateTime? _fecha = DateTime.now();
  DateTime? get fecha => _fecha;

  bool _guardando = false;
  bool get guardando => _guardando;

  String? _mensajeError;
  String? get mensajeError => _mensajeError;

  Future<void> cargarTipos() async {
    _estadoTipos = const Cargando();
    notifyListeners();

    try {
      final tipos = await _tiposRepositorio.obtenerTipos();
      _estadoTipos = tipos.isEmpty ? const Vacio() : Datos(tipos);
    } on Fallo catch (fallo) {
      _estadoTipos = ErrorCarga(fallo.mensaje);
    }

    notifyListeners();
  }

  void seleccionarTipo(int? id) {
    _tipoCuidadoId = id;
    _mensajeError = null;
    notifyListeners();
  }

  void seleccionarFecha(DateTime? fecha) {
    _fecha = fecha;
    _mensajeError = null;
    notifyListeners();
  }

  Future<bool> guardar(String notas) async {
    if (_tipoCuidadoId == null) {
      _mensajeError = 'Selecciona un tipo de cuidado.';
      notifyListeners();
      return false;
    }

    if (_fecha == null) {
      _mensajeError = 'Selecciona una fecha.';
      notifyListeners();
      return false;
    }

    _guardando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      await _cuidadosRepositorio.registrar(
        Cuidado(
          mascotaId: mascotaId,
          tipoCuidadoId: _tipoCuidadoId!,
          fecha: _fecha!,
          notas: notas.trim().isEmpty ? null : notas.trim(),
        ),
      );
      return true;
    } on Fallo catch (fallo) {
      _mensajeError = fallo.mensaje;
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }
}
