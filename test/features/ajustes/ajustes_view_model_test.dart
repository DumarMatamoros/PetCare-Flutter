import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petcare_flutter/core/errores/fallo.dart';
import 'package:petcare_flutter/features/ajustes/domain/preferencias.dart';
import 'package:petcare_flutter/features/ajustes/domain/preferencias_repository.dart';
import 'package:petcare_flutter/features/ajustes/presentation/ajustes_view_model.dart';

class _PreferenciasRepositoryFalso extends Mock
    implements PreferenciasRepository {}

void main() {
  late _PreferenciasRepositoryFalso repositorio;

  setUpAll(() => registerFallbackValue(Preferencias.porDefecto));

  setUp(() {
    repositorio = _PreferenciasRepositoryFalso();
    when(() => repositorio.guardar(any())).thenAnswer((_) async {});
  });

  test('empieza con las preferencias iniciales', () {
    const iniciales = Preferencias(tema: Tema.oscuro);

    final vm = AjustesViewModel(repositorio, inicial: iniciales);

    expect(vm.preferencias, iniciales);
    expect(vm.tema, Tema.oscuro);
  });

  test('cargar lee las preferencias guardadas y notifica', () async {
    const guardadas = Preferencias(ordenMascotas: OrdenMascotas.masReciente);
    when(() => repositorio.leer()).thenAnswer((_) async => guardadas);
    final vm = AjustesViewModel(repositorio);
    var avisos = 0;
    vm.addListener(() => avisos++);

    await vm.cargar();

    expect(vm.ordenMascotas, OrdenMascotas.masReciente);
    expect(avisos, 1);
  });

  test('cambiarTema aplica el cambio, notifica y lo guarda', () async {
    final vm = AjustesViewModel(repositorio);
    var avisos = 0;
    vm.addListener(() => avisos++);

    await vm.cambiarTema(Tema.oscuro);

    expect(vm.tema, Tema.oscuro);
    expect(avisos, 1);
    verify(() => repositorio.guardar(const Preferencias(tema: Tema.oscuro)))
        .called(1);
  });

  test('cambiar los órdenes guarda solo ese campo', () async {
    final vm = AjustesViewModel(repositorio);

    await vm.cambiarOrdenMascotas(OrdenMascotas.masReciente);
    await vm.cambiarOrdenHistorial(OrdenHistorial.masAntiguo);

    expect(
      vm.preferencias,
      const Preferencias(
        ordenMascotas: OrdenMascotas.masReciente,
        ordenHistorial: OrdenHistorial.masAntiguo,
      ),
    );
    expect(vm.tema, Tema.claro);
  });

  test('elegir la opción que ya está no guarda ni notifica', () async {
    final vm = AjustesViewModel(repositorio);
    var avisos = 0;
    vm.addListener(() => avisos++);

    await vm.cambiarTema(Tema.claro);

    expect(avisos, 0);
    verifyNever(() => repositorio.guardar(any()));
  });

  test('si no se puede guardar, deshace el cambio y lanza el fallo', () async {
    when(() => repositorio.guardar(any()))
        .thenThrow(const FalloServidor('No se pudo guardar el ajuste'));
    final vm = AjustesViewModel(repositorio);

    await expectLater(vm.cambiarTema(Tema.oscuro), throwsA(isA<Fallo>()));

    expect(vm.tema, Tema.claro);
  });
}
