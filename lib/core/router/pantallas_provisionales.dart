import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/sesion_view_model.dart';
import '../errores/fallo.dart';

// Pantallas provisionales para que todas las rutas abran algo mientras cada
// persona hace la suya. Al reemplazar la tuya en `app_router.dart`, ya no la
// uses; el archivo se borra cuando no quede ninguna en uso.

/// Pantalla con el nombre de la ruta y enlaces para probar la navegación.
class PantallaProvisional extends StatelessWidget {
  const PantallaProvisional({
    super.key,
    required this.titulo,
    this.enlaces = const {},
  });

  final String titulo;

  /// Texto del botón → ruta a la que lleva.
  final Map<String, String> enlaces;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pantalla provisional',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              for (final MapEntry(key: texto, value: ruta) in enlaces.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => context.push(ruta),
                    child: Text(texto),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formulario mínimo para probar el registro y el inicio de sesión.
/// Persona A lo reemplaza por `SignInScreen` y `SignUpScreen`.
class FormularioSesionProvisional extends StatefulWidget {
  const FormularioSesionProvisional({super.key, required this.esRegistro});

  final bool esRegistro;

  @override
  State<FormularioSesionProvisional> createState() =>
      _FormularioSesionProvisionalState();
}

class _FormularioSesionProvisionalState
    extends State<FormularioSesionProvisional> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final repositorio = context.read<AuthRepository>();
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      // Si sale bien, el router redirige solo a /inicio.
      if (widget.esRegistro) {
        await repositorio.registrar(
          correo: _correo.text,
          contrasena: _contrasena.text,
        );
      } else {
        await repositorio.iniciarSesion(
          correo: _correo.text,
          contrasena: _contrasena.text,
        );
      }
    } on Fallo catch (fallo) {
      if (mounted) setState(() => _error = fallo.mensaje);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.esRegistro ? 'Registrarse' : 'Iniciar sesión';
    return Scaffold(
      appBar: AppBar(title: Text('$titulo (provisional)')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _correo,
            decoration: const InputDecoration(labelText: 'Correo'),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contrasena,
            decoration: const InputDecoration(labelText: 'Contraseña'),
            obscureText: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _enviando ? null : _enviar,
            child: Text(_enviando ? 'Enviando…' : titulo),
          ),
          TextButton(
            onPressed: () =>
                context.go(widget.esRegistro ? '/sign-in' : '/sign-up'),
            child: Text(
              widget.esRegistro
                  ? 'Ya tengo cuenta'
                  : 'No tengo cuenta, registrarme',
            ),
          ),
        ],
      ),
    );
  }
}

/// Ajustes mínimo con "Cerrar sesión". Persona D lo reemplaza por
/// `AjustesScreen`.
class AjustesProvisional extends StatelessWidget {
  const AjustesProvisional({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pantalla provisional\n${sesion.usuario?.correo ?? ''}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                try {
                  await sesion.cerrarSesion();
                } on Fallo catch (fallo) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(fallo.mensaje)));
                  }
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
