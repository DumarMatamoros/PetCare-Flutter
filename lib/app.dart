import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/provisional/repositorios_provisionales.dart';
import 'core/router/app_router.dart';
import 'core/tema/tema_app.dart';
import 'features/ajustes/domain/preferencias_repository.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/sesion_view_model.dart';
import 'features/cuidados/data/cuidado_repository_impl.dart';
import 'features/cuidados/data/cuidado_service.dart';
import 'features/cuidados/domain/cuidado_repository.dart';
import 'features/mascotas/data/mascota_repository_impl.dart';
import 'features/mascotas/data/mascota_service.dart';
import 'features/mascotas/domain/guardar_mascota_use_case.dart';
import 'features/mascotas/domain/mascota_repository.dart';
import 'features/tipos_cuidado/data/tipo_cuidado_repository_impl.dart';
import 'features/tipos_cuidado/data/tipo_cuidado_service.dart';
import 'features/tipos_cuidado/domain/tipo_cuidado_repository.dart';

/// Raíz de la app: entrega las dependencias con Provider y monta el router.
///
/// Orden: cliente de Supabase → servicios → repositorios (registrados por su
/// contrato) → ViewModels globales.
class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key, required this.cliente});

  final SupabaseClient cliente;

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
        Provider<TipoCuidadoService>(
          create: (context) =>
              TipoCuidadoService(context.read<SupabaseClient>()),
        ),
        Provider<CuidadoService>(
          create: (context) => CuidadoService(context.read<SupabaseClient>()),
        ),
        Provider<MascotaService>(
          create: (context) => MascotaService(context.read<SupabaseClient>()),
        ),

        // Repositorios
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(context.read<AuthService>()),
        ),
        Provider<MascotaRepository>(
          create: (context) =>
              MascotaRepositoryImpl(context.read<MascotaService>()),
        ),
        Provider<GuardarMascotaUseCase>(
          create: (context) =>
              GuardarMascotaUseCase(context.read<MascotaRepository>()),
        ),
        Provider<TipoCuidadoRepository>(
          create: (context) =>
              TipoCuidadoRepositoryImpl(context.read<TipoCuidadoService>()),
        ),
        Provider<CuidadoRepository>(
          create: (context) =>
              CuidadoRepositoryImpl(context.read<CuidadoService>()),
        ),
        Provider<PreferenciasRepository>(
          create: (_) => PreferenciasRepositoryProvisional(),
        ),

        // ViewModels globales
        ChangeNotifierProvider<SesionViewModel>(
          create: (context) => SesionViewModel(context.read<AuthRepository>()),
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
    return MaterialApp.router(
      title: 'PetCare',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      darkTheme: TemaApp.oscuro,
      // Paso 1: lo decidirá AjustesViewModel según la preferencia guardada.
      themeMode: ThemeMode.light,
      routerConfig: _router,
    );
  }
}
