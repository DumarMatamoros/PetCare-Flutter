import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/entorno.dart';
import 'core/sesion/almacen_sesion_seguro.dart';
import 'features/ajustes/data/preferencias_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Entorno.estaConfigurado) {
    runApp(const _FaltaConfiguracion());
    return;
  }

  // Antes de pintar la primera pantalla se restaura la sesión y se leen las
  // preferencias (así el tema oscuro no aparece primero en claro).
  final preferenciasRepository = PreferenciasRepositoryImpl();
  final (_, preferencias) = await (
    Supabase.initialize(
      url: Entorno.supabaseUrl,
      publishableKey: Entorno.supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: AlmacenSesionSeguro(),
      ),
    ),
    preferenciasRepository.leer(),
  ).wait;

  runApp(
    PetCareApp(
      cliente: Supabase.instance.client,
      preferenciasRepository: preferenciasRepository,
      preferenciasIniciales: preferencias,
    ),
  );
}

/// Se muestra si se ejecutó la app sin `--dart-define-from-file=env.json`.
class _FaltaConfiguracion extends StatelessWidget {
  const _FaltaConfiguracion();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Falta la configuración de Supabase.\n\n'
              'Copia env.ejemplo.json como env.json, llena los valores y '
              'ejecuta:\nflutter run --dart-define-from-file=env.json',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
