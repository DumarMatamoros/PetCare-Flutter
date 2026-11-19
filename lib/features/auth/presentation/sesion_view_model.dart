import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/auth_repository.dart';
import '../domain/usuario.dart';

/// Estado global de la sesión.
///
/// El router lo usa como `refreshListenable`: cuando la sesión cambia, el
/// `redirect` vuelve a evaluarse y lleva a la pantalla correcta. Por eso nadie
/// navega a mano después de iniciar o cerrar sesión.
class SesionViewModel extends ChangeNotifier {
  SesionViewModel(this._repositorio) : _usuario = _repositorio.usuarioActual {
    _suscripcion = _repositorio.cambiosDeSesion.listen(_alCambiarSesion);
  }

  final AuthRepository _repositorio;
  late final StreamSubscription<Usuario?> _suscripcion;
  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  bool get haySesion => _usuario != null;

  /// Lanza un `Fallo` si no se pudo cerrar la sesión.
  Future<void> cerrarSesion() => _repositorio.cerrarSesion();

  void _alCambiarSesion(Usuario? usuario) {
    // El SDK también emite al refrescar el token; solo avisamos si cambió
    // el usuario.
    if (usuario == _usuario) return;
    _usuario = usuario;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }
}
