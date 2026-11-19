import 'package:flutter_test/flutter_test.dart';
import 'package:petcare_flutter/features/ajustes/data/preferencias_repository_impl.dart';
import 'package:petcare_flutter/features/ajustes/domain/preferencias.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  void usarAlmacen(Map<String, Object> datos) {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(datos);
  }

  test('sin nada guardado devuelve los valores por defecto', () async {
    usarAlmacen({});

    final preferencias = await PreferenciasRepositoryImpl().leer();

    expect(preferencias, Preferencias.porDefecto);
  });

  test('lo que se guarda se vuelve a leer igual', () async {
    usarAlmacen({});
    const elegidas = Preferencias(
      tema: Tema.oscuro,
      ordenMascotas: OrdenMascotas.masReciente,
      ordenHistorial: OrdenHistorial.masAntiguo,
    );

    await PreferenciasRepositoryImpl().guardar(elegidas);
    final leidas = await PreferenciasRepositoryImpl().leer();

    expect(leidas, elegidas);
  });

  test('un valor guardado que no existe usa el valor por defecto', () async {
    usarAlmacen({
      'preferencias.tema': 'sepia',
      'preferencias.ordenMascotas': 'masReciente',
    });

    final preferencias = await PreferenciasRepositoryImpl().leer();

    expect(preferencias.tema, Tema.claro);
    expect(preferencias.ordenMascotas, OrdenMascotas.masReciente);
  });

  test('no toca claves ajenas a las preferencias', () async {
    usarAlmacen({'otra.clave': 'valor'});

    await PreferenciasRepositoryImpl().guardar(Preferencias.porDefecto);
    final todo = await SharedPreferencesAsync().getAll();

    expect(todo['otra.clave'], 'valor');
  });
}
