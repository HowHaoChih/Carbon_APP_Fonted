import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/localization_utils.dart'; // 引入修正後的 LocalizationUtils
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/industry_page.dart';
import 'screens/single_year_page.dart';
import 'screens/map_page.dart';
import 'screens/settings_page.dart';
import 'screens/favorite_page.dart';
import 'screens/infomation.dart';
import 'screens/home_screen.dart';
import 'bottom_navigation_bar.dart';
import 'app_state.dart'; // 引入AppState
import 'l10n/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('hive_box');
  LocalizationUtils.instance.initialize();
  runApp(
    ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
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
          locale: LocalizationUtils.instance.locale, // 修正為正確的實例
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: appState.isDarkMode ? ThemeData.dark() : ThemeData.light(),
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
  int _currentIndex = 0; // 當前選中的頁面索引

  // 子頁面列表
  final List<Widget> _screens = [
    const HomeScreen(), // 首頁
    const FavoriteScreen(), // 收藏頁
    const SettingsScreen(), // 設定頁
  ];

  // 每個頁面對應的標題
  late List<String> _titles;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在 didChangeDependencies 中初始化 _titles，保證 context 已經準備好
    _titles = [
      context.l10n.carbon_emissions_overview,
      context.l10n.favorites,
      context.l10n.settings,
    ];
  }

  // 切換頁面
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context), // 使用自定義的 AppBar
      drawer: sideBar(context), // 使用自定義的 Drawer
      body: _screens[_currentIndex], // 根據當前索引顯示對應頁面
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex, // 傳遞當前選中的索引
        onTabTapped: _onTabTapped, // 傳遞切換頁面的邏輯
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text(
        _titles[_currentIndex], // 根據當前索引顯示對應的標題
        style: TextStyle(
          fontSize: 20, // 字體大小
          fontWeight: FontWeight.bold, // 粗體
        ),
      ),
      elevation: 0.0, // 移除陰影
      centerTitle: true, // 標題置中
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu), // 菜單圖標
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
                title: Text(context.l10n.home),
                onTap: () {
                  setState(() {
                    _currentIndex = 0; // 切換到首頁
                  });
                  Navigator.pop(context); // 關閉 Drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.factory),
                title: Text(context.l10n.industry_view),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const IndustryViewScreen(),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.pie_chart),
                title: Text(context.l10n.single_year_view),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DepartmentPieChartViewScreen(),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.map),
                title: Text(context.l10n.map_view),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const TaiwanMapScreen(),
                  ));
                },
              ),
              const Divider(color: Color.fromARGB(135, 169, 169, 169)),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(context.l10n.about),
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