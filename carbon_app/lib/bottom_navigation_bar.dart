import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/settings_page.dart';
import '../screens/favorite_page.dart'; // 收藏頁面
import '../screens/home_screen.dart'; // 首頁內容
import '../app_state.dart'; // 引入AppState

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

    // 子頁面列表
    final List<Widget> _screens = [
      const HomeScreen(), // 首頁
      const FavoriteScreen(), // 收藏頁
      const SettingsScreen(), // 設定頁
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex, // 當前選中的索引
      onTap: onTabTapped, // 點擊切換頁面
      selectedItemColor: appState.isDarkMode
          ? Colors.greenAccent
          : Colors.green[700], // 設定選中項目的顏色，這裡使用淺綠色
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
