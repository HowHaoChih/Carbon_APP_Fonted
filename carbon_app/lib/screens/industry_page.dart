import 'package:flutter/material.dart';
import '../widgets/city_chart.dart'; // 引入城市碳排放圖表的 widget

class IndustryViewScreen extends StatefulWidget {
  const IndustryViewScreen({super.key});

  @override
  State<IndustryViewScreen> createState() => _IndustryViewScreenState();
}

class _IndustryViewScreenState extends State<IndustryViewScreen> {
  // 用於選擇顯示的產業（英文對應繁體中文）
  final Map<String, String> allDepartments = {
    "Residential": "住宅部門",
    "Services": "服務業",
    "Energy": "能源部門",
    "Manufacturing": "製造業",
    "Transportation": "交通運輸",
    "Electricity": "電力部門"
  };

  // 初始選中的產業
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
    final departmentList = allDepartments.entries.toList();
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
          const SizedBox(height: 16), // 增加一些間距
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
          const SizedBox(height: 16), // 增加一些間距
          // 圖表展示
          SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.4, // 將圖表高度設置為屏幕高度的 40%
            child: Row(
              children: [
                const SizedBox(width: 16), // 左側新增 16 像素的空白
                Expanded(
                  child: CityChart(
                    city: "Total", // 顯示全國數據
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
