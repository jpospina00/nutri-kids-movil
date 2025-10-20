import 'dart:async';
import 'package:flutter/material.dart';

class LoadingProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<String> _messages = ["Cargando..."];
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  bool get isLoading => _isLoading;
  List<String> get messages => _messages;
  String get currentMessage => _messages[_currentMessageIndex];

  /// Muestra el loading y comienza la rotación de mensajes
  void show({List<String>? messages}) {
    _isLoading = true;
    if (messages != null && messages.isNotEmpty) {
      _messages = messages;
      _currentMessageIndex = 0;
    }
    _startMessageRotation();
    notifyListeners();
  }

  /// Oculta el loading y detiene el cambio de mensajes
  void hide() {
    _isLoading = false;
    _messageTimer?.cancel();
    notifyListeners();
  }

  /// Configura nuevos mensajes sin mostrar el loading
  void setMessages(List<String> messages) {
    _messages = messages;
    _currentMessageIndex = 0;
    notifyListeners();
  }

  void _startMessageRotation() {
    _messageTimer?.cancel();
    if (_messages.length > 1) {
      _messageTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!_isLoading) return;
        _currentMessageIndex =
            (_currentMessageIndex + 1) % _messages.length;
        notifyListeners();
      });
    }
  }
}
