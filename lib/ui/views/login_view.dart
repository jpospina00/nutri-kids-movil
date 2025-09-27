import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/helpers/ui_helper.dart';
import 'package:nutri_kids_movil/providers/loading_provider.dart';
import 'package:nutri_kids_movil/router/router.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final loadingProvider = Provider.of<LoadingProvider>(context);

    return Column(
      children: [
        // Campo de email
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Correo electrónico",
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),

        // Campo de contraseña
        TextFormField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Contraseña",
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 24),

        // Botón login
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: llamar a tu AuthProvider para login
              loadingProvider.show();
              Future.delayed(const Duration(seconds: 2), () {
                loadingProvider.hide();
                UiHelper.showSuccess(context, 'Inicio de sesión exitoso');
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFF1d7151), // verde de tu logo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Iniciar sesión",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Botón de olvidé mi contraseña
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, Flurorouter.forgotPasswordRoute);
          },
          child: const Text(
            "¿Olvidaste tu contraseña?",  
            style: TextStyle(color: Color(0xFF1d7151)),
          ),
        ),
      ],
    );
  }
}