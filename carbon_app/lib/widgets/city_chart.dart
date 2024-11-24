import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class CityChart extends StatefulWidget {
  final String city;

  const CityChart({required this.city, super.key});

  @override
  State<CityChart> createState() => _CityChartState();
}

class _CityChartState extends State<CityChart> {
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
  @override
  void didUpdateWidget(CityChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city != widget.city) {
      loadData(); // 重新加載新城市的資料
    }
  }

  void loadData() async {
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

    final cityIndex = _getCityIndex(widget.city);
    final allDepartments = {
      "Residential": residentialData,
      "Services": servicesData,
      "Energy": energyData,
      "Manufacturing": manufacturingData,
      "Transportation": transportationData,
      "Electricity": electricityData,
    };

    final yearRange = List<int>.generate(2024 - 1990, (i) => 1990 + i);

    departmentData = {};
    for (final department in allDepartments.keys) {
      departmentData[department] = List<double>.filled(yearRange.length, 0);
      final rows = const LineSplitter().convert(allDepartments[department]!);
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i].split(',');
        final year = int.parse(row[0]);
        final value = double.parse(row[cityIndex]);
        if (year >= 1990 && year <= 2023) {
          departmentData[department]![year - 1990] += value;
        }
      }
    }

    years = yearRange;
    totalEmissions = List<double>.filled(yearRange.length, 0);
    for (var i = 0; i < yearRange.length; i++) {
      for (final department in departmentData.keys) {
        totalEmissions[i] += departmentData[department]![i];
      }
    }

    barGroups = List.generate(yearRange.length, (index) {
      double stackBottom = 0;
      final rods = departmentData.keys.map((department) {
        final value = departmentData[department]![index];
        final rod = BarChartRodData(
          fromY: stackBottom,
          toY: stackBottom + value,
          color: _getColorForDepartment(department),
          width: 8,
        );
        stackBottom += value;
        return rod;
      }).toList();
      return BarChartGroupData(
        x: years[index],
        barRods: rods,
      );
    });

    trendLine = List.generate(
      years.length,
      (index) => FlSpot(years[index].toDouble(), totalEmissions[index]),
    );

    setState(() {});
  }

  int _getCityIndex(String city) {
    final cities = [
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
    return cities.indexOf(city) + 3;
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1000, // 擴大顯示範圍
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
                      groupsSpace: 20, // 增加年份之間的間隔
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
