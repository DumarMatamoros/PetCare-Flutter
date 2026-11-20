// Pruebas visuales de Login, Registro e Inicio (Persona A):
// comportamiento del formulario, diseño en horizontal y accesibilidad.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare_flutter/core/tema/tema_app.dart';
import 'package:petcare_flutter/core/widgets/navegacion_principal.dart';
import 'package:petcare_flutter/core/widgets/vista_error.dart';
import 'package:petcare_flutter/core/widgets/vista_vacia.dart';
import 'package:petcare_flutter/features/auth/presentation/login_view.dart';
import 'package:petcare_flutter/features/auth/presentation/registro_view.dart';
import 'package:petcare_flutter/features/inicio/presentation/inicio_view.dart';

const _vertical = Size(360, 800);
const _horizontal = Size(800, 360);

Future<void> _mostrar(
  WidgetTester tester,
  Widget pantalla, {
  Size tamano = _vertical,
  double escalaTexto = 1,
  ThemeData? tema,
}) async {
  tester.view
    ..physicalSize = tamano * 3
    ..devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = escalaTexto;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    MaterialApp(theme: tema ?? TemaApp.claro, home: pantalla),
  );
  await tester.pumpAndSettle();
}

Widget _login({
  void Function(String, String)? onIngresar,
  String? error,
  String? errorCorreo,
  String? errorContrasena,
}) => LoginView(
  onIngresar: onIngresar ?? (_, _) {},
  onIrARegistro: () {},
  error: error,
  errorCorreo: errorCorreo,
  errorContrasena: errorContrasena,
);

Widget _registro({String? errorConfirmacion}) => RegistroView(
  onRegistrarse: (_, _, _) {},
  onIrALogin: () {},
  errorConfirmacion: errorConfirmacion,
);

Widget _inicio({
  bool cargando = false,
  String? error,
  int totalMascotas = 3,
  VoidCallback? onReintentar,
  VoidCallback? onRegistrarMascota,
}) => NavegacionPrincipal(
  indiceActual: 0,
  onSeleccionar: (_) {},
  child: InicioView(
    cargando: cargando,
    error: error,
    totalMascotas: totalMascotas,
    totalCuidados: 8,
    cuidadosRecientes: [
      CuidadoRecienteVista(
        nombreTipo: 'Vacunación',
        nombreMascota: 'Luna',
        fecha: DateTime(2026, 11, 10),
      ),
    ],
    onVerMascotas: () {},
    onRegistrarMascota: onRegistrarMascota ?? () {},
    onVerCatalogo: () {},
    onReintentar: onReintentar ?? () {},
  ),
);

void main() {
  group('Iniciar sesión', () {
    testWidgets('el error de contraseña se lee completo con letra al 200 %', (
      tester,
    ) async {
      const mensaje = 'La contraseña debe tener al menos 6 caracteres';
      await _mostrar(
        tester,
        _login(errorContrasena: mensaje),
        tamano: const Size(600, 340),
        escalaTexto: 2,
      );

      final texto = tester.renderObject<RenderParagraph>(find.text(mensaje));
      expect(texto.didExceedMaxLines, isFalse);
    });

    testWidgets('muestra los errores de correo y contraseña', (tester) async {
      await _mostrar(
        tester,
        _login(
          errorCorreo: 'Escribe tu correo',
          errorContrasena: 'Escribe tu contraseña',
        ),
      );

      expect(find.text('Escribe tu correo'), findsOneWidget);
      expect(find.text('Escribe tu contraseña'), findsOneWidget);
    });

    testWidgets('con datos válidos envía el correo sin espacios', (
      tester,
    ) async {
      String? correo;
      String? clave;
      await _mostrar(
        tester,
        _login(
          onIngresar: (c, k) {
            correo = c;
            clave = k;
          },
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo electrónico'),
        '  ana@correo.com ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'secreta',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
      await tester.pump();

      expect(correo, 'ana@correo.com');
      expect(clave, 'secreta');
    });

    testWidgets('muestra el error que manda el ViewModel', (tester) async {
      await _mostrar(tester, _login(error: 'Correo o contraseña incorrectos.'));

      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    });

    testWidgets('el botón del ojo muestra y oculta la contraseña', (
      tester,
    ) async {
      await _mostrar(tester, _login());

      EditableText campoClave() => tester.widget<EditableText>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Contraseña'),
          matching: find.byType(EditableText),
        ),
      );

      expect(campoClave().obscureText, isTrue);
      await tester.tap(find.byTooltip('Mostrar contraseña'));
      await tester.pump();
      expect(campoClave().obscureText, isFalse);
      expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
    });
  });

  group('Registrarse', () {
    testWidgets('muestra el error de confirmación', (tester) async {
      await _mostrar(
        tester,
        _registro(errorConfirmacion: 'Las contraseñas no coinciden'),
      );

      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });
  });

  group('Inicio', () {
    testWidgets('muestra los totales y la actividad reciente', (tester) async {
      await _mostrar(tester, _inicio());

      expect(find.text('3'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('Vacunación'), findsOneWidget);
      expect(find.text('Luna  ·  10/11/2026'), findsOneWidget);
    });

    testWidgets(
      'sin mascotas, el acceso rápido abre el formulario de mascota',
      (tester) async {
        var abierto = false;
        await _mostrar(
          tester,
          _inicio(totalMascotas: 0, onRegistrarMascota: () => abierto = true),
        );

        expect(find.byType(VistaVacia), findsOneWidget);
        final registrar = find.text('Registrar mi primera mascota');
        await tester.ensureVisible(registrar);
        await tester.tap(registrar);
        expect(abierto, isTrue);
      },
    );

    testWidgets('sin internet muestra el error y deja reintentar', (
      tester,
    ) async {
      var reintentos = 0;
      await _mostrar(
        tester,
        _inicio(error: 'Sin conexión', onReintentar: () => reintentos++),
      );

      expect(find.text('Sin conexión'), findsOneWidget);
      expect(find.byType(VistaError), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      expect(reintentos, 1);
    });
  });

  group('Navegación principal', () {
    testWidgets('en vertical usa la barra inferior', (tester) async {
      await _mostrar(tester, _inicio());

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('en horizontal usa el riel a la izquierda', (tester) async {
      await _mostrar(tester, _inicio(), tamano: _horizontal);

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      // El riel queda pegado al borde izquierdo y el contenido a su derecha
      final riel = tester.getRect(find.byType(NavigationRail));
      expect(riel.left, 0);
      expect(
        tester.getRect(find.text('Resumen')).left,
        greaterThan(riel.right),
      );
    });

    testWidgets('tocar una pestaña avisa cuál se eligió', (tester) async {
      int? elegida;
      await _mostrar(
        tester,
        NavegacionPrincipal(
          indiceActual: 0,
          onSeleccionar: (i) => elegida = i,
          child: const SizedBox(),
        ),
        tamano: _horizontal,
      );

      await tester.tap(find.text('Ajustes'));
      expect(elegida, 2);
    });
  });

  // Pide el plan: "Girar el teléfono: nada se desborda".
  // Un desborde (las franjas amarillas y negras) hace fallar la prueba.
  group('Nada se desborda', () {
    final pantallas = <String, Widget Function()>{
      'Login': _login,
      'Login con error': () =>
          _login(error: 'Correo o contraseña incorrectos.'),
      'Registro': _registro,
      'Inicio': _inicio,
      'Inicio sin internet': () => _inicio(error: 'Sin conexión a internet'),
    };

    for (final MapEntry(key: nombre, value: crear) in pantallas.entries) {
      for (final (orientacion, tamano) in [
        ('vertical', _vertical),
        ('horizontal', _horizontal),
      ]) {
        for (final escala in [1.0, 2.0]) {
          testWidgets('$nombre en $orientacion con letra x$escala', (
            tester,
          ) async {
            await _mostrar(
              tester,
              crear(),
              tamano: tamano,
              escalaTexto: escala,
            );
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });

  group('Accesibilidad', () {
    final pantallas = <String, Widget Function()>{
      'Login': _login,
      'Registro': _registro,
      'Inicio': _inicio,
    };

    for (final MapEntry(key: nombre, value: crear) in pantallas.entries) {
      for (final (nombreTema, tema) in [
        ('claro', TemaApp.claro),
        ('oscuro', TemaApp.oscuro),
      ]) {
        testWidgets('$nombre (tema $nombreTema) cumple las pautas de Android', (
          tester,
        ) async {
          final semantica = tester.ensureSemantics();
          await _mostrar(tester, crear(), tema: tema);

          // Todo lo que se toca mide al menos 48 x 48
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          // Todo lo que se toca tiene un nombre que TalkBack puede leer
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          // El texto se lee bien sobre su fondo (4.5:1, o 3:1 si es grande)
          await expectLater(tester, meetsGuideline(textContrastGuideline));

          semantica.dispose();
        });
      }
    }
  });
}
