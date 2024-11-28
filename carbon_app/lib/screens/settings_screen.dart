import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (bool value) {
              // 處理主題切換（需搭配主題管理）
              final newTheme = value ? Brightness.dark : Brightness.light;
              // 此處應與主題管理邏輯對接，例如使用 Provider 或其他狀態管理方案。
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('Traditional Chinese / English'),
            onTap: () {
              // 處理語言切換（需實現多語言支持）
              // 通常與 `localization` 配合
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
