import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import '../utils/department_utils.dart';
import '../utils/city_utils.dart';
import 'dart:convert';
import 'dart:math';

class MonthlyStackedBarAndLineChart extends StatefulWidget {
  final String city; // 城市名稱
  final Set<String> selectedDepartments; // 選擇的產業
  final int selectedYear; // 指定年份

  const MonthlyStackedBarAndLineChart({
    required this.city,
    required this.selectedDepartments,
    required this.selectedYear,
    super.key,
  });

  @override
  State<MonthlyStackedBarAndLineChart> createState() =>
      _MonthlyStackedBarAndLineChartState();
}

class _MonthlyStackedBarAndLineChartState
    extends State<MonthlyStackedBarAndLineChart> {
  List<BarChartGroupData> barGroups = [];
  List<FlSpot> lineData = [];
  double adjustedMaxValue = 0;

  final List<String> allDepartments = DepartmentUtils.getAllDepartments();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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

    final cityIndex = CityUtils.getCityIndex(widget.city, context);
    final allDataFiles = {
      "Residential": residentialData,
      "Services": servicesData,
      "Energy": energyData,
      "Manufacturing": manufacturingData,
      "Transportation": transportationData,
      "Electricity": electricityData,
    };

    Map<String, List<double>> departmentData = {};
    for (final department in allDepartments) {
      departmentData[department] = List.filled(12, 0);
      final data = allDataFiles[department];
      if (data != null) {
        final rows = const LineSplitter().convert(data);
        for (var i = 1; i < rows.length; i++) {
          final row = rows[i].split(',');
          final year = int.parse(row[0]);
          final month = int.parse(row[1]);
          if (year == widget.selectedYear) {
            final value = double.parse(row[cityIndex]);
            departmentData[department]![month - 1] += value;
          }
        }
      }
    }

    _generateChartData(departmentData);
  }

  void _generateChartData(Map<String, List<double>> departmentData) {
    barGroups = [];
    lineData = [];
    for (int monthIndex = 0; monthIndex < 12; monthIndex++) {
      double stackBottom = 0;
      double total = 0;
      final rodStackItems = allDepartments.map((department) {
        final value = widget.selectedDepartments.contains(department)
            ? departmentData[department]![monthIndex]
            : 0;
        total += value;

        final stackItem = BarChartRodStackItem(
          stackBottom,
          stackBottom + value,
          DepartmentUtils.getDepartmentColor(department,
              isDarkMode: Theme.of(context).brightness == Brightness.dark),
        );
        stackBottom += value;
        return stackItem;
      }).toList();

      barGroups.add(BarChartGroupData(
        x: monthIndex,
        barRods: [
          BarChartRodData(
            toY: stackBottom,
            rodStackItems: rodStackItems,
            width: 15,
          ),
        ],
      ));

      lineData.add(FlSpot(monthIndex.toDouble(), total));
    }

    adjustedMaxValue = _adjustMaxValue(
        barGroups.fold(0, (prev, group) => max(prev, group.barRods[0].toY)));

    setState(() {});
  }

  double _adjustMaxValue(double value) {
    return value == 0 ? 0 : (value * 1.1).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: barGroups.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 左側刻度
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0), // 與圖表分隔
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final value = (adjustedMaxValue / 5 * index).toInt();
                        return Text(
                          value.toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      }).reversed.toList(),
                    ),
                  ),
                  // 圖表區域
                  Expanded(
                    child: Stack(
                      children: [
                        BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups: barGroups,
                            gridData: FlGridData(
                              show: true,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    if (value < 0 || value >= 12) {
                                      return const Text('');
                                    }
                                    return Text('${(value + 1).toInt()}',
                                        style: const TextStyle(fontSize: 10));
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            maxY: adjustedMaxValue,
                          ),
                        ),
                        LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: lineData,
                                isCurved: true,
                                barWidth: 2,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey
                                    : Colors.black,
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            titlesData: FlTitlesData(show: false),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            minX: -0.5,
                            maxX: 11.5,
                            minY: 0,
                            maxY: adjustedMaxValue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
