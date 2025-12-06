import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutri_kids_movil/providers/loading_provider.dart';
import 'package:nutri_kids_movil/providers/dropdown_provider.dart';
import 'package:nutri_kids_movil/services/apis/dashboard_service.dart';
import 'package:nutri_kids_movil/services/hive_services.dart';

import 'package:provider/provider.dart';

class UpdateUserView extends StatefulWidget {
  const UpdateUserView({super.key});

  @override
  State<UpdateUserView> createState() => _UpdateUserViewState();
}

class _UpdateUserViewState extends State<UpdateUserView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _likesController = TextEditingController();
  final TextEditingController _dislikesController = TextEditingController();

  String _activityLevel = 'media';
  String _goal = 'mantener';

  Map<String, dynamic>? userSelected; // usuario seleccionado
  String userId = ""; // id real del usuario

  @override
  void initState() {
    super.initState();
    _loadUserFromHive();
  }

  Future<void> _loadUserFromHive() async {
    HiveServices hiveServices = HiveServices();
    final data = hiveServices.getData('users');

    if (data == null || (data as List).isEmpty) {
      print('⚠️ No hay usuarios en Hive');
      return;
    }

    final List<Map<String, dynamic>> users =
        (data as List).map((e) => Map<String, dynamic>.from(e)).toList();

    final dropdownProvider =
        Provider.of<DropdownProvider>(context, listen: false);

    userSelected = users.firstWhere(
      (e) => e['name'] == dropdownProvider.selectedValue,
      orElse: () => {},
    );

    if (userSelected == null || userSelected!.isEmpty) {
      print("⚠️ Usuario no encontrado");
      return;
    }

    userId = userSelected!['id'];

    _ageController.text = userSelected!['age'].toString();
    _heightController.text = userSelected!['height'].toString();
    _weightController.text = userSelected!['weight'].toString();

    _activityLevel = userSelected!['activityLevel'] ?? 'media';
    _goal = userSelected!['goal'] ?? 'mantener';

    _allergiesController.text = (userSelected!['allergies'] as List).join(', ');
    _likesController.text = (userSelected!['likes'] as List).join(', ');
    _dislikesController.text = (userSelected!['dislikes'] as List).join(', ');

    setState(() {});
  }

  void _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    final loadingProvider = Provider.of<LoadingProvider>(context, listen: false);
    loadingProvider.show(messages: [
      'Actualizando datos...',
      'Guardando cambios...',
      'Un momento...',
    ]);

    DashboardService service = DashboardService();

    bool ok = await service.updateUser(
      userId,
      int.parse(_ageController.text.trim()),
      double.parse(_heightController.text.trim()),
      double.parse(_weightController.text.trim()),
      _activityLevel,
      _goal,
      _split(_allergiesController),
      _split(_likesController),
      _split(_dislikesController),
    );

    loadingProvider.hide();

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar usuario ❌'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usuario actualizado correctamente ✔'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  List<String> _split(TextEditingController c) =>
      c.text.isNotEmpty ? c.text.split(',').map((e) => e.trim()).toList() : [];

  @override
  Widget build(BuildContext context) {
    if (userSelected == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Actualizar usuario',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _sectionCard(
                icon: Icons.person_outline,
                title: 'Datos personales',
                children: [
                  _disabledTextField("Nombre", userSelected!['name']),
                  _disabledTextField("Apellido", userSelected!['lastName']),
                ],
              ),
              _sectionCard(
                icon: Icons.monitor_weight,
                title: "Datos físicos",
                children: [
                  _buildTextField(
                    _ageController,
                    "Edad",
                    "Ej: 25",
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _heightController,
                          "Altura (m)",
                          "Ej: 1.75",
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          _weightController,
                          "Peso (kg)",
                          "Ej: 70.2",
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _sectionCard(
                icon: Icons.fitness_center,
                title: "Actividad y objetivo",
                children: [
                  _buildDropdown("Nivel de actividad", _activityLevel,
                      ['baja', 'media', 'alta', 'muy alta'], (v) {
                    setState(() => _activityLevel = v!);
                  }),
                  _buildDropdown(
                      "Objetivo", _goal, ['mantener', 'bajar', 'subir'], (v) {
                    setState(() => _goal = v!);
                  }),
                ],
              ),
              _sectionCard(
                icon: Icons.restaurant_menu,
                title: "Preferencias alimenticias",
                children: [
                  _buildTextField(_allergiesController, "Alergias", "Ej: maní, gluten"),
                  _buildTextField(_likesController, "Comidas que le gustan", "Ej: pollo"),
                  _buildTextField(_dislikesController, "Comidas que no le gustan", "Ej: pescado"),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _updateUser,
                  label: const Text(
                    "Guardar cambios",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- COMPONENTES ----------

  Widget _disabledTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        enabled: false,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

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
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (v) => v == null || v.trim().isEmpty ? "Campo requerido" : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String currentValue,
      List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField(
        value: currentValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
