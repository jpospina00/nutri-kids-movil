import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/models/user_model.dart';
import 'package:nutri_kids_movil/providers/dropdown_provider.dart';
import 'package:nutri_kids_movil/services/apis/dashboard_service.dart';
import 'package:nutri_kids_movil/services/local_storage.dart';
import 'package:nutri_kids_movil/services/navigation_services.dart';
import 'package:provider/provider.dart';

class Customdropdownbutton extends StatefulWidget {
  @override
  State<Customdropdownbutton> createState() => _CustomdropdownbuttonState();
}

class _CustomdropdownbuttonState extends State<Customdropdownbutton> {
  bool _isHovered = false;
  final List<String> options = [];
  @override
  void initState() {
    super.initState();
    String? userJson = LocalStorage.prefs.getString('user');
    Map<String, dynamic>? user;
    if (userJson != null) {
      user = jsonDecode(userJson);
    }

    if (user != null && user['sector'] != null) {
      // Itera sobre la lista de sectores y añade cada nombre a _sectorLabels
      for (var sector in user['sector']) {
        options.add(sector['name']);
      }
    }
  }

  void _showOptionsDialog(DropdownProvider dropdownProvider) {
    BuildContext cnt = NavigationService.navigatorKey.currentContext!;
    // print('Entre aqui con: ${dropdownProvider.showMenu}');
    if (dropdownProvider.showMenu) {
      dropdownProvider.setShowMenu(false);
      return Navigator.of(cnt).pop();
    }
    dropdownProvider.setShowMenu(true);
    ;
    showDialog(
      context: cnt,
      builder: (BuildContext context) {
        return DropOptions(options: options);
      },
    ).then((_) => dropdownProvider.setShowMenu(false));
  }

  @override
  Widget build(BuildContext context) {
    final dropdownProvider =
        Provider.of<DropdownProvider>(context, listen: true);
    return GestureDetector(
      onTap: () => _showOptionsDialog(dropdownProvider),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) => setState(() {
          _isHovered = true;
        }),
        onExit: (event) => setState(() {
          _isHovered = false;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            color: _isHovered ? Colors.grey : Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.foundation,
                color: Colors.green,
                size: 20,
              ),
              Expanded(
                child: Text(
                  dropdownProvider.selectedValue,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14.40,
                    fontFamily: 'MyriadPro',
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              Icon(
                dropdownProvider.showMenu
                    ? Icons.expand_less
                    : Icons.expand_more,
                size: 20,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropOptions extends StatefulWidget {
  const DropOptions({
    super.key,
    required this.options,
  });

  final List<String> options;

  @override
  State<DropOptions> createState() => _DropOptionsState();
}

class _DropOptionsState extends State<DropOptions> {
  late List<bool> _isHoveredList;
  String search = '';

  bool get _supportsHover =>
      kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  @override
  void initState() {
    super.initState();
    _isHoveredList = List<bool>.filled(widget.options.length, false);
  }

  @override
  Widget build(BuildContext context) {
    List<String> filteredOptions = widget.options.where((option) {
      return option.toString().toLowerCase().contains(search.toLowerCase());
    }).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final dropdownProvider = Provider.of<DropdownProvider>(context);

    return AlertDialog(
      backgroundColor: const Color(0xFFF4F4F4),
      title: const Text(
        'Selección de Usuario',
        style: TextStyle(
          color: Colors.green,
          fontSize: 24.88,
          fontFamily: 'MyriadPro',
          fontWeight: FontWeight.w600,
          height: 0,
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 320, maxWidth: 310),
        child: SingleChildScrollView(
          child: ListBody(
            children: [
              SizedBox(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.green,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide:
                          const BorderSide(color: Colors.green, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      search = value;
                    });
                  },
                ),
              ),
              if (filteredOptions.isNotEmpty)
                ...filteredOptions.asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;

                  bool isSelected = option == dropdownProvider.selectedValue;

                  Widget optionTile = AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 40,
                    width: 400,
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 16.0),
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.withOpacity(0.8)
                          : _isHoveredList[index]
                              ? Colors.red.withOpacity(0.6)
                              : const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isSelected
                            ? Colors.green
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : _isHoveredList[index]
                                  ? Colors.white
                                  : Colors.black,
                          fontSize: 14.4,
                          fontFamily: 'MyriadPro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );

                  // --- Comportamiento táctil (Android/iOS) ---
                  if (!_supportsHover) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(12.0),
                      onHighlightChanged: (isPressed) {
                        setState(() {
                          _isHoveredList[index] = isPressed;
                        });
                      },
                      onTap: () {
                        dropdownProvider.setShowMenu(false);
                        dropdownProvider.setSelectedValue(option);
                        Navigator.of(context).pop();
                      },
                      child: optionTile,
                    );
                  }

                  // --- Comportamiento con hover (Desktop/Web) ---
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() {
                      _isHoveredList[index] = true;
                    }),
                    onExit: (_) => setState(() {
                      _isHoveredList[index] = false;
                    }),
                    child: GestureDetector(
                      onTap: () {
                        dropdownProvider.setShowMenu(false);
                        dropdownProvider.setSelectedValue(option);
                        Navigator.of(context).pop();
                      },
                      child: optionTile,
                    ),
                  );
                }).toList()
              else
                const Text(
                  'Lo sentimos, no se encontraron resultados para tu búsqueda. '
                  'Intenta con diferentes términos o ajusta los filtros.',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropDown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final IconData icon;
  final ValueChanged<String?> onChanged;
  final double width;

  const DropDown({
    Key? key,
    required this.value,
    required this.items,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.width = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 34,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(4, 4),
              spreadRadius: 0,
            )
          ]),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(icon, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: value,
              style: const TextStyle(color: Colors.green),
              items: items.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item == hint ? null : item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14.40,
                      fontFamily: 'MyriadPro',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                );
              }).toList(),
              hint: Text(
                hint,
                style: const TextStyle(
                  color:  Colors.green,
                  fontSize: 14.40,
                  fontFamily: 'MyriadPro',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
              onChanged: onChanged,
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more,
                color: Colors.green,
              ),
              underline: const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

class DropDownChoose extends StatefulWidget {
  final List<String> selectedValues;
  final List<String> items;
  final String hint;
  final IconData icon;
  final ValueChanged<List<String>> onChanged;
  final double width;
  final int? limit;

  const DropDownChoose({
    Key? key,
    required this.selectedValues,
    required this.items,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.width = 120,
    this.limit,
  }) : super(key: key);

  @override
  _DropDownChooseState createState() => _DropDownChooseState();
}

class _DropDownChooseState extends State<DropDownChoose> {
  late List<String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.selectedValues;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(widget.icon, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: null,
                style: const TextStyle(color: Colors.green),
                items:
                    widget.items.map<DropdownMenuItem<String>>((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(
                          _selectedValues.contains(item)
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: _selectedValues.contains(item)
                              ? Colors.red
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14.40,
                            fontFamily: 'MyriadPro',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                hint: Text(
                  widget.hint,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14.40,
                    fontFamily: 'MyriadPro',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      if (_selectedValues.contains(newValue)) {
                        _selectedValues.remove(newValue);
                      } else {
                        if (widget.limit != null &&
                            _selectedValues.length == widget.limit!) return;
                        _selectedValues.add(newValue);
                      }
                    });
                    widget.onChanged(_selectedValues);
                  }
                },
                isExpanded: true,
                icon: const Icon(Icons.expand_more,
                    color: Colors.grey), // Hacer clic aquí expande la lista
              ),
            ),
          ),
        ],
      ),
    );
  }
}
