import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/providers/dropdown_provider.dart';
import 'package:nutri_kids_movil/router/router.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:provider/provider.dart';

class HistoryMealDetailView extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> data;

  const HistoryMealDetailView({
    super.key,
    required this.tipo,
    required this.data,
  });

  @override
  State<HistoryMealDetailView> createState() => _HistoryMealDetailViewState();
}

class _HistoryMealDetailViewState extends State<HistoryMealDetailView> {
  late Map<String, dynamic>? _meals;
  late String _fecha;

  @override
  void initState() {
    super.initState();
    _fecha = widget.data['fecha'] ?? '';
    final plan = widget.data['plan'];
    _meals = plan is Map<String, dynamic> ? plan : null;
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final dropdownProvider = Provider.of<DropdownProvider>(
      context,
      listen: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '📅 Plan del $_fecha',
          style: const TextStyle(
            fontFamily: 'MyriadPro',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
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

              // 🔹 Si no hay comidas guardadas
              if (_meals == null || _meals!.isEmpty)
                const Center(
                  child: Text(
                    'No hay comidas registradas para esta fecha.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontFamily: 'MyriadPro',
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    // 🔹 Mostrar cards de desayuno, almuerzo y cena
                    for (var entry in _meals!.entries)
                      _mealCard(context, entry.key, entry.value),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mealCard(BuildContext context, String tipo, dynamic data) {
    print('Construyendo tarjeta para $tipo con datos: $data');
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        NavigationService.navigateTo(
          Flurorouter.mealDetailViewRoute,
          arguments: {'tipo': tipo, 'data': data},
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

              // Imagen del plato
              if (data['imagen'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    data['imagen'] ?? '',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/defecto.jpg', // <-- Asegúrate del path correcto
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fastfood,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

              const SizedBox(height: 10),
              Text(
                data['plato'] ?? 'Sin nombre',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                data['descripcion'] ?? 'Sin descripción.',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 10),
              if (data['nutricion'] != null)
                Text(
                  '🍎 Nutrición: ${data['nutricion']['calorias']} kcal | '
                  '${data['nutricion']['proteinas']}g proteínas | '
                  '${data['nutricion']['carbohidratos']}g carbos | '
                  '${data['nutricion']['grasas']}g grasas',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
