import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/router/router.dart';
import 'package:nutri_kids_movil/services/apis/dashboard_service.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';

class RecommendationsView extends StatefulWidget {
  final String userId;
  final List recommendations;

  const RecommendationsView({
    Key? key,
    required this.userId,
    required this.recommendations,
  }) : super(key: key);

  @override
  State<RecommendationsView> createState() => _RecommendationsViewState();
}

class _RecommendationsViewState extends State<RecommendationsView> {
  Map<String, dynamic>? _selectedPlan;
  bool _customSelected = false;
  final TextEditingController _customCaloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('Recomendaciones recibidas: ${widget.recommendations}');
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Selecciona tu plan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade600,
        elevation: 3,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCustomOption(), // 🔹 Ahora primero
                const SizedBox(height: 10),
                ...List.generate(
                  widget.recommendations.length,
                  (index) {
                    final rec = widget.recommendations[index];
                    final isSelected = _selectedPlan == rec && !_customSelected;

                    return _RecommendationCard(
                      index: index,
                      data: rec,
                      selected: isSelected,
                      onSelect: () {
                        setState(() {
                          _selectedPlan = rec;
                          _customSelected = false;
                          _customCaloriesController.clear();
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // 🔹 Botón continuar
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _selectedPlan != null || _customSelected
                  ? () => _continue(context)
                  : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text(
                'Continuar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomOption() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _customSelected ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _customSelected ? Colors.green.shade400 : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(_customSelected ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.green.shade700),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Crea tu propio plan personalizado',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
              if (_customSelected)
                Icon(Icons.check_circle, color: Colors.green.shade600),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customCaloriesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Calorías deseadas',
              hintText: 'Ejemplo: 2300',
              prefixIcon: const Icon(Icons.local_fire_department_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onTap: () {
              setState(() {
                _customSelected = true;
                _selectedPlan = null;
              });
            },
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _customSelected = true;
                  _selectedPlan = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _continue(BuildContext context) {
    Map<String, dynamic> selectedData;

    if (_customSelected) {
      final calories = int.tryParse(_customCaloriesController.text.trim());
      if (calories == null || calories <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor ingresa un número válido de calorías.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      selectedData = {'custom': true, 'calorias_diarias': calories};
    } else {
      selectedData = _selectedPlan ?? {};
    }
    DashboardService dashboardService = DashboardService();
    final response = dashboardService.createPlan(
      widget.userId,
      selectedData['calorias_diarias'],
    );
    if (response == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear el plan. Inténtalo de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
      return;

    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _customSelected
              ? 'Has creado un plan de ${selectedData['calorias_diarias']} calorías 💪'
              : 'Has seleccionado el plan de ${selectedData['calorias_diarias']} calorías 🥗',
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
      print('calorias seleccionadas: ${selectedData['calorias_diarias']}');
    // Future.delayed(const Duration(milliseconds: 700), () {
    //   NavigationService.navigateTo(
    //     Flurorouter.dashboardRoute,
    //     arguments: {'userId': widget.userId, 'plan': selectedData},
    //   );
    // });
  }
}

class _RecommendationCard extends StatelessWidget {
  final int index;
  final Map data;
  final bool selected;
  final VoidCallback onSelect;

  const _RecommendationCard({
    required this.index,
    required this.data,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final rec = data;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? Colors.green.shade500 : Colors.grey.shade300,
          width: selected ? 2 : 1.2,
        ),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: Colors.green.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department,
                      color: selected ? Colors.green.shade700 : Colors.green[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Plan ${index + 1}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.green.shade800 : Colors.grey[900],
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
                ],
              ),
              const SizedBox(height: 10),
              _buildInfo('Calorías diarias', '${rec['calorias_diarias']} kcal'),
              _buildInfo('Proteínas', '${rec['proteinas_totales']} g'),
              _buildInfo('Carbohidratos', '${rec['carbohidratos_totales']} g'),
              _buildInfo('Grasas', '${rec['grasas_totales']} g'),
              const SizedBox(height: 8),
              if (rec['descripcion'] != null && rec['descripcion'].toString().isNotEmpty)
                Text(
                  rec['descripcion'],
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                ),
              if (rec['recomendacion'] != null &&
                  rec['recomendacion'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    rec['recomendacion'],
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
