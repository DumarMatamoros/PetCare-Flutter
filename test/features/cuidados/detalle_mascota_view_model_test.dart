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
  const mascota = Mascota(
    id: 1,
    nombre: 'Luna',
    especie: 'Perro',
    raza: 'Mestiza',
    pesoKg: 12.0,
  );

  final cuidado = Cuidado(
    id: 10,
    mascotaId: 1,
    tipoCuidadoId: 2,
    tipoNombre: 'Vacunación',
    fecha: DateTime(2026, 11, 20),
  );

  late MascotasRepositorioFalso mascotasRepositorio;
  late CuidadosRepositorioFalso cuidadosRepositorio;
  late DetalleMascotaViewModel viewModel;

  setUp(() {
    mascotasRepositorio = MascotasRepositorioFalso();
    cuidadosRepositorio = CuidadosRepositorioFalso();

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
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('pasa de cargando a datos con la mascota y sus cuidados', () async {
    final estados = <EstadoCarga<DetalleMascotaDatos>>[];

    viewModel.addListener(() {
      estados.add(viewModel.estado);
    });

    await viewModel.cargar();

    expect(estados, [
      isA<Cargando<DetalleMascotaDatos>>(),
      isA<Datos<DetalleMascotaDatos>>(),
    ]);

    final datos = (viewModel.estado as Datos<DetalleMascotaDatos>).valor;

    expect(datos.mascota, mascota);
    expect(datos.urlFoto, isNull);
    expect(datos.cuidados, [cuidado]);
  });

  test('muestra error de red y recupera los datos al reintentar', () async {
    when(() => mascotasRepositorio.obtenerMascota(1))
        .thenThrow(const FalloRed('Sin conexión'));

    await viewModel.cargar();

    expect(viewModel.estado, isA<ErrorCarga<DetalleMascotaDatos>>());
    expect(
      (viewModel.estado as ErrorCarga<DetalleMascotaDatos>).mensaje,
      'Sin conexión',
    );

    when(() => mascotasRepositorio.obtenerMascota(1))
        .thenAnswer((_) async => mascota);

    final estadosReintento = <EstadoCarga<DetalleMascotaDatos>>[];

    viewModel.addListener(() {
      estadosReintento.add(viewModel.estado);
    });

    await viewModel.cargar();

    expect(estadosReintento, [
      isA<Cargando<DetalleMascotaDatos>>(),
      isA<Datos<DetalleMascotaDatos>>(),
    ]);

    final datos = (viewModel.estado as Datos<DetalleMascotaDatos>).valor;

    expect(datos.mascota, mascota);
    expect(datos.cuidados, [cuidado]);

    verify(() => mascotasRepositorio.obtenerMascota(1)).called(2);
  });

  test('elimina un cuidado y actualiza el historial', () async {
    await viewModel.cargar();

    final datosIniciales =
        (viewModel.estado as Datos<DetalleMascotaDatos>).valor;
    expect(datosIniciales.cuidados, [cuidado]);

    when(() => cuidadosRepositorio.eliminar(10)).thenAnswer((_) async {});

    when(() => cuidadosRepositorio.obtenerCuidadosDeMascota(1))
        .thenAnswer((_) async => []);

    final error = await viewModel.eliminarCuidado(10);

    expect(error, isNull);
    expect(viewModel.estado, isA<Datos<DetalleMascotaDatos>>());

    final datosFinales = (viewModel.estado as Datos<DetalleMascotaDatos>).valor;
    expect(datosFinales.mascota, mascota);
    expect(datosFinales.cuidados, isEmpty);

    verify(() => cuidadosRepositorio.eliminar(10)).called(1);

    verify(() => cuidadosRepositorio.obtenerCuidadosDeMascota(1)).called(2);
  });

  test('elimina la mascota con su identificador', () async {
    when(() => mascotasRepositorio.eliminar(1)).thenAnswer((_) async {});

    final error = await viewModel.eliminarMascota();

    expect(error, isNull);

    verify(() => mascotasRepositorio.eliminar(1)).called(1);
  });
}
