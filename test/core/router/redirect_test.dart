import 'package:flutter_test/flutter_test.dart';
import 'package:petcare_flutter/core/router/app_router.dart';

void main() {
  group('redirigir', () {
    group('sin sesión', () {
      test('una ruta protegida lleva a /sign-in', () {
        expect(redirigir(haySesion: false, ruta: '/mascotas'), '/sign-in');
        expect(redirigir(haySesion: false, ruta: '/mascotas/3'), '/sign-in');
        expect(redirigir(haySesion: false, ruta: '/ajustes'), '/sign-in');
      });

      test('/sign-in y /sign-up se quedan donde están', () {
        expect(redirigir(haySesion: false, ruta: '/sign-in'), isNull);
        expect(redirigir(haySesion: false, ruta: '/sign-up'), isNull);
      });
    });

    group('con sesión', () {
      test('/sign-in y /sign-up llevan a /inicio', () {
        expect(redirigir(haySesion: true, ruta: '/sign-in'), '/inicio');
        expect(redirigir(haySesion: true, ruta: '/sign-up'), '/inicio');
      });

      test('una ruta protegida se queda donde está', () {
        expect(redirigir(haySesion: true, ruta: '/mascotas'), isNull);
        expect(redirigir(haySesion: true, ruta: '/mascotas/nueva'), isNull);
      });

      test('la raíz lleva a /inicio', () {
        expect(redirigir(haySesion: true, ruta: '/'), '/inicio');
      });
    });
  });
}
