/// Validaciones de los formularios de Iniciar sesión y Registrarse.
///
/// Cada función devuelve el mensaje de error, o null si el valor es válido,
/// que es lo que espera `TextFormField.validator`.
abstract final class ValidadoresAuth {
  /// Supabase rechaza contraseñas de menos de 6 caracteres por defecto.
  static const largoMinimoClave = 6;

  static final _formatoCorreo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? correo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe tu correo';
    if (!_formatoCorreo.hasMatch(texto)) return 'Escribe un correo válido';
    return null;
  }

  static String? claveIngreso(String? valor) {
    if (valor == null || valor.isEmpty) return 'Escribe tu contraseña';
    return _validarLongitud(valor);
  }

  static String? claveNueva(String? valor) {
    if (valor == null || valor.isEmpty) return 'Escribe una contraseña';
    return _validarLongitud(valor);
  }

  static String? _validarLongitud(String valor) {
    if (valor.length < largoMinimoClave) {
      return 'La contraseña debe tener al menos $largoMinimoClave caracteres';
    }
    return null;
  }

  static String? confirmacionClave(String? valor, String clave) {
    if (valor == null || valor.isEmpty) return 'Repite la contraseña';
    if (valor != clave) return 'Las contraseñas no coinciden';
    return null;
  }
}
