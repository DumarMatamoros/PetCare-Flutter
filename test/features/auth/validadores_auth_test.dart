import 'package:flutter_test/flutter_test.dart';
import 'package:petcare_flutter/features/auth/presentation/validadores_auth.dart';

void main() {
  group('correo', () {
    test('vacío o solo espacios pide escribirlo', () {
      expect(ValidadoresAuth.correo(null), 'Escribe tu correo');
      expect(ValidadoresAuth.correo('   '), 'Escribe tu correo');
    });

    test('sin @ o sin dominio no es válido', () {
      expect(ValidadoresAuth.correo('josue'), 'Escribe un correo válido');
      expect(ValidadoresAuth.correo('josue@'), 'Escribe un correo válido');
      expect(
        ValidadoresAuth.correo('josue@correo'),
        'Escribe un correo válido',
      );
      expect(
        ValidadoresAuth.correo('jo sue@correo.com'),
        'Escribe un correo válido',
      );
    });

    test('un correo normal es válido, aunque tenga espacios alrededor', () {
      expect(ValidadoresAuth.correo('ana@correo.com'), isNull);
      expect(ValidadoresAuth.correo('  ana@correo.com  '), isNull);
    });
  });

  group('claveIngreso', () {
    test('exige al menos seis caracteres al iniciar sesión', () {
      expect(ValidadoresAuth.claveIngreso(''), 'Escribe tu contraseña');
      expect(ValidadoresAuth.claveIngreso('12345'), isNotNull);
      expect(ValidadoresAuth.claveIngreso('123456'), isNull);
    });
  });

  group('claveNueva', () {
    test('vacía pide escribirla', () {
      expect(ValidadoresAuth.claveNueva(''), 'Escribe una contraseña');
    });

    test('exige el largo mínimo de Supabase', () {
      expect(ValidadoresAuth.claveNueva('12345'), isNotNull);
      expect(ValidadoresAuth.claveNueva('123456'), isNull);
    });
  });

  group('confirmacionClave', () {
    test('vacía pide repetirla', () {
      expect(
        ValidadoresAuth.confirmacionClave('', 'secreta'),
        'Repite la contraseña',
      );
    });

    test('distinta no coincide, igual sí', () {
      expect(
        ValidadoresAuth.confirmacionClave('otra', 'secreta'),
        'Las contraseñas no coinciden',
      );
      expect(ValidadoresAuth.confirmacionClave('secreta', 'secreta'), isNull);
    });
  });
}
