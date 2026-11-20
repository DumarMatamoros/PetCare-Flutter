import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petcare_flutter/core/errores/fallo.dart';
import 'package:petcare_flutter/core/estado/estado_carga.dart';
import 'package:petcare_flutter/features/inicio/presentation/inicio_view_model.dart';
import 'package:petcare_flutter/features/mascotas/domain/mascota.dart';
import 'package:petcare_flutter/features/mascotas/domain/mascota_repository.dart';

class _MascotaRepository extends Mock implements MascotaRepository {}

void main() {
  late _MascotaRepository repositorio;
  late InicioViewModel inicio;

  setUp(() {
    repositorio = _MascotaRepository();
    inicio = InicioViewModel(repositorio);
    addTearDown(inicio.dispose);
  });

  test('muestra carga hasta disponer del conteo de mascotas', () async {
    final respuesta = Completer<List<Mascota>>();
    when(repositorio.obtenerMascotas).thenAnswer((_) => respuesta.future);

    final carga = inicio.cargar();
    expect(inicio.estado, isA<Cargando<int>>());
    respuesta.complete(const [Mascota(nombre: 'Luna', especie: 'Gato')]);
    await carga;

    expect(
      inicio.estado,
      isA<Datos<int>>().having((estado) => estado.valor, 'total', 1),
    );
  });

  test('emite el estado vacío si el usuario no tiene mascotas', () async {
    when(repositorio.obtenerMascotas).thenAnswer((_) async => []);
    await inicio.cargar();

    expect(inicio.estado, isA<Vacio<int>>());
  });

  test('muestra un fallo de red y recupera los datos al reintentar', () async {
    when(repositorio.obtenerMascotas).thenThrow(const FalloRed());
    await inicio.cargar();
    expect(
      inicio.estado,
      isA<ErrorCarga<int>>().having(
        (estado) => estado.mensaje,
        'mensaje',
        const FalloRed().mensaje,
      ),
    );

    when(repositorio.obtenerMascotas).thenAnswer((_) async => []);
    await inicio.cargar();
    expect(inicio.estado, isA<Vacio<int>>());
  });
}
