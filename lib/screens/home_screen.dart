import 'package:flutter/material.dart';
import '../widgets/stacked_bar_and_line_chart.dart'; // 引入碳排放圖表的 widget
import '../widgets/department_legend.dart'; // 引入部門圖例的 widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 預設選擇的城市名稱，初始值為 "台北市"
  String selectedCity = "台北市";

  // 所有產業選項
  final List<String> allDepartments = [
    "Residential",
    "Services",
    "Energy",
    "Manufacturing",
    "Transportation",
    "Electricity"
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 整個頁面內容四周的內邊距
        child: Column(
          children: [
            // 全國碳排放趨勢圖表 (居中顯示)
            Expanded(
              flex: 2,
              child: Center(
                child: SizedBox(
                  width: size.width * 0.9, // 設定寬度為螢幕寬度的 90%
                  height: size.height * 0.4, // 設定高度為螢幕高度的 40%
                  child: StackedBarAndLineChart(
                    city: "Total",
                    selectedDepartments: allDepartments.toSet(),
                  ),
                ),
              ),
            ),
            // 城市選擇下拉選單
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
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
            ),
            // 城市碳排放趨勢圖表 (居中顯示)
            Expanded(
              flex: 2,
              child: Center(
                child: SizedBox(
                  width: size.width * 0.9, // 設定寬度為螢幕寬度的 90%
                  height: size.height * 0.4, // 設定高度為螢幕高度的 40%
                  child: StackedBarAndLineChart(
                    city: selectedCity,
                    selectedDepartments: allDepartments.toSet(),
                  ),
                ),
              ),
            ),
            // 部門圖例
            Container(
              margin: const EdgeInsets.only(left: 16.0, right: 8.0), // 左右邊距
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8, // 最大寬度為螢幕 80%
              ),
              child: DepartmentLegend(
                departmentList: allDepartments,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
