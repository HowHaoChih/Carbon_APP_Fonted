import 'dart:convert';
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
import '../widgets/stacked_bar_and_line_chart.dart';

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
              name: name == "桃園縣" ? "桃園市" : (name == "台東縣" ? "台東縣" : name),
              points: points,
              color: color,
              emission: emission));
        }
      } else if (feature['geometry']['type'] == 'Polygon') {
        final points = GeoJsonUtils.convertCoordinates(coordinates[0]);
        tempPolygons.putIfAbsent(name, () => []).add(PolygonData(
            name: name == "桃園縣" ? "桃園市" : (name == "台東縣" ? "台東縣" : name),
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

  Marker _buildCityMarker(LatLng position, String name) {
    return Marker(
      point: position,
      width: 100,
      height: 30,
      child: Center(
        child: Text(
          name,
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
    final List<String> allDepartments = DepartmentUtils.getAllDepartments();

    for (var polygon in polygons) {
      if (GeoJsonUtils.isPointInPolygon(point, polygon.points)) {
        int selectedChart = 0; // 0: PieChart, 1: StackedBarChart

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
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
                          '${polygon.name} - $selectedYear/$selectedMonth',
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
                                    MediaQuery.of(context).size.height * 0.4,
                                child: DepartmentPieChart(
                                  year: selectedYear,
                                  city: polygon.name,
                                  month: selectedMonth,
                                ),
                              )
                            : SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: StackedBarAndLineChart(
                                  city: polygon.name,
                                  selectedDepartments: allDepartments.toSet(),
                                  // isMonthlyView: true,
                                  // selectedYear: selectedYear,
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
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.pie_chart),
                            label: 'Pie Chart',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.bar_chart),
                            label: 'Stacked Chart',
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
                      label: 'Year:',
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
                      label: 'Month:',
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
                      width: 20, // 自定義寬度
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
