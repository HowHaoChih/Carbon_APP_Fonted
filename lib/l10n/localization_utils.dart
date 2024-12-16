import 'package:flutter/foundation.dart'; 
import 'package:flutter/widgets.dart'; // 提供 WidgetsBinding
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 匯入生成的本地化

class LocalizationUtils extends ChangeNotifier {
  // Singleton 實例
  LocalizationUtils._();
  static final instance = LocalizationUtils._();

  final storageBox = Hive.box('hive_box');
  late Locale _locale;

  Locale get locale => _locale;

  void initialize() {
    final String? languageCode = storageBox.get('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      return;
    }
    _locale = WidgetsBinding.instance.window.locale; // 使用 Flutter 的方式獲取預設語系
  }

  void changeLocale({required Locale locale, required bool systemDefault}) {
    if (systemDefault) {
      storageBox.delete('language_code');
      if (AppLocalizations.supportedLocales.contains(locale)) {
        _locale = locale;
      } else {
        _locale = const Locale('en');
      }
    } else {
      _locale = locale;
      storageBox.put('language_code', locale.languageCode);
    }
    notifyListeners();
  }

  Locale? localeResolutionCallback(
      Locale? locale, Iterable<Locale> supportedLocales) {
    if (storageBox.get('language_code') != null) return null;
    if (locale != null && supportedLocales.contains(locale)) {
      return locale;
    }
    return const Locale('en');
  }
}