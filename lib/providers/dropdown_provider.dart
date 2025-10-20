
import 'package:flutter/material.dart';
import 'package:nutri_kids_movil/services/local_storage.dart';

class DropdownProvider with ChangeNotifier {
  String _selectedValue = LocalStorage.prefs.getString('selectedUser') ?? 'Selecciona una opción';
  bool showMenu = false;

  String get selectedValue => _selectedValue;

  bool setSelectedValue(String newValue) {
    _selectedValue = newValue;
    LocalStorage.prefs.setString('selectedUser', newValue);
    notifyListeners();
    return true;
  }

  void setShowMenu(bool change) {
    showMenu = change;
    notifyListeners();
  }
}
