import '../../../core/utilidades/fecha_sql.dart';

/// Cuidado registrado para una mascota (tabla `cuidados`).
class Cuidado {
  const Cuidado({
    this.id,
    required this.mascotaId,
    required this.tipoCuidadoId,
    this.tipoNombre = '',
    required this.fecha,
    this.notas,
  });

  /// `null` mientras no se ha guardado; Supabase lo genera.
  final int? id;
  final int mascotaId;
  final int tipoCuidadoId;

  /// Nombre del tipo, para pintar el historial sin otra consulta. Se lee con
  /// `select('*, tipos_cuidado(nombre)')`.
  final String tipoNombre;
  final DateTime fecha;
  final String? notas;

  factory Cuidado.fromMap(Map<String, dynamic> map) => Cuidado(
    id: (map['id'] as num?)?.toInt(),
    mascotaId: (map['mascota_id'] as num).toInt(),
    tipoCuidadoId: (map['tipo_cuidado_id'] as num).toInt(),
    tipoNombre:
        (map['tipos_cuidado'] as Map<String, dynamic>?)?['nombre'] as String? ??
        '',
    fecha: DateTime.parse(map['fecha'] as String),
    notas: map['notas'] as String?,
  );

  /// Columnas para insertar. No lleva `id`, `usuario_id` ni `tipoNombre`.
  Map<String, dynamic> toMap() => {
    'mascota_id': mascotaId,
    'tipo_cuidado_id': tipoCuidadoId,
    'fecha': fechaSql(fecha),
    'notas': notas,
  };
}
