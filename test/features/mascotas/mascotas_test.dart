import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare_flutter/core/errores/fallo.dart';
import 'package:petcare_flutter/core/estado/estado_carga.dart';
import 'package:petcare_flutter/features/ajustes/domain/preferencias.dart';
import 'package:petcare_flutter/features/mascotas/domain/guardar_mascota_use_case.dart';
import 'package:petcare_flutter/features/mascotas/domain/mascota.dart';
import 'package:petcare_flutter/features/mascotas/domain/mascota_repository.dart';
import 'package:petcare_flutter/features/mascotas/presentation/mascotas_view_model.dart';

class RepositorioFalso implements MascotaRepository {
  List<Mascota> mascotas = [];
  bool falla = false;
  int guardados = 0;
  @override
  Future<List<Mascota>> obtenerMascotas() async {
    if (falla) throw const FalloRed();
    return mascotas;
  }

  @override
  Future<Mascota> guardar(Mascota mascota, {XFile? fotoNueva}) async {
    guardados++;
    return mascota;
  }

  @override
  Future<void> eliminar(int id) async {}
  @override
  Future<Mascota> obtenerMascota(int id) async =>
      mascotas.firstWhere((m) => m.id == id);
  @override
  Future<String?> urlDeFoto(Mascota mascota) async => null;
}

void main() {
  late RepositorioFalso repo;
  setUp(() => repo = RepositorioFalso());

  test('valida los campos y no guarda datos inválidos', () async {
    final caso = GuardarMascotaUseCase(repo);
    final mascota = Mascota(
      nombre: ' ',
      especie: '',
      fechaNacimiento: DateTime.now().add(const Duration(days: 2)),
      pesoKg: 0,
    );
    expect(
      caso.validar(mascota).keys,
      containsAll(['nombre', 'especie', 'fechaNacimiento', 'pesoKg']),
    );
    expect(
      () => caso.guardar(mascota),
      throwsA(isA<ValidacionMascotaException>()),
    );
    expect(repo.guardados, 0);
    await caso.guardar(const Mascota(nombre: 'Luna', especie: 'Perro'));
    expect(repo.guardados, 1);
  });

  test('carga, búsqueda, vacío y recuperación de error', () async {
    final vm = MascotasViewModel(repo);
    await vm.cargar();
    expect(vm.estado, isA<Vacio<List<Mascota>>>());
    repo.falla = true;
    await vm.cargar();
    expect(vm.estado, isA<ErrorCarga<List<Mascota>>>());
    repo.falla = false;
    repo.mascotas = [
      const Mascota(id: 1, nombre: 'Luna', especie: 'Perro'),
      const Mascota(id: 2, nombre: 'Max', especie: 'Gato'),
    ];
    await vm.cargar();
    expect(vm.estado, isA<Datos<List<Mascota>>>());
    vm.buscar('  luN ');
    expect(vm.visibles(OrdenMascotas.nombre).single.nombre, 'Luna');
    vm.dispose();
  });
}
