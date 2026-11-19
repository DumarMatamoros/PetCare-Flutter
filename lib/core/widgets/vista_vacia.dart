import 'package:flutter/material.dart';

/// Mensaje para cuando una lista no tiene elementos, con una acción opcional.
class VistaVacia extends StatelessWidget {
  const VistaVacia({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox_outlined,
    this.textoAccion,
    this.alAccionar,
  }) : assert(
         (textoAccion == null) == (alAccionar == null),
         'textoAccion y alAccionar van juntos',
       );

  final String mensaje;
  final IconData icono;
  final String? textoAccion;
  final VoidCallback? alAccionar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(icono, size: 56, color: tema.colorScheme.outline),
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyLarge,
            ),
            if (textoAccion != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: alAccionar,
                child: Text(textoAccion!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
