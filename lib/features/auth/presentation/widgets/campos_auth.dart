import 'package:flutter/material.dart';

Widget textoErrorCampoAuth(BuildContext context, String mensaje) {
  final tema = Theme.of(context);
  final estilo = tema.textTheme.bodySmall?.copyWith(
    color: tema.colorScheme.error,
  );
  return Text(
    mensaje,
    style: estilo?.merge(tema.inputDecorationTheme.errorStyle),
  );
}

/// Campo de contraseña con botón para mostrarla u ocultarla.
class CampoClave extends StatefulWidget {
  const CampoClave({
    super.key,
    required this.controller,
    required this.etiqueta,
    this.error,
    this.autofillHints = const [AutofillHints.password],
    this.textoAyuda,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String etiqueta;
  final String? error;
  final Iterable<String> autofillHints;
  final String? textoAyuda;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;

  @override
  State<CampoClave> createState() => _CampoClaveState();
}

class _CampoClaveState extends State<CampoClave> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _oculta,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      forceErrorText: widget.error,
      errorBuilder: textoErrorCampoAuth,
      decoration: InputDecoration(
        labelText: widget.etiqueta,
        helperText: widget.textoAyuda,
        helperMaxLines: 2,
        suffixIcon: IconButton(
          // El tooltip también es la etiqueta que lee TalkBack
          tooltip: _oculta ? 'Mostrar contraseña' : 'Ocultar contraseña',
          icon: Icon(_oculta ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _oculta = !_oculta),
        ),
      ),
    );
  }
}

/// Mensaje de error que llega del ViewModel (por ejemplo "Correo o contraseña
/// incorrectos" o "Sin conexión a internet").
///
/// Es una "región viva": TalkBack lo anuncia apenas aparece, sin que el usuario
/// tenga que buscarlo.
class MensajeErrorAuth extends StatelessWidget {
  const MensajeErrorAuth({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colores.errorContainer,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colores.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: TextStyle(color: colores.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BotonEnvioAuth extends StatelessWidget {
  const BotonEnvioAuth({
    super.key,
    required this.cargando,
    required this.texto,
    required this.textoCargando,
    required this.onPressed,
  });

  final bool cargando;
  final String texto;
  final String textoCargando;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!cargando) {
      return FilledButton(onPressed: onPressed, child: Text(texto));
    }

    return FilledButton(
      onPressed: null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          const ExcludeSemantics(
            child: SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          Flexible(child: Text(textoCargando, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

/// "¿No tienes cuenta? Regístrate" / "¿Ya tienes cuenta? Inicia sesión".
///
/// Usa Wrap para que, con letra grande, el botón baje de línea en vez de desbordarse.
class EnlaceAuth extends StatelessWidget {
  const EnlaceAuth({
    super.key,
    required this.pregunta,
    required this.accion,
    required this.onPressed,
  });

  final String pregunta;
  final String accion;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          pregunta,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(onPressed: onPressed, child: Text(accion)),
      ],
    );
  }
}
