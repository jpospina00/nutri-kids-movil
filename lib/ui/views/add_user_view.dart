import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutri_kids_movil/providers/loading_provider.dart';
import 'package:nutri_kids_movil/router/router.dart';
import 'package:nutri_kids_movil/services/apis/dashboard_service.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:provider/provider.dart';

class AddUserView extends StatefulWidget {
  const AddUserView({super.key});

  @override
  State<AddUserView> createState() => _AddUserViewState();
}

class _AddUserViewState extends State<AddUserView> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _likesController = TextEditingController();
  final TextEditingController _dislikesController = TextEditingController();

  String _activityLevel = 'media';
  String _goal = 'mantener';

  void _saveForm() async{
    if (_formKey.currentState!.validate()) {
      final loadingProvider = Provider.of<LoadingProvider>(context, listen: false);

    loadingProvider.show(
      messages: [
        'Preparando su comida...',
        'Agregando ingredientes...',
        'Emplatando con amor...',
      ],
    );

      final userData = {
        'name': _nameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()),
        'height': double.tryParse(_heightController.text.trim()),
        'weight': double.tryParse(_weightController.text.trim()),
        'activityLevel': _activityLevel,
        'goal': _goal,
        'allergies': _allergiesController.text.isNotEmpty
            ? _allergiesController.text.split(',').map((e) => e.trim()).toList()
            : [],
        'likes': _likesController.text.isNotEmpty
            ? _likesController.text.split(',').map((e) => e.trim()).toList()
            : [],
        'dislikes': _dislikesController.text.isNotEmpty
            ? _dislikesController.text.split(',').map((e) => e.trim()).toList()
            : [],
      };
      print('Nuevo usuario a crear: $userData');
      DashboardService dashboardService = DashboardService();
      String? createUserResultId = await dashboardService.createUser(
        _nameController.text.trim(),
        _lastNameController.text.trim(),
        int.parse(_ageController.text.trim()),
        double.parse(_heightController.text.trim()),
        double.parse(_weightController.text.trim()),
        _activityLevel,
        _goal,
        _allergiesController.text.isNotEmpty
            ? _allergiesController.text.split(',').map((e) => e.trim()).toList()
            : [],
        _likesController.text.isNotEmpty
            ? _likesController.text.split(',').map((e) => e.trim()).toList()
            : [],
        _dislikesController.text.isNotEmpty
            ? _dislikesController.text.split(',').map((e) => e.trim()).toList()
            : [],
      );
      print('✅ Datos del usuario: $userData');
      if (createUserResultId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el usuario ❌'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        loadingProvider.hide();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario guardado correctamente 🥗'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      List? recommendations = await dashboardService.generateRecommendations(createUserResultId);
      print('Recomendaciones generadas: $recommendations');
      if(recommendations.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al generar recomendaciones ❌'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        loadingProvider.hide();
        return;
      }
      loadingProvider.hide();
      NavigationService.navigateTo(
    Flurorouter.recommendationsViewRoute,
    arguments: {
      'userId': createUserResultId,
      'recommendations': recommendations,
    },
  );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Agregar usuario',
          style: TextStyle(
            fontFamily: 'MyriadPro',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🧍 DATOS PERSONALES
              _sectionCard(
                icon: Icons.person_outline,
                title: 'Datos personales',
                children: [
                  _buildTextField(_nameController, 'Nombre', 'Ingresa el nombre'),
                  _buildTextField(_lastNameController, 'Apellido', 'Ingresa el apellido'),
                  _buildTextField(
                    _ageController,
                    'Edad',
                    'Ej: 25',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _heightController,
                          'Altura (m)',
                          'Ej: 1.75',
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          _weightController,
                          'Peso (kg)',
                          'Ej: 70.5',
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 🏃 ACTIVIDAD Y OBJETIVO
              _sectionCard(
                icon: Icons.fitness_center,
                title: 'Actividad y objetivo',
                children: [
                  _buildDropdown(
                    'Nivel de actividad',
                    _activityLevel,
                    ['baja', 'media', 'alta', 'muy alta'],
                    (value) => setState(() => _activityLevel = value!),
                  ),
                  _buildDropdown(
                    'Objetivo físico',
                    _goal,
                    ['mantener', 'bajar', 'subir'],
                    (value) => setState(() => _goal = value!),
                  ),
                 
                ],
              ),

              // 🥦 PREFERENCIAS ALIMENTICIAS
              _sectionCard(
                icon: Icons.restaurant_menu,
                title: 'Preferencias alimenticias',
                children: [
                  _buildTextField(
                    _allergiesController,
                    'Alergias (separadas por comas)',
                    'Ej: maní, mariscos, gluten',
                  ),
                  _buildTextField(
                    _likesController,
                    'Comidas que le gustan',
                    'Ej: pollo, pasta, frutas',
                  ),
                  _buildTextField(
                    _dislikesController,
                    'Comidas que no le gustan',
                    'Ej: brócoli, pescado',
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // BOTÓN GUARDAR
              SizedBox(
                width: screen.width * 0.7,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _saveForm,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Guardar usuario',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'MyriadPro',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable widgets

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'MyriadPro',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo requerido';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String currentValue,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green),
          ),
        ),
        items: options
            .map((opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(opt[0].toUpperCase() + opt.substring(1)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
