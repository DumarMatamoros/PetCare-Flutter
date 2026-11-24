import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/estado/estado_carga.dart';
import '../../../core/widgets/vista_error.dart';
import '../../../core/widgets/vista_vacia.dart';
import '../domain/tipo_cuidado.dart';
import 'tipos_cuidado_view_model.dart';

class TiposCuidadoScreen extends StatelessWidget {
  const TiposCuidadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<TiposCuidadoViewModel>();
    final estado = modelo.estado;

    Widget contenido;

    if (estado is Cargando<List<TipoCuidado>>) {
      contenido = const Center(child: CircularProgressIndicator());
    } else if (estado is Datos<List<TipoCuidado>>) {
      final tipos = estado.valor;
      contenido = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tipos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, indice) {
          final tipo = tipos[indice];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.health_and_safety_outlined),
              ),
              title: Text(tipo.nombre),
            ),
          );
        },
      );
    } else if (estado is Vacio<List<TipoCuidado>>) {
      contenido = const VistaVacia(
        mensaje: 'No hay tipos de cuidado disponibles.',
        icono: Icons.pets_outlined,
      );
    } else if (estado is ErrorCarga<List<TipoCuidado>>) {
      contenido = VistaError(
        mensaje: estado.mensaje,
        alReintentar: modelo.cargar,
      );
    } else {
      contenido = const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tipos de cuidado')),
      body: contenido,
    );
  }
}
