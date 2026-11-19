/// Usuario con sesión iniciada.
class Usuario {
  const Usuario({required this.id, required this.correo});

  final String id;
  final String correo;

  @override
  bool operator ==(Object other) =>
      other is Usuario && other.id == id && other.correo == correo;

  @override
  int get hashCode => Object.hash(id, correo);

  @override
  String toString() => 'Usuario($correo)';
}
