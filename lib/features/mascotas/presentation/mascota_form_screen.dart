import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/estado/estado_carga.dart';
import '../../../core/widgets/vista_error.dart';
import '../domain/mascota.dart';
import 'mascota_form_view_model.dart';

class MascotaFormScreen extends StatefulWidget {
  const MascotaFormScreen({super.key});
  @override
  State<MascotaFormScreen> createState() => _MascotaFormScreenState();
}

class _MascotaFormScreenState extends State<MascotaFormScreen> {
  final nombre = TextEditingController();
  final especie = TextEditingController();
  final raza = TextEditingController();
  final sexo = TextEditingController();
  final peso = TextEditingController();
  DateTime? fecha;
  XFile? foto;
  Uint8List? fotoBytes;
  Mascota? original;
  bool cargado = false;
  String? errorPeso;

  @override
  void dispose() {
    nombre.dispose();
    especie.dispose();
    raza.dispose();
    sexo.dispose();
    peso.dispose();
    super.dispose();
  }

  void _rellenar(Mascota m) {
    original = m;
    nombre.text = m.nombre;
    especie.text = m.especie;
    raza.text = m.raza;
    sexo.text = m.sexo;
    peso.text = m.pesoKg?.toString() ?? '';
    fecha = m.fechaNacimiento;
    cargado = true;
  }

  Future<void> _elegirFoto() async {
    try {
      final elegida = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 70,
      );
      if (elegida != null) {
        final bytes = await elegida.readAsBytes();
        if (mounted) setState(() { foto = elegida; fotoBytes = bytes; });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo seleccionar la foto')),
        );
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: fecha ?? ahora,
      firstDate: DateTime(1900),
      lastDate: ahora,
    );
    if (mounted && elegida != null) setState(() => fecha = elegida);
  }

  Future<void> _guardar() async {
    final textoPeso = peso.text.trim().replaceAll(',', '.');
    final pesoNumero = textoPeso.isEmpty ? null : double.tryParse(textoPeso);
    setState(
      () => errorPeso = textoPeso.isNotEmpty && pesoNumero == null
          ? 'Ingresa un peso válido'
          : null,
    );
    if (errorPeso != null) return;
    final mascota = Mascota(
      id: original?.id,
      nombre: nombre.text.trim(),
      especie: especie.text.trim(),
      raza: raza.text.trim(),
      sexo: sexo.text.trim(),
      pesoKg: pesoNumero,
      fechaNacimiento: fecha,
      fotoPath: original?.fotoPath,
    );
    final vm = context.read<MascotaFormViewModel>();
    final exito = await vm.guardar(mascota, fotoNueva: foto);
    if (mounted && exito) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MascotaFormViewModel>();
    if (vm.id != null && !cargado) {
      final estado = vm.estado;
      if (estado is Datos<Mascota>) {
        _rellenar(estado.valor);
      } else {
        return Scaffold(
          appBar: AppBar(title: const Text('Editar mascota')),
          body: estado is ErrorCarga<Mascota>
              ? VistaError(mensaje: estado.mensaje, alReintentar: vm.cargar)
              : const Center(child: CircularProgressIndicator()),
        );
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(vm.id == null ? 'Registrar mascota' : 'Editar mascota'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundImage: fotoBytes == null
                  ? null
                  : MemoryImage(fotoBytes!),
              child: foto == null ? const Icon(Icons.pets, size: 40) : null,
            ),
          ),
          TextButton.icon(
            onPressed: vm.guardando ? null : _elegirFoto,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Elegir foto'),
          ),
          TextField(
            controller: nombre,
            decoration: InputDecoration(
              labelText: 'Nombre *',
              errorText: vm.errores['nombre'],
            ),
          ),
          TextField(
            controller: especie,
            decoration: InputDecoration(
              labelText: 'Especie *',
              errorText: vm.errores['especie'],
            ),
          ),
          TextField(
            controller: raza,
            decoration: const InputDecoration(labelText: 'Raza'),
          ),
          TextField(
            controller: sexo,
            decoration: const InputDecoration(labelText: 'Sexo'),
          ),
          TextField(
            controller: peso,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Peso (kg)',
              errorText: errorPeso ?? vm.errores['pesoKg'],
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Fecha de nacimiento'),
            subtitle: Text(
              fecha == null
                  ? 'Sin fecha'
                  : '${fecha!.day}/${fecha!.month}/${fecha!.year}',
            ),
            trailing: IconButton(
              onPressed: _seleccionarFecha,
              icon: const Icon(Icons.calendar_today),
            ),
          ),
          if (fecha != null)
            TextButton(
              onPressed: () => setState(() => fecha = null),
              child: const Text('Quitar fecha'),
            ),
          if (vm.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                vm.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: vm.guardando ? null : _guardar,
            child: Text(vm.guardando ? 'Guardando…' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}
