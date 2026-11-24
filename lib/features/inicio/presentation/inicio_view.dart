import 'package:flutter/material.dart';

import '../../../core/widgets/marca_petcare.dart';
import '../../../core/widgets/vista_error.dart';
import '../../../core/widgets/vista_vacia.dart';

/// Un cuidado de la sección "Actividad reciente", ya listo para mostrar.
class CuidadoRecienteVista {
  const CuidadoRecienteVista({
    required this.nombreTipo,
    required this.nombreMascota,
    required this.fecha,
  });

  final String nombreTipo;
  final String nombreMascota;
  final DateTime fecha;
}

/// Pantalla de Inicio, solo la parte visual. Copia el `HomeScreen` de Kotlin
/// y agrega el acceso al catálogo de tipos de cuidado.
///
/// Va dentro de la pestaña "Inicio", así que no trae Scaffold ni barra inferior.
class InicioView extends StatelessWidget {
  const InicioView({
    super.key,
    required this.onVerMascotas,
    required this.onRegistrarMascota,
    required this.onVerCatalogo,
    required this.onReintentar,
    this.cargando = false,
    this.error,
    this.totalMascotas = 0,
    this.totalCuidados,
    this.cuidadosRecientes,
  });

  final VoidCallback onVerMascotas;
  final VoidCallback onRegistrarMascota;
  final VoidCallback onVerCatalogo;
  final VoidCallback onReintentar;

  final bool cargando;
  final String? error;
  final int totalMascotas;

  /// Si es null no se muestra la tarjeta de cuidados (depende del módulo de
  /// cuidados de la Tarea 3).
  final int? totalCuidados;

  /// Si es null no se muestra la sección "Actividad reciente".
  final List<CuidadoRecienteVista>? cuidadosRecientes;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, limites) {
          final amplio = limites.maxWidth >= 600;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: amplio ? 32 : 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 22,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: MarcaPetCare(),
                    ),
                    const _Titulo(),
                    ..._contenido(context, amplio),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _contenido(BuildContext context, bool amplio) {
    final catalogo = _CatalogoCard(onPressed: onVerCatalogo);
    if (cargando) {
      return [
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Cargando resumen',
            ),
          ),
        ),
        catalogo,
      ];
    }

    if (error case final mensaje?) {
      return [
        Semantics(
          liveRegion: true,
          child: VistaError(mensaje: mensaje, alReintentar: onReintentar),
        ),
        catalogo,
      ];
    }

    if (totalMascotas == 0) {
      return [
        VistaVacia(
          mensaje: 'Aún no tienes mascotas registradas.',
          icono: Icons.pets_outlined,
          textoAccion: 'Registrar mi primera mascota',
          alAccionar: onRegistrarMascota,
        ),
        catalogo,
      ];
    }

    final mascotas = _AccesoRapidoCard(
      destacada: true,
      icono: Icons.pets,
      titulo: 'Tus mascotas',
      descripcion: 'Consulta sus perfiles y registra nuevas mascotas.',
      boton: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: onVerMascotas,
            child: const Text('Mis mascotas'),
          ),
          TextButton(
            onPressed: onRegistrarMascota,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            child: const Text('Registrar mascota'),
          ),
        ],
      ),
    );

    return [
      // IntrinsicHeight + stretch: ambas tarjetas toman la altura de la más alta
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Expanded(
              child: _ResumenCard(
                titulo: 'Mascotas',
                total: totalMascotas,
                icono: Icons.pets,
              ),
            ),
            if (totalCuidados case final total?)
              Expanded(
                child: _ResumenCard(
                  titulo: 'Cuidados\nregistrados',
                  total: total,
                  icono: Icons.favorite,
                ),
              ),
          ],
        ),
      ),
      // En horizontal o tablet, los dos accesos rápidos van lado a lado
      if (amplio)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Expanded(child: mascotas),
              Expanded(child: catalogo),
            ],
          ),
        )
      else ...[
        mascotas,
        catalogo,
      ],
      if (cuidadosRecientes case final recientes?) ...[
        const _Subtitulo('Actividad reciente'),
        if (recientes.isEmpty)
          const _TextoVacio('Aún no hay cuidados registrados.')
        else
          for (final cuidado in recientes) _CuidadoRecienteCard(cuidado),
      ],
    ];
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Resumen',
            style: tema.textTheme.headlineLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          'El cuidado de tus mascotas, en un solo lugar.',
          style: tema.textTheme.bodyLarge!.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Subtitulo extends StatelessWidget {
  const _Subtitulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        texto,
        style: Theme.of(context).textTheme.headlineSmall!
            .copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _TextoVacio extends StatelessWidget {
  const _TextoVacio(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// Círculo de color con un ícono decorativo en el centro.
class _IconoCircular extends StatelessWidget {
  const _IconoCircular({
    required this.icono,
    required this.tamano,
    required this.tamanoIcono,
    required this.fondo,
    required this.colorIcono,
  });

  final IconData icono;
  final double tamano;
  final double tamanoIcono;
  final Color fondo;
  final Color colorIcono;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(color: fondo, shape: BoxShape.circle),
        child: Icon(icono, size: tamanoIcono, color: colorIcono),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  const _ResumenCard({
    required this.titulo,
    required this.total,
    required this.icono,
  });

  final String titulo;
  final int total;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    // TalkBack lo lee de una vez: "Mascotas, 3"
    return MergeSemantics(
      child: Card(
        color: colores.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            spacing: 10,
            children: [
              _IconoCircular(
                icono: icono,
                tamano: 48,
                tamanoIcono: 27,
                fondo: tema.scaffoldBackgroundColor.withValues(alpha: 0.75),
                colorIcono: colores.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: tema.textTheme.labelLarge!.copyWith(
                        color: colores.onSurfaceVariant,
                        height: 18 / 14,
                      ),
                    ),
                    Text(
                      '$total',
                      style: tema.textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colores.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de acceso rápido: ícono, título, descripción y un botón.
class _AccesoRapidoCard extends StatelessWidget {
  const _AccesoRapidoCard({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.boton,
    required this.destacada,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final Widget boton;

  /// La destacada usa el verde claro de fondo; la otra va en blanco con borde.
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return Card(
      color: destacada ? colores.primaryContainer : colores.surface,
      shape: destacada
          ? null
          : RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              side: BorderSide(color: colores.outlineVariant),
            ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // En horizontal empuja el botón al fondo para alinearlo con la otra tarjeta
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 16,
          children: [
            Row(
              spacing: 16,
              children: [
                _IconoCircular(
                  icono: icono,
                  tamano: 60,
                  tamanoIcono: 34,
                  fondo: destacada ? colores.primary : colores.primaryContainer,
                  colorIcono: destacada ? colores.onPrimary : colores.primary,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        titulo,
                        style: tema.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        descripcion,
                        style: tema.textTheme.bodyMedium!.copyWith(
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            boton,
          ],
        ),
      ),
    );
  }
}

class _CatalogoCard extends StatelessWidget {
  const _CatalogoCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _AccesoRapidoCard(
      destacada: false,
      icono: Icons.menu_book,
      titulo: 'Tipos de cuidado',
      descripcion: 'Vacunación, baño, desparasitación y visita veterinaria.',
      boton: OutlinedButton(
        onPressed: onPressed,
        child: const Text('Ver catálogo'),
      ),
    );
  }
}

class _CuidadoRecienteCard extends StatelessWidget {
  const _CuidadoRecienteCard(this.cuidado);

  final CuidadoRecienteVista cuidado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return MergeSemantics(
      child: Card(
        color: colores.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: colores.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            spacing: 14,
            children: [
              _IconoCircular(
                icono: Icons.favorite,
                tamano: 52,
                tamanoIcono: 27,
                fondo: colores.primaryContainer,
                colorIcono: colores.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cuidado.nombreTipo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${cuidado.nombreMascota}  ·  ${_formatearFecha(cuidado.fecha)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodyLarge!.copyWith(
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatearFecha(DateTime fecha) {
  String dosDigitos(int n) => n.toString().padLeft(2, '0');
  return '${dosDigitos(fecha.day)}/${dosDigitos(fecha.month)}/${fecha.year}';
}
