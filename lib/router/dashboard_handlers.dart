import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/providers/auth_provider.dart';
import 'package:nutri_kids_movil/ui/views/add_user_view.dart';
import 'package:nutri_kids_movil/ui/views/dashboard_view.dart';
import 'package:nutri_kids_movil/ui/views/food_history_view.dart';
import 'package:nutri_kids_movil/ui/views/history_meal_detail_view.dart';
import 'package:nutri_kids_movil/ui/views/login_view.dart';
import 'package:nutri_kids_movil/ui/views/meal_detail_view.dart';
import 'package:nutri_kids_movil/ui/views/recommendations_view.dart';
import 'package:provider/provider.dart';

class DashboardHandlers {
  static Handler dashboard = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final authProvider = Provider.of<AuthProvider>(context!, listen: false);
      if(authProvider.authStatus == AuthStatus.notAuthenticated){
        return LoginView();
      }
      return const DashboardView();
    },
  );
  static Handler mealDetailView = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    final authProvider = Provider.of<AuthProvider>(context!, listen: false);
      if(authProvider.authStatus == AuthStatus.notAuthenticated){
        return LoginView();
      }
    final args = context?.settings?.arguments as Map<String, dynamic>? ?? {};
    final tipo = args['tipo'] ?? '';
    final data = args['data'] ?? {};

    return MealDetailView(tipo: tipo, data: data);
  },
);

  static Handler addUserView = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final authProvider = Provider.of<AuthProvider>(context!, listen: false);
      if(authProvider.authStatus == AuthStatus.notAuthenticated){
        return LoginView();
      }
      // Aquí iría la lógica para retornar la vista de agregar usuario
      return AddUserView();
    },
  );
  
  static Handler recommendationsView = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final authProvider = Provider.of<AuthProvider>(context!, listen: false);
      if(authProvider.authStatus == AuthStatus.notAuthenticated){
        return LoginView();
      }
      final args = context?.settings?.arguments as Map<String, dynamic>? ?? {};
      final String userId = args['userId'] ?? '';
      final List<Map<String, dynamic>> recommendations = List<Map<String, dynamic>>.from(args['recommendations'] ?? []);

      return RecommendationsView(
        userId: userId,
        recommendations: recommendations,
      );
    },
  );

  static Handler foodHistoryView = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      final authProvider = Provider.of<AuthProvider>(context!, listen: false);
      if(authProvider.authStatus == AuthStatus.notAuthenticated){
        return LoginView();
      }
      // Aquí iría la lógica para retornar la vista de historial de comidas
      return const FoodHistoryView();
    },
  );

  static Handler foodHistoryDetailView = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    final authProvider = Provider.of<AuthProvider>(context!, listen: false);
    if (authProvider.authStatus == AuthStatus.notAuthenticated) {
      return LoginView();
    }

    final args = context.settings?.arguments as Map<String, dynamic>? ?? {};
    final date = args['date'] ?? '';
    final plan = args['plan'] ?? {};

    return HistoryMealDetailView(
      tipo: 'Plan diario',
      data: {
        'fecha': date,
        'plan': plan,
      },
    );
  },
);

}