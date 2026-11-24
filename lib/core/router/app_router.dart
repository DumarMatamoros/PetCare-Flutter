import '../../features/ajustes/presentation/ajustes_view_model.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/auth_formulario_view_model.dart';
import '../../features/ajustes/presentation/ajustes_screen.dart';
import '../../features/auth/presentation/sesion_view_model.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/cuidados/domain/cuidado_repository.dart';
import '../../features/cuidados/presentation/cuidado_form_screen.dart';
import '../../features/cuidados/presentation/cuidado_form_view_model.dart';
import '../../features/cuidados/presentation/detalle_mascota_screen.dart';
import '../../features/cuidados/presentation/detalle_mascota_view_model.dart';
import '../../features/inicio/presentation/inicio_screen.dart';
import '../../features/inicio/presentation/inicio_view_model.dart';
import '../../features/mascotas/domain/mascota_repository.dart';
import '../../features/tipos_cuidado/domain/tipo_cuidado_repository.dart';
import '../../features/tipos_cuidado/presentation/tipos_cuidado_screen.dart';
import '../../features/tipos_cuidado/presentation/tipos_cuidado_view_model.dart';
import '../widgets/navegacion_principal.dart';
import '../../features/mascotas/domain/guardar_mascota_use_case.dart';
import '../../features/mascotas/presentation/mascota_form_screen.dart';
import '../../features/mascotas/presentation/mascota_form_view_model.dart';
import '../../features/mascotas/presentation/mascotas_screen.dart';
import '../../features/mascotas/presentation/mascotas_view_model.dart';
import 'pantallas_provisionales.dart';

/// Rutas a las que se entra sin sesión.
const rutasPublicas = {'/sign-in', '/sign-up'};

/// Decide a dónde redirigir según la sesión. Devuelve `null` para quedarse.
///
/// Está separada del `GoRouter` para poder probarla sin montar widgets.
String? redirigir({required bool haySesion, required String ruta}) {
  final esPublica = rutasPublicas.contains(ruta);
  if (!haySesion && !esPublica) return '/sign-in';
  if (haySesion && (esPublica || ruta == '/')) return '/inicio';
  return null;
}

/// Crea el router de la app. Se crea una sola vez, en `app.dart`.
GoRouter crearRouter(SesionViewModel sesion) => GoRouter(
  initialLocation: '/inicio',
  refreshListenable: sesion,
  redirect: (context, state) =>
      redirigir(haySesion: sesion.haySesion, ruta: state.matchedLocation),
  errorBuilder: (context, state) => const PantallaProvisional(
    titulo: 'Página no encontrada',
    enlaces: {'Ir a Inicio': '/inicio'},
  ),
  routes: [
    // --- Sin sesión (Persona A) ---
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => SignInViewModel(context.read<AuthRepository>()),
        child: const SignInScreen(),
      ),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => SignUpViewModel(context.read<AuthRepository>()),
        child: const SignUpScreen(),
      ),
    ),

    // Catálogo de tipos de cuidado (Persona C).
    GoRoute(
      path: '/tipos-cuidado',
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) =>
            TiposCuidadoViewModel(context.read<TipoCuidadoRepository>())
              ..cargar(),
        child: const TiposCuidadoScreen(),
      ),
    ),

    // --- Con sesión, en pestañas ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navegacion) =>
          ShellConPestanas(navegacion: navegacion),
      branches: [
        // Pestaña Inicio (Persona A)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inicio',
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) =>
                    InicioViewModel(context.read<MascotaRepository>())
                      ..cargar(),
                child: const InicioScreen(),
              ),
            ),
          ],
        ),

        // Pestaña Mascotas (Personas B y C)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mascotas',
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) =>
                    MascotasViewModel(context.read<MascotaRepository>())
                      ..cargar(),
                child: MascotasScreen(
                  orden: context.watch<AjustesViewModel>().ordenMascotas,
                ),
              ),
              routes: [
                // `nueva` va antes que `:id`; si no, se leería como un id.
                GoRoute(
                  path: 'nueva',
                  builder: (context, state) =>
                      _formularioMascota(context, null),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => _conId(
                    state,
                    (id) => ChangeNotifierProvider(
                      create: (context) => DetalleMascotaViewModel(
                        id,
                        context.read<MascotaRepository>(),
                        context.read<CuidadoRepository>(),
                      )..cargar(),
                      child: const DetalleMascotaScreen(),
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'editar',
                      builder: (context, state) => _conId(
                        state,
                        (id) => _formularioMascota(context, id),
                      ),
                    ),
                    GoRoute(
                      path: 'cuidados/nuevo',
                      builder: (context, state) => _conId(
                        state,
                        (id) => ChangeNotifierProvider(
                          create: (context) => CuidadoFormViewModel(
                            id,
                            context.read<TipoCuidadoRepository>(),
                            context.read<CuidadoRepository>(),
                          )..cargarTipos(),
                          child: const CuidadoFormScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Pestaña Ajustes (Persona D)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ajustes',
              builder: (context, state) => const AjustesScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

Widget _formularioMascota(BuildContext context, int? id) =>
    ChangeNotifierProvider(
      create: (context) => MascotaFormViewModel(
        context.read<MascotaRepository>(),
        context.read<GuardarMascotaUseCase>(),
        id,
      )..cargar(),
      child: const MascotaFormScreen(),
    );

/// Convierte `:id` a `int` y se lo pasa a [construir]. Las pantallas no leen
/// parámetros de la ruta: reciben el id ya convertido.
Widget _conId(GoRouterState state, Widget Function(int id) construir) {
  final id = int.tryParse(state.pathParameters['id'] ?? '');
  if (id == null) {
    return const PantallaProvisional(
      titulo: 'Mascota no encontrada',
      enlaces: {'Ir a Mis mascotas': '/mascotas'},
    );
  }
  return construir(id);
}

/// Contenedor adaptable de las tres pestañas.
class ShellConPestanas extends StatelessWidget {
  const ShellConPestanas({super.key, required this.navegacion});

  final StatefulNavigationShell navegacion;

  void _irA(int indice) => navegacion.goBranch(
    indice,
    // Tocar la pestaña actual vuelve a su primera pantalla.
    initialLocation: indice == navegacion.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    return NavegacionPrincipal(
      indiceActual: navegacion.currentIndex,
      onSeleccionar: _irA,
      child: navegacion,
    );
  }
}
