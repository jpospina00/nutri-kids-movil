import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/helpers/ui_helper.dart';
import 'package:nutri_kids_movil/providers/loading_provider.dart';
import 'package:nutri_kids_movil/services/apis/auth_service.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:provider/provider.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  const ResetPasswordView({super.key, required this.email});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
   GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loadinProvider = Provider.of<LoadingProvider>(context, listen: false);
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Campo de email
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Nueva contraseña",
              prefixIcon: Icon(Icons.lock_outline),
            ),
            controller: passwordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nueva contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Campo de confirmación de contraseña
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Confirmar nueva contraseña",
              prefixIcon: Icon(Icons.lock_outline),
            ),
            controller: confirmPasswordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor confirma tu nueva contraseña';
              }
              if (value != passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                formKey.currentState?.validate();
                loadinProvider.show();
                bool success = await AuthService().resetPassword(widget.email, passwordController.text);
                if (success) {
                  UiHelper.showSuccess(context, 'Contraseña restablecida con éxito');
                  loadinProvider.hide();
                  NavigationService.navigateTo('/login');
                } else {
                  loadinProvider.hide();
                  UiHelper.showError(context, 'Error al restablecer la contraseña');
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
                "Restablecer contraseña",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}