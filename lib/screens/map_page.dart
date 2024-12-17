import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/l10n.dart';
import '../utils/geojson_utils.dart';
import '../utils/polygon_data.dart';
import '../widgets/color_legend.dart';

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
    _loadGeoJson();
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

      Color color = _getFillColor(emission);

      if (feature['geometry']['type'] == 'MultiPolygon') {
        for (var polygon in coordinates) {
          final points = GeoJsonUtils.convertCoordinates(polygon[0]);
          tempPolygons.putIfAbsent(name, () => []).add(PolygonData(
              name: name, points: points, color: color, emission: emission));
        }
      } else if (feature['geometry']['type'] == 'Polygon') {
        final points = GeoJsonUtils.convertCoordinates(coordinates[0]);
        tempPolygons.putIfAbsent(name, () => []).add(PolygonData(
            name: name, points: points, color: color, emission: emission));
      }
    }

    final List<PolygonData> loadedPolygons = [];
    final List<Marker> loadedMarkers = [];

    // 遍歷縣市，選取每個縣市的最大區塊
    tempPolygons.forEach((name, polygonList) {
      polygonList.sort((a, b) => _calculateArea(b.points)
          .compareTo(_calculateArea(a.points))); // 依面積降序排序

      // 取最大區塊
      final largestPolygon = polygonList.first;
      loadedPolygons.addAll(polygonList);

      // 計算最大區塊的中心點並建立 Marker
      final center = _calculateCenter(largestPolygon.points);
      loadedMarkers.add(_buildCityMarker(center, name));
    });

    setState(() {
      polygons = loadedPolygons;
      cityMarkers = loadedMarkers;
    });
  }

  LatLng _calculateCenter(List<LatLng> points) {
    // 計算多邊形座標的平均值作為中心點
    double sumLat = 0.0;
    double sumLng = 0.0;

    for (var point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }

    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  double _calculateArea(List<LatLng> points) {
    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];
      area += (p1.longitude * p2.latitude) - (p2.longitude * p1.latitude);
    }
    return (area.abs() / 2.0);
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

  Color _getFillColor(double emission) {
    const List<Color> gradientColors = [
      Color(0xFF00FF00), // 綠色
      Color(0xFFFFFF00), // 黃色
      Color(0xFFFFA500), // 橘色
      Color(0xFFFF4500), // 深橘色
      Color(0xFFFF0000), // 紅色
      Color(0xFF8B0000), // 深紅色
      Color(0xFF000000), // 黑色
    ];

    double normalized;

    if (emission <= 100) {
      // 前 100 使用平方根映射，加強漸變效果
      normalized = (emission / 100.0).clamp(0.0, 1.0);
      normalized = normalized * normalized; // 平方根後加強過渡
      normalized *= 0.5; // 壓縮至漸變的前 50%
    } else {
      // 100 ~ 500 線性映射，平滑過渡
      normalized = ((emission - 100) / 400.0).clamp(0.0, 1.0);
      normalized = 0.5 + normalized * 0.5; // 將剩餘範圍平滑過渡至 50%
    }

    int lowerIndex = (normalized * (gradientColors.length - 1)).floor();
    int upperIndex = (normalized * (gradientColors.length - 1)).ceil();
    double t = (normalized * (gradientColors.length - 1)) - lowerIndex;

    return Color.lerp(
            gradientColors[lowerIndex], gradientColors[upperIndex], t)!
        .withOpacity(0.6);
  }

  void _handleMapTap(LatLng point) {
    // 處理點擊地圖事件
    for (var polygon in polygons) {
      if (GeoJsonUtils.isPointInPolygon(point, polygon.points)) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(polygon.name),
              content: Text(
                  'Emission: ${polygon.emission.toStringAsFixed(2)} kton CO₂e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text('Year:'),
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
                    SizedBox(
                      width: 40,
                      child: Text('$selectedYear', textAlign: TextAlign.center),
                    ),
                    const Text('Month:'),
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
                    SizedBox(
                      width: 40,
                      child:
                          Text('$selectedMonth', textAlign: TextAlign.center),
                    ),
                  ],
                ),
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
