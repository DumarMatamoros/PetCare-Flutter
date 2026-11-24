import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/estado/estado_carga.dart';
import 'inicio_view.dart';
import 'inicio_view_model.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  GoRouterDelegate? _delegado;
  bool _visible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final delegado = GoRouter.of(context).routerDelegate;
    if (identical(delegado, _delegado)) return;
    _delegado?.removeListener(_alNavegar);
    _delegado = delegado;
    _visible = _estaEnInicio(delegado);
    delegado.addListener(_alNavegar);
  }

  bool _estaEnInicio(GoRouterDelegate delegado) {
    final rutas = delegado.currentConfiguration;
    return rutas.isNotEmpty && rutas.last.matchedLocation == '/inicio';
  }

  void _alNavegar() {
    final visible = _estaEnInicio(_delegado!);
    final regresa = visible && !_visible;
    _visible = visible;
    if (!regresa) return;

    // La rama de Inicio se mantiene montada al cambiar de pestaña.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _visible) context.read<InicioViewModel>().cargar();
    });
  }

  @override
  void dispose() {
    _delegado?.removeListener(_alNavegar);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<InicioViewModel>();
    final estado = modelo.estado;
    return InicioView(
      cargando: estado is Cargando<int>,
      error: estado is ErrorCarga<int> ? estado.mensaje : null,
      totalMascotas: estado is Datos<int> ? estado.valor : 0,
      onVerMascotas: () => context.go('/mascotas'),
      onRegistrarMascota: () => context.go('/mascotas/nueva'),
      onVerCatalogo: () => context.push('/tipos-cuidado'),
      onReintentar: modelo.cargar,
    );
  }
}
