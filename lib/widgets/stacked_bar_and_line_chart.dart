import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import '../utils/department_utils.dart';
import '../utils/city_utils.dart';
import 'dart:convert';
import 'dart:math';

// 堆疊柱狀圖和折線圖的組件
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
  List<BarChartGroupData> barGroups = []; // 保存柱狀圖的數據
  List<FlSpot> lineData = []; // 保存折線圖的數據點
  List<int> years = []; // 保存年份數據
  Map<String, List<double>> departmentData = {}; // 各部門的年度排放數據
  double adjustedMaxValue = 0; // 調整後的最大值，用於圖表的 Y 軸

  final List<String> allDepartments =
      DepartmentUtils.getAllDepartments(); // 固定的產業順序，用於柱狀圖堆疊順序

  final ScrollController _scrollController = ScrollController(); // 用於控制柱狀圖的橫向滾動

  @override
  void initState() {
    super.initState();
    _loadData(); // 初始化時加載數據
  }

  @override
  void didUpdateWidget(StackedBarAndLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 當城市或選中的產業改變時，重新加載數據
    if (oldWidget.city != widget.city ||
        !_isSetEqual(
            oldWidget.selectedDepartments, widget.selectedDepartments)) {
      _loadData();
    }
  }

  // 判斷兩個 Set 是否相等
  bool _isSetEqual(Set<String> set1, Set<String> set2) {
    return set1.length == set2.length && set1.difference(set2).isEmpty;
  }

  // 加載數據
  void _loadData() async {
    // 讀取 CSV 文件
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

    // 獲取當前選擇城市的索引
    final cityIndex = CityUtils.getCityIndex(widget.city, context);

    // 將所有文件按部門分類存入 Map
    final allDataFiles = {
      "Residential": residentialData,
      "Services": servicesData,
      "Energy": energyData,
      "Manufacturing": manufacturingData,
      "Transportation": transportationData,
      "Electricity": electricityData,
    };

    // 年份範圍
    final yearRange = List<int>.generate(2024 - 1990, (i) => 1990 + i);

    departmentData = {}; // 重置部門數據

    // 解析每個部門的數據
    for (final department in allDepartments) {
      final data = allDataFiles[department]; // 對應部門的數據
      departmentData[department] =
          List<double>.filled(yearRange.length, 0); // 初始化數據列表
      if (data != null) {
        final rows = const LineSplitter().convert(data); // 分割 CSV 行
        for (var i = 1; i < rows.length; i++) {
          // 跳過標題行
          final row = rows[i].split(','); // 分割每行的數據
          final year = int.parse(row[0]); // 讀取年份
          final value = double.parse(row[cityIndex]); // 對應城市的值
          if (year >= 1990 && year <= 2023) {
            departmentData[department]![year - 1990] += value; // 累加排放數據
          }
        }
      }
    }

    years = yearRange; // 設置年份數據

    // 生成柱狀圖和折線圖數據
    barGroups = [];
    lineData = [];
    for (var index = 0; index < yearRange.length; index++) {
      double stackBottom = 0; // 堆疊柱狀圖的初始高度
      double total = 0; // 當前年份的總排放量
      final rodStackItems = allDepartments.map((department) {
        final value = widget.selectedDepartments.contains(department)
            ? departmentData[department]![index]
            : 0; // 如果未選中該部門，數值為 0
        total += value;

        // 創建堆疊項
        final stackItem = BarChartRodStackItem(
          stackBottom,
          stackBottom + value, // 新的高度
          DepartmentUtils.getDepartmentColor(
            department,
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
          ), // 部門顏色
        );
        stackBottom += value; // 更新基底高度
        return stackItem;
      }).toList();

      // 添加柱狀圖數據
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

    // 在數據加載完成後自動滾動到最右側
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    setState(() {}); // 刷新界面
  }

  // 調整最大值到整數的邏輯
  double _adjustMaxValue(double value) {
    if (value == 0) return 0;

    if (value < 10) {
      return value.ceilToDouble(); // 小於 10 直接取整
    }

    final int magnitude =
        pow(10, value.toInt().toString().length - 2).toInt(); // 計算數量級

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
    final bool isWideScreen = size.width > 600; // 判斷是否為寬屏

    return Center(
      child: SizedBox(
        width: isWideScreen ? size.width * 0.8 : null, // 寬螢幕時限制寬度
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左側的刻度
            Padding(
              padding: const EdgeInsets.only(bottom: 22.0), // 調整位置
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(6, (index) {
                  final value = (adjustedMaxValue / 5 * index).toInt();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Text(
                      value.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }).reversed.toList(), // 倒序顯示
              ),
            ),
            const SizedBox(width: 5),
            // 柱狀圖和折線圖
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1000,
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context).scaffoldBackgroundColor,
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
                                            ? Colors.grey
                                            : Colors.black,
                                        barWidth: 2,
                                        belowBarData: BarAreaData(show: false),
                                      ),
                                    ],
                                    titlesData: FlTitlesData(show: false),
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
