import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/providers/auth_provider.dart';
import 'package:nutri_kids_movil/providers/loading_provider.dart';
import 'package:nutri_kids_movil/router/router.dart';
import 'package:nutri_kids_movil/services/hive_services.dart';
import 'package:nutri_kids_movil/services/local_storage.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:nutri_kids_movil/ui/layouts/auth/auth_layout.dart';
import 'package:nutri_kids_movil/ui/layouts/dashboard/dashboard_layout.dart';
import 'package:nutri_kids_movil/ui/layouts/splash/splash_layout.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.configurePrefs();
  await HiveServices.initHive();
  Flurorouter.configureRoutes();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Optionally log to a service like Sentry or Firebase Crashlytics
    print('Caught Flutter error: ${details.exception}');
  };
  runApp(const AppState());
}

class AppState extends StatefulWidget {
  const AppState({super.key});

  @override
  State<AppState> createState() => _AppStateState();
}

class _AppStateState extends State<AppState> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create:  (_) => AuthProvider(), lazy: false),
        ChangeNotifierProvider(create:  (_) => LoadingProvider()),
      ],
      child: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Nutri Kids',
      initialRoute: '/',
      onGenerateRoute: Flurorouter.router.generator,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      builder: (context, child) {
        final authProvider = Provider.of<AuthProvider>(context);
        print('Auth Status: ${authProvider.authStatus}');
        if (authProvider.authStatus == AuthStatus.checking) {
          return const SplashLayout();
        } else if (authProvider.authStatus == AuthStatus.authenticated) {
          return  DashboardLayout(child: child!);
          
        } else {
          
          return AuthLayout(child: child!);
        }
      },
    );
  }
}
