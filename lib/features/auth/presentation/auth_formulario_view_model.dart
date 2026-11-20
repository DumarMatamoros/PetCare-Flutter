import 'package:flutter/foundation.dart';

import '../../../core/errores/fallo.dart';
import '../domain/auth_repository.dart';
import 'validadores_auth.dart';

class SignInViewModel extends _AuthFormularioViewModel {
  SignInViewModel(this._repositorio);

  final AuthRepository _repositorio;

  Future<void> iniciarSesion(String correo, String contrasena) async {
    if (enviando) return;
    _errorCorreo = ValidadoresAuth.correo(correo);
    _errorContrasena = ValidadoresAuth.claveIngreso(contrasena);
    await _enviar(
      valido: errorCorreo == null && errorContrasena == null,
      accion: () => _repositorio.iniciarSesion(
        correo: correo.trim(),
        contrasena: contrasena,
      ),
    );
  }
}

class SignUpViewModel extends _AuthFormularioViewModel {
  SignUpViewModel(this._repositorio);

  final AuthRepository _repositorio;
  String? _errorConfirmacion;

  String? get errorConfirmacion => _errorConfirmacion;

  Future<void> registrar(
    String correo,
    String contrasena,
    String confirmacion,
  ) async {
    if (enviando) return;
    _errorCorreo = ValidadoresAuth.correo(correo);
    _errorContrasena = ValidadoresAuth.claveNueva(contrasena);
    _errorConfirmacion = ValidadoresAuth.confirmacionClave(
      confirmacion,
      contrasena,
    );
    await _enviar(
      valido:
          errorCorreo == null &&
          errorContrasena == null &&
          errorConfirmacion == null,
      accion: () =>
          _repositorio.registrar(correo: correo.trim(), contrasena: contrasena),
    );
  }
}

abstract class _AuthFormularioViewModel extends ChangeNotifier {
  bool _enviando = false;
  bool _descartado = false;
  String? _error;
  String? _errorCorreo;
  String? _errorContrasena;

  bool get enviando => _enviando;
  String? get error => _error;
  String? get errorCorreo => _errorCorreo;
  String? get errorContrasena => _errorContrasena;

  Future<void> _enviar({
    required bool valido,
    required Future<void> Function() accion,
  }) async {
    if (_descartado) return;
    _error = null;
    _enviando = valido;
    notifyListeners();
    if (!valido) return;

    try {
      await accion();
    } on Fallo catch (fallo) {
      _error = fallo.mensaje;
    } finally {
      _enviando = false;
      if (!_descartado) notifyListeners();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
