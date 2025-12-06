import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/helpers/uitls.dart';
import 'package:nutri_kids_movil/models/user_model.dart';
import 'package:nutri_kids_movil/providers/dropdown_provider.dart';
import 'package:nutri_kids_movil/providers/loading_provider.dart';
import 'package:nutri_kids_movil/router/router.dart';
import 'package:nutri_kids_movil/services/apis/dashboard_service.dart';
import 'package:nutri_kids_movil/services/hive_services.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Map<String, dynamic>? _meals;
  String? _lastSelectedValue; // Para detectar cambios en el dropdown

  @override
  void initState() {
    super.initState();
    _getMeals(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final dropdownProvider = Provider.of<DropdownProvider>(context);
    // Solo recargamos si cambió el valor
    if (_lastSelectedValue != dropdownProvider.selectedValue) {
      _lastSelectedValue = dropdownProvider.selectedValue;
      _getMeals(context);
    }
  }

  Future<void> _getMeals(BuildContext context) async {
    try {
      HiveServices hiveServices = HiveServices();
      final data = hiveServices.getData('users');
      print('Datos obtenidos de Hive: $data');

      if (data == null || (data as List).isEmpty) {
        print('⚠️ No hay usuarios guardados en Hive');
        return;
      }

      final List<Map<String, dynamic>> users = (data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final dropdownProvider =
          Provider.of<DropdownProvider>(context, listen: false);
      Map<String, dynamic> userSelected = users.firstWhere(
        (element) => element['name'] == dropdownProvider.selectedValue,
      );

      print('Usuario seleccionado en DashboardView: $userSelected');

      DashboardService dashboardService = DashboardService();
      Map<String, dynamic> meals =
          await dashboardService.getMeals(userSelected['id']);
      print('Comidas obtenidas: $meals');

      if (!mounted) return;
      setState(() {
        _meals = meals['plan'] as Map<String, dynamic>?;
      });
    } catch (e) {
      print('Error al obtener comidas: $e');
    }
  }

  Future<void> _generateMeals(BuildContext context) async {
    final loadingProvider = Provider.of<LoadingProvider>(context, listen: false);

    loadingProvider.show(
      messages: [
        'Preparando su comida...',
        'Agregando ingredientes...',
        'Emplatando con amor...',
      ],
    );

    try {
      
      HiveServices hiveServices = HiveServices();
       final data = hiveServices.getData('users'); // sin cast directo
    print('Datos obtenidos de Hive: $data');

    if (data == null || (data as List).isEmpty) {
      print('⚠️ No hay usuarios guardados en Hive');
      return;
    }

    // 🔹 Convertir de List<dynamic> → List<Map<String, dynamic>>
    final List<Map<String, dynamic>> users = (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

       final dropdownProvider =
              Provider.of<DropdownProvider>(context, listen: false);
       Map<String, dynamic> userSelected = users.firstWhere((element) => element['name'] == dropdownProvider.selectedValue);
       print(userSelected);
      DashboardService dashboardService = DashboardService();
      Map<String, dynamic> meals = await dashboardService.generateMeals(userSelected['id']);
      if (!mounted) return;

      setState(() {
        _meals = meals['plan'] as Map<String, dynamic>;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Comidas generadas exitosamente! 🍽️'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar comidas: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) loadingProvider.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final dropdownProvider =
        Provider.of<DropdownProvider>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              '🍽️ Comidas diarias',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontFamily: 'MyriadPro',
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Si no hay comidas generadas
            if (_meals == null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Aún no ha generado sus comidas diarias.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontFamily: 'MyriadPro',
                    ),
                  ),
                  const SizedBox(height: 30),
                  _generateButton(screen, context),
                ],
              )
            else
              Column(
                children: [
                  // 🔹 Mostrar cards de desayuno, almuerzo y cena
                  for (var entry in _meals!.entries)
                    _mealCard(context,entry.key, entry.value),
                   _generateButton(screen, context),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _generateButton(Size screen, BuildContext context) {
    return Container(
      width: screen.width * 0.7,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 6,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        onPressed: () => _generateMeals(context),
        child: const Text(
          'Generar comidas diarias',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'MyriadPro',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _mealCard(BuildContext context, String tipo, dynamic data) {
  return InkWell(
    borderRadius: BorderRadius.circular(15),
    onTap: () {
      NavigationService.navigateTo(
        Flurorouter.mealDetailViewRoute,
        arguments: {
          'tipo': tipo,
          'data': data,
        },
      );
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tipo[0].toUpperCase() + tipo.substring(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                data['imagen'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data['plato'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              data['descripcion'],
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              '🍎 Nutrición: ${data['nutricion']['calorias']} kcal | '
              '${data['nutricion']['proteinas']}g proteínas | '
              '${data['nutricion']['carbohidratos']}g carbos | '
              '${data['nutricion']['grasas']}g grasas',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
