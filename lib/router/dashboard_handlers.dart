import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/ui/views/dashboard_view.dart';
import 'package:nutri_kids_movil/ui/views/meal_detail_view.dart';

class DashboardHandlers {
  static Handler dashboard = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const DashboardView();
    },
  );
  static Handler mealDetailView = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    final args = context?.settings?.arguments as Map<String, dynamic>? ?? {};
    final tipo = args['tipo'] ?? '';
    final data = args['data'] ?? {};

    return MealDetailView(tipo: tipo, data: data);
  },
);
  
}