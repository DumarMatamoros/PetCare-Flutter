import 'package:flutter/material.dart';

/// La huella con corazón del ícono de la app (`ic_launcher_foreground` en Kotlin),
/// dibujada a mano para no depender de un paquete de SVG.
///
/// Es decorativa: los lectores de pantalla la ignoran.
class LogoPetCare extends StatelessWidget {
  const LogoPetCare({super.key, this.tamano = 42});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: tamano,
        child: CustomPaint(
          painter: _HuellaPainter(Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _HuellaPainter extends CustomPainter {
  _HuellaPainter(this.color);

  final Color color;

  // El vector original mide 108 x 108 (zona segura de los íconos adaptativos)
  static const _lienzo = 108.0;

  @override
  void paint(Canvas canvas, Size size) {
    final pintura = Paint()..color = color;

    canvas
      ..save()
      ..scale(size.width / _lienzo, size.height / _lienzo)
      ..translate(0, -2);

    // Los cuatro dedos
    for (final dedo in const [
      (centro: Offset(29.5, 50), ancho: 14.0, alto: 18.0),
      (centro: Offset(44, 37.25), ancho: 15.0, alto: 22.5),
      (centro: Offset(64, 37.25), ancho: 15.0, alto: 22.5),
      (centro: Offset(78.5, 50), ancho: 14.0, alto: 18.0),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: dedo.centro, width: dedo.ancho, height: dedo.alto),
        pintura,
      );
    }

    // La almohadilla, con el corazón recortado
    final almohadilla = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(54, 51.5)
      ..cubicTo(47.5, 51.5, 43.6, 54.7, 41.6, 59.6)
      ..cubicTo(33.8, 61.4, 28.5, 66.5, 28.5, 73.5)
      ..cubicTo(28.5, 82.7, 38.4, 88.5, 54, 88.5)
      ..cubicTo(69.6, 88.5, 79.5, 82.7, 79.5, 73.5)
      ..cubicTo(79.5, 66.5, 74.2, 61.4, 66.4, 59.6)
      ..cubicTo(64.4, 54.7, 60.5, 51.5, 54, 51.5)
      ..close()
      ..moveTo(54, 78)
      ..cubicTo(51.4, 75.9, 46.5, 71.2, 46.5, 67.6)
      ..cubicTo(46.5, 64.4, 48.5, 62.3, 51.1, 62.3)
      ..cubicTo(52.4, 62.3, 53.4, 63, 54, 64)
      ..cubicTo(54.6, 63, 55.6, 62.3, 56.9, 62.3)
      ..cubicTo(59.5, 62.3, 61.5, 64.4, 61.5, 67.6)
      ..cubicTo(61.5, 71.2, 56.6, 75.9, 54, 78)
      ..close();
    canvas
      ..drawPath(almohadilla, pintura)
      ..restore();
  }

  @override
  bool shouldRepaint(_HuellaPainter anterior) => anterior.color != color;
}
