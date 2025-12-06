import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/helpers/ui_helper.dart';
import 'package:nutri_kids_movil/providers/loading_provider.dart';
import 'package:nutri_kids_movil/router/router.dart';
import 'package:nutri_kids_movil/services/apis/auth_service.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:provider/provider.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  void submit() async {
    if (formKey.currentState!.validate()) {
      BuildContext cdx = NavigationService.navigatorKey.currentContext!;
      LoadingProvider loadingProvider = Provider.of<LoadingProvider>(cdx, listen: false);
      print("Email: ${emailController.text}");

      loadingProvider.show();
      bool success = await AuthService().forgotPassword(emailController.text);
      loadingProvider.hide();
      if (success) {
        NavigationService.navigateTo(Flurorouter.verifyPinRoute, arguments: {
          'email': emailController.text,
        });
      } else {
        UiHelper.showError(cdx, 'Error al enviar el correo');
      }
    }
  }
}