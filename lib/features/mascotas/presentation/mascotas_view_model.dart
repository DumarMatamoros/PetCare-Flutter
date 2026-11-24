import 'package:flutter/foundation.dart';

import '../../../core/errores/fallo.dart';
import '../../../core/estado/estado_carga.dart';
import '../../ajustes/domain/preferencias.dart';
import '../domain/mascota.dart';
import '../domain/mascota_repository.dart';

class MascotasViewModel extends ChangeNotifier {
  MascotasViewModel(this._repositorio);
  final MascotaRepository _repositorio;
  EstadoCarga<List<Mascota>> estado = const Cargando();
  String busqueda = '';
  bool _cerrado = false;

  @override
  void dispose() {
    _cerrado = true;
    super.dispose();
  }

  Future<void> cargar() async {
    estado = const Cargando();
    notifyListeners();
    try {
      final mascotas = await _repositorio.obtenerMascotas();
      estado = mascotas.isEmpty ? const Vacio() : Datos(mascotas);
    } on Fallo catch (error) {
      estado = ErrorCarga(error.mensaje);
    } catch (_) {
      estado = const ErrorCarga('No se pudieron cargar las mascotas');
    }
    if (!_cerrado) notifyListeners();
  }

  void buscar(String texto) {
    busqueda = texto;
    notifyListeners();
  }

  List<Mascota> visibles(OrdenMascotas orden) {
    final actual = estado;
    if (actual is! Datos<List<Mascota>>) return [];
    final filtro = busqueda.trim().toLowerCase();
    final lista = actual.valor
        .where((m) => m.nombre.toLowerCase().contains(filtro))
        .toList();
    lista.sort(
      orden == OrdenMascotas.nombre
          ? (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase())
          : (a, b) => (b.id ?? 0).compareTo(a.id ?? 0),
    );
    return lista;
  }
}
