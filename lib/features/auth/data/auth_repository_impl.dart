import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errores/fallo.dart';
import '../domain/auth_repository.dart';
import '../domain/usuario.dart';
import 'auth_service.dart';

/// Implementa [AuthRepository] con Supabase y convierte sus errores en [Fallo].
///
/// Sirve de ejemplo para los demás `RepositorioImpl`: cada método envuelve la
/// llamada al servicio en [_traducir], que decide qué [Fallo] lanzar.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._servicio);

  final AuthService _servicio;

  @override
  Usuario? get usuarioActual => _aUsuario(_servicio.usuarioActual);

  @override
  Stream<Usuario?> get cambiosDeSesion =>
      _servicio.cambiosDeSesion.map(_aUsuario);

  @override
  Future<void> registrar({
    required String correo,
    required String contrasena,
  }) => _traducir(() => _servicio.registrar(correo.trim(), contrasena));

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) => _traducir(() => _servicio.iniciarSesion(correo.trim(), contrasena));

  @override
  Future<void> cerrarSesion() async {
    try {
      await _servicio.cerrarSesion();
    } catch (error) {
      // El SDK borra la sesión local antes de llamar al servidor, así que sin
      // conexión la sesión ya quedó cerrada en el teléfono.
      if (!esErrorDeRed(error)) rethrow;
    }
  }

  static Usuario? _aUsuario(User? usuario) => usuario == null
      ? null
      : Usuario(id: usuario.id, correo: usuario.email ?? '');

  static Future<void> _traducir(Future<void> Function() accion) async {
    try {
      await accion();
    } catch (error) {
      if (esErrorDeRed(error)) throw const FalloRed();
      if (error is AuthException) throw FalloSesion(_mensaje(error));
      throw const FalloServidor();
    }
  }

  static String _mensaje(AuthException error) => switch (error.code) {
    'invalid_credentials' => 'Correo o contraseña incorrectos',
    'user_already_exists' ||
    'email_exists' => 'Ya existe una cuenta con ese correo',
    'weak_password' => 'La contraseña debe tener al menos 6 caracteres',
    'email_address_invalid' || 'validation_failed' => 'El correo no es válido',
    'email_not_confirmed' => 'Debes confirmar tu correo antes de entrar',
    'over_request_rate_limit' ||
    'over_email_send_rate_limit' => 'Demasiados intentos. Espera un momento.',
    _ => 'No se pudo completar la operación. Intenta de nuevo.',
  };
}
