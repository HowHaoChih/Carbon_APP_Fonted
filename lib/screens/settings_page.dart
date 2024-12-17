import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/l10n.dart';
import '../l10n/localization_utils.dart'; // 引入修正後的 LocalizationUtils

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: 2, // 總共有幾個列表項
        itemBuilder: (context, index) {
          if (index == 0) {
            return SwitchListTile(
              title: Text(context.l10n.dark_mode),
              value: Provider.of<AppState>(context).isDarkMode,
              onChanged: (bool value) {
                // 切換暗模式
                Provider.of<AppState>(context, listen: false).isDarkMode = value;
              },
              activeColor: Colors.green, // 開啟顏色
              inactiveThumbColor: Colors.grey, // 關閉顏色
              activeTrackColor: Colors.greenAccent, // 開啟背景顏色
              inactiveTrackColor: Colors.grey[300], // 關閉背景顏色
            );
          } else if (index == 1) {
            return ListTile(
              leading: const Icon(Icons.language),
              title: Text(context.l10n.language),
              subtitle: Text(
                Provider.of<AppState>(context).locale.languageCode == 'zh'
                    ? '繁體中文'
                    : 'English',
              ),
              onTap: () {
                // 切換語言
                final appState = Provider.of<AppState>(context, listen: false);
                final newLocale = appState.locale.languageCode == 'zh'
                    ? const Locale('en', 'US') // 切換到英文
                    : const Locale('zh', 'TW'); // 切換到繁體中文

                // 使用 LocalizationUtils 切換語言
                LocalizationUtils.instance.changeLocale(locale: newLocale, systemDefault: false);

                // 更新 AppState 中的語言設置
                appState.locale = newLocale;

                // 通知 Flutter 更新語言界面，刷新當前頁面
                setState(() {}); // 強制重建頁面
              },
            );
          }
          return const SizedBox.shrink(); // 避免出現空項錯誤
        },
        separatorBuilder: (context, index) {
          return const Divider(); // 分隔符
        },
      ),
    );
  }
}