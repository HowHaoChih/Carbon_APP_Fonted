import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import '../utils/department_utils.dart';
import '../utils/city_utils.dart';

class DepartmentPieChart extends StatefulWidget {
  final int year;
  final String city;
  final int? month;
  final String? title; // 新增可選標題

  const DepartmentPieChart({
    required this.year,
    required this.city,
    this.month,
    this.title, // 默認為 null
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
    departmentData = {};
    setState(() {});
    final allDataFiles = {
      "Residential": await rootBundle.loadString(
          'assets/data/ResidentialSector_CarbonEmissions_10ktonCO2e.csv'),
      "Services": await rootBundle.loadString(
          'assets/data/ServiceIndustry_CarbonEmissions_10ktonCO2e.csv'),
      "Energy": await rootBundle.loadString(
          'assets/data/EnergySector_CarbonEmissions_10ktonCO2e.csv'),
      "Manufacturing": await rootBundle.loadString(
          'assets/data/ManufacturingAndConstruction_CarbonEmissions_10ktonCO2e.csv'),
      "Transportation": await rootBundle.loadString(
          'assets/data/TransportationSector_CarbonEmissions_10ktonCO2e.csv'),
      "Electricity": await rootBundle
          .loadString('assets/data/Electricity_CarbonEmissions_10ktonCO2e.csv'),
    };

    double totalDepartmentValue = 0;

    for (final department in allDepartments) {
      final data = allDataFiles[department];
      if (data != null) {
        final rows = const LineSplitter().convert(data);
        for (var i = 1; i < rows.length; i++) {
          final row = rows[i].split(',');
          final year = int.parse(row[0]);
          final month = row.length > 1 ? int.parse(row[1]) : null;
          final cityIndex = CityUtils.getCityIndex(widget.city, context);
          final value = double.parse(row[cityIndex]);

          if (year == widget.year &&
              (widget.month == null || month == widget.month)) {
            departmentData.update(department, (v) => v + value,
                ifAbsent: () => value);
            totalDepartmentValue += value;
          }
        }
      }
    }

    for (final department in departmentData.keys) {
      final value = departmentData[department]!;
      departmentData[department] = (value / totalDepartmentValue) * 100;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const double otherComponentsHeight = 270.0;
    final double availableHeight = size.height - otherComponentsHeight;
    final double maxDimension =
        availableHeight < size.width ? availableHeight : size.width;
    final double radius = maxDimension * 0.3;
    final double pieChartSize = maxDimension * 0.8;

    return SingleChildScrollView(
      child: Column(
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
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
                      width: pieChartSize,
                      height: pieChartSize,
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
      final color = DepartmentUtils.getDepartmentColor(
        departmentKey,
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      );
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${value.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 28, 28, 28),
        ),
      );
    }).toList();
  }
}
