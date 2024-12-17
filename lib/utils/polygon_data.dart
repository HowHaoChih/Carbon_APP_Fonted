import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class PolygonData {
  final String name;
  final List<LatLng> points;
  final Color color;
  final double emission;

  PolygonData({
    required this.name,
    required this.points,
    required this.color,
    required this.emission,
  });
}
