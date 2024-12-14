import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import '../services/db_service.dart';
import '../services/getdata.dart';

class DepartmentPieChart extends StatefulWidget {
  final int year;
  final String city;

  const DepartmentPieChart({
    required this.year,
    required this.city,
    super.key,
  });

  @override
  State<DepartmentPieChart> createState() => _DepartmentPieChartState();
}

class _DepartmentPieChartState extends State<DepartmentPieChart> {
  int _getCityIndex(String city) {
    final cities = [
      "Total",
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
    return cities.indexOf(city) + 2;
  }

  Map<String, double> departmentData = {};

  final List<String> allDepartments = [
    "Residential",
    "Services",
    "Energy",
    "Manufacturing",
    "Transportation",
    "Electricity"
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    departmentData = {}; // 清空舊資料
    setState(() {});
    // 連接資料庫
    final dbService = DBService();
    await dbService.initializeConnection();
    final userRepository = UserRepository(dbService);
    // 取得各部門資料
    final residentialData = await userRepository.GetData('public.house_data');
    final servicesData = await userRepository.GetData('public.service_data');
    final energyData = await userRepository.GetData('public.energy_data');
    final manufacturingData =
        await userRepository.GetData('public.manufacturing_data');
    final transportationData =
        await userRepository.GetData('public.trans_data');
    final electricityData = await userRepository.GetData('public.elec_data');
    // 預測模型資料，範圍 : 2024年到2026年
    final predict_residentialData =
        await userRepository.GetData('public.predict_house_data');
    final predict_servicesData =
        await userRepository.GetData('public.predict_service_data');
    final predict_energyData =
        await userRepository.GetData('public.predict_energy_data');
    final predict_manufacturingData =
        await userRepository.GetData('public.predict_manufacturing_data');
    final predict_transportationData =
        await userRepository.GetData('public.predict_trans_data');
    final predict_electricityData =
        await userRepository.GetData('public.predict_elec_data');
    // 關閉資料庫連結
    dbService.connection.close();

    final allDataFiles = {
      "Residential": residentialData,
      "Services": servicesData,
      "Energy": energyData,
      "Manufacturing": manufacturingData,
      "Transportation": transportationData,
      "Electricity": electricityData,
    };

    departmentData = {};
    double totalDepartmentValue = 0;

    // 解析每個部門的資料
    for (final department in allDepartments) {
      final data = allDataFiles[department];
      if (data != null) {
        for (var row in data) {
          final year = int.parse(row[0]);
          final cityIndex = _getCityIndex(widget.city);
          final value = double.parse(row[cityIndex]); // 根據選定的城市取值
          if (year == widget.year) {
            departmentData[department] = value;
            totalDepartmentValue += value;
            break;
          }
        }
      }
    }
    for (final department in allDepartments) {
      final value = departmentData[department]!;
      departmentData[department] = value / totalDepartmentValue * 100;
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(DepartmentPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year || oldWidget.city != widget.city) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: departmentData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : AspectRatio(
                      aspectRatio: 1.2,
                      child: PieChart(
                        PieChartData(
                          sections: _getSections(),
                          sectionsSpace: 1,
                          centerSpaceRadius: 30,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    return departmentData.entries.map((entry) {
      final departmentKey = entry.key;
      // final department = _getDepartmentName(departmentKey);
      final value = entry.value;
      final color = _getColorForDepartment(departmentKey);
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${value.toStringAsFixed(1)}%',
        radius: 90,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 28, 28, 28),
        ),
      );
    }).toList();
  }

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
}
