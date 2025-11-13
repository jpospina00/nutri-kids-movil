import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/models/user_model.dart';
import 'package:nutri_kids_movil/providers/auth_provider.dart';
import 'package:nutri_kids_movil/router/router.dart';
import 'package:nutri_kids_movil/services/apis/dashboard_service.dart';
import 'package:nutri_kids_movil/services/hive_services.dart';
import 'package:nutri_kids_movil/services/local_storage.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _selectedIndex = 0;
  final List<String> options = [];
  User? user;

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
    getUserData();
  }
void getUserData() {
  try {
    HiveServices hiveServices = HiveServices();
    final userData = hiveServices.getData('user');

    if (userData == null) {
      print('⚠️ No hay datos de usuario guardados en Hive');
      return;
    }

    print('User Data in Sidebar: $userData');

    // 🔹 Convertir a Map<String, dynamic> de forma segura
    final Map<String, dynamic> parsedUser =
        Map<String, dynamic>.from(userData as Map);

    setState(() {
      user = User.fromJson(parsedUser);
    });
  } catch (e) {
    print('Error al obtener datos del usuario: $e');
  }
}


  void _loadSelectedIndex() async{
    // Load the selected index from shared preferences or any other source
    print('Aqui');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('selectedIndex') ?? 0;
    });

  }

  void _saveSelectedIndex(int index) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedIndex', index);
  }

  void _closeDrawer() {
    Scaffold.of(context).closeDrawer();
  }

  final List<Map<String, dynamic>> _menuItems = [
    {
      'text': 'Home',
      'icon': Icons.home,
      'route': '/dashboard',
      'index': 0,
    },
    {
      'text': 'Profile',
      'icon': Icons.person,
      'route': '/dashboard/profile',
      'index': 1,
    },
    {
      'text': 'Agregar usuario',
      'icon': Icons.add_circle_outline,
      'route': '/dashboard/add_user',
      'index': 2,
    },
    {
      'text': 'Historial de comidas',
      'icon': Icons.history,
      'route': '/dashboard/food_history',
      'index': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    print('Building Sidebar');
    return Drawer(
      backgroundColor: const Color(0xFFF2F2F2),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(padding: const EdgeInsets.all(30.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(onPressed: () {
                  Scaffold.of(context).closeDrawer();
                }, icon: const Icon(Icons.west, size: 25, color: Colors.green,)),
              ),),
            InkWell(
                onTap: () {
                  // Acción cuando se presiona el CircleAvatar
                  NavigationService.navigateTo(
                      Flurorouter.profileViewRoute);

                  Scaffold.of(context).closeDrawer();
                },
                borderRadius: BorderRadius.circular(
                    22), // Coincide con el radio del CircleAvatar
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                       const AssetImage('assets/images/Default.png')
                         
                ),
              ),
              const SizedBox(height: 15),
              Text(
                user != null ? '${user!.name} ${user!.lastName}' : 'Nombre de Usuario',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.40,
                  fontFamily: 'MyriadPro',
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ..._menuItems.map(
                      (item) => _createDrawerItem(
                        icon: item["icon"],
                        text: item["text"],
                        index: item["index"],
                        onTap: () {
                          setState(() {
                            _selectedIndex = item["index"];
                            _saveSelectedIndex(
                                item["index"]); // Save the selected index
                          });
                          NavigationService.navigateTo(
                              item["route"]);
                        },
                      ),
                    ),                
                    
                    _createDrawerItem(
                      icon: Icons.exit_to_app_outlined,
                      text: 'Salir',
                      index: 12,
                      onTap: () {
                        setState(() {
                          _selectedIndex = 12;
                          _saveSelectedIndex(12); 
                          context.read<AuthProvider>().logout();
                      Navigator.pushNamed(context, Flurorouter.loginRoute);
                          // _showLogOutDialog(dropdownProvider, authProvider);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
  Widget _createDrawerItem(
        {IconData? icon, String? text, GestureTapCallback? onTap, int? index}) {
      bool isSelected = _selectedIndex == index;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: MouseRegion(
          onEnter: (_) => setState(() {
            if (_selectedIndex != index) {
              _selectedIndex = index!;
            }
          }),
          onExit: (_) => setState(() {
            if (_selectedIndex == index) {
              _selectedIndex = -1;
            }
          }),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : null,
              borderRadius:
                  BorderRadius.circular(15), // Aplicar borderRadius aquí
            ),
            child: ListTile(
              title: Row(
                children: <Widget>[
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.green,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      text!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.green,
                        fontSize: 14.40,
                        fontFamily: 'MyriadPro',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _selectedIndex = index!;
                  _saveSelectedIndex(index);
                });

                _closeDrawer();
                if (onTap != null) {
                  onTap();
                }
              },
            ),
          ),
        ),
      );
    }
}