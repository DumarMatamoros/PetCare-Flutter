import 'package:supabase_flutter/supabase_flutter.dart';

/// Ejecuta en Supabase las consultas de cuidados.
class CuidadoService {
  CuidadoService(this._cliente);

  final SupabaseClient _cliente;

  Future<List<Map<String, dynamic>>> obtenerPorMascota(int mascotaId) async {
    return await _cliente
        .from('cuidados')
        .select('*, tipos_cuidado(nombre)')
        .eq('mascota_id', mascotaId)
        .order('fecha', ascending: false);
  }

  Future<Map<String, dynamic>> registrar(Map<String, dynamic> datos) async {
    return await _cliente
        .from('cuidados')
        .insert(datos)
        .select('*, tipos_cuidado(nombre)')
        .single();
  }

  Future<void> eliminar(int id) async {
    await _cliente.from('cuidados').delete().eq('id', id);
  }
}
