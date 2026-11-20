import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/estado/estado_carga.dart';
import '../../../core/widgets/vista_error.dart';
import '../../../core/widgets/vista_vacia.dart';
import '../../tipos_cuidado/domain/tipo_cuidado.dart';
import 'cuidado_form_view_model.dart';

class CuidadoFormScreen extends StatefulWidget {
  const CuidadoFormScreen({super.key});

  @override
  State<CuidadoFormScreen> createState() => _CuidadoFormScreenState();
}

class _CuidadoFormScreenState extends State<CuidadoFormScreen> {
  final _notasController = TextEditingController();

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(CuidadoFormViewModel modelo) async {
    final fechaActual = modelo.fecha ?? DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaActual,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (fecha != null) modelo.seleccionarFecha(fecha);
  }

  Future<void> _guardar(CuidadoFormViewModel modelo) async {
    final guardado = await modelo.guardar(_notasController.text);

    if (!mounted) return;
    if (guardado) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<CuidadoFormViewModel>();
    final estado = modelo.estadoTipos;

    if (estado is Cargando<List<TipoCuidado>>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Registrar cuidado')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (estado is ErrorCarga<List<TipoCuidado>>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Registrar cuidado')),
        body: VistaError(
          mensaje: estado.mensaje,
          alReintentar: modelo.cargarTipos,
        ),
      );
    }

    if (estado is Vacio<List<TipoCuidado>>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Registrar cuidado')),
        body: const VistaVacia(
          mensaje: 'No hay tipos de cuidado disponibles.',
          icono: Icons.pets_outlined,
        ),
      );
    }

    if (estado is! Datos<List<TipoCuidado>>) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final tipos = estado.valor;
    final fecha = modelo.fecha;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar cuidado')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<int>(
              initialValue: modelo.tipoCuidadoId,
              decoration: const InputDecoration(
                labelText: 'Tipo de cuidado',
                border: OutlineInputBorder(),
              ),
              items: tipos
                  .map(
                    (tipo) => DropdownMenuItem<int>(
                      value: tipo.id,
                      child: Text(tipo.nombre),
                    ),
                  )
                  .toList(),
              onChanged: modelo.guardando ? null : modelo.seleccionarTipo,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: modelo.guardando
                  ? null
                  : () => _seleccionarFecha(modelo),
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                fecha == null
                    ? 'Seleccionar fecha'
                    : MaterialLocalizations.of(context).formatMediumDate(fecha),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notasController,
              enabled: !modelo.guardando,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            if (modelo.mensajeError != null) ...[
              const SizedBox(height: 16),
              Text(
                modelo.mensajeError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: modelo.guardando ? null : () => _guardar(modelo),
              child: modelo.guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar cuidado'),
            ),
          ],
        ),
      ),
    );
  }
}
