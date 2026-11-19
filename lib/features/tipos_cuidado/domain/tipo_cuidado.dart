/// Tipo de cuidado del catálogo fijo (tabla `tipos_cuidado`).
class TipoCuidado {
  const TipoCuidado({required this.id, required this.nombre});

  final int id;
  final String nombre;

  factory TipoCuidado.fromMap(Map<String, dynamic> map) => TipoCuidado(
    id: (map['id'] as num).toInt(),
    nombre: map['nombre'] as String,
  );

  Map<String, dynamic> toMap() => {'id': id, 'nombre': nombre};

  @override
  bool operator ==(Object other) =>
      other is TipoCuidado && other.id == id && other.nombre == nombre;

  @override
  int get hashCode => Object.hash(id, nombre);
}
