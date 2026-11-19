import 'usuario.dart';

/// Registro, inicio y cierre de sesión.
///
/// Los métodos lanzan un `Fallo` con un mensaje en español si algo sale mal.
abstract class AuthRepository {
  /// El usuario con sesión, o `null` si no hay sesión.
  Usuario? get usuarioActual;

  /// Emite el usuario cada vez que la sesión cambia (`null` al cerrarla).
  Stream<Usuario?> get cambiosDeSesion;

  Future<void> registrar({required String correo, required String contrasena});

  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  Future<void> cerrarSesion();
}
