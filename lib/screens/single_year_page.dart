import 'package:flutter/material.dart';
import '../widgets/department_pie_chart.dart'; // 引入圓餅圖 widget
import '../widgets/department_legend.dart'; // 引入部門圖例的 widget
import '../l10n/l10n.dart';
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
  late List<String> cities;
  // 選中的城市
  late String selectedCity;

  // 年份列表
  final List<int> years = List<int>.generate(2023 - 1990 + 1, (i) => 1990 + i);

  // 選中的年份
  int selectedYear = 2023;

  // 所有產業選項
  final List<String> allDepartments = DepartmentUtils.getAllDepartments();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 確保 `context` 在此方法中可以安全使用
    cities = [
      context.l10n.entire_country,
      context.l10n.taipei_city,
      context.l10n.new_taipei_city,
      context.l10n.taoyuan_city,
      context.l10n.taizhong_city,
      context.l10n.tainan_city,
      context.l10n.kaohsiung_city,
      context.l10n.hsinchu_city,
      context.l10n.hsinchu_county,
      context.l10n.miaoli_county,
      context.l10n.changhua_county,
      context.l10n.nantou_county,
      context.l10n.yunlin_county,
      context.l10n.chiayi_city,
      context.l10n.chiayi_county,
      context.l10n.pingtung_county,
      context.l10n.yilan_county,
      context.l10n.hualien_county,
      context.l10n.taitung_city,
      context.l10n.penghu_county,
      context.l10n.kinmen_county,
      context.l10n.lienchiang_county,
      context.l10n.keelung_city,
    ];
    selectedCity = cities.first; // 預設選中第一個城市
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.single_year_view),
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
              decoration: InputDecoration(
                labelText: context.l10n.select_city,
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
              decoration: InputDecoration(
                labelText: context.l10n.select_year,
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
                  city: selectedCity == context.l10n.entire_country ? "Total" : selectedCity,
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