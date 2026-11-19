import '../../../core/utilidades/fecha_sql.dart';

/// Mascota del usuario (tabla `mascotas`).
class Mascota {
  const Mascota({
    this.id,
    required this.nombre,
    required this.especie,
    this.raza = '',
    this.fechaNacimiento,
    this.sexo = '',
    this.pesoKg,
    this.fotoPath,
  });

  /// `null` mientras no se ha guardado; Supabase lo genera.
  final int? id;
  final String nombre;
  final String especie;
  final String raza;
  final DateTime? fechaNacimiento;
  final String sexo;
  final double? pesoKg;

  /// Ruta del archivo dentro del bucket `fotos-mascotas`, no una URL.
  final String? fotoPath;

  factory Mascota.fromMap(Map<String, dynamic> map) => Mascota(
    id: (map['id'] as num?)?.toInt(),
    nombre: map['nombre'] as String,
    especie: map['especie'] as String,
    raza: map['raza'] as String? ?? '',
    fechaNacimiento: map['fecha_nacimiento'] == null
        ? null
        : DateTime.parse(map['fecha_nacimiento'] as String),
    sexo: map['sexo'] as String? ?? '',
    pesoKg: (map['peso_kg'] as num?)?.toDouble(),
    fotoPath: map['foto_path'] as String?,
  );

  /// Columnas para insertar o actualizar. No lleva `id` ni `usuario_id`:
  /// los pone la base de datos.
  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'especie': especie,
    'raza': raza,
    'fecha_nacimiento': fechaNacimiento == null
        ? null
        : fechaSql(fechaNacimiento!),
    'sexo': sexo,
    'peso_kg': pesoKg,
    'foto_path': fotoPath,
  };

  /// Copia con algunos campos cambiados. Para dejar un campo opcional en
  /// `null`, construye la mascota de nuevo.
  Mascota copyWith({
    int? id,
    String? nombre,
    String? especie,
    String? raza,
    DateTime? fechaNacimiento,
    String? sexo,
    double? pesoKg,
    String? fotoPath,
  }) => Mascota(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    especie: especie ?? this.especie,
    raza: raza ?? this.raza,
    fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
    sexo: sexo ?? this.sexo,
    pesoKg: pesoKg ?? this.pesoKg,
    fotoPath: fotoPath ?? this.fotoPath,
  );
}
