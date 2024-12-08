import 'package:flutter/material.dart';
import '../widgets/department_pie_chart.dart'; // 引入圓餅圖 widget
import '../widgets/department_legend.dart'; // 引入部門圖例的 widget

class DepartmentPieChartViewScreen extends StatefulWidget {
  const DepartmentPieChartViewScreen({super.key});

  @override
  State<DepartmentPieChartViewScreen> createState() =>
      _DepartmentPieChartViewScreenState();
}

class _DepartmentPieChartViewScreenState
    extends State<DepartmentPieChartViewScreen> {
  // 縣市列表
  final List<String> cities = [
    "全國",
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
  ];

  // 選中的城市
  String selectedCity = "台北市";
  // 年份列表
  final List<int> years = List<int>.generate(2023 - 1990 + 1, (i) => 1990 + i);

  // 選中的年份
  int selectedYear = 2023;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('年份部門碳排放圓餅圖視圖'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16), // 增加間距
          // 城市選擇器
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: selectedCity,
              items: cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCity = value; // 更新選中的城市
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: "選擇城市",
                border: OutlineInputBorder(),
              ),
              menuMaxHeight: 600, // 設置最大展開高度
            ),
          ),
          const SizedBox(height: 16), // 增加間距
          // 年份選擇器
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<int>(
              value: selectedYear,
              items: years.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedYear = value; // 更新選中的年份
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: "選擇年份",
                border: OutlineInputBorder(),
              ),
              menuMaxHeight: 600, // 設置最大展開高度
            ),
          ),
          const SizedBox(height: 16), // 增加間距
          // 圖表展示
          SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.45, // 整個容器高度為屏幕高度的 50%
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 3, // PieChart 占用更多空間
                    child: DepartmentPieChart(
                      year: selectedYear,
                      city: selectedCity == "全國"
                          ? "Total"
                          : selectedCity, // 傳入選中的年份
                    ),
                  ),
                  const SizedBox(height: 16), // PieChart 和 Legend 之間的間距
                  Container(
                    margin:
                        const EdgeInsets.only(left: 16.0, right: 8.0), // 左右邊距
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8, // 限制寬度
                    ),
                    child: DepartmentLegend(
                      departmentList: allDepartments,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
