import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import '../utils/department_utils.dart';
import '../utils/city_utils.dart';
import 'dart:convert';

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
  Map<String, double> departmentData = {};

  final List<String> allDepartments = DepartmentUtils.getAllDepartments();

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
    double totalDepartmentValue = 0;

    // 解析每個部門的資料
    for (final department in allDepartments) {
      final data = allDataFiles[department];
      if (data != null) {
        final rows = const LineSplitter().convert(data);
        for (var i = 1; i < rows.length; i++) {
          final row = rows[i].split(',');
          final year = int.parse(row[0]);
          final cityIndex = CityUtils.getCityIndex(widget.city, context);
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
    final size = MediaQuery.of(context).size;

    // 其他部件的總高度（根據之前計算得出）
    const double otherComponentsHeight = 270.0; // 包括 AppBar、高度和其他間距
    final double availableHeight =
        size.height - otherComponentsHeight; // 剩餘可用高度
    final double maxDimension =
        availableHeight < size.width ? availableHeight : size.width;

    final double radius = maxDimension * 0.3; // 將 radius 限制為可用尺寸的 30%
    final double pieChartSize = maxDimension * 0.8; // 圖表寬高限制為可用尺寸的 80%

    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: departmentData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: pieChartSize, // 設定動態寬度
                      height: pieChartSize, // 設定動態高度
                      child: PieChart(
                        PieChartData(
                          sections: _getSections(radius),
                          sectionsSpace: 1,
                          centerSpaceRadius: radius / 3,
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

  List<PieChartSectionData> _getSections(double radius) {
    return departmentData.entries.map((entry) {
      final departmentKey = entry.key;
      final value = entry.value;
      final color = DepartmentUtils.getDepartmentColor(departmentKey, isDarkMode: Theme.of(context).brightness == Brightness.dark,);
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${value.toStringAsFixed(1)}%',
        radius: radius, // 根據動態計算的 radius 設定
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 28, 28, 28),
        ),
      );
    }).toList();
  }
}
