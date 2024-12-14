import 'package:flutter/material.dart';
import '../widgets/stacked_bar_and_line_chart.dart'; // 引入堆疊柱狀圖與折線圖的 widget
import '../utils/department_utils.dart'; // 引入 department_utils.dart
import '../utils/city_utils.dart';

class IndustryViewScreen extends StatefulWidget {
  const IndustryViewScreen({super.key});

  @override
  State<IndustryViewScreen> createState() => _IndustryViewScreenState();
}

class _IndustryViewScreenState extends State<IndustryViewScreen> {
  // 縣市列表
  final List<String> cities = CityUtils.getCountiesWithNation();

  // 產業列表
  final List<String> allDepartments = DepartmentUtils.getAllDepartments();

  // 選中的縣市
  String selectedCity = "台北市";

  // 選中的產業
  Set<String> selectedDepartments = DepartmentUtils.getAllDepartments().toSet();

  @override
  Widget build(BuildContext context) {
    // 將產業列表分為 2 行
    final departmentList = allDepartments;
    final firstRow =
        departmentList.sublist(0, (departmentList.length / 2).ceil());
    final secondRow =
        departmentList.sublist((departmentList.length / 2).ceil());

    return Scaffold(
      appBar: AppBar(
        title: const Text('產業視圖'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16), // 增加間距
          // 縣市選擇器
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: selectedCity,
              items: cities.map((county) {
                return DropdownMenuItem(
                  value: county,
                  child: Text(county),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCity = value; // 更新選中的縣市
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: "選擇縣市",
                border: OutlineInputBorder(),
              ),
              menuMaxHeight: 400, // 設置最大展開高度
            ),
          ),
          const SizedBox(height: 16), // 增加間距
          // 產業篩選器
          Column(
            children: [
              // 第一行
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: firstRow.map((department) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FilterChip(
                      label: Text(
                        DepartmentUtils.getDepartmentName(
                            department), // 使用工具類獲取繁體中文名稱
                      ),
                      selected: selectedDepartments.contains(department),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDepartments = Set.from(selectedDepartments)
                              ..add(department);
                          } else {
                            selectedDepartments = Set.from(selectedDepartments)
                              ..remove(department);
                          }
                        });
                      },
                      backgroundColor:
                          DepartmentUtils.getDepartmentColor(department)
                              .withOpacity(0.3), // 未選中背景色對應產業顏色
                      selectedColor:
                          DepartmentUtils.getDepartmentColor(department)
                              .withOpacity(0.6), // 選中背景色對應產業顏色
                      labelStyle: const TextStyle(
                        color: Colors.black, // 文字顏色
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8), // 行間距
              // 第二行
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: secondRow.map((department) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FilterChip(
                      label: Text(
                        DepartmentUtils.getDepartmentName(
                            department), // 使用工具類獲取繁體中文名稱
                      ),
                      selected: selectedDepartments.contains(department),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDepartments = Set.from(selectedDepartments)
                              ..add(department);
                          } else {
                            selectedDepartments = Set.from(selectedDepartments)
                              ..remove(department);
                          }
                        });
                      },
                      backgroundColor:
                          DepartmentUtils.getDepartmentColor(department)
                              .withOpacity(0.3), // 未選中背景色對應產業顏色
                      selectedColor:
                          DepartmentUtils.getDepartmentColor(department)
                              .withOpacity(0.6), // 選中背景色對應產業顏色
                      labelStyle: const TextStyle(
                        color: Colors.black, // 文字顏色
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16), // 增加間距
          // 圖表展示
          SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.4, // 將圖表高度設置為屏幕高度的 40%
            child: Row(
              children: [
                const SizedBox(width: 16), // 左側新增 16 像素的空白
                Expanded(
                  child: StackedBarAndLineChart(
                    city: selectedCity == "全國"
                        ? "Total"
                        : selectedCity, // 傳入 "Total" 或縣市名稱
                    selectedDepartments: selectedDepartments, // 傳入選中的產業
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
