import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutri_kids_movil/providers/dropdown_provider.dart';
import 'package:nutri_kids_movil/services/apis/dashboard_service.dart';
import 'package:nutri_kids_movil/services/hive_services.dart';
import 'package:provider/provider.dart';

class MealDetailView extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> data;

  const MealDetailView({super.key, required this.tipo, required this.data});

  @override
  State<MealDetailView> createState() => _MealDetailViewState();
}

class _MealDetailViewState extends State<MealDetailView> {
  final Set<String> _selectedIngredients = {};

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final nutricion = data['nutricion'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tipo[0].toUpperCase() + widget.tipo.substring(1),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Imagen principal
            Stack(
              children: [
                Image.network(
                  data['imagen'],
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.1),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 20,
                  right: 20,
                  child: Text(
                    data['plato'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                          color: Colors.black38,
                          offset: Offset(1, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                data['descripcion'],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey[800],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Información nutricional
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _nutrientCard('🔥 Calorías', '${nutricion['calorias']} kcal'),
                  _nutrientCard('💪 Proteínas', '${nutricion['proteinas']} g'),
                  _nutrientCard(
                    '🍞 Carbohidratos',
                    '${nutricion['carbohidratos']} g',
                  ),
                  _nutrientCard('🥑 Grasas', '${nutricion['grasas']} g'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Ingredientes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ingredientes',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            ...List.generate((data['ingredientes'] as List).length, (i) {
              final ing = data['ingredientes'][i];
              final isSelected = _selectedIngredients.contains(ing);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedIngredients.remove(ing);
                    } else {
                      _selectedIngredients.add(ing);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.green.withOpacity(0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey.shade300,
                      width: 1.3,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ing,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 30),

            // Botones finales
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _likeButton(
                    icon: Icons.thumb_up_alt_rounded,
                    label: "Me gusta",
                    color: Colors.green,
                    onPressed: () async {
                      try{
                      await onClick(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Añadido a tus comidas favoritas! 💚'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      } catch(e){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al procesar la solicitud: $e'),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    }
                    },
                  ),
                  _likeButton(
                    icon: Icons.thumb_down_alt_rounded,
                    label: "No me gusta",
                    color: Colors.redAccent,
                    onPressed: () async{
                      try{
                      await onClick(false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Entendido, no te la mostraremos más 🍅',
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      } catch(e){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al procesar la solicitud: $e'),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _nutrientCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _likeButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<bool> onClick(bool value) async {
    try{

    HiveServices hiveServices = HiveServices();
    final data = hiveServices.getData('users'); // sin cast directo
    print('Datos obtenidos de Hive: $data');

    if (data == null || (data as List).isEmpty) {
      print('⚠️ No hay usuarios guardados en Hive');
      return false;
    }

    // 🔹 Convertir de List<dynamic> → List<Map<String, dynamic>>
    final List<Map<String, dynamic>> users = (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final dropdownProvider = Provider.of<DropdownProvider>(
      context,
      listen: false,
    );
    Map<String, dynamic> userSelected = users.firstWhere(
      (element) => element['name'] == dropdownProvider.selectedValue,
    );
    DashboardService dashboardService = DashboardService();
    await dashboardService.likeOrDislikeMeal(
      userSelected['id'],
      _selectedIngredients.toList(),
      value,
    );
    return true;
    } catch(e){
      throw Exception('Error al procesar la solicitud: $e');
    }
  }
}
