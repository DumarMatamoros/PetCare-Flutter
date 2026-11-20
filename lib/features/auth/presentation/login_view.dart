import 'package:flutter/material.dart';

import 'widgets/campos_auth.dart';
import 'widgets/plantilla_auth.dart';

/// Formulario de inicio de sesión con el estado y las acciones de la pantalla.
class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
    required this.onIngresar,
    required this.onIrARegistro,
    this.cargando = false,
    this.error,
    this.errorCorreo,
    this.errorContrasena,
  });

  final void Function(String correo, String clave) onIngresar;
  final VoidCallback onIrARegistro;
  final bool cargando;
  final String? error;
  final String? errorCorreo;
  final String? errorContrasena;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _correo = TextEditingController();
  final _clave = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  void _enviar() {
    if (widget.cargando) return;
    widget.onIngresar(_correo.text.trim(), _clave.text);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final habilitado = !widget.cargando;

    return PlantillaAuth(
      formulario: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Iniciar sesión',
                style: tema.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              'Entra con tu correo para ver a tus mascotas.',
              style: tema.textTheme.bodyLarge!.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            TextFormField(
              controller: _correo,
              enabled: habilitado,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              forceErrorText: widget.errorCorreo,
              errorBuilder: textoErrorCampoAuth,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
            CampoClave(
              controller: _clave,
              enabled: habilitado,
              etiqueta: 'Contraseña',
              error: widget.errorContrasena,
              onFieldSubmitted: (_) => _enviar(),
            ),
            if (widget.error case final mensaje?)
              MensajeErrorAuth(mensaje: mensaje),
            BotonEnvioAuth(
              cargando: widget.cargando,
              texto: 'Iniciar sesión',
              textoCargando: 'Ingresando…',
              onPressed: _enviar,
            ),
            EnlaceAuth(
              pregunta: '¿No tienes cuenta?',
              accion: 'Regístrate',
              onPressed: habilitado ? widget.onIrARegistro : null,
            ),
          ],
        ),
      ),
    );
  }
}
