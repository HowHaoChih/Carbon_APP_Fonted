import 'dart:convert';
import 'package:carbon_app/widgets/department_legend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/l10n.dart';
import '../utils/geojson_utils.dart';
import '../utils/polygon_data.dart';
import '../utils/department_utils.dart';
import '../widgets/color_legend.dart';
import '../widgets/map_slider.dart';
import '../widgets/department_pie_chart.dart';
import '../widgets/monthly_stacked_bar_and_line_chart.dart';

class TaiwanMapScreen extends StatefulWidget {
  const TaiwanMapScreen({super.key});

  @override
  State<TaiwanMapScreen> createState() => _TaiwanMapScreenState();
}

class _TaiwanMapScreenState extends State<TaiwanMapScreen> {
  List<PolygonData> polygons = [];
  List<Marker> cityMarkers = [];
  final Map<String, double> countyEmissions = {};
  int selectedYear = 2023;
  int selectedMonth = 1;
  // 所有產業選項
  final List<String> allDepartments = DepartmentUtils.getAllDepartments();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadEmissionData();
    await _loadGeoJson();
  }

  Future<void> _loadEmissionData() async {
    // 加載碳排放數據
    final String csvData = await rootBundle.loadString(
        'assets/data/TotalCarbonEmissions_AllSectors_10ktonCO2e.csv');
    final rows = const LineSplitter().convert(csvData);
    final headers = rows.first.split(',');

    for (var row in rows.skip(1)) {
      final values = row.split(',');
      if (int.parse(values[0]) == selectedYear &&
          int.parse(values[1]) == selectedMonth) {
        for (var i = 3; i < values.length; i++) {
          countyEmissions[headers[i]] = double.parse(values[i]);
        }
        break;
      }
    }
  }

  Future<void> _loadGeoJson() async {
    final String geoJsonData =
        await rootBundle.loadString('assets/data/twCounty2010merge.geo.json');
    final jsonMap = jsonDecode(geoJsonData);

    final Map<String, List<PolygonData>> tempPolygons = {};

    for (var feature in jsonMap['features']) {
      final name = feature['properties']['COUNTYNAME'];
      final coordinates = feature['geometry']['coordinates'];
      final emission = countyEmissions[name] ?? 0.0;
      Color color = GeoJsonUtils.getFillColor(emission);

      if (feature['geometry']['type'] == 'MultiPolygon') {
        for (var polygon in coordinates) {
          final points = GeoJsonUtils.convertCoordinates(polygon[0]);
          tempPolygons.putIfAbsent(name, () => []).add(PolygonData(
              name: name == "桃園縣" ? "桃園市" : name,
              points: points,
              color: color,
              emission: emission));
        }
      } else if (feature['geometry']['type'] == 'Polygon') {
        final points = GeoJsonUtils.convertCoordinates(coordinates[0]);
        tempPolygons.putIfAbsent(name, () => []).add(PolygonData(
            name: name == "桃園縣" ? "桃園市" : name,
            points: points,
            color: color,
            emission: emission));
      }
    }

    final List<PolygonData> loadedPolygons = [];
    final List<Marker> loadedMarkers = [];

    tempPolygons.forEach((name, polygonList) {
      polygonList.sort((a, b) => GeoJsonUtils.calculateArea(b.points)
          .compareTo(GeoJsonUtils.calculateArea(a.points)));

      final largestPolygon = polygonList.first;
      loadedPolygons.addAll(polygonList);

      final center = GeoJsonUtils.calculateCenter(largestPolygon.points);
      loadedMarkers.add(_buildCityMarker(
          center, name == "桃園縣" ? "桃園市" : (name == "台東縣" ? "台東縣" : name)));
    });

    setState(() {
      polygons = loadedPolygons;
      cityMarkers = loadedMarkers;
    });
  }

  // Helper function to map county name to localized value
  String getLocalizedCountyName(BuildContext context, String countyName) {
    final mapping = {
      "台北市": context.l10n.taipei_city,
      "台中市": context.l10n.taizhong_city,
      "高雄市": context.l10n.kaohsiung_city,
      "南投縣": context.l10n.nantou_county,
      "新北市": context.l10n.new_taipei_city,
      "台南市": context.l10n.tainan_city,
      "台東縣": context.l10n.taitung_city,
      "嘉義市": context.l10n.chiayi_city,
      "嘉義縣": context.l10n.chiayi_county,
      "基隆市": context.l10n.keelung_city,
      "宜蘭縣": context.l10n.yilan_county,
      "屏東縣": context.l10n.pingtung_county,
      "彰化縣": context.l10n.changhua_county,
      "新竹市": context.l10n.hsinchu_city,
      "新竹縣": context.l10n.hsinchu_county,
      "桃園市": context.l10n.taoyuan_city,
      "澎湖縣": context.l10n.penghu_county,
      "花蓮縣": context.l10n.hualien_county,
      "苗栗縣": context.l10n.miaoli_county,
      "連江縣": context.l10n.lienchiang_county,
      "金門縣": context.l10n.kinmen_county,
      "雲林縣": context.l10n.yunlin_county,
    };

    return mapping[countyName] ??
        countyName; // If not found, return original name
  }

  Marker _buildCityMarker(LatLng position, String name) {
    final localizedName = getLocalizedCountyName(context, name);

    return Marker(
      point: position,
      width: 100,
      height: 30,
      child: Center(
        child: Text(
          localizedName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white54,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _handleMapTap(LatLng point) {
    for (var polygon in polygons) {
      if (GeoJsonUtils.isPointInPolygon(point, polygon.points)) {
        int selectedChart = 0; // 0: PieChart, 1: StackedBarChart

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            final localizedName = getLocalizedCountyName(context, polygon.name);
            return StatefulBuilder(
              builder: (context, setModalState) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(
                    children: [
                      // 標題
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '$localizedName - $selectedYear/$selectedMonth',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: selectedChart == 0
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: Column(
                                  children: [
                                    DepartmentPieChart(
                                      year: selectedYear,
                                      city: localizedName,
                                      month: selectedMonth,
                                    ),
                                    DepartmentLegend(
                                      departmentList: allDepartments,
                                    )
                                  ],
                                ),
                              )
                            : SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3, // 上方圖表佔 3 份空間
                                      child: MonthlyStackedBarAndLineChart(
                                        city: localizedName,
                                        selectedDepartments:
                                            allDepartments.toSet(),
                                        selectedYear: selectedYear,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1, // 下方 Legend 佔 1 份空間
                                      child: DepartmentLegend(
                                        departmentList: allDepartments,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      // BottomNavigationBar
                      BottomNavigationBar(
                        currentIndex: selectedChart,
                        onTap: (index) {
                          setModalState(() {
                            selectedChart = index; // 切換圖表類型
                          });
                        },
                        items: [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.pie_chart),
                            label: context.l10n.pie_chart,
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.bar_chart),
                            label: context.l10n.bar_chart,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.map_view)),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: MapSlider(
                      label: context.l10n.year,
                      value: selectedYear.toDouble(),
                      min: 1990,
                      max: 2023,
                      divisions: 33,
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value.toInt();
                          _loadData();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: MapSlider(
                      label: context.l10n.month,
                      value: selectedMonth.toDouble(),
                      min: 1,
                      max: 12,
                      divisions: 12,
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value.toInt();
                          _loadData();
                        });
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(23.5, 121.0),
                    initialZoom: 7.0,
                    onTap: (TapPosition tapPosition, LatLng point) {
                      _handleMapTap(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    PolygonLayer(
                      polygons: polygons
                          .map((p) => Polygon(
                                points: p.points,
                                color: p.color.withOpacity(0.6),
                                borderColor: Colors.black,
                                borderStrokeWidth: 1.0,
                              ))
                          .toList(),
                    ),
                    MarkerLayer(markers: cityMarkers),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: const ColorLegend(),
          ),
        ],
      ),
    );
  }
}
