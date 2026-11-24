import 'package:supabase_flutter/supabase_flutter.dart';

/// Hace las consultas de Supabase para el catálogo de tipos de cuidado.
class TipoCuidadoService {
  TipoCuidadoService(this._cliente);

  final SupabaseClient _cliente;

  Future<List<Map<String, dynamic>>> obtenerTipos() async {
    return await _cliente.from('tipos_cuidado').select().order('id');
  }
}
