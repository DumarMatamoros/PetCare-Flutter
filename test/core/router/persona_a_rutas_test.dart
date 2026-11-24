import 'dart:async';

import 'package:petcare_flutter/features/ajustes/domain/preferencias_repository.dart';
import 'package:petcare_flutter/features/ajustes/presentation/ajustes_view_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petcare_flutter/core/errores/fallo.dart';
import 'package:petcare_flutter/core/router/app_router.dart';
import 'package:petcare_flutter/core/tema/tema_app.dart';
import 'package:petcare_flutter/features/auth/domain/auth_repository.dart';
import 'package:petcare_flutter/features/auth/domain/usuario.dart';
import 'package:petcare_flutter/features/auth/presentation/sesion_view_model.dart';
import 'package:petcare_flutter/features/mascotas/domain/mascota.dart';
import 'package:petcare_flutter/features/mascotas/domain/guardar_mascota_use_case.dart';
import 'package:petcare_flutter/features/mascotas/domain/mascota_repository.dart';
import 'package:petcare_flutter/features/tipos_cuidado/domain/tipo_cuidado_repository.dart';
import 'package:provider/provider.dart';

class _Preferencias extends Mock implements PreferenciasRepository {}

class _AuthRepository extends Mock implements AuthRepository {}

class _MascotaRepository extends Mock implements MascotaRepository {}

class _TipoCuidadoRepository extends Mock implements TipoCuidadoRepository {}

void main() {
  const ana = Usuario(id: 'u1', correo: 'ana@correo.com');
  const luna = Mascota(nombre: 'Luna', especie: 'Gato');
  late StreamController<Usuario?> cambios;
  late _AuthRepository auth;
  late _MascotaRepository mascotas;
  late _TipoCuidadoRepository tiposCuidado;
  late GoRouter router;

  Future<void> montar(WidgetTester tester, {Usuario? usuario}) async {
    cambios = StreamController<Usuario?>();
    auth = _AuthRepository();
    mascotas = _MascotaRepository();
    tiposCuidado = _TipoCuidadoRepository();

    when(() => auth.usuarioActual).thenReturn(usuario);
    when(() => auth.cambiosDeSesion).thenAnswer((_) => cambios.stream);
    registerFallbackValue(luna);
    when(() => mascotas.urlDeFoto(any())).thenAnswer((_) async => null);
    when(mascotas.obtenerMascotas).thenAnswer((_) async => [luna]);
    when(tiposCuidado.obtenerTipos).thenAnswer((_) async => []);

    final sesion = SesionViewModel(auth);
    router = crearRouter(sesion);
    addTearDown(() async {
      router.dispose();
      sesion.dispose();
      await cambios.close();
      tester.view.reset();
    });

    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(400, 850);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AjustesViewModel(_Preferencias()),
          ),
          Provider<AuthRepository>.value(value: auth),
          Provider<MascotaRepository>.value(value: mascotas),
          Provider(create: (_) => GuardarMascotaUseCase(mascotas)),
          Provider<TipoCuidadoRepository>.value(value: tiposCuidado),
          ChangeNotifierProvider<SesionViewModel>.value(value: sesion),
        ],
        child: MaterialApp.router(theme: TemaApp.claro, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mascotas y formulario admiten letra grande en horizontal', (
    tester,
  ) async {
    await montar(tester, usuario: ana);
    tester.view.physicalSize = const Size(800, 380);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    router.go('/mascotas');
    await tester.pumpAndSettle();
    expect(find.text('Luna'), findsOneWidget);
    expect(tester.takeException(), isNull);
    router.go('/mascotas/nueva');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byTooltip('Elegir fecha de nacimiento'),
      140,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byTooltip('Elegir fecha de nacimiento'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('las rutas públicas abren las vistas de registro e ingreso', (
    tester,
  ) async {
    await montar(tester);

    await tester.tap(find.text('Regístrate'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Crear cuenta'), findsOneWidget);

    await tester.ensureVisible(find.text('Inicia sesión'));
    await tester.tap(find.text('Inicia sesión'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Iniciar sesión'), findsOneWidget);
  });

  testWidgets('un inicio de sesión lleva a Inicio por el cambio de sesión', (
    tester,
  ) async {
    await montar(tester);
    when(
      () => auth.iniciarSesion(correo: 'ana@correo.com', contrasena: 'secreta'),
    ).thenAnswer((_) async => cambios.add(ana));

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'ana@correo.com');
    await tester.enterText(campos.at(1), 'secreta');
    final ingresar = find.widgetWithText(FilledButton, 'Iniciar sesión');
    await tester.ensureVisible(ingresar);
    await tester.tap(ingresar);
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, '/inicio');
    expect(find.text('Resumen'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('el registro inicia sesión al recibir el usuario', (
    tester,
  ) async {
    await montar(tester);
    final respuesta = Completer<void>();
    when(() => auth.registrar(correo: 'ana@correo.com', contrasena: 'secreta'))
        .thenAnswer((_) => respuesta.future);
    await tester.tap(find.text('Regístrate'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'ana@correo.com');
    await tester.enterText(campos.at(1), 'secreta');
    await tester.enterText(campos.at(2), 'secreta');
    final registrar = find.widgetWithText(FilledButton, 'Crear cuenta');
    await tester.ensureVisible(registrar);
    await tester.tap(registrar);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final enviando = find.widgetWithText(FilledButton, 'Creando cuenta…');
    expect(tester.widget<FilledButton>(enviando).onPressed, isNull);

    cambios.add(ana);
    respuesta.complete();
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, '/inicio');
  });

  testWidgets('el ingreso inválido muestra los errores del ViewModel', (
    tester,
  ) async {
    await montar(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextFormField &&
            widget.forceErrorText == 'Escribe tu correo',
      ),
      findsOneWidget,
    );
    expect(find.text('Escribe tu contraseña'), findsOneWidget);
    verifyNever(
      () => auth.iniciarSesion(
        correo: any(named: 'correo'),
        contrasena: any(named: 'contrasena'),
      ),
    );
  });

  testWidgets('el catálogo abre aunque haya fallado el conteo', (tester) async {
    await montar(tester, usuario: ana);
    when(mascotas.obtenerMascotas).thenThrow(const FalloServidor('Pendiente'));
    router.go('/mascotas');
    await tester.pumpAndSettle();
    router.go('/inicio');
    await tester.pumpAndSettle();

    expect(find.text('Pendiente'), findsOneWidget);
    final catalogo = find.text('Ver catálogo');
    await tester.ensureVisible(catalogo);
    await tester.tap(catalogo);
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, '/tipos-cuidado');
  });

  testWidgets(
    'Inicio actualiza el conteo al regresar y muestra riel en ancho',
    (tester) async {
      await montar(tester, usuario: ana);
      expect(find.text('1'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Mis mascotas'));
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, '/mascotas');
      when(mascotas.obtenerMascotas).thenAnswer(
        (_) async => [luna, const Mascota(nombre: 'Max', especie: 'Perro')],
      );

      tester.view.physicalSize = const Size(850, 400);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text('Inicio'),
        ),
      );
      await tester.pumpAndSettle();

      expect(router.state.matchedLocation, '/inicio');
      expect(find.text('2'), findsOneWidget);
    },
  );
}
