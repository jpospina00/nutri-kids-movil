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
  Map<String, dynamic>? _meals; // Guardará el plan recibido del backend

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
      // 🔹 Aquí deberías usar tu servicio real, esto es un ejemplo con delay
      await Future.delayed(const Duration(seconds: 4));
      
      HiveServices hiveServices = HiveServices();
       List<Map<String, dynamic>> users = await hiveServices.getData('users');
       final dropdownProvider =
              Provider.of<DropdownProvider>(context, listen: false);
       Map<String, dynamic> userSelected = users.firstWhere((element) => element['name'] == dropdownProvider.selectedValue);
       print(userSelected);
      DashboardService dashboardService = DashboardService();
      Map<String, dynamic> meals = await dashboardService.generateMeals(userSelected['id']);


      // Simulación de respuesta del backend
      // const responseJson = {
      //   "ok": true,
      //   "plan": {
      //     "desayuno": {
      //       "plato": "Tostada de plátano con mermelada de fresa",
      //       "descripcion":
      //           "Una tostada integral rellena con mermelada de fresa y una rodaja de plátano.",
      //       "ingredientes": [
      //         "1 tosta integral",
      //         "1 plátano",
      //         "1 cucharadita de mermelada de fresa"
      //       ],
      //       "nutricion": {
      //         "calorias": 250,
      //         "carbohidratos": 40,
      //         "proteinas": 2,
      //         "grasas": 5
      //       },
      //       "imagen":
      //           "https://pixabay.com/get/g8ea958957b4a292e20832642ded3feb66de40ccfb37bbdbccda9134e41f2279efc2138f337ff01db1f54858660586de1b14d9a5fedf25f911e73711c4671acb6_640.jpg"
      //     },
      //     "almuerzo": {
      //       "plato": "Pescado frito con arroz y ensalada de aguacate",
      //       "descripcion":
      //           "Pescado frito acompañado de arroz blanco y una ensalada fresca de aguacate.",
      //       "ingredientes": [
      //         "150g pescado frito (pargo o tilapia)",
      //         "1 taza de arroz blanco",
      //         "1 taza de ensalada (aguacate, tomate)"
      //       ],
      //       "nutricion": {
      //         "calorias": 550,
      //         "carbohidratos": 60,
      //         "proteinas": 35,
      //         "grasas": 15
      //       },
      //       "imagen":
      //           "https://pixabay.com/get/g8c16bd0d37086969a201b580c9bcdd7aa11a866ade58a1494c8e401ebd858b526b91a22a5881f853e5d6ce1cae85c77b93246de6b5984e51fbc1952f6b7ac124_640.jpg"
      //     },
      //     "cena": {
      //       "plato": "Sopa de frutas con quinoa",
      //       "descripcion": "Una sopa ligera de frutas acompañada de quinoa.",
      //       "ingredientes": [
      //         "1 taza de sopa de frutas (banana, mango)",
      //         "1/2 taza de quinoa",
      //         "1 cucharadita de aceite"
      //       ],
      //       "nutricion": {
      //         "calorias": 450,
      //         "carbohidratos": 60,
      //         "proteinas": 10,
      //         "grasas": 10
      //       },
      //       "imagen":
      //           "https://pixabay.com/get/g3ac924ccd894e8b25bf405e944362efd30d50841ade566348a7bfff5129926f35f45819a793ab699454a7c324a659c6b5205e84f4d5695f5269c411dea318ca4_640.jpg"
      //     }
      //   }
      // };

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
