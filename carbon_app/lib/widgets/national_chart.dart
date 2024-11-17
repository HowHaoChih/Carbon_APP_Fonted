import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class NationalChart extends StatefulWidget {
  const NationalChart({super.key});

  @override
  State<NationalChart> createState() => _NationalChartState();
}

class _NationalChartState extends State<NationalChart> {
  List<BarChartGroupData> barGroups = [];
  List<FlSpot> trendLine = [];
  List<int> years = [];
  List<double> totalEmissions = [];
  Map<String, List<double>> departmentData = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    // Load CSV files
    final totalEmissionData =
        await rootBundle.loadString('assets/總碳排(各部門加總)_10ktonCO2e.csv');
    final residentialData =
        await rootBundle.loadString('assets/住宅部門碳排_10ktonCO2e.csv');
    final servicesData =
        await rootBundle.loadString('assets/服務業部門碳排_10ktonCO2e.csv');
    final energyData = await rootBundle.loadString('assets/能源部門碳排_10ktonCO2e.csv');
    final manufacturingData =
        await rootBundle.loadString('assets/製造業與營造業碳排_10ktonCO2e.csv');
    final transportationData =
        await rootBundle.loadString('assets/運輸部門碳排_10ktonCO2e.csv');
    final electricityData =
        await rootBundle.loadString('assets/電力碳排_10ktonCO2e.csv');

    // Parse CSV data
    final totalRows = const LineSplitter().convert(totalEmissionData);
    final residentialRows = const LineSplitter().convert(residentialData);
    final servicesRows = const LineSplitter().convert(servicesData);
    final energyRows = const LineSplitter().convert(energyData);
    final manufacturingRows = const LineSplitter().convert(manufacturingData);
    final transportationRows = const LineSplitter().convert(transportationData);
    final electricityRows = const LineSplitter().convert(electricityData);

    final allDepartments = {
      "Residential": residentialRows,
      "Services": servicesRows,
      "Energy": energyRows,
      "Manufacturing": manufacturingRows,
      "Transportation": transportationRows,
      "Electricity": electricityRows,
    };

    final yearRange = List<int>.generate(2024 - 1990, (i) => 1990 + i);

    // Process data for each department
    departmentData = {};
    for (final department in allDepartments.keys) {
      departmentData[department] = List<double>.filled(yearRange.length, 0);
      for (var i = 1; i < allDepartments[department]!.length; i++) {
        final row = allDepartments[department]![i].split(',');
        final year = int.parse(row[0]);
        final value = double.parse(row[2]); // Column 3 for each department
        if (year >= 1990 && year <= 2023) {
          departmentData[department]![year - 1990] += value;
        }
      }
    }

    // Total emissions and trend line
    years = yearRange;
    totalEmissions = List<double>.filled(yearRange.length, 0);
    for (var i = 0; i < yearRange.length; i++) {
      for (final department in departmentData.keys) {
        totalEmissions[i] += departmentData[department]![i];
      }
    }

    // Generate BarChartGroupData
    barGroups = years.map((year) {
      final index = year - 1990;
      double stackBottom = 0;
      final rods = departmentData.keys.map((department) {
        final value = departmentData[department]![index];
        final rod = BarChartRodData(toY: value + stackBottom, color: _getColorForDepartment(department));
        stackBottom += value;
        return rod;
      }).toList();
      return BarChartGroupData(x: year, barRods: rods);
    }).toList();

    // Generate trend line
    trendLine = List.generate(
      years.length,
      (index) => FlSpot(years[index].toDouble(), totalEmissions[index]),
    );

    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: barGroups.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) =>
                            Text(value.toInt().toString()),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    extraLinesOnTop: true,
                    horizontalLines: [
                      HorizontalLine(
                        y: trendLine.isNotEmpty
                            ? trendLine.last.y
                            : 0, // Plot the trend line
                        color: Colors.black,
                        strokeWidth: 2,
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
