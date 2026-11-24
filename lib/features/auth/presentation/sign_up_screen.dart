import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'auth_formulario_view_model.dart';
import 'registro_view.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<SignUpViewModel>();
    return RegistroView(
      cargando: modelo.enviando,
      error: modelo.error,
      errorCorreo: modelo.errorCorreo,
      errorContrasena: modelo.errorContrasena,
      errorConfirmacion: modelo.errorConfirmacion,
      onRegistrarse: modelo.registrar,
      onIrALogin: () => context.go('/sign-in'),
    );
  }
}
