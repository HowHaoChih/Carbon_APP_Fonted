import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class DepartmentPieChart extends StatefulWidget {
  final int year;
  final String city; // 選定的年份

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

  String _getDepartmentName(String key) {
    switch (key) {
      case "Residential":
        return "住宅部門";
      case "Services":
        return "服務業";
      case "Energy":
        return "能源部門";
      case "Manufacturing":
        return "製造業";
      case "Transportation":
        return "運輸業";
      case "Electricity":
        return "電力部門";
      default:
        return key;
    }
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
    final residentialData = await rootBundle.loadString(
        'assets/data/ResidentialSector_CarbonEmissions_10ktonCO2e.csv');
    final servicesData = await rootBundle.loadString(
        'assets/data/ServiceIndustry_CarbonEmissions_10ktonCO2e.csv');
    final energyData = await rootBundle
        .loadString('assets/data/EnergySector_CarbonEmissions_10ktonCO2e.csv');
    final manufacturingData = await rootBundle.loadString(
        'assets/data/ManufacturingAndConstruction_CarbonEmissions_10ktonCO2e.csv');
    final transportationData = await rootBundle.loadString(
        'assets/data/TransportationSector_CarbonEmissions_10ktonCO2e.csv');
    final electricityData = await rootBundle
        .loadString('assets/data/Electricity_CarbonEmissions_10ktonCO2e.csv');

    final allDataFiles = {
      "Residential": residentialData,
      "Services": servicesData,
      "Energy": energyData,
      "Manufacturing": manufacturingData,
      "Transportation": transportationData,
      "Electricity": electricityData,
    };

    departmentData = {};

    // 解析每個部門的資料
    for (final department in allDepartments) {
      final data = allDataFiles[department];
      if (data != null) {
        final rows = const LineSplitter().convert(data);
        for (var i = 1; i < rows.length; i++) {
          final row = rows[i].split(',');
          final year = int.parse(row[0]);
          final cityIndex = _getCityIndex(widget.city);
          final value = double.parse(row[cityIndex]); // 根據選定的城市取值
          if (year == widget.year) {
            departmentData[department] = value;
            break;
          }
        }
      }
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: departmentData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : PieChart(
                PieChartData(
                  sections: _getSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                ),
              ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    return departmentData.entries.map((entry) {
      final departmentKey = entry.key;
      final department = _getDepartmentName(departmentKey);
      final value = entry.value;
      final color = _getColorForDepartment(departmentKey);
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${value.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
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
