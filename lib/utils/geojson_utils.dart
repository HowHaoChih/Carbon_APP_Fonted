import 'package:latlong2/latlong.dart';

class GeoJsonUtils {
  static List<LatLng> convertCoordinates(List coordinates) {
    return coordinates.map<LatLng>((coord) {
      return LatLng(coord[1], coord[0]);
    }).toList();
  }

  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    for (int i = 0; i < polygon.length; i++) {
      LatLng p1 = polygon[i];
      LatLng p2 = polygon[(i + 1) % polygon.length];
      if (p1.latitude > point.latitude != p2.latitude > point.latitude) {
        double intersectX = (p2.longitude - p1.longitude) *
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
}
