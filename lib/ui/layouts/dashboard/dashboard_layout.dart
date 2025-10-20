import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:nutri_kids_movil/models/user_model.dart';
import 'package:nutri_kids_movil/providers/dropdown_provider.dart';
import 'package:nutri_kids_movil/providers/loading_provider.dart';
import 'package:nutri_kids_movil/services/apis/dashboard_service.dart';
import 'package:nutri_kids_movil/services/hive_services.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:nutri_kids_movil/ui/shared/widgets/sidebar.dart';
import 'package:nutri_kids_movil/ui/views/customdropdownbutton.dart';
import 'package:provider/provider.dart';

class DashboardLayout extends StatefulWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> options = [];

  @override
  void initState() {
    super.initState();
    getUsersByUser();
  }

  void getUsersByUser() async {
  DashboardService dashboardService = DashboardService();
  List<User?> users = await dashboardService.getUsersByUser();

  HiveServices hiveServices = HiveServices();

  // Convertimos la lista de usuarios a lista de mapas JSON
  List<Map<String, dynamic>> usersList =
      users.map((u) => u!.toJson()).toList();

  // Guardamos directamente la lista
  await hiveServices.saveData('users', usersList);

  // Extraemos nombres
  List<String> userNames = users.map((u) => u!.name).toList();

  setState(() {
    options.addAll(userNames);
  });
}

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final loadingProvider = context.watch<LoadingProvider>();
    final isLoading = loadingProvider.isLoading;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DropdownProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final dropdownProvider =
              Provider.of<DropdownProvider>(context, listen: true);
          return Scaffold(
            key: _scaffoldKey,
            drawer: const Sidebar(),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.green),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                          GestureDetector(
                            onTap: () => _showOptionsDialog(dropdownProvider),
                            child: Container(
                              width: 220,
                              height: 26,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x3F000000),
                                    blurRadius: 4,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 4, left: 15),
                                child: Text(
                                  dropdownProvider.selectedValue,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontFamily: 'MyriadPro',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          width: screenSize.width,
                          height: screenSize.height,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/FondoM1.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: const Alignment(0.0, -0.7),
                                end: const Alignment(0, 1),
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.6),
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: widget.child,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 🌿 Loading Global
                  if (isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/ensalada-loading.svg',
                              width: 120,
                              height: 120,
                            ),
                            const SizedBox(height: 25),
                            AnimatedTextKit(
                              repeatForever: true,
                              animatedTexts: [
                                TyperAnimatedText(
                                  loadingProvider.currentMessage,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'MyriadPro',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  speed:
                                      const Duration(milliseconds: 100),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOptionsDialog(DropdownProvider dropdownProvider) {
    try {
      BuildContext cnt = NavigationService.navigatorKey.currentContext!;
      if (dropdownProvider.showMenu) {
        dropdownProvider.setShowMenu(false);
        return Navigator.of(cnt).pop();
      }
      dropdownProvider.setShowMenu(true);
      showDialog(
        context: cnt,
        builder: (BuildContext context) {
          return DropOptions(options: options);
        },
      ).then((_) => dropdownProvider.setShowMenu(false));
    } catch (e) {
      print("Error al mostrar el diálogo de opciones: $e");
    }
  }
}
