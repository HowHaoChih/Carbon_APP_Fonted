import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart'; // 引入AppStatex
import 'l10n/l10n.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTabTapped,
    super.key, // 使用 super.key 的簡化語法
  });

  @override
  Widget build(BuildContext context) {
    // 取得 AppState
    final appState = Provider.of<AppState>(context);

    return BottomNavigationBar(
      currentIndex: currentIndex, // 當前選中的索引
      onTap: onTabTapped, // 點擊切換頁面
      selectedItemColor: appState.isDarkMode
          ? Colors.greenAccent
          : Colors.green[700], // 設定選中項目的顏色，這裡使用淺綠色
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: context.l10n.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: context.l10n.favorites,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: context.l10n.settings,
        ),
      ],
    );
  }
}