import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Encapsula el acceso del módulo a Supabase y a Storage.
class MascotaService {
  MascotaService(this._cliente);
  final SupabaseClient _cliente;
  static const _bucket = 'fotos-mascotas';

  Future<List<Map<String, dynamic>>> listar() async =>
      await _cliente.from('mascotas').select();

  Future<Map<String, dynamic>> obtener(int id) =>
      _cliente.from('mascotas').select().eq('id', id).single();

  Future<Map<String, dynamic>> guardar(Map<String, dynamic> datos, int? id) =>
      id == null
      ? _cliente.from('mascotas').insert(datos).select().single()
      : _cliente.from('mascotas').update(datos).eq('id', id).select().single();

  Future<void> eliminar(int id) async {
    await _cliente.from('mascotas').delete().eq('id', id);
  }

  Future<String> subirFoto(XFile foto) async {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null) throw StateError('No hay una sesión activa');
    final ruta = '${usuario.id}/${DateTime.now().microsecondsSinceEpoch}.jpg';
    await _cliente.storage
        .from(_bucket)
        .uploadBinary(
          ruta,
          await foto.readAsBytes(),
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return ruta;
  }

  Future<void> eliminarFoto(String ruta) async {
    await _cliente.storage.from(_bucket).remove([ruta]);
  }

  Future<String> urlFoto(String ruta) =>
      _cliente.storage.from(_bucket).createSignedUrl(ruta, 3600);
}
