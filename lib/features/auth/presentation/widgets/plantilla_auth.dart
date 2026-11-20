import 'package:flutter/material.dart';

import '../../../../core/widgets/logo_petcare.dart';
import '../../../../core/widgets/marca_petcare.dart';

/// Estructura común de Iniciar sesión y Registrarse.
///
/// - Vertical: marca arriba (como el Splash de Kotlin) y el formulario debajo.
/// - Horizontal: marca a la izquierda y formulario a la derecha, cada mitad con
///   su propio scroll para que nada se desborde aunque el teclado esté abierto.
class PlantillaAuth extends StatelessWidget {
  const PlantillaAuth({super.key, required this.formulario});

  final Widget formulario;

  static const _anchoMaximoFormulario = 440.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, limites) {
            final horizontal = limites.maxWidth >= 600;

            if (horizontal) {
              return Row(
                children: [
                  const Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24),
                        child: _EncabezadoAuth(tamanoLogo: 150),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: _anchoMaximoFormulario,
                          ),
                          child: formulario,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _anchoMaximoFormulario,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _EncabezadoAuth(tamanoLogo: 130),
                      const SizedBox(height: 32),
                      formulario,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Logo grande, "PetCare" y el lema: el mismo bloque central del Splash de Kotlin.
class _EncabezadoAuth extends StatelessWidget {
  const _EncabezadoAuth({required this.tamanoLogo});

  final double tamanoLogo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoPetCare(tamano: tamanoLogo),
        const TextoPetCare(
          textAlign: TextAlign.center,
          estilo: TextStyle(
            fontSize: 40,
            height: 46 / 40,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'El cuidado de tus mascotas,\nen un solo lugar',
          textAlign: TextAlign.center,
          style: tema.textTheme.titleLarge!.copyWith(
            fontSize: 18,
            height: 25 / 18,
            fontWeight: FontWeight.w400,
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
