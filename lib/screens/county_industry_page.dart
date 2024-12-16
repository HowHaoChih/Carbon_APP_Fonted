import 'package:flutter/material.dart';
import '../widgets/stacked_bar_and_line_chart.dart'; // 引入城市碳排放圖表的 widget
import '../widgets/department_legend.dart'; // 引入部門圖例的 widget
import '../l10n/l10n.dart';

class CountyIndustryViewScreen extends StatefulWidget {
  const CountyIndustryViewScreen({super.key});

  @override
  State<CountyIndustryViewScreen> createState() =>
      _CountyIndustryViewScreenState();
}

class _CountyIndustryViewScreenState extends State<CountyIndustryViewScreen> {
  
  // 縣市列表
  late List<String> cities;
  // 選中的城市
  late String selectedCity;

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

  // 產業列表（英文對應繁體中文）
  final Map<String, String> allDepartments = {
    "Residential": "住宅部門",
    "Services": "服務業",
    "Energy": "能源部門",
    "Manufacturing": "製造業",
    "Transportation": "交通運輸",
    "Electricity": "電力部門"
  };

  // 選中的產業
  Set<String> selectedDepartments = {
    "Residential",
    "Services",
    "Energy",
    "Manufacturing",
    "Transportation",
    "Electricity"
  };

  Color _getColorForDepartment(String department) {
    switch (department) {
      case "Residential":
        return Colors.orange;
      case "Services":
        return Colors.blue;
      case "Energy":
        return Colors.green;
      case "Manufacturing":
        return Colors.purple;
      case "Transportation":
        return Colors.red;
      case "Electricity":
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 將產業列表分為 2 行
    final departmentName = _getDepartmentName(context, departmentKey);
    final firstRow =
        departmentList.sublist(0, (departmentList.length / 2).ceil());
    final secondRow =
        departmentList.sublist((departmentList.length / 2).ceil());

    return Scaffold(
      appBar: AppBar(
        title: const Text('縣市產業視圖'),
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
                children: firstRow.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FilterChip(
                      label: Text(entry.value), // 顯示繁體中文名稱
                      selected: selectedDepartments.contains(entry.key),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDepartments = Set.from(selectedDepartments)
                              ..add(entry.key);
                          } else {
                            selectedDepartments = Set.from(selectedDepartments)
                              ..remove(entry.key);
                          }
                        });
                      },
                      backgroundColor: _getColorForDepartment(entry.key)
                          .withOpacity(0.3), // 未選中背景色對應產業顏色
                      selectedColor: _getColorForDepartment(entry.key)
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
                children: secondRow.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FilterChip(
                      label: Text(entry.value), // 顯示繁體中文名稱
                      selected: selectedDepartments.contains(entry.key),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDepartments = Set.from(selectedDepartments)
                              ..add(entry.key);
                          } else {
                            selectedDepartments = Set.from(selectedDepartments)
                              ..remove(entry.key);
                          }
                        });
                      },
                      backgroundColor: _getColorForDepartment(entry.key)
                          .withOpacity(0.3), // 未選中背景色對應產業顏色
                      selectedColor: _getColorForDepartment(entry.key)
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
                    city: selectedCity, // 傳入選中的縣市
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
