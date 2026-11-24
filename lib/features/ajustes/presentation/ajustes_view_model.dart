import 'package:flutter/foundation.dart';

import '../../../core/errores/fallo.dart';
import '../domain/preferencias.dart';
import '../domain/preferencias_repository.dart';

/// Preferencias de la app. Es global porque varias partes las leen:
///
/// - `MaterialApp` lee [tema].
/// - La lista de mascotas (Persona B) lee [ordenMascotas].
/// - El historial de cuidados (Persona C) lee [ordenHistorial].
///
/// ```dart
/// final orden = context.watch<AjustesViewModel>().ordenMascotas;
/// ```
class AjustesViewModel extends ChangeNotifier {
  AjustesViewModel(
    this._repositorio, {
    Preferencias inicial = Preferencias.porDefecto,
  }) : _preferencias = inicial;

  final PreferenciasRepository _repositorio;
  Preferencias _preferencias;

  Preferencias get preferencias => _preferencias;
  Tema get tema => _preferencias.tema;
  OrdenMascotas get ordenMascotas => _preferencias.ordenMascotas;
  OrdenHistorial get ordenHistorial => _preferencias.ordenHistorial;

  /// Vuelve a leer las preferencias guardadas.
  Future<void> cargar() async {
    _preferencias = await _repositorio.leer();
    notifyListeners();
  }

  /// Los métodos `cambiar...` aplican el cambio al instante. Si no se puede
  /// guardar, lo deshacen y lanzan el [Fallo].
  Future<void> cambiarTema(Tema tema) =>
      _actualizar(_preferencias.copyWith(tema: tema));

  Future<void> cambiarOrdenMascotas(OrdenMascotas orden) =>
      _actualizar(_preferencias.copyWith(ordenMascotas: orden));

  Future<void> cambiarOrdenHistorial(OrdenHistorial orden) =>
      _actualizar(_preferencias.copyWith(ordenHistorial: orden));

  Future<void> _actualizar(Preferencias nuevas) async {
    if (nuevas == _preferencias) return;
    final anteriores = _preferencias;
    _preferencias = nuevas;
    notifyListeners();
    try {
      await _repositorio.guardar(nuevas);
    } on Fallo {
      _preferencias = anteriores;
      notifyListeners();
      rethrow;
    }
  }
}
