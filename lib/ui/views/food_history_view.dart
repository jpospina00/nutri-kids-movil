import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/services/hive_services.dart';
import 'package:nutri_kids_movil/providers/dropdown_provider.dart';
import 'package:nutri_kids_movil/services/apis/dashboard_service.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:nutri_kids_movil/router/router.dart';
import 'package:provider/provider.dart';

class FoodHistoryView extends StatefulWidget {
  const FoodHistoryView({super.key});

  @override
  State<FoodHistoryView> createState() => _FoodHistoryViewState();
}

class _FoodHistoryViewState extends State<FoodHistoryView> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  String? _lastSelectedValue;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final dropdownProvider = Provider.of<DropdownProvider>(context);
    // Solo recargamos si cambió el valor
    if (_lastSelectedValue != dropdownProvider.selectedValue) {
      _lastSelectedValue = dropdownProvider.selectedValue;
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    try {
      HiveServices hiveServices = HiveServices();
      final data = hiveServices.getData('users');

      if (data == null || (data as List).isEmpty) {
        print('⚠️ No hay usuarios guardados en Hive');
        return;
      }

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
      final response = await dashboardService.getFoodHistory(
        userSelected['id'],
      );
      if (!mounted) return;

      if (response['ok'] == true) {
        setState(() {
          _history = List<Map<String, dynamic>>.from(response['history']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _history = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error al cargar historial: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Comidas 🍽️',
          style: TextStyle(fontFamily: 'MyriadPro'),
        ),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? const Center(
              child: Text(
                'No hay historial disponible',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                final plan = item['plan'];
                final date = item['date'];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      print('Ver detalles del plan del $date');
                      print(plan);
                      NavigationService.navigateTo(
                        Flurorouter.foodHistoryDetailViewRoute,
                        arguments: {'date': date, 'plan': plan},
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📅 $date',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _previewMeals(plan),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _previewMeals(Map<String, dynamic> plan) {
    final comidas = plan.keys.take(3).toList(); // desayuno, almuerzo, cena
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: comidas.map((key) {
        final comida = plan[key];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              const Icon(Icons.fastfood, color: Colors.orangeAccent, size: 18),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${key[0].toUpperCase()}${key.substring(1)}: ${comida['plato']}',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
