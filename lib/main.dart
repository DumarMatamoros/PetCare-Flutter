import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/entorno.dart';
import 'core/sesion/almacen_sesion_seguro.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Entorno.estaConfigurado) {
    runApp(const _FaltaConfiguracion());
    return;
  }

  // Restaura la sesión guardada antes de pintar la primera pantalla.
  await Supabase.initialize(
    url: Entorno.supabaseUrl,
    publishableKey: Entorno.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(localStorage: AlmacenSesionSeguro()),
  );

  runApp(PetCareApp(cliente: Supabase.instance.client));
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
