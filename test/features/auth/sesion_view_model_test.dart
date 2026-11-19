import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petcare_flutter/features/auth/domain/auth_repository.dart';
import 'package:petcare_flutter/features/auth/domain/usuario.dart';
import 'package:petcare_flutter/features/auth/presentation/sesion_view_model.dart';

class _AuthRepositoryFalso extends Mock implements AuthRepository {}

void main() {
  const ana = Usuario(id: 'u1', correo: 'ana@correo.com');

  late _AuthRepositoryFalso repositorio;
  late StreamController<Usuario?> cambios;

  setUp(() {
    repositorio = _AuthRepositoryFalso();
    cambios = StreamController<Usuario?>();
    when(() => repositorio.cambiosDeSesion).thenAnswer((_) => cambios.stream);
  });

  tearDown(() => cambios.close());

  test('sin usuario, haySesion es falso', () {
    when(() => repositorio.usuarioActual).thenReturn(null);

    final vm = SesionViewModel(repositorio);

    expect(vm.haySesion, isFalse);
    expect(vm.usuario, isNull);
  });

  test('con una sesión restaurada, haySesion empieza en verdadero', () {
    when(() => repositorio.usuarioActual).thenReturn(ana);

    final vm = SesionViewModel(repositorio);

    expect(vm.haySesion, isTrue);
    expect(vm.usuario, ana);
  });

  test('al iniciar sesión pasa a verdadero y notifica', () async {
    when(() => repositorio.usuarioActual).thenReturn(null);
    final vm = SesionViewModel(repositorio);
    var avisos = 0;
    vm.addListener(() => avisos++);

    cambios.add(ana);
    await pumpEventQueue();

    expect(vm.haySesion, isTrue);
    expect(vm.usuario, ana);
    expect(avisos, 1);
  });

  test('al cerrar sesión vuelve a falso y notifica', () async {
    when(() => repositorio.usuarioActual).thenReturn(ana);
    final vm = SesionViewModel(repositorio);
    var avisos = 0;
    vm.addListener(() => avisos++);

    cambios.add(null);
    await pumpEventQueue();

    expect(vm.haySesion, isFalse);
    expect(avisos, 1);
  });

  test('no notifica si el usuario no cambia (refresco de token)', () async {
    when(() => repositorio.usuarioActual).thenReturn(ana);
    final vm = SesionViewModel(repositorio);
    var avisos = 0;
    vm.addListener(() => avisos++);

    cambios.add(ana);
    await pumpEventQueue();

    expect(avisos, 0);
  });

  test('cerrarSesion delega en el repositorio', () async {
    when(() => repositorio.usuarioActual).thenReturn(ana);
    when(() => repositorio.cerrarSesion()).thenAnswer((_) async {});
    final vm = SesionViewModel(repositorio);

    await vm.cerrarSesion();

    verify(() => repositorio.cerrarSesion()).called(1);
  });

  test('dispose cancela la suscripción', () async {
    when(() => repositorio.usuarioActual).thenReturn(null);
    final vm = SesionViewModel(repositorio);

    vm.dispose();

    expect(cambios.hasListener, isFalse);
  });
}
