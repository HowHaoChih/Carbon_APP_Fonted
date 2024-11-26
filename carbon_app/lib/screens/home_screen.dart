import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../widgets/national_chart.dart'; // 引入全國碳排放圖表的 widget
import '../widgets/city_chart.dart'; // 引入城市碳排放圖表的 widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 預設選擇的城市名稱，初始值為 "台北市"
  String selectedCity = "台北市";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold 是 Flutter 提供的基礎頁面框架，包含 appBar、drawer 和 body
      appBar: appBar(), // 自定義的 AppBar
      drawer: Drawer(
        // 左側的抽屜導航欄
        child: ListView(
          padding: EdgeInsets.zero, // 移除默認內邊距
          children: <Widget>[
            // 顯示抽屜頂部的空間以適應狀態欄
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
            ),
            // 抽屜選項 - 首頁
            ListTile(
              leading: const Icon(Icons.home), // Icon 圖標：首頁
              title: const Text('首頁'),
              onTap: () {
                Navigator.pop(context); // 關閉抽屜
                // 添加其他邏輯處理（例如跳轉頁面）
              },
            ),
            // 抽屜選項 - 產業視圖
            ListTile(
              leading: const Icon(Icons.factory), // Icon 圖標：工廠
              title: const Text('產業視圖'),
              onTap: () {
                Navigator.pop(context); // 關閉抽屜
                // 添加其他邏輯處理
              },
            ),
            // 抽屜選項 - 縣市產業視圖
            ListTile(
              leading: const Icon(Icons.format_list_bulleted), // Icon 圖標：清單
              title: const Text('縣市產業視圖'),
              onTap: () {
                Navigator.pop(context); // 關閉抽屜
                // 添加其他邏輯處理
              },
            ),
            // 抽屜選項 - 單年視圖
            ListTile(
              leading: const Icon(Icons.pie_chart), // Icon 圖標：圓餅圖
              title: const Text('單年視圖'),
              onTap: () {
                Navigator.pop(context); // 關閉抽屜
                // 添加其他邏輯處理
              },
            ),
            // 抽屜選項 - 地圖視角
            ListTile(
              leading: const Icon(Icons.map), // Icon 圖標：地圖
              title: const Text('地圖視角'),
              onTap: () {
                Navigator.pop(context); // 關閉抽屜
                // 添加其他邏輯處理
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 整個頁面內容四周的內邊距
        child: Column(
          children: [
            // 全國碳排放趨勢圖表
            const Expanded(
              flex: 2, // 占用父容器 2 倍的空間
              child: NationalChart(), // 顯示全國碳排放趨勢的自定義 widget
            ),
            const SizedBox(height: 16), // 垂直間距
            // 城市碳排放趨勢圖
            Expanded(
              flex: 2, // 占用父容器 2 倍的空間
              child: Column(
                children: [
                  // 城市選擇下拉選單
                  DropdownButton<String>(
                    value: selectedCity, // 當前選中的城市
                    items: const [
                      // 縣市選項列表
                      "南投縣",
                      "台中市",
                      "台北市",
                      "台南市",
                      "台東縣",
                      "嘉義市",
                      "嘉義縣",
                      "基隆市",
                      "宜蘭縣",
                      "屏東縣",
                      "彰化縣",
                      "新北市",
                      "新竹市",
                      "新竹縣",
                      "桃園市",
                      "澎湖縣",
                      "花蓮縣",
                      "苗栗縣",
                      "連江縣",
                      "金門縣",
                      "雲林縣",
                      "高雄市"
                    ].map((String city) {
                      // 將每個城市名稱轉為 DropdownMenuItem
                      return DropdownMenuItem<String>(
                        value: city, // 城市名稱
                        child: Text(city), // 顯示城市名稱
                      );
                    }).toList(),
                    onChanged: (value) {
                      // 當用戶選擇不同的城市時觸發
                      setState(() {
                        selectedCity = value!; // 更新選中的城市
                      });
                    },
                  ),
                  // 城市碳排放趨勢圖表
                  Expanded(
                    child: CityChart(city: selectedCity), // 顯示選中城市的碳排放數據
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 自定義的 AppBar
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
      actions: <Widget>[], // AppBar 的其他動作按鈕
    );
  }
}
