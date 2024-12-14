import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: Provider.of<AppState>(context).isDarkMode,
            onChanged: (bool value) {
              Provider.of<AppState>(context, listen: false).isDarkMode = value;
            },
            activeColor: Colors.green, // 開啟顏色
            inactiveThumbColor: Colors.grey, // 關閉顏色
            activeTrackColor: Colors.greenAccent, // 開啟背景顏色
            inactiveTrackColor: Colors.grey[300], // 關閉背景顏色
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('Traditional Chinese / English'),
            onTap: () {
              // 切換語言
              final appState = Provider.of<AppState>(context, listen: false);
              final newLocale = appState.locale.languageCode == 'zh'
                  ? const Locale('en', 'US')
                  : const Locale('zh', 'TW');
              appState.locale = newLocale;
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Clear Cache'),
            onTap: () {
              // 處理清除緩存的功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
