import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/helpers/ui_helper.dart';
import 'package:nutri_kids_movil/providers/loading_provider.dart';
import 'package:nutri_kids_movil/services/apis/auth_service.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:provider/provider.dart';
import 'reset_password_view.dart';

class VerifyPinView extends StatefulWidget {
  final String email;

  const VerifyPinView({super.key, required this.email});

  @override
  State<VerifyPinView> createState() => _VerifyPinViewState();
}

class _VerifyPinViewState extends State<VerifyPinView> {
  final int pinLength = 6;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < pinLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  Future<void> _verifyPin() async {
      LoadingProvider loadingProvider = Provider.of<LoadingProvider>(context, listen: false);
    if (_pin.length != pinLength) {
      UiHelper.showInfo(context, 'Ingresa los 6 dígitos del PIN');
      return;
    }

      loadingProvider.show();

    try {
      // Aquí llamas a tu API para verificar el PIN
      final success = await AuthService().verifyPin(widget.email, _pin);

      if (success) {
        
        NavigationService.navigateTo('/reset-password', arguments: {
          'email': widget.email,
        });
      } else {
        UiHelper.showError(context, 'PIN inválido. Intenta de nuevo.');
        for (var c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
      }
    } finally {
      loadingProvider.hide();
    }
  }

  Widget _buildPinField(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < pinLength - 1) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Ingresa el PIN de 6 dígitos enviado a tu correo',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(pinLength, (index) => _buildPinField(index)),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:  _verifyPin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFF1d7151),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Verificar PIN',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
