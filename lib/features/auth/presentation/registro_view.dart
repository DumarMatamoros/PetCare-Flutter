import 'package:flutter/material.dart';

import 'validadores_auth.dart';
import 'widgets/campos_auth.dart';
import 'widgets/plantilla_auth.dart';

/// Formulario de registro con el estado y las acciones de la pantalla.
class RegistroView extends StatefulWidget {
  const RegistroView({
    super.key,
    required this.onRegistrarse,
    required this.onIrALogin,
    this.cargando = false,
    this.error,
    this.errorCorreo,
    this.errorContrasena,
    this.errorConfirmacion,
  });

  final void Function(String correo, String clave, String confirmacion)
  onRegistrarse;
  final VoidCallback onIrALogin;
  final bool cargando;
  final String? error;
  final String? errorCorreo;
  final String? errorContrasena;
  final String? errorConfirmacion;

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  final _confirmacion = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  void _enviar() {
    if (widget.cargando) return;
    widget.onRegistrarse(_correo.text.trim(), _clave.text, _confirmacion.text);
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
                'Crear cuenta',
                style: tema.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              'Tus mascotas quedan guardadas en tu cuenta.',
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
              textoAyuda:
                  'Al menos ${ValidadoresAuth.largoMinimoClave} caracteres',
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              error: widget.errorContrasena,
            ),
            CampoClave(
              controller: _confirmacion,
              enabled: habilitado,
              etiqueta: 'Repite la contraseña',
              autofillHints: const [AutofillHints.newPassword],
              error: widget.errorConfirmacion,
              onFieldSubmitted: (_) => _enviar(),
            ),
            if (widget.error case final mensaje?)
              MensajeErrorAuth(mensaje: mensaje),
            BotonEnvioAuth(
              cargando: widget.cargando,
              texto: 'Crear cuenta',
              textoCargando: 'Creando cuenta…',
              onPressed: _enviar,
            ),
            EnlaceAuth(
              pregunta: '¿Ya tienes cuenta?',
              accion: 'Inicia sesión',
              onPressed: habilitado ? widget.onIrALogin : null,
            ),
          ],
        ),
      ),
    );
  }
}
