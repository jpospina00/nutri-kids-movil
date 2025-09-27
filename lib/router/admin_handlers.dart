import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:nutri_kids_movil/providers/auth_provider.dart';
import 'package:nutri_kids_movil/ui/views/dashboard_view.dart';
import 'package:nutri_kids_movil/ui/views/forgot_password_view.dart';
import 'package:nutri_kids_movil/ui/views/login_view.dart';
import 'package:nutri_kids_movil/ui/views/reset_password_view.dart';
import 'package:nutri_kids_movil/ui/views/verify_pin_view.dart';
import 'package:provider/provider.dart';

class AdminHandlers {
  static Handler login = Handler(handlerFunc: (context, parameters) {
    final authProvider = Provider.of<AuthProvider>(context!);
    if (authProvider.authStatus == AuthStatus.authenticated) {
      // return const AdminDashboardPage();
      return const DashboardView();
    } else {
      // return const AdminLoginPage();
      return const LoginView();
    }
  });
  
  static Handler forgotPassword = Handler(handlerFunc: (context, parameters) {
    final authProvider = Provider.of<AuthProvider>(context!);
    if (authProvider.authStatus == AuthStatus.authenticated) {
      // return const AdminDashboardPage();
      return const DashboardView();
    } else {
      return const ForgotPasswordView();
    }
  });

  static Handler verifyPin = Handler(handlerFunc: (context, parameters) {
    final authProvider = Provider.of<AuthProvider>(context!);
    if (authProvider.authStatus == AuthStatus.authenticated) {
      // return const AdminDashboardPage();
      return const DashboardView();
    } else {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final email = args != null && args.containsKey('email') ? args['email'] as String : '';
      print(  "Email in verifyPin handler: $email");
      return VerifyPinView(email: email);
    }
  });

  static Handler resetPassword = Handler(handlerFunc: (context, parameters) {
    final authProvider = Provider.of<AuthProvider>(context!);
    if (authProvider.authStatus == AuthStatus.authenticated) {
      // return const AdminDashboardPage();
      return const DashboardView();
    } else {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final email = args != null && args.containsKey('email') ? args['email'] as String : '';
      return ResetPasswordView(email: email);
    }
  });
}