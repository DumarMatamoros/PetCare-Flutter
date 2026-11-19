enum Tema { claro, oscuro }

enum OrdenMascotas { nombre, masReciente }

enum OrdenHistorial { masReciente, masAntiguo }

/// Preferencias del teléfono (no de la cuenta): tema y orden de las listas.
class Preferencias {
  const Preferencias({
    this.tema = Tema.claro,
    this.ordenMascotas = OrdenMascotas.nombre,
    this.ordenHistorial = OrdenHistorial.masReciente,
  });

  static const porDefecto = Preferencias();

  final Tema tema;
  final OrdenMascotas ordenMascotas;
  final OrdenHistorial ordenHistorial;

  /// Si un valor guardado no coincide con ninguna opción, usa el de por defecto.
  factory Preferencias.fromMap(Map<String, Object?> map) => Preferencias(
    tema: _buscar(Tema.values, map['tema'], porDefecto.tema),
    ordenMascotas: _buscar(
      OrdenMascotas.values,
      map['ordenMascotas'],
      porDefecto.ordenMascotas,
    ),
    ordenHistorial: _buscar(
      OrdenHistorial.values,
      map['ordenHistorial'],
      porDefecto.ordenHistorial,
    ),
  );

  Map<String, String> toMap() => {
    'tema': tema.name,
    'ordenMascotas': ordenMascotas.name,
    'ordenHistorial': ordenHistorial.name,
  };

  Preferencias copyWith({
    Tema? tema,
    OrdenMascotas? ordenMascotas,
    OrdenHistorial? ordenHistorial,
  }) => Preferencias(
    tema: tema ?? this.tema,
    ordenMascotas: ordenMascotas ?? this.ordenMascotas,
    ordenHistorial: ordenHistorial ?? this.ordenHistorial,
  );

  @override
  bool operator ==(Object other) =>
      other is Preferencias &&
      other.tema == tema &&
      other.ordenMascotas == ordenMascotas &&
      other.ordenHistorial == ordenHistorial;

  @override
  int get hashCode => Object.hash(tema, ordenMascotas, ordenHistorial);
}

T _buscar<T extends Enum>(List<T> valores, Object? nombre, T porDefecto) {
  for (final valor in valores) {
    if (valor.name == nombre) return valor;
  }
  return porDefecto;
}
