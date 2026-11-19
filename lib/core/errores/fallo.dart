import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Error que los repositorios lanzan hacia los ViewModels.
///
/// Cada `RepositorioImpl` atrapa las excepciones del SDK y de red y las
/// convierte en un [Fallo] con un mensaje en español listo para mostrar.
abstract class Fallo implements Exception {
  const Fallo(this.mensaje);

  final String mensaje;

  @override
  String toString() => '$runtimeType: $mensaje';
}

class FalloRed extends Fallo {
  const FalloRed([super.mensaje = 'Sin conexión a internet']);
}

class FalloSesion extends Fallo {
  const FalloSesion(super.mensaje);
}

class FalloServidor extends Fallo {
  const FalloServidor([super.mensaje = 'Ocurrió un error. Intenta de nuevo.']);
}

/// Indica si [error] se debe a que no hay conexión o el servidor no respondió.
///
/// Sirve para cualquier `RepositorioImpl`: cuando falla la red, el SDK de
/// Supabase deja pasar estas excepciones en lugar de las suyas propias.
bool esErrorDeRed(Object error) =>
    error is SocketException ||
    error is HandshakeException ||
    error is TimeoutException ||
    error is http.ClientException ||
    error is AuthRetryableFetchException;
