import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  // 默認主題為淺色模式
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // 默認語言為繁體中文
  Locale _locale = const Locale('zh', 'TW');

  Locale get locale => _locale;

  set locale(Locale value) {
    _locale = value;
    notifyListeners();
  }
}
