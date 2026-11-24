import '../../ajustes/domain/preferencias.dart';
import '../../ajustes/presentation/ajustes_view_model.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/estado/estado_carga.dart';
import '../../../core/widgets/vista_error.dart';
import '../../../core/widgets/vista_vacia.dart';
import '../../mascotas/domain/mascota.dart';
import '../domain/cuidado.dart';
import 'detalle_mascota_view_model.dart';

class DetalleMascotaScreen extends StatelessWidget {
  const DetalleMascotaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<DetalleMascotaViewModel>();
    final estado = modelo.estado;

    if (estado is Cargando<DetalleMascotaDatos>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de mascota')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (estado is ErrorCarga<DetalleMascotaDatos>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de mascota')),
        body: VistaError(mensaje: estado.mensaje, alReintentar: modelo.cargar),
      );
    }

    if (estado is Vacio<DetalleMascotaDatos>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de mascota')),
        body: const VistaVacia(mensaje: 'No se encontraron los datos.'),
      );
    }

    if (estado is! Datos<DetalleMascotaDatos>) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final datos = estado.valor;
    final ancho = MediaQuery.sizeOf(context).width;
    final mascota = datos.mascota;

    return Scaffold(
      appBar: AppBar(title: Text(mascota.nombre)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ancho >= 800
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _datosMascota(
                        context,
                        mascota,
                        datos.urlFoto,
                        modelo,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _historial(context, datos.cuidados, modelo),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _datosMascota(context, mascota, datos.urlFoto, modelo),
                    const SizedBox(height: 20),
                    _historial(context, datos.cuidados, modelo),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _datosMascota(
    BuildContext context,
    Mascota mascota,
    String? urlFoto,
    DetalleMascotaViewModel modelo,
  ) {
    final localizaciones = MaterialLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (urlFoto != null)
              Image.network(
                urlFoto,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 100,
                  child: Center(child: Icon(Icons.pets_outlined, size: 48)),
                ),
              )
            else
              const SizedBox(
                height: 100,
                child: Center(child: Icon(Icons.pets_outlined, size: 48)),
              ),
            const SizedBox(height: 16),
            Text(mascota.nombre, style: Theme.of(context).textTheme.titleLarge),
            Text('Especie: ${mascota.especie}'),
            if (mascota.raza.isNotEmpty) Text('Raza: ${mascota.raza}'),
            if (mascota.sexo.isNotEmpty) Text('Sexo: ${mascota.sexo}'),
            if (mascota.fechaNacimiento != null)
              Text(
                'Nacimiento: ${localizaciones.formatMediumDate(mascota.fechaNacimiento!)}',
              ),
            if (mascota.pesoKg != null) Text('Peso: ${mascota.pesoKg} kg'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await context.push('/mascotas/${modelo.mascotaId}/editar');
                    if (context.mounted) await modelo.cargar();
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    await context.push(
                      '/mascotas/${modelo.mascotaId}/cuidados/nuevo',
                    );
                    if (context.mounted) await modelo.cargar();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar cuidado'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmarEliminarMascota(context, modelo),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar mascota'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _historial(
    BuildContext context,
    List<Cuidado> cuidados,
    DetalleMascotaViewModel modelo,
  ) {
    final localizaciones = MaterialLocalizations.of(context);
    final orden = context.watch<AjustesViewModel>().ordenHistorial;
    final ordenados = [...cuidados]
      ..sort(
        (a, b) => orden == OrdenHistorial.masReciente
            ? b.fecha.compareTo(a.fecha)
            : a.fecha.compareTo(b.fecha),
      );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historial de cuidados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (cuidados.isEmpty)
              const Text('Aún no hay cuidados registrados.')
            else
              ...ordenados.map((cuidado) {
                final fecha = localizaciones.formatMediumDate(cuidado.fecha);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    cuidado.tipoNombre.isEmpty ? 'Cuidado' : cuidado.tipoNombre,
                  ),
                  subtitle: Text(
                    cuidado.notas == null || cuidado.notas!.isEmpty
                        ? fecha
                        : '$fecha\n${cuidado.notas}',
                  ),
                  isThreeLine:
                      cuidado.notas != null && cuidado.notas!.isNotEmpty,
                  trailing: IconButton(
                    tooltip: 'Eliminar cuidado',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: cuidado.id == null
                        ? null
                        : () => _confirmarEliminarCuidado(
                            context,
                            modelo,
                            cuidado.id!,
                          ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarEliminarCuidado(
    BuildContext context,
    DetalleMascotaViewModel modelo,
    int cuidadoId,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuidado'),
        content: const Text('¿Seguro que deseas eliminar este cuidado?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) return;

    final mensaje = await modelo.eliminarCuidado(cuidadoId);
    if (mensaje != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  Future<void> _confirmarEliminarMascota(
    BuildContext context,
    DetalleMascotaViewModel modelo,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar mascota'),
        content: const Text(
          'Se eliminarán también sus cuidados. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) return;

    final mensaje = await modelo.eliminarMascota();
    if (!context.mounted) return;

    if (mensaje == null) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }
}
