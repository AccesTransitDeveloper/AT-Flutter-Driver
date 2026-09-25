/// Map provider types matching backend MapType constants.
enum MapProviderType {
  google(1),
  mapbox(2),
  apple(3),
  openStreet(4);

  final int value;
  const MapProviderType(this.value);

  static MapProviderType fromValue(int? value) {
    return MapProviderType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MapProviderType.google,
    );
  }
}

/// Platform-agnostic LatLng model
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

/// Camera position for map
class CameraPosition {
  final LatLng target;
  final double zoom;
  final double tilt;
  final double bearing;

  const CameraPosition({
    required this.target,
    this.zoom = 15.0,
    this.tilt = 0.0,
    this.bearing = 0.0,
  });
}

/// Marker data for map
class MapMarker {
  final String id;
  final LatLng position;
  final String? title;
  final String? snippet;
  final String? iconAsset;
  final String? iconUrl;
  final double? iconWidth;
  final double? iconHeight;
  final int? iconColor;
  final int? stopNumber;

  const MapMarker({
    required this.id,
    required this.position,
    this.title,
    this.snippet,
    this.iconAsset,
    this.iconUrl,
    this.iconWidth,
    this.iconHeight,
    this.iconColor,
    this.stopNumber,
  });
}

/// Polyline data for map
class MapPolyline {
  final String id;
  final List<LatLng> points;
  final int color;
  final double width;

  const MapPolyline({
    required this.id,
    required this.points,
    this.color = 0xFF000000,
    this.width = 5.0,
  });

  /// Create MapPolyline from encoded Google polyline string
  factory MapPolyline.fromEncoded({
    required String encoded,
    required int color,
    String id = 'route',
    double width = 5.0,
  }) {
    return MapPolyline(
      id: id,
      points: decodePolyline(encoded),
      color: color,
      width: width,
    );
  }
}

/// Decode Google polyline encoding format to list of LatLng points
List<LatLng> decodePolyline(String encoded) {
  final List<LatLng> points = [];
  int index = 0;
  int lat = 0;
  int lng = 0;

  while (index < encoded.length) {
    int shift = 0;
    int result = 0;

    int b;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);

    int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);

    int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }

  return points;
}
