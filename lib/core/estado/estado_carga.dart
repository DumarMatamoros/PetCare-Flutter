/// Estado de una pantalla que carga datos.
///
/// ```dart
/// switch (vm.estado) {
///   Cargando() => const Center(child: CircularProgressIndicator()),
///   Datos(:final valor) => ListaMascotas(valor),
///   Vacio() => const VistaVacia(mensaje: 'Aún no tienes mascotas'),
///   ErrorCarga(:final mensaje) => VistaError(mensaje: mensaje, alReintentar: vm.cargar),
/// }
/// ```
sealed class EstadoCarga<T> {
  const EstadoCarga();
}

class Cargando<T> extends EstadoCarga<T> {
  const Cargando();
}

class Datos<T> extends EstadoCarga<T> {
  const Datos(this.valor);
  final T valor;
}

class Vacio<T> extends EstadoCarga<T> {
  const Vacio();
}

class ErrorCarga<T> extends EstadoCarga<T> {
  const ErrorCarga(this.mensaje);
  final String mensaje;
}
