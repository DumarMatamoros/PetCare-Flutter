import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/estado/estado_carga.dart';
import '../../../core/widgets/vista_error.dart';
import '../../../core/widgets/vista_vacia.dart';
import '../../ajustes/domain/preferencias.dart';
import '../domain/mascota.dart';
import '../domain/mascota_repository.dart';
import 'mascotas_view_model.dart';

/// Recibe el orden desde Ajustes al conectar la pantalla al router.
class MascotasScreen extends StatelessWidget {
  const MascotasScreen({super.key, this.orden = OrdenMascotas.nombre});
  final OrdenMascotas orden;

  Future<void> _abrir(BuildContext context, String ruta) async {
    await context.push(ruta);
    if (context.mounted) context.read<MascotasViewModel>().cargar();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MascotasViewModel>();
    final contenido = switch (vm.estado) {
      Cargando<List<Mascota>>() => const Center(
        child: CircularProgressIndicator(),
      ),
      ErrorCarga<List<Mascota>>(:final mensaje) => VistaError(
        mensaje: mensaje,
        alReintentar: vm.cargar,
      ),
      Vacio<List<Mascota>>() => VistaVacia(
        mensaje: 'Aún no tienes mascotas',
        textoAccion: 'Registrar mascota',
        alAccionar: () => _abrir(context, '/mascotas/nueva'),
      ),
      Datos<List<Mascota>>() => _lista(context, vm),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Mis mascotas')),
      body: contenido,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrir(context, '/mascotas/nueva'),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _lista(BuildContext context, MascotasViewModel vm) {
    final mascotas = vm.visibles(orden);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: vm.buscar,
            decoration: const InputDecoration(
              labelText: 'Buscar por nombre',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: mascotas.isEmpty
              ? const VistaVacia(
                  mensaje: 'Ninguna mascota coincide con la búsqueda',
                )
              : ListView.builder(
                  itemCount: mascotas.length,
                  itemBuilder: (context, index) {
                    final mascota = mascotas[index];
                    return ListTile(
                      leading: _FotoMascota(mascota: mascota),
                      title: Text(mascota.nombre),
                      subtitle: Text(
                        [
                          mascota.especie,
                          mascota.raza,
                        ].where((s) => s.isNotEmpty).join(' · '),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _abrir(context, '/mascotas/${mascota.id}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FotoMascota extends StatelessWidget {
  const _FotoMascota({required this.mascota});
  final Mascota mascota;
  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: context.read<MascotaRepository>().urlDeFoto(mascota),
    builder: (context, snapshot) => CircleAvatar(
      foregroundImage: snapshot.hasData && snapshot.data != null
          ? NetworkImage(snapshot.data!)
          : null,
      child: const Icon(Icons.pets),
    ),
  );
}
