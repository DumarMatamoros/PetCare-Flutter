import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Guarda la sesión de Supabase cifrada con `flutter_secure_storage`.
///
/// Por defecto el SDK la guardaría en `shared_preferences`, en texto plano.
class AlmacenSesionSeguro extends LocalStorage {
  AlmacenSesionSeguro({FlutterSecureStorage? almacen})
    : _almacen = almacen ?? const FlutterSecureStorage();

  static const _clave = 'petcare.sesion_supabase';

  final FlutterSecureStorage _almacen;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() => _almacen.containsKey(key: _clave);

  @override
  Future<String?> accessToken() => _almacen.read(key: _clave);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _almacen.write(key: _clave, value: persistSessionString);

  @override
  Future<void> removePersistedSession() => _almacen.delete(key: _clave);
}
