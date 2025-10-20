import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/helpers/ui_helper.dart';
import 'package:nutri_kids_movil/providers/auth_provider.dart';
import 'package:nutri_kids_movil/providers/loading_provider.dart';
import 'package:nutri_kids_movil/router/router.dart';
import 'package:nutri_kids_movil/services/apis/auth_service.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loadingProvider = Provider.of<LoadingProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Correo electrónico",
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo electrónico';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) {
                return 'Por favor ingresa un correo electrónico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
      
          // Campo de contraseña
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Contraseña",
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
      
          // Botón login
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  loadingProvider.show();
                  final success = await AuthService().login(_emailController.text, _passwordController.text);
                  print(  "Login success: $success");
                  loadingProvider.hide();
                  if (success) {
                    UiHelper.showSuccess(context, 'Inicio de sesión exitoso');
                    NavigationService.replaceTo(Flurorouter.dashboardRoute);
                  } else {
                    UiHelper.showError(context, 'Error en el inicio de sesión. Verifica tus credenciales.');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF1d7151), // verde de tu logo
                foregroundColor: Colors.white,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("¿No tienes una cuenta?"),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, Flurorouter.registerRoute);
                },
                child: const Text(
                  "Regístrate",
                  style: TextStyle(color: Color(0xFF1d7151), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
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
      ),
    );
  }
}