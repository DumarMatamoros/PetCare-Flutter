import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/provisional/repositorios_provisionales.dart';
import 'core/router/app_router.dart';
import 'core/tema/tema_app.dart';
import 'features/ajustes/domain/preferencias.dart';
import 'features/ajustes/domain/preferencias_repository.dart';
import 'features/ajustes/presentation/ajustes_view_model.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/sesion_view_model.dart';
import 'features/cuidados/domain/cuidado_repository.dart';
import 'features/mascotas/domain/mascota_repository.dart';
import 'features/tipos_cuidado/domain/tipo_cuidado_repository.dart';

/// Raíz de la app: entrega las dependencias con Provider y monta el router.
///
/// Orden: cliente de Supabase → servicios → repositorios (registrados por su
/// contrato) → ViewModels globales. Para registrar tu repositorio real,
/// cambia su línea provisional, por ejemplo:
///
/// ```dart
/// Provider<MascotaRepository>(
///   create: (context) => MascotaRepositoryImpl(context.read<MascotaService>()),
/// ),
/// ```
class PetCareApp extends StatelessWidget {
  const PetCareApp({
    super.key,
    required this.cliente,
    required this.preferenciasRepository,
    required this.preferenciasIniciales,
  });

  final SupabaseClient cliente;

  /// Se crean en `main` porque las preferencias se leen antes de `runApp`.
  final PreferenciasRepository preferenciasRepository;
  final Preferencias preferenciasIniciales;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Cliente
        Provider<SupabaseClient>.value(value: cliente),

        // Servicios
        Provider<AuthService>(
          create: (context) => AuthService(context.read<SupabaseClient>()),
        ),

        // Repositorios
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(context.read<AuthService>()),
        ),
        Provider<MascotaRepository>(
          create: (_) => MascotaRepositoryProvisional(),
        ),
        Provider<TipoCuidadoRepository>(
          create: (_) => TipoCuidadoRepositoryProvisional(),
        ),
        Provider<CuidadoRepository>(
          create: (_) => CuidadoRepositoryProvisional(),
        ),
        Provider<PreferenciasRepository>.value(value: preferenciasRepository),

        // ViewModels globales
        ChangeNotifierProvider<SesionViewModel>(
          create: (context) => SesionViewModel(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<AjustesViewModel>(
          create: (context) => AjustesViewModel(
            context.read<PreferenciasRepository>(),
            inicial: preferenciasIniciales,
          ),
        ),
      ],
      child: const _AppConRouter(),
    );
  }
}

class _AppConRouter extends StatefulWidget {
  const _AppConRouter();

  @override
  State<_AppConRouter> createState() => _AppConRouterState();
}

class _AppConRouterState extends State<_AppConRouter> {
  // El router se crea una sola vez; si se creara en `build`, cada
  // reconstrucción perdería la pila de navegación.
  late final GoRouter _router = crearRouter(context.read<SesionViewModel>());

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = context.select<AjustesViewModel, Tema>((a) => a.tema);
    return MaterialApp.router(
      title: 'PetCare',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      darkTheme: TemaApp.oscuro,
      themeMode: switch (tema) {
        Tema.claro => ThemeMode.light,
        Tema.oscuro => ThemeMode.dark,
      },
      routerConfig: _router,
    );
  }
}
