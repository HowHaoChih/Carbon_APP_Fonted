import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';

class CityChart extends StatefulWidget {
  final String city; // 城市名稱
  final Set<String> selectedDepartments; // 傳入的選中產業

  const CityChart({
    required this.city,
    required this.selectedDepartments,
    super.key,
  });

  @override
  State<CityChart> createState() => _CityChartState();
}

class _CityChartState extends State<CityChart> {
  List<BarChartGroupData> barGroups = [];
  List<FlSpot> lineData = []; // 折線圖數據點
  List<int> years = [];
  Map<String, List<double>> departmentData = {};
  double maxValue = 0; // 用於存儲柱狀圖中的最大值
  double adjustedMaxValue = 0; // 調整後的最大值（取整）

  final List<String> allDepartments = [
    "Residential",
    "Services",
    "Energy",
    "Manufacturing",
    "Transportation",
    "Electricity"
  ]; // 固定產業順序

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(CityChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 檢查城市或選中產業集合是否發生變化
    if (oldWidget.city != widget.city ||
        !_isSetEqual(
            oldWidget.selectedDepartments, widget.selectedDepartments)) {
      _loadData();
    }
  }

  bool _isSetEqual(Set<String> set1, Set<String> set2) {
    // 比較兩個 Set 是否相等
    return set1.length == set2.length && set1.difference(set2).isEmpty;
  }

  void _loadData() async {
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
    final allDataFiles = {
      "Residential": residentialData,
      "Services": servicesData,
      "Energy": energyData,
      "Manufacturing": manufacturingData,
      "Transportation": transportationData,
      "Electricity": electricityData,
    };

    final yearRange = List<int>.generate(2024 - 1990, (i) => 1990 + i);

    departmentData = {};
    maxValue = 0; // 初始化最大值

    // 解析每個部門的資料
    for (final department in allDepartments) {
      final data = allDataFiles[department];
      departmentData[department] = List<double>.filled(yearRange.length, 0);
      if (data != null) {
        final rows = const LineSplitter().convert(data);
        for (var i = 1; i < rows.length; i++) {
          final row = rows[i].split(',');
          final year = int.parse(row[0]);
          final value = double.parse(row[cityIndex]);
          if (year >= 1990 && year <= 2023) {
            departmentData[department]![year - 1990] += value;
          }
        }
      }
    }

    years = yearRange;

    // 生成堆疊棒狀圖資料和折線圖數據
    barGroups = [];
    lineData = [];
    for (var index = 0; index < yearRange.length; index++) {
      double stackBottom = 0;
      double total = 0;
      final rodStackItems = allDepartments.map((department) {
        final value = widget.selectedDepartments.contains(department)
            ? departmentData[department]![index]
            : 0; // 若未勾選，值設為 0
        total += value; // 計算當前年份的總值
        final stackItem = BarChartRodStackItem(
          stackBottom,
          stackBottom + value, // 堆疊到新高度
          _getColorForDepartment(department), // 部門顏色
        );
        stackBottom += value; // 更新堆疊基底
        return stackItem;
      }).toList();

      // 添加柱狀圖資料
      barGroups.add(BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: stackBottom, // 堆疊的總高度
            rodStackItems: rodStackItems, // 堆疊項目
            width: 15, // 柱條寬度
          ),
        ],
      ));

      // 添加折線圖數據點
      lineData.add(FlSpot(index.toDouble(), total));
    }

    // 計算調整後的最大值
    adjustedMaxValue = _adjustMaxValue(
      barGroups.fold<double>(
        0,
        (prev, group) => max(prev, group.barRods[0].toY),
      ),
    );

    // 在數據加載完成後將滾動條移到最右側
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    setState(() {});
  }

  double _adjustMaxValue(double value) {
    if (value == 0) return 0;

    if (value < 10) {
      return value.ceilToDouble(); // 直接返回向上取整的值
    }

    final int magnitude = pow(10, value.toInt().toString().length - 2).toInt();

    final double roundedValue =
        (value / magnitude).ceil() * magnitude.toDouble();

    if (roundedValue > value * 1.1) {
      return (value / magnitude).floor() * magnitude.toDouble();
    }

    return roundedValue;
  }

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左側固定的數量級刻度
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            final value = (adjustedMaxValue / 5 * index).toInt();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text(
                value.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            );
          }).reversed.toList(),
        ),
        const SizedBox(width: 5),
        // 柱狀圖部分
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController, // 添加滾動控制器
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1000,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: barGroups.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                          children: [
                            BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.center,
                                groupsSpace: 20,
                                barGroups: barGroups,
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, _) {
                                        if (value < 0 ||
                                            value >= years.length) {
                                          return const SizedBox();
                                        }
                                        return Text(
                                          years[value.toInt()].toString(),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                barTouchData: BarTouchData(enabled: true),
                                gridData: FlGridData(
                                  show: true,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.grey.withOpacity(0.2),
                                    strokeWidth: 1,
                                  ),
                                ),
                              ),
                            ),
                            LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: lineData,
                                    isCurved: true,
                                    color: Colors.black,
                                    barWidth: 2,
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  show: false, // 隱藏標題
                                ),
                                gridData: FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                minX: -0.75,
                                maxX: 33.75,
                                minY: 0,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
