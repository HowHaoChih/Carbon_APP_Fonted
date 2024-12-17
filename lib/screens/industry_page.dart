import 'package:flutter/material.dart';
import '../widgets/stacked_bar_and_line_chart.dart'; // 引入堆疊柱狀圖與折線圖的 widget
import '../utils/department_utils.dart'; // 引入 department_utils.dart
import '../utils/city_utils.dart';
import '../l10n/l10n.dart';

class IndustryViewScreen extends StatefulWidget {
  final String? initialCity;
  final List<String>? initialIndustries;

  const IndustryViewScreen({
    super.key,
    this.initialCity,
    this.initialIndustries,
  });

  @override
  State<IndustryViewScreen> createState() => _IndustryViewScreenState();
}

class _IndustryViewScreenState extends State<IndustryViewScreen> {
  // 選中的城市
  late String selectedCity;

  // 產業列表
  final List<String> allDepartments = DepartmentUtils.getAllDepartments();

  // 縣市列表
  late List<String> cities;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在此時初始化 cities 並設定預設選中的城市
    cities = CityUtils.getCountiesWithNation(context);
    selectedCity = widget.initialCity ?? cities.first; // 預設選中第一個城市
    if (widget.initialIndustries != null) {
      selectedDepartments = widget.initialIndustries!.toSet();
    } else {
      selectedDepartments = allDepartments.toSet();
    }
  }

  // 選中的產業
  Set<String> selectedDepartments = DepartmentUtils.getAllDepartments().toSet();

  @override
  Widget build(BuildContext context) {
    // 將產業列表分為 2 行
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; // 判斷是否為黑暗模式
    final departmentList = allDepartments;
    final firstRow =
        departmentList.sublist(0, (departmentList.length / 2).ceil());
    final secondRow =
        departmentList.sublist((departmentList.length / 2).ceil());

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.industry_view),
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
              decoration: InputDecoration(
                labelText: context.l10n.select_city,
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
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: Text(
                        DepartmentUtils.getDepartmentName(context, department),
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
                      backgroundColor: isDarkMode
                          ? Colors.black.withOpacity(0.1) // 暗色模式下的空心背景
                          : Colors.white.withOpacity(0.9), // 亮色模式下的空心背景
                      selectedColor: DepartmentUtils.getDepartmentColor(
                        department,
                        isDarkMode: isDarkMode,
                      ).withOpacity(1.0), // 選中時的背景色
                      side: BorderSide(
                        color: DepartmentUtils.getDepartmentColor(
                          department,
                          isDarkMode: isDarkMode,
                        ),
                        width: 2.0, // 邊框寬度
                      ),
                      labelStyle: TextStyle(
                        color: selectedDepartments.contains(department)
                          ? Colors.black // 選中時字體顏色為黑色
                          : (isDarkMode ? Colors.white : Colors.black), // 未選中時依據模式設定
                        fontSize: 14,
                      ),
                      checkmarkColor: Colors.black, // 勾勾的顏色設置為黑色
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
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: Text(
                        DepartmentUtils.getDepartmentName(context, department),
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
                      backgroundColor: isDarkMode
                          ? Colors.black.withOpacity(0.1) // 暗色模式下的空心背景
                          : Colors.white.withOpacity(0.9), // 亮色模式下的空心背景
                      selectedColor: DepartmentUtils.getDepartmentColor(
                        department,
                        isDarkMode: isDarkMode,
                      ).withOpacity(1.0), // 選中時的背景色
                      side: BorderSide(
                        color: DepartmentUtils.getDepartmentColor(
                          department,
                          isDarkMode: isDarkMode,
                        ),
                        width: 2.0, // 邊框寬度
                      ),
                      labelStyle: TextStyle(
                        color: selectedDepartments.contains(department)
                          ? Colors.black // 選中時字體顏色為黑色
                          : (isDarkMode ? Colors.white : Colors.black), // 未選中時依據模式設定
                        fontSize: 14,
                      ),
                      checkmarkColor: Colors.black, // 勾勾的顏色設置為黑色
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
                    city: selectedCity, // 傳入 "Total" 或縣市名稱
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
