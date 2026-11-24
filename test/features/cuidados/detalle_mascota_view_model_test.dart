import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:petcare_flutter/core/errores/fallo.dart';
import 'package:petcare_flutter/core/estado/estado_carga.dart';
import 'package:petcare_flutter/features/cuidados/domain/cuidado.dart';
import 'package:petcare_flutter/features/cuidados/domain/cuidado_repository.dart';
import 'package:petcare_flutter/features/cuidados/presentation/detalle_mascota_view_model.dart';
import 'package:petcare_flutter/features/mascotas/domain/mascota.dart';
import 'package:petcare_flutter/features/mascotas/domain/mascota_repository.dart';

class MascotasRepositorioFalso extends Mock implements MascotaRepository {}

class CuidadosRepositorioFalso extends Mock implements CuidadoRepository {}

void main() {
  late MascotasRepositorioFalso mascotasRepositorio;
  late CuidadosRepositorioFalso cuidadosRepositorio;
  late DetalleMascotaViewModel viewModel;

  setUp(() {
    mascotasRepositorio = MascotasRepositorioFalso();
    cuidadosRepositorio = CuidadosRepositorioFalso();
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('carga la mascota y sus cuidados', () async {
    final mascota = Mascota(
      id: 1,
      nombre: 'Luna',
      especie: 'Perro',
      raza: 'Mestiza',
      fechaNacimiento: DateTime(2022, 1, 1),
      pesoKg: 12.0,
      fotoPath: null,
    );
    final cuidado = Cuidado(
      id: 10,
      mascotaId: 1,
      tipoCuidadoId: 2,
      tipoNombre: 'Vacunación',
      fecha: DateTime(2026, 11, 20),
      notas: null,
    );

    when(() => mascotasRepositorio.obtenerMascota(1))
        .thenAnswer((_) async => mascota);
    when(() => mascotasRepositorio.urlDeFoto(mascota))
        .thenAnswer((_) async => null);
    when(() => cuidadosRepositorio.obtenerCuidadosDeMascota(1))
        .thenAnswer((_) async => [cuidado]);

    viewModel = DetalleMascotaViewModel(
      1,
      mascotasRepositorio,
      cuidadosRepositorio,
    );

    await viewModel.cargar();

    expect(viewModel.estado, isA<Datos<DetalleMascotaDatos>>());
    final datos = (viewModel.estado as Datos<DetalleMascotaDatos>).valor;
    expect(datos.mascota, mascota);
    expect(datos.cuidados, [cuidado]);
  });

  test('si falla al obtener la mascota muestra error', () async {
    when(() => mascotasRepositorio.obtenerMascota(1))
        .thenThrow(const FalloRed('Sin conexión'));

    viewModel = DetalleMascotaViewModel(
      1,
      mascotasRepositorio,
      cuidadosRepositorio,
    );

    await viewModel.cargar();

    expect(viewModel.estado, isA<ErrorCarga<DetalleMascotaDatos>>());
    expect(
      (viewModel.estado as ErrorCarga<DetalleMascotaDatos>).mensaje,
      'Sin conexión',
    );
  });

  test('elimina cuidado y recarga el historial', () async {
    final mascota = Mascota(
      id: 1,
      nombre: 'Luna',
      especie: 'Perro',
      raza: 'Mestiza',
      fechaNacimiento: DateTime(2022, 1, 1),
      pesoKg: 12.0,
      fotoPath: null,
    );

    when(() => cuidadosRepositorio.eliminar(10)).thenAnswer((_) async {});
    when(() => mascotasRepositorio.obtenerMascota(1))
        .thenAnswer((_) async => mascota);
    when(() => mascotasRepositorio.urlDeFoto(mascota))
        .thenAnswer((_) async => null);
    when(() => cuidadosRepositorio.obtenerCuidadosDeMascota(1))
        .thenAnswer((_) async => []);

    viewModel = DetalleMascotaViewModel(
      1,
      mascotasRepositorio,
      cuidadosRepositorio,
    );

    final error = await viewModel.eliminarCuidado(10);

    expect(error, isNull);
    verify(() => cuidadosRepositorio.eliminar(10)).called(1);
    verify(() => cuidadosRepositorio.obtenerCuidadosDeMascota(1)).called(1);
  });

  test('elimina la mascota con su id', () async {
    when(() => mascotasRepositorio.eliminar(1)).thenAnswer((_) async {});

    viewModel = DetalleMascotaViewModel(
      1,
      mascotasRepositorio,
      cuidadosRepositorio,
    );

    final error = await viewModel.eliminarMascota();

    expect(error, isNull);
    verify(() => mascotasRepositorio.eliminar(1)).called(1);
  });
}
