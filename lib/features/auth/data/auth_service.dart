import 'package:supabase_flutter/supabase_flutter.dart';

/// Envoltorio delgado sobre Supabase Auth. Deja pasar las excepciones del SDK;
/// las traduce [AuthRepositoryImpl].
class AuthService {
  AuthService(this._cliente);

  final SupabaseClient _cliente;

  GoTrueClient get _auth => _cliente.auth;

  User? get usuarioActual => _auth.currentUser;

  Stream<User?> get cambiosDeSesion =>
      _auth.onAuthStateChange.map((evento) => evento.session?.user);

  Future<void> registrar(String correo, String contrasena) =>
      _auth.signUp(email: correo, password: contrasena);

  Future<void> iniciarSesion(String correo, String contrasena) =>
      _auth.signInWithPassword(email: correo, password: contrasena);

  /// Borra la sesión del teléfono primero y después avisa al servidor.
  Future<void> cerrarSesion() => _auth.signOut();
}
