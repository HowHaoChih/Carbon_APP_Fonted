import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/industry_page.dart';
import 'screens/single_year_page.dart';
import 'screens/map_page.dart';
import 'screens/settings_page.dart';
import 'screens/favorite_page.dart';
import 'screens/infomation.dart';
import 'screens/home_screen.dart';
import 'bottom_navigation_bar.dart';
import 'app_state.dart'; // 引入AppState

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const CarbonApp(),
    ),
  );
}

class CarbonApp extends StatelessWidget {
  const CarbonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appState.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          locale: appState.locale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('zh', 'TW'),
          ],
          localizationsDelegates: const [
            ...GlobalMaterialLocalizations
                .delegates, // Spread the delegates list here
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations
                .delegate, // Add this to support Cupertino localization
          ],
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 子頁面列表
  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoriteScreen(),
    const SettingsScreen(),
  ];

  // 每個頁面對應的標題
  final List<String> _titles = [
    '城市碳排總覽',
    '我的最愛',
    '設定',
  ];

  // 切換頁面
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: appBar(appState), // 使用自定義的 AppBar
          drawer: sideBar(context), // 使用自定義的 Drawer
          body: _screens[_currentIndex], // 根據當前索引顯示對應頁面
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: _currentIndex,
            onTabTapped: _onTabTapped,
          ),
        );
      },
    );
  }

  AppBar appBar(AppState appState) {
    return AppBar(
      title: Text(
        _titles[_currentIndex], // 根據當前索引顯示對應的標題
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0.0,
      centerTitle: true,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
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
                    _currentIndex = 0;
                  });
                  Navigator.pop(context);
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
                leading: const Icon(Icons.pie_chart),
                title: const Text('單年視圖'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DepartmentPieChartViewScreen(),
                  ));
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
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const InfomationScreen(),
                  ));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
