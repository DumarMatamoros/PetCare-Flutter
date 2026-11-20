import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errores/fallo.dart';
import '../domain/preferencias.dart';
import '../domain/preferencias_repository.dart';

/// Guarda las preferencias en el teléfono con `shared_preferences`.
///
/// Solo tema y orden de listas: los datos de negocio viven en Supabase.
class PreferenciasRepositoryImpl implements PreferenciasRepository {
  PreferenciasRepositoryImpl([SharedPreferencesAsync? almacen])
    : _almacen = almacen ?? SharedPreferencesAsync();

  static const _prefijo = 'preferencias.';

  final SharedPreferencesAsync _almacen;

  /// Claves en `shared_preferences`, por ejemplo `preferencias.tema`.
  static final _claves = {
    for (final campo in Preferencias.porDefecto.toMap().keys) '$_prefijo$campo',
  };

  @override
  Future<Preferencias> leer() async {
    try {
      final guardadas = await _almacen.getAll(allowList: _claves);
      return Preferencias.fromMap({
        for (final MapEntry(:key, :value) in guardadas.entries)
          key.substring(_prefijo.length): value,
      });
    } catch (_) {
      // Si no se pueden leer, la app sigue con los valores por defecto.
      return Preferencias.porDefecto;
    }
  }

  @override
  Future<void> guardar(Preferencias preferencias) async {
    try {
      for (final MapEntry(:key, :value) in preferencias.toMap().entries) {
        await _almacen.setString('$_prefijo$key', value);
      }
    } catch (_) {
      throw const FalloServidor('No se pudo guardar el ajuste');
    }
  }
}
