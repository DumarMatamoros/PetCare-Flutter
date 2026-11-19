import 'package:image_picker/image_picker.dart' show XFile;

import 'mascota.dart';

/// Mascotas del usuario con sesión. Los métodos lanzan un `Fallo`.
abstract class MascotaRepository {
  Future<List<Mascota>> obtenerMascotas();

  Future<Mascota> obtenerMascota(int id);

  /// Inserta si `mascota.id` es `null`; si no, actualiza. Si viene
  /// [fotoNueva], la sube a Storage y guarda su ruta en `fotoPath`.
  Future<Mascota> guardar(Mascota mascota, {XFile? fotoNueva});

  Future<void> eliminar(int id);

  /// URL firmada temporal para mostrar la foto, o `null` si no tiene.
  Future<String?> urlDeFoto(Mascota mascota);
}
