import '../../features/ajustes/domain/preferencias.dart';
import '../../features/ajustes/domain/preferencias_repository.dart';
/// Persona D lo reemplaza por `PreferenciasRepositoryImpl`. Mientras tanto
/// devuelve los valores por defecto y no guarda nada.
class PreferenciasRepositoryProvisional implements PreferenciasRepository {
  @override
  Future<Preferencias> leer() async => Preferencias.porDefecto;

  @override
  Future<void> guardar(Preferencias preferencias) async {}
}
