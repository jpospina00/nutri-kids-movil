import 'package:flutter/material.dart';

class OverlayProvider extends ChangeNotifier {
  bool isExpanded = false;

  bool get isOverlayVisible => isExpanded;

  void showOverlay() {
    isExpanded = true;
    notifyListeners();
  }

  void hideOverlay() {
    isExpanded = false;
    notifyListeners();
  }
}