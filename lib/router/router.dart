import 'package:fluro/fluro.dart';
import 'package:nutri_kids_movil/router/admin_handlers.dart';

class Flurorouter {
  static final FluroRouter router = FluroRouter();

  static String rootRoute = '/';
  static String loginRoute = '/login';
  static String forgotPasswordRoute = '/forgot-password';
  static String verifyPinRoute = '/verify-pin';
  static String resetPasswordRoute = '/reset-password';

  static void configureRoutes() {
    router.define(rootRoute, handler: AdminHandlers.login, transitionType: TransitionType.inFromRight);
    router.define(loginRoute, handler: AdminHandlers.login, transitionType: TransitionType.inFromRight);
    router.define(forgotPasswordRoute, handler: AdminHandlers.forgotPassword, transitionType: TransitionType.inFromRight);
    router.define(verifyPinRoute, handler: AdminHandlers.verifyPin, transitionType: TransitionType.inFromRight);
    router.define(resetPasswordRoute, handler: AdminHandlers.resetPassword, transitionType: TransitionType.inFromRight);
  }
}