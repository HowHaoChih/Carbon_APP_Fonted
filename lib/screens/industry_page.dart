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

  Set<String> selectedDepartments = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 初始化城市列表和選中的城市
    cities = CityUtils.getCountiesWithNation(context);

    final cityMap = {
      "context.l10n.taipei_city": context.l10n.taipei_city,
      "context.l10n.new_taipei_city": context.l10n.new_taipei_city,
      "context.l10n.taoyuan_city": context.l10n.taoyuan_city,
      "context.l10n.taizhong_city": context.l10n.taizhong_city,
      "context.l10n.tainan_city": context.l10n.tainan_city,
      "context.l10n.kaohsiung_city": context.l10n.kaohsiung_city,
      "context.l10n.hsinchu_city": context.l10n.hsinchu_city,
      "context.l10n.hsinchu_county": context.l10n.hsinchu_county,
      "context.l10n.miaoli_county": context.l10n.miaoli_county,
      "context.l10n.changhua_county": context.l10n.changhua_county,
      "context.l10n.nantou_county": context.l10n.nantou_county,
      "context.l10n.yunlin_county": context.l10n.yunlin_county,
      "context.l10n.chiayi_city": context.l10n.chiayi_city,
      "context.l10n.chiayi_county": context.l10n.chiayi_county,
      "context.l10n.pingtung_county": context.l10n.pingtung_county,
      "context.l10n.yilan_county": context.l10n.yilan_county,
      "context.l10n.hualien_county": context.l10n.hualien_county,
      "context.l10n.taitung_county": context.l10n.taitung_county,
      "context.l10n.penghu_county": context.l10n.penghu_county,
      "context.l10n.kinmen_county": context.l10n.kinmen_county,
      "context.l10n.lienchiang_county": context.l10n.lienchiang_county,
      "context.l10n.keelung_city": context.l10n.keelung_city,
    };

    selectedCity = cityMap[widget.initialCity] ?? cities.first;

    // 處理產業名稱從原始資料轉換為顯示名稱
    if (widget.initialIndustries != null) {
      final industryMap = {
        "context.l10n.residential": "Residential",
        "context.l10n.services": "Services",
        "context.l10n.energy": "Energy",
        "context.l10n.manufacturing": "Manufacturing",
        "context.l10n.transportation": "Transportation",
        "context.l10n.electricity": "Electricity",
      };

      selectedDepartments = widget.initialIndustries!
          .map((industryKey) => industryMap[industryKey] ?? industryKey)
          .toSet();
    } else {
      selectedDepartments = allDepartments.toSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 將產業列表分為兩行
    final firstRow = allDepartments.sublist(0, (allDepartments.length / 2).ceil());
    final secondRow = allDepartments.sublist((allDepartments.length / 2).ceil());

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.industry_view),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

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
                    selectedCity = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: context.l10n.select_city,
                border: OutlineInputBorder(),
              ),
              menuMaxHeight: 400,
            ),
          ),

          const SizedBox(height: 16),

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
                            selectedDepartments.add(department);
                          } else {
                            selectedDepartments.remove(department);
                          }
                        });
                      },
                      backgroundColor: isDarkMode
                          ? Colors.black.withOpacity(0.1)
                          : Colors.white.withOpacity(0.9),
                      selectedColor: DepartmentUtils.getDepartmentColor(
                        department,
                        isDarkMode: isDarkMode,
                      ).withOpacity(1.0),
                      side: BorderSide(
                        color: DepartmentUtils.getDepartmentColor(
                          department,
                          isDarkMode: isDarkMode,
                        ),
                        width: 2.0,
                      ),
                      labelStyle: TextStyle(
                        color: selectedDepartments.contains(department)
                            ? Colors.black
                            : (isDarkMode ? Colors.white : Colors.black),
                        fontSize: 14,
                      ),
                      checkmarkColor: Colors.black,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

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
                            selectedDepartments.add(department);
                          } else {
                            selectedDepartments.remove(department);
                          }
                        });
                      },
                      backgroundColor: isDarkMode
                          ? Colors.black.withOpacity(0.1)
                          : Colors.white.withOpacity(0.9),
                      selectedColor: DepartmentUtils.getDepartmentColor(
                        department,
                        isDarkMode: isDarkMode,
                      ).withOpacity(1.0),
                      side: BorderSide(
                        color: DepartmentUtils.getDepartmentColor(
                          department,
                          isDarkMode: isDarkMode,
                        ),
                        width: 2.0,
                      ),
                      labelStyle: TextStyle(
                        color: selectedDepartments.contains(department)
                            ? Colors.black
                            : (isDarkMode ? Colors.white : Colors.black),
                        fontSize: 14,
                      ),
                      checkmarkColor: Colors.black,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 圖表展示
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: StackedBarAndLineChart(
                    city: selectedCity,
                    selectedDepartments: selectedDepartments,
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
