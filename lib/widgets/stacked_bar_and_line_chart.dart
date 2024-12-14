import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import '../utils/department_utils.dart';
import '../utils/city_utils.dart';
import 'dart:convert';
import 'dart:math';

class StackedBarAndLineChart extends StatefulWidget {
  final String city; // 城市名稱
  final Set<String> selectedDepartments; // 傳入的選中產業

  const StackedBarAndLineChart({
    required this.city,
    required this.selectedDepartments,
    super.key,
  });

  @override
  State<StackedBarAndLineChart> createState() => _StackedBarAndLineChartState();
}

class _StackedBarAndLineChartState extends State<StackedBarAndLineChart> {
  List<BarChartGroupData> barGroups = [];
  List<FlSpot> lineData = []; // 折線圖數據點
  List<int> years = [];
  Map<String, List<double>> departmentData = {};
  double adjustedMaxValue = 0; // 調整後的最大值（取整）

  final List<String> allDepartments =
      DepartmentUtils.getAllDepartments(); // 固定產業順序

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(StackedBarAndLineChart oldWidget) {
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

    final cityIndex = CityUtils.getCityIndex(widget.city);
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

        // 使用靜態方法獲取顏色
        final color = DepartmentUtils.getDepartmentColor(department);

        final stackItem = BarChartRodStackItem(
          stackBottom,
          stackBottom + value, // 堆疊到新高度
          color, // 部門顏色
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
            borderRadius: BorderRadius.zero, // 確保柱狀條沒有圓角
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 600; // 判斷是否為寬螢幕

    return Center(
      child: SizedBox(
        width: isWideScreen ? size.width * 0.8 : null, // 寬螢幕時限制寬度
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左側固定的數量級刻度
            Padding(
              padding: const EdgeInsets.only(bottom: 22.0), // 提高底部位置
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // 刻度間隙更均勻
                children: List.generate(6, (index) {
                  final value = (adjustedMaxValue / 5 * index).toInt();
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3.0), // 減小刻度之間的間距
                    child: Text(
                      value.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }).reversed.toList(),
              ),
            ),
            const SizedBox(width: 5),
            // 柱狀圖部分
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController, // 添加滾動控制器
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1000, // 每組柱狀圖固定寬度
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context)
                        .scaffoldBackgroundColor, // 設置 Card 的背景顏色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: barGroups.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : Stack(
                              children: [
                                BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.center,
                                    groupsSpace: 20, // 柱間間距
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
                                              style:
                                                  const TextStyle(fontSize: 10),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                    ),
                                    barTouchData: BarTouchData(enabled: true),
                                    gridData: FlGridData(
                                      show: true,
                                      getDrawingHorizontalLine: (value) =>
                                          FlLine(
                                        color: Colors.grey.withOpacity(0.2),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    // backgroundColor: Theme.of(context)
                                    //     .scaffoldBackgroundColor, // 設置背景顏色
                                  ),
                                ),
                                LineChart(
                                  LineChartData(
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: lineData,
                                        isCurved: true,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey // 在黑暗模式中顯示灰色
                                            : Colors.black, // 在亮模式中顯示黑色
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
        ),
      ),
    );
  }
}
