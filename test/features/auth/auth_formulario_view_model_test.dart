import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petcare_flutter/core/errores/fallo.dart';
import 'package:petcare_flutter/features/auth/domain/auth_repository.dart';
import 'package:petcare_flutter/features/auth/presentation/auth_formulario_view_model.dart';

class _AuthRepository extends Mock implements AuthRepository {}

void main() {
  late _AuthRepository repositorio;
  late SignInViewModel ingreso;
  late SignUpViewModel registro;

  setUp(() {
    repositorio = _AuthRepository();
    ingreso = SignInViewModel(repositorio);
    registro = SignUpViewModel(repositorio);
    addTearDown(ingreso.dispose);
    addTearDown(registro.dispose);
  });

  test(
    'el ingreso inválido muestra errores de campo sin llamar al repositorio',
    () async {
      await ingreso.iniciarSesion('ana', '12345');

      expect(ingreso.errorCorreo, 'Escribe un correo válido');
      expect(ingreso.errorContrasena, contains('al menos 6'));
      verifyZeroInteractions(repositorio);
    },
  );

  test(
    'el ingreso válido envía una sola solicitud mientras está ocupado',
    () async {
      final respuesta = Completer<void>();
      when(
        () => repositorio.iniciarSesion(
          correo: 'ana@correo.com',
          contrasena: 'secreta',
        ),
      ).thenAnswer((_) => respuesta.future);

      final envio = ingreso.iniciarSesion(' ana@correo.com ', 'secreta');
      expect(ingreso.enviando, isTrue);
      await ingreso.iniciarSesion('ana@correo.com', 'secreta');
      respuesta.complete();
      await envio;

      expect(ingreso.enviando, isFalse);
      expect(ingreso.error, isNull);
      verify(
        () => repositorio.iniciarSesion(
          correo: 'ana@correo.com',
          contrasena: 'secreta',
        ),
      ).called(1);
    },
  );

  test('un fallo de sesión muestra el mensaje y permite reintentar', () async {
    when(
      () => repositorio.iniciarSesion(
        correo: 'ana@correo.com',
        contrasena: 'secreta',
      ),
    ).thenThrow(const FalloSesion('Credenciales incorrectas'));

    await ingreso.iniciarSesion('ana@correo.com', 'secreta');

    expect(ingreso.error, 'Credenciales incorrectas');
    expect(ingreso.enviando, isFalse);
  });

  test('el registro exige que las dos contraseñas coincidan', () async {
    await registro.registrar('ana@correo.com', 'secreta', 'distinta');

    expect(registro.errorConfirmacion, 'Las contraseñas no coinciden');
    verifyZeroInteractions(repositorio);
  });

  test('un registro puede reintentarse tras perder conexión', () async {
    Future<void> llamada() =>
        repositorio.registrar(correo: 'ana@correo.com', contrasena: 'secreta');
    when(llamada).thenThrow(const FalloRed());
    await registro.registrar('ana@correo.com', 'secreta', 'secreta');
    expect(registro.error, const FalloRed().mensaje);
    expect(registro.enviando, isFalse);

    when(llamada).thenAnswer((_) async {});
    await registro.registrar('ana@correo.com', 'secreta', 'secreta');
    expect(registro.error, isNull);
    expect(registro.enviando, isFalse);
  });
}
