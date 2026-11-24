import 'package:flutter/material.dart';

/// Las tres pestañas principales (Inicio, Mis mascotas, Ajustes) con la
/// navegación que mejor aprovecha la pantalla, como en `PetCareApp` de Kotlin:
///
/// - Teléfono en vertical: barra inferior.
/// - Teléfono en horizontal o tablet (ancho >= 600): riel a la izquierda, para
///   no gastar en la barra la poca altura que hay.
///
/// Pensado para el `StatefulShellRoute` de go_router del proyecto base:
///
/// ```dart
/// builder: (context, state, shell) => NavegacionPrincipal(
///   indiceActual: shell.currentIndex,
///   onSeleccionar: (i) =>
///       shell.goBranch(i, initialLocation: i == shell.currentIndex),
///   child: shell,
/// ),
/// ```
class NavegacionPrincipal extends StatelessWidget {
  const NavegacionPrincipal({
    super.key,
    required this.indiceActual,
    required this.onSeleccionar,
    required this.child,
  });

  final int indiceActual;
  final ValueChanged<int> onSeleccionar;
  final Widget child;

  static const anchoParaRiel = 600.0;

  static const _destinos = [
    (icono: Icons.home_outlined, activo: Icons.home, etiqueta: 'Inicio'),
    (icono: Icons.pets_outlined, activo: Icons.pets, etiqueta: 'Mascotas'),
    (
      icono: Icons.settings_outlined,
      activo: Icons.settings,
      etiqueta: 'Ajustes',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final usarRiel = MediaQuery.sizeOf(context).width >= anchoParaRiel;

    return Scaffold(
      body: Row(
        children: [
          if (usarRiel)
            SafeArea(
              right: false,
              child: NavigationRail(
                selectedIndex: indiceActual,
                onDestinationSelected: onSeleccionar,
                labelType: NavigationRailLabelType.all,
                scrollable: true,
                destinations: [
                  for (final destino in _destinos)
                    NavigationRailDestination(
                      icon: Icon(destino.icono),
                      selectedIcon: Icon(destino.activo),
                      label: Text(destino.etiqueta),
                    ),
                ],
              ),
            ),
          Expanded(
            key: const ValueKey('contenido-pestanas'),
            child: Builder(
              builder: (context) => MediaQuery.removePadding(
                context: context,
                removeLeft: usarRiel,
                child: child,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: usarRiel
          ? null
          : NavigationBar(
              selectedIndex: indiceActual,
              onDestinationSelected: onSeleccionar,
              destinations: [
                for (final destino in _destinos)
                  NavigationDestination(
                    icon: Icon(destino.icono),
                    selectedIcon: Icon(destino.activo),
                    label: destino.etiqueta,
                  ),
              ],
            ),
    );
  }
}
