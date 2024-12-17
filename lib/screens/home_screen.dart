import 'package:flutter/material.dart';
import '../widgets/stacked_bar_and_line_chart.dart'; // 引入碳排放圖表的 widget
import '../widgets/department_legend.dart'; // 引入部門圖例的 widget
import '../utils/department_utils.dart';
import '../utils/city_utils.dart';
import '../l10n/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 預設選擇的城市名稱
  late String selectedCity;

  // 所有產業選項
  final List<String> allDepartments = DepartmentUtils.getAllDepartments();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在 context 可用時初始化 selectedCity
    selectedCity = context.l10n.taipei_city;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 全國碳排放趨勢圖表 (居中顯示)
            Expanded(
              flex: 2,
              child: Center(
                child: SizedBox(
                  width: size.width * 0.9,
                  height: size.height * 0.4,
                  child: StackedBarAndLineChart(
                    city: context.l10n.entire_country,
                    selectedDepartments: allDepartments.toSet(),
                  ),
                ),
              ),
            ),
            // 城市選擇下拉選單
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                value: CityUtils.getCountyList(context).contains(selectedCity) 
                  ? selectedCity 
                  : null, // 如果無效則設定為 null
                items: CityUtils.getCountyList(context).map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value!;
                  });
                },
              ),
            ),
            // 城市碳排放趨勢圖表 (居中顯示)
            Expanded(
              flex: 2,
              child: Center(
                child: SizedBox(
                  width: size.width * 0.9,
                  height: size.height * 0.4,
                  child: StackedBarAndLineChart(
                    city: selectedCity,
                    selectedDepartments: allDepartments.toSet(),
                  ),
                ),
              ),
            ),
            // 部門圖例
            Container(
              margin: const EdgeInsets.only(left: 16.0, right: 8.0),
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
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