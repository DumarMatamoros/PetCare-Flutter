import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/errores/fallo.dart';
import '../../auth/presentation/sesion_view_model.dart';
import '../domain/preferencias.dart';
import 'ajustes_view_model.dart';

/// Tema, orden de las listas y cerrar sesión.
class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ajustes = context.watch<AjustesViewModel>();
    final correo = context.select<SesionViewModel, String?>(
      (sesion) => sesion.usuario?.correo,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const _Encabezado('Apariencia'),
              _Opcion<Tema>(
                titulo: 'Tema',
                valor: ajustes.tema,
                opciones: const {
                  Tema.claro: ('Claro', Icons.light_mode_outlined),
                  Tema.oscuro: ('Oscuro', Icons.dark_mode_outlined),
                },
                alCambiar: ajustes.cambiarTema,
              ),
              const Divider(),
              const _Encabezado('Listas'),
              _Opcion<OrdenMascotas>(
                titulo: 'Ordenar mascotas por',
                valor: ajustes.ordenMascotas,
                opciones: const {
                  OrdenMascotas.nombre: ('Nombre', Icons.sort_by_alpha),
                  OrdenMascotas.masReciente: ('Más reciente', Icons.schedule),
                },
                alCambiar: ajustes.cambiarOrdenMascotas,
              ),
              _Opcion<OrdenHistorial>(
                titulo: 'Ordenar historial de cuidados',
                valor: ajustes.ordenHistorial,
                opciones: const {
                  OrdenHistorial.masReciente: (
                    'Más reciente',
                    Icons.arrow_downward,
                  ),
                  OrdenHistorial.masAntiguo: (
                    'Más antiguo',
                    Icons.arrow_upward,
                  ),
                },
                alCambiar: ajustes.cambiarOrdenHistorial,
              ),
              const Divider(),
              const _Encabezado('Cuenta'),
              if (correo != null && correo.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('Sesión iniciada como'),
                  subtitle: Text(correo),
                ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => _cerrarSesion(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final sesion = context.read<SesionViewModel>();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tus mascotas y cuidados quedan guardados en tu cuenta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      // Si sale bien, el router lleva solo a /sign-in.
      await sesion.cerrarSesion();
    } on Fallo catch (fallo) {
      if (context.mounted) _avisar(context, fallo.mensaje);
    }
  }
}

void _avisar(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensaje)));
}

class _Encabezado extends StatelessWidget {
  const _Encabezado(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Semantics(
        header: true,
        child: Text(
          texto,
          style: tema.textTheme.titleSmall?.copyWith(
            color: tema.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Un ajuste con dos o más opciones, mostradas como botones segmentados.
class _Opcion<T> extends StatelessWidget {
  const _Opcion({
    required this.titulo,
    required this.valor,
    required this.opciones,
    required this.alCambiar,
  });

  final String titulo;
  final T valor;

  /// Valor → (texto, icono).
  final Map<T, (String, IconData)> opciones;
  final Future<void> Function(T) alCambiar;

  Future<void> _cambiar(BuildContext context, T nuevo) async {
    try {
      await alCambiar(nuevo);
    } on Fallo catch (fallo) {
      if (context.mounted) _avisar(context, fallo.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          SegmentedButton<T>(
            segments: [
              for (final MapEntry(key: opcion, value: (texto, icono))
                  in opciones.entries)
                ButtonSegment(
                  value: opcion,
                  label: Text(texto),
                  icon: Icon(icono),
                ),
            ],
            selected: {valor},
            onSelectionChanged: (seleccion) =>
                _cambiar(context, seleccion.single),
          ),
        ],
      ),
    );
  }
}
