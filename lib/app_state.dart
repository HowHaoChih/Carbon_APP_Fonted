import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  // 默認主題為淺色模式
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // 默認語言為英文
Locale _locale = const Locale('en', 'US');

  Locale get locale => _locale;

  set locale(Locale value) {
    _locale = value;
    notifyListeners();
  }
}