import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class GeoJsonUtils {
  static List<LatLng> convertCoordinates(List coordinates) {
    return coordinates.map<LatLng>((coord) {
      return LatLng(coord[1], coord[0]);
    }).toList();
  }

  static double calculateArea(List<LatLng> points) {
    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];
      area += (p1.longitude * p2.latitude) - (p2.longitude * p1.latitude);
    }
    return (area.abs() / 2.0);
  }

  static LatLng calculateCenter(List<LatLng> points) {
    double sumLat = 0.0;
    double sumLng = 0.0;
    for (var point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];
      if (p1.latitude > point.latitude != p2.latitude > point.latitude) {
        final intersectX = (p2.longitude - p1.longitude) *
                (point.latitude - p1.latitude) /
                (p2.latitude - p1.latitude) +
            p1.longitude;
        if (point.longitude < intersectX) {
          intersections++;
        }
      }
    }
    return intersections % 2 == 1;
  }

  static Color getFillColor(double emission) {
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
      normalized = (emission / 100.0).clamp(0.0, 1.0);
      normalized = normalized * normalized;
      normalized *= 0.5;
    } else {
      normalized = ((emission - 100) / 400.0).clamp(0.0, 1.0);
      normalized = 0.5 + normalized * 0.5;
    }

    int lowerIndex = (normalized * (gradientColors.length - 1)).floor();
    int upperIndex = (normalized * (gradientColors.length - 1)).ceil();
    double t = (normalized * (gradientColors.length - 1)) - lowerIndex;

    return Color.lerp(
            gradientColors[lowerIndex], gradientColors[upperIndex], t)!
        .withOpacity(0.6);
  }
}
