import 'package:flutter/material.dart';
import '../widgets/city_chart.dart'; // 引入城市碳排放圖表的 widget

class CountyIndustryViewScreen extends StatefulWidget {
  const CountyIndustryViewScreen({super.key});

  @override
  State<CountyIndustryViewScreen> createState() =>
      _CountyIndustryViewScreenState();
}

class _CountyIndustryViewScreenState extends State<CountyIndustryViewScreen> {
  // 縣市列表
  final List<String> counties = [
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

  // 產業列表（英文對應繁體中文）
  final Map<String, String> allDepartments = {
    "Residential": "住宅部門",
    "Services": "服務業",
    "Energy": "能源部門",
    "Manufacturing": "製造業",
    "Transportation": "交通運輸",
    "Electricity": "電力部門"
  };

  // 選中的縣市
  String selectedCounty = "台北市";

  // 選中的產業
  Set<String> selectedDepartments = {
    "Residential",
    "Services",
    "Energy",
    "Manufacturing",
    "Transportation",
    "Electricity"
  };

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
        title: const Text('縣市產業視圖'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16), // 增加間距
          // 縣市選擇器
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: selectedCounty,
              items: counties.map((county) {
                return DropdownMenuItem(
                  value: county,
                  child: Text(county),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCounty = value; // 更新選中的縣市
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: "選擇縣市",
                border: OutlineInputBorder(),
              ),
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
                  child: CityChart(
                    city: selectedCounty, // 傳入選中的縣市
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
