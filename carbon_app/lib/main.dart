import 'package:flutter/material.dart';
import 'screens/industry_page.dart';
import 'screens/county_industry_page.dart';
import 'screens/single_year_page.dart';
import 'screens/map_page.dart';
import 'screens/setting_page.dart';
import 'screens/favorite_screen.dart'; // 收藏頁面
import 'screens/home_screen.dart'; // 首頁內容
import 'bottom_navigation_bar.dart'; // 引入自定義的 BottomNavigationBar

void main() {
  runApp(const CarbonApp());
}

class CarbonApp extends StatelessWidget {
  const CarbonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carbon Emission Tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MainScreen(), // 將主頁設置為 MainScreen
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // 當前選中的頁面索引

  // 子頁面列表
  final List<Widget> _screens = [
    const HomeScreen(), // 首頁
    const FavoriteScreen(), // 收藏頁
    const SettingScreen(), // 設定頁
  ];

  // 切換頁面
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(), // 使用自定義的 AppBar
      drawer: sideBar(context), // 使用自定義的 Drawer
      body: _screens[_currentIndex], // 根據當前索引顯示對應頁面
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex, // 傳遞當前選中的索引
        onTabTapped: _onTabTapped, // 傳遞切換頁面的邏輯
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Carbon Emission Tracker", // 應用標題
        style: TextStyle(
          color: Colors.black, // 標題文字顏色
          fontSize: 18, // 字體大小
          fontWeight: FontWeight.bold, // 粗體
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 250, 250, 250), // AppBar 背景色
      elevation: 0.0, // 移除陰影
      centerTitle: true, // 標題置中
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.black), // 菜單圖標
            onPressed: () {
              Scaffold.of(context).openDrawer(); // 點擊圖標打開抽屜
            },
          );
        },
      ),
    );
  }

  // 自定義的側邊欄
  Drawer sideBar(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(
            runSpacing: 16,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('首頁'),
                onTap: () {
                  setState(() {
                    _currentIndex = 0; // 切換到首頁
                  });
                  Navigator.pop(context); // 關閉 Drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.factory),
                title: const Text('產業視圖'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const IndustryViewScreen(),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_list_bulleted),
                title: const Text('縣市產業視圖'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CountyIndustryViewScreen(),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('單年視圖'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DepartmentPieChartViewScreen(),
                  ));
                  // 導航到單年視圖頁面
                },
              ),
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('地圖視角'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MapViewScreen(),
                  ));
                },
              ),
              const Divider(color: Color.fromARGB(135, 169, 169, 169)),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('有關'),
                onTap: () {
                  setState(() {
                    _currentIndex = 2; // 切換到設定頁
                  });
                  Navigator.pop(context); // 關閉 Drawer
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
