import 'package:flutter/material.dart';
import '../widgets/department_pie_chart.dart'; // 引入圓餅圖 widget
import '../widgets/department_legend.dart'; // 引入部門圖例的 widget
import '../utils/department_utils.dart'; // 引入 department_utils.dart
import '../utils/city_utils.dart';

class DepartmentPieChartViewScreen extends StatefulWidget {
  const DepartmentPieChartViewScreen({super.key});

  @override
  State<DepartmentPieChartViewScreen> createState() =>
      _DepartmentPieChartViewScreenState();
}

class _DepartmentPieChartViewScreenState
    extends State<DepartmentPieChartViewScreen> {
  // 縣市列表
  final List<String> cities = CityUtils.getCountiesWithNation();

  // 選中的城市
  String selectedCity = "台北市";
  // 年份列表
  final List<int> years = List<int>.generate(2023 - 1990 + 1, (i) => 1990 + i);

  // 選中的年份
  int selectedYear = 2023;

  // 所有產業選項
  final List<String> allDepartments = DepartmentUtils.getAllDepartments();

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
              menuMaxHeight:
                  MediaQuery.of(context).size.height * 0.5, // 設置最大展開高度
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
              menuMaxHeight:
                  MediaQuery.of(context).size.height * 0.5, // 設置最大展開高度
            ),
          ),
          const SizedBox(height: 16), // 增加間距
          // 圖表展示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                DepartmentPieChart(
                  year: selectedYear, // 傳入選中的年份
                  city: selectedCity == "全國" ? "Total" : selectedCity,
                ),
                const SizedBox(height: 16), // PieChart 和 Legend 之間的間距
                Container(
                  margin: const EdgeInsets.only(left: 16.0, right: 8.0), // 左右邊距
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
        ],
      ),
    );
  }
}
