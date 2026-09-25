import 'package:flutter/widgets.dart';

import '../../../models/destination_address.dart';
import '../models/map_types.dart';

/// Callback for when camera stops moving
typedef OnCameraIdleCallback = void Function(LatLng center);

/// Abstract interface for map operations.
/// Each map provider (Google, Mapbox, Apple, OpenStreet) implements this.
///
/// The map widget is built ONCE and controlled via commands.
/// This prevents rebuilds that cause ANR.
abstract class MapInterface {
  /// Build the map widget - called ONCE by MapHost
  Widget build();

  /// Set callback for when camera stops moving (map idle)
  set onCameraIdle(OnCameraIdleCallback? callback);

  /// Get current map center coordinates
  Future<LatLng?> getCameraCenter();

  /// Animate camera to target position
  Future<void> animateCamera(LatLng target, {double? zoom});

  /// Reverse geocode coordinates to get place details
  Future<DestinationAddress> getPlaceDetailWithCoordinates(
    double latitude,
    double longitude,
  );

  /// Search for places using autocomplete
  Future<List<DestinationAddress>> searchPlaces(String query);

  /// Get full place details from a place ID
  Future<DestinationAddress?> getPlaceDetails(String placeId);

  /// Reset autocomplete session token (call after place selection)
  void resetAutocompleteSession();

  /// Check if map is ready
  bool get isReady;

  /// Set map controller from external widget
  void setController(dynamic controller);

  /// Handle camera idle event from external widget
  void handleCameraIdle();

  /// Set markers on the map
  void setMarkers(List<MapMarker> markers);

  /// Set polyline on the map (route polyline)
  void setPolyline(MapPolyline? polyline);

  /// Set driver's traveled path polyline (shown alongside route polyline)
  void setDriverPathPolyline(MapPolyline? polyline);

  /// Set map padding (to account for overlapping UI like bottom sheets)
  void setMapPadding(EdgeInsets padding);

  /// Fit camera to show all markers
  Future<void> fitBounds(List<LatLng> points, {double padding = 50});

  /// Show info window for a marker by its ID
  void showMarkerInfoWindow(String markerId);

  /// Set whether camera should automatically follow the driver marker.
  /// When true (default), camera moves and rotates with driver.
  /// When false, only the driver marker animates — camera stays still.
  void setCameraFollowDriver(bool follow);

  /// Set heat map data on the map
  void setHeatMap(List<HeatMapPoint> points);

  /// Clear heat map from the map
  void clearHeatMap();

  /// Set map style JSON string (Google Maps style format)
  void setMapStyle(String? styleJson);

  /// Apply map style from settings based on current brightness
  void applyMapStyleFromSettings(Brightness brightness);

  /// Detach the current map view from this manager without clearing map data.
  /// Use this when the hosting widget is disposed but the owning screen
  /// still intends to reuse the same manager later.
  void detachView();

  /// Dispose resources
  void dispose();
}

/// A weighted point for heat map rendering
class HeatMapPoint {
  final double latitude;
  final double longitude;
  final double weight;

  const HeatMapPoint({
    required this.latitude,
    required this.longitude,
    this.weight = 1.0,
  });
}
