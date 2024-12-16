import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TaiwanMapScreen extends StatefulWidget {
  const TaiwanMapScreen({super.key});

  @override
  State<TaiwanMapScreen> createState() => _TaiwanMapScreenState();
}

class _TaiwanMapScreenState extends State<TaiwanMapScreen> {
  List<Polygon> polygons = [];
  final Map<String, double> countyEmissions = {};
  int selectedYear = 2023;
  int selectedMonth = 1;

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
    _loadData();
  }

  Future<void> _loadGeoJson() async {
    final String geoJsonData =
        await rootBundle.loadString('assets/data/twCounty2010merge.geo.json');
    final Map<String, dynamic> jsonMap = jsonDecode(geoJsonData);

    List<Polygon> loadedPolygons = [];

    for (var feature in jsonMap['features']) {
      final String countyName = feature['properties']['COUNTYNAME'];
      final List coordinates = feature['geometry']['coordinates'];
      final double emission = countyEmissions[countyName] ?? 0.0;

      final Color fillColor = _getFillColor(emission);

      if (feature['geometry']['type'] == 'MultiPolygon') {
        for (var polygon in coordinates) {
          loadedPolygons.add(
            Polygon(
              points: _convertCoordinates(polygon[0]),
              color: fillColor,
              borderStrokeWidth: 1.0,
              borderColor: Colors.black,
            ),
          );
        }
      } else if (feature['geometry']['type'] == 'Polygon') {
        loadedPolygons.add(
          Polygon(
            points: _convertCoordinates(coordinates[0]),
            color: fillColor,
            borderStrokeWidth: 1.0,
            borderColor: Colors.black,
          ),
        );
      }
    }

    setState(() {
      polygons = loadedPolygons;
    });
  }

  Future<void> _loadData() async {
    final String csvData = await rootBundle.loadString(
        'assets/data/TotalCarbonEmissions_AllSectors_10ktonCO2e.csv');
    final rows = const LineSplitter().convert(csvData);

    final headers = rows.first.split(',');
    final int monthIndex = 1;
    final countyNames = headers.sublist(3); // 縣市名稱

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i].split(',');
      final int year = int.parse(row[0]);
      final int month = int.parse(row[monthIndex]);

      if (year == selectedYear && month == selectedMonth) {
        for (var j = 3; j < row.length; j++) {
          countyEmissions[countyNames[j - 3]] = double.parse(row[j]);
        }
        break;
      }
    }

    _loadGeoJson();
  }

  Color _getFillColor(double emission) {
    const double maxEmission = 500.0; // 最大值設為500
    const List<Color> gradientColors = [
      Color(0xFF00FF00), // 綠色 (最低排放)
      Color(0xFFFFFF00), // 黃色
      Color(0xFFFFA500), // 橘色
      Color(0xFFFF4500), // 深橘色
      Color(0xFFFF0000), // 紅色
      Color(0xFF8B0000), // 深紅色
      Color(0xFF000000), // 黑色 (最高排放)
    ];

    double normalized;
    if (emission <= 100) {
      normalized = (emission / 100).clamp(0.0, 1.0);
      normalized = normalized * normalized;
      normalized *= 0.5;
    } else {
      normalized = ((emission - 100) / (maxEmission - 100)).clamp(0.0, 1.0);
      normalized = 0.5 + normalized * 0.5;
    }

    int lowerIndex = (normalized * (gradientColors.length - 1)).floor();
    int upperIndex = (normalized * (gradientColors.length - 1)).ceil();
    double t = (normalized * (gradientColors.length - 1)) - lowerIndex;

    Color lowerColor = gradientColors[lowerIndex];
    Color upperColor = gradientColors[upperIndex];
    return Color.lerp(lowerColor, upperColor, t)!.withOpacity(0.6);
  }

  List<LatLng> _convertCoordinates(List coordinates) {
    return coordinates.map<LatLng>((coord) {
      return LatLng(coord[1], coord[0]);
    }).toList();
  }

  Widget _buildColorLegend() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '碳強度 (10ktonCO₂e)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            height: 16,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00FF00),
                  Color(0xFFFFFF00),
                  Color(0xFFFFA500),
                  Color(0xFFFF4500),
                  Color(0xFFFF0000),
                  Color(0xFF8B0000),
                  Color(0xFF000000),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0', style: TextStyle(fontSize: 10)),
              Text('100', style: TextStyle(fontSize: 10)),
              Text('200', style: TextStyle(fontSize: 10)),
              Text('300', style: TextStyle(fontSize: 10)),
              Text('400', style: TextStyle(fontSize: 10)),
              Text('500+', style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('台灣碳排放熱點圖'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // 年份滑桿
                    const Text('年份:'),
                    Expanded(
                      child: Slider(
                        value: selectedYear.toDouble(),
                        min: 1990,
                        max: 2023,
                        divisions: 33,
                        label: selectedYear.toString(),
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value.toInt();
                            _loadData();
                          });
                        },
                      ),
                    ),
                    Text('$selectedYear '), // 顯示當前年份
                    const Text('月份:'),
                    Expanded(
                      child: Slider(
                        value: selectedMonth.toDouble(),
                        min: 1,
                        max: 12,
                        divisions: 12,
                        label: selectedMonth.toString(),
                        onChanged: (value) {
                          setState(() {
                            selectedMonth = value.toInt();
                            _loadData();
                          });
                        },
                      ),
                    ),
                    Text('$selectedMonth '), // 顯示當前月份
                  ],
                ),
              ),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(23.5, 121.0),
                    initialZoom: 7.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    PolygonLayer(polygons: polygons),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildColorLegend(),
          ),
        ],
      ),
    );
  }
}
