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

  /// 加載數據並處理為可視化所需的格式
  void loadData() async {
    // 加載所有 CSV 檔案
    final totalEmissionData = await rootBundle.loadString(
        'assets/data/TotalCarbonEmissions_AllSectors_10ktonCO2e.csv');
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

    // 使用 LineSplitter 將資料行分割
    final totalRows = const LineSplitter().convert(totalEmissionData);
    final residentialRows = const LineSplitter().convert(residentialData);
    final servicesRows = const LineSplitter().convert(servicesData);
    final energyRows = const LineSplitter().convert(energyData);
    final manufacturingRows = const LineSplitter().convert(manufacturingData);
    final transportationRows = const LineSplitter().convert(transportationData);
    final electricityRows = const LineSplitter().convert(electricityData);

    // 定義所有部門資料
    final allDepartments = {
      "Residential": residentialRows,
      "Services": servicesRows,
      "Energy": energyRows,
      "Manufacturing": manufacturingRows,
      "Transportation": transportationRows,
      "Electricity": electricityRows,
    };

    // 定義年份範圍
    final yearRange = List<int>.generate(2024 - 1990, (i) => 1990 + i);

    // 逐部門處理數據
    departmentData = {};
    for (final department in allDepartments.keys) {
      departmentData[department] = List<double>.filled(yearRange.length, 0);
      for (var i = 1; i < allDepartments[department]!.length; i++) {
        final row = allDepartments[department]![i].split(',');
        final year = int.parse(row[0]);
        final value = double.parse(row[2]); // 部門的數據在第 3 欄
        if (year >= 1990 && year <= 2023) {
          departmentData[department]![year - 1990] += value;
        }
      }
    }

    // 計算總碳排放量並生成趨勢線
    years = yearRange;
    totalEmissions = List<double>.filled(yearRange.length, 0);
    for (var i = 0; i < yearRange.length; i++) {
      for (final department in departmentData.keys) {
        totalEmissions[i] += departmentData[department]![i];
      }
    }

    // 生成 BarChartGroupData
    barGroups = List.generate(yearRange.length, (index) {
      double stackBottom = 0;
      final rods = departmentData.keys.map((department) {
        final value = departmentData[department]![index];
        final rod = BarChartRodData(
          fromY: stackBottom,
          toY: stackBottom + value, // 從下到上堆疊
          color: _getColorForDepartment(department),
          width: 8, // 控制柱狀圖寬度
        );
        stackBottom += value; // 更新堆疊基底
        return rod;
      }).toList();
      return BarChartGroupData(
        x: years[index], // 使用年份作為 x 軸值
        barRods: rods,
        barsSpace: 0, // 避免內部柱子之間的間距
      );
    });

    // 生成趨勢線
    trendLine = List.generate(
      years.length,
      (index) => FlSpot(years[index].toDouble(), totalEmissions[index]),
    );

    setState(() {});
  }

  /// 根據部門名稱分配顏色
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1000, // 確保寬度能顯示所有年份
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            getTitlesWidget: (value, _) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      barTouchData: BarTouchData(enabled: true),
                      gridData: FlGridData(show: true),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: totalEmissions.isNotEmpty
                                ? totalEmissions.last
                                : 0,
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
