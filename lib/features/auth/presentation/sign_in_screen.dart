import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'auth_formulario_view_model.dart';
import 'login_view.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modelo = context.watch<SignInViewModel>();
    return LoginView(
      cargando: modelo.enviando,
      error: modelo.error,
      errorCorreo: modelo.errorCorreo,
      errorContrasena: modelo.errorContrasena,
      onIngresar: modelo.iniciarSesion,
      onIrARegistro: () => context.go('/sign-up'),
    );
  }
}
