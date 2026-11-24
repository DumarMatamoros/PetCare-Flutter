import 'package:flutter/material.dart';

import 'logo_petcare.dart';

/// Logo + "PetCare" en una fila, como en el encabezado del Inicio de Kotlin.
class MarcaPetCare extends StatelessWidget {
  const MarcaPetCare({super.key, this.tamanoLogo = 42, this.estilo});

  final double tamanoLogo;

  /// Si es null usa headlineSmall en negrita, igual que el Inicio de Kotlin.
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoPetCare(tamano: tamanoLogo),
        const SizedBox(width: 8),
        Flexible(
          child: TextoPetCare(
            estilo: estilo ??
                Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
          ),
        ),
      ],
    );
  }
}

/// La palabra "PetCare" con "Care" en el color principal.
class TextoPetCare extends StatelessWidget {
  const TextoPetCare({super.key, required this.estilo, this.textAlign});

  final TextStyle estilo;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    // Se lee como una sola palabra, no "Pet" y "Care" por separado
    return Semantics(
      label: 'PetCare',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Pet', style: TextStyle(color: colores.onSurface)),
            TextSpan(text: 'Care', style: TextStyle(color: colores.primary)),
          ],
        ),
        style: estilo,
        textAlign: textAlign,
      ),
    );
  }
}
