import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import '../../../data/repository/app_repository.dart';
import '../../../models/destination_address.dart';
import '../../preferences/shared_preference_manager.dart';
import '../interface/map_interface.dart';
import '../models/map_types.dart';
import 'google_map_manager.dart';

/// Public Mapbox token supplied at build time.
///
/// Build with `--dart-define=MAPBOX_ACCESS_TOKEN=...`. Keep the real value out
/// of source control even though public Mapbox tokens should be restricted.
const String kMapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

/// Mapbox implementation of [MapInterface].
///
/// Mirrors the native `MapBoxManager`: Mapbox draws the map, while every place
/// lookup (autocomplete, place details, reverse geocode) still goes through
/// Google. Those calls are delegated to [GoogleMapManager], which is
/// constructed here purely as an API client — it never builds a map widget.
class MapboxMapManager implements MapInterface {
  // ===========================================================================
  // MARK: - Dependencies
  // ===========================================================================

  final SharedPreferenceManager? _sharedPref;

  /// Google-backed place/geocoding lookups (native does the same).
  final GoogleMapManager _places;

  // ===========================================================================
  // MARK: - Map Controller & State
  // ===========================================================================

  mb.MapboxMap? _controller;
  mb.PointAnnotationManager? _pointManager;
  mb.PolylineAnnotationManager? _polylineManager;
  bool _buildCalled = false;

  // ===========================================================================
  // MARK: - Camera State
  // ===========================================================================

  LatLng? _pendingCameraTarget;
  double? _pendingCameraZoom;
  List<LatLng>? _pendingBoundsPoints;
  double? _pendingBoundsPadding;
  OnCameraIdleCallback? _onCameraIdleCallback;

  // ===========================================================================
  // MARK: - Overlay State
  // ===========================================================================

  List<MapMarker> _markers = const [];
  MapPolyline? _routePolyline;
  MapPolyline? _driverPathPolyline;

  final Map<String, Uint8List> _iconCache = {};

  /// Live annotations keyed by [MapMarker.id]. Driver updates arrive about once
  /// a second; moving these in place is far cheaper than deleting and
  /// recreating every annotation, and it avoids the icon reload each time.
  final Map<String, mb.PointAnnotation> _annotations = {};

  /// Redraws are chained so two overlapping updates can't interleave a
  /// `deleteAll()` with another run's `createMulti()` — that race left the map
  /// with stale or missing markers.
  Future<void>? _redrawQueue;

  List<HeatMapPoint> _heatPoints = const [];

  /// Matches GoogleMapManager's single-point / pending-camera zoom.
  static const double _defaultZoom = 16;

  /// GoogleMapManager treats the marker with this id as the driver.
  static const String _driverMarkerId = 'driver';

  LatLng? _previousDriverPosition;
  double _driverBearing = 0;

  /// Mapbox draws an annotation image at its raw pixel size (iconSize 1.0),
  /// while the marker sizes in MapMarker are logical pixels. Rasterise at the
  /// screen's density so pins match Google Maps and stay crisp.
  double get _dpr => ui.PlatformDispatcher.instance.views.isEmpty
      ? 1.0
      : ui.PlatformDispatcher.instance.views.first.devicePixelRatio;

  static const String _heatSourceId = 'heatmap-source';
  static const String _heatLayerId = 'heatmap-layer';

  EdgeInsets _mapPadding = EdgeInsets.zero;
  String _styleUri = mb.MapboxStyles.STANDARD;

  MapboxMapManager({
    required AppRepository appRepository,
    SharedPreferenceManager? sharedPref,
  }) : _sharedPref = sharedPref,
       _places = GoogleMapManager(
         appRepository: appRepository,
         sharedPref: sharedPref,
       ) {
    if (kMapboxAccessToken.isEmpty) {
      throw StateError(
        'MAPBOX_ACCESS_TOKEN must be supplied with --dart-define.',
      );
    }
    mb.MapboxOptions.setAccessToken(kMapboxAccessToken);
  }

  // ===========================================================================
  // MARK: - Build & Lifecycle
  // ===========================================================================

  @override
  Widget build() {
    if (_buildCalled) {
      debugPrint('🗺️ MapboxMapManager.build() called AGAIN');
    } else {
      debugPrint('🗺️ MapboxMapManager.build() called FIRST TIME');
      _buildCalled = true;
    }

    return mb.MapWidget(
      key: const ValueKey('mapbox_map'),
      styleUri: _styleUri,
      cameraOptions: mb.CameraOptions(
        center: _point(20.5937, 78.9629), // India center
        zoom: 5,
      ),
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: _onStyleLoaded,
      onMapIdleListener: (_) => handleCameraIdle(),
    );
  }

  Future<void> _onMapCreated(mb.MapboxMap controller) async {
    debugPrint('🗺️ MapboxMap created');
    _controller = controller;

    // Hide the default UI ornaments; the app draws its own controls.
    await controller.scaleBar.updateSettings(
      mb.ScaleBarSettings(enabled: false),
    );
    await controller.compass.updateSettings(mb.CompassSettings(enabled: false));

    await _applyMapPadding();

    if (_pendingCameraTarget != null) {
      await _applyPendingCameraPosition();
    }
    if (_pendingBoundsPoints != null) {
      await _applyPendingBounds();
    }
  }

  /// Annotation managers belong to the loaded style — creating them in
  /// [_onMapCreated] raced the initial style load, and every annotation added
  /// against the half-ready style was thrown away once loading finished (the
  /// driver pin never appeared and later position updates silently no-opped).
  /// A style reload wipes them the same way, so rebuild here every time.
  Future<void> _onStyleLoaded(mb.StyleLoadedEventData _) async {
    final controller = _controller;
    if (controller == null) return;

    debugPrint('🗺️ Mapbox style loaded - (re)creating annotation managers');

    _annotations.clear();
    _pointManager = await controller.annotations.createPointAnnotationManager();
    _polylineManager = await controller.annotations
        .createPolylineAnnotationManager();

    // Mapbox culls symbols that collide with other symbols or map labels, so
    // the driver pin disappeared over busy areas. Google Maps always draws
    // every marker — match that.
    await _pointManager!.setIconAllowOverlap(true);
    await _pointManager!.setIconIgnorePlacement(true);

    await _redrawMarkers();
    await _redrawPolylines();
  }

  @override
  bool get isReady => _controller != null;

  @override
  void setController(dynamic controller) {
    if (controller is mb.MapboxMap) {
      _onMapCreated(controller);
    }
  }

  @override
  void detachView() {
    debugPrint('🗺️ MapboxMapManager.detachView()');
    _controller = null;
    _pointManager = null;
    _polylineManager = null;
    _buildCalled = false;
  }

  @override
  void dispose() {
    debugPrint('🗺️ MapboxMapManager.dispose()');
    _iconCache.clear();
    _annotations.clear();
    _markers = const [];
    _routePolyline = null;
    _driverPathPolyline = null;
    _heatPoints = const [];
    detachView();
    _places.dispose();
  }

  // ===========================================================================
  // MARK: - Camera
  // ===========================================================================

  @override
  set onCameraIdle(OnCameraIdleCallback? callback) {
    _onCameraIdleCallback = callback;
  }

  @override
  void handleCameraIdle() {
    final callback = _onCameraIdleCallback;
    if (callback == null) return;
    getCameraCenter().then((center) {
      if (center != null) callback(center);
    });
  }

  @override
  Future<LatLng?> getCameraCenter() async {
    final controller = _controller;
    if (controller == null) return null;
    try {
      final state = await controller.getCameraState();
      final coords = state.center.coordinates;
      return LatLng(coords.lat.toDouble(), coords.lng.toDouble());
    } catch (e) {
      debugPrint('🗺️ getCameraCenter error: $e');
      return null;
    }
  }

  @override
  Future<void> animateCamera(LatLng target, {double? zoom}) async {
    if (_controller == null) {
      _pendingCameraTarget = target;
      _pendingCameraZoom = zoom;
      return;
    }
    await _controller!.flyTo(
      mb.CameraOptions(
        center: _point(target.latitude, target.longitude),
        zoom: zoom ?? _defaultZoom,
      ),
      mb.MapAnimationOptions(duration: 500),
    );
  }

  Future<void> _applyPendingCameraPosition() async {
    final target = _pendingCameraTarget;
    if (target == null) return;
    final zoom = _pendingCameraZoom;
    _pendingCameraTarget = null;
    _pendingCameraZoom = null;
    await animateCamera(target, zoom: zoom);
  }

  @override
  Future<void> fitBounds(List<LatLng> points, {double padding = 50}) async {
    if (points.isEmpty) return;

    if (_controller == null) {
      _pendingBoundsPoints = points;
      _pendingBoundsPadding = padding;
      return;
    }

    // A single coordinate has no extent, so Mapbox cannot derive a zoom from
    // it — fall back to a fixed close-up like GoogleMapManager does.
    if (points.length == 1) {
      await animateCamera(points.first, zoom: _defaultZoom);
      return;
    }

    try {
      final camera = await _controller!.cameraForCoordinatesPadding(
        points.map((p) => _point(p.latitude, p.longitude)).toList(),
        mb.CameraOptions(),
        mb.MbxEdgeInsets(
          top: padding + _mapPadding.top,
          left: padding + _mapPadding.left,
          bottom: padding + _mapPadding.bottom,
          right: padding + _mapPadding.right,
        ),
        null,
        null,
      );
      await _controller!.flyTo(camera, mb.MapAnimationOptions(duration: 500));
    } catch (e) {
      debugPrint('🗺️ fitBounds error: $e');
    }
  }

  Future<void> _applyPendingBounds() async {
    final points = _pendingBoundsPoints;
    if (points == null) return;
    final padding = _pendingBoundsPadding ?? 50;
    _pendingBoundsPoints = null;
    _pendingBoundsPadding = null;
    await Future.delayed(const Duration(milliseconds: 300));
    await fitBounds(points, padding: padding);
  }

  // ===========================================================================
  // MARK: - Padding & Style
  // ===========================================================================

  @override
  void setMapPadding(EdgeInsets padding) {
    _mapPadding = padding;
    _applyMapPadding();
  }

  Future<void> _applyMapPadding() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.setCamera(
        mb.CameraOptions(
          padding: mb.MbxEdgeInsets(
            top: _mapPadding.top,
            left: _mapPadding.left,
            bottom: _mapPadding.bottom,
            right: _mapPadding.right,
          ),
        ),
      );
    } catch (e) {
      debugPrint('🗺️ setMapPadding error: $e');
    }
  }

  /// Google-format style JSON cannot be applied to Mapbox, so this is a no-op.
  /// Theming goes through [applyMapStyleFromSettings], which picks a Mapbox
  /// style URI — the same approach the native `MapBoxManager` takes with
  /// `MapboxStandardStyle` light/dark presets.
  @override
  void setMapStyle(String? styleJson) {}

  @override
  void applyMapStyleFromSettings(Brightness brightness) {
    final uri = brightness == Brightness.dark
        ? mb.MapboxStyles.DARK
        : mb.MapboxStyles.STANDARD;
    if (uri == _styleUri) return;
    _styleUri = uri;
    debugPrint('🗺️ applyMapStyleFromSettings: $_styleUri');
    _controller?.loadStyleURI(uri);
  }

  /// No-op: unlike GoogleMapManager this manager has no driver-follow
  /// animation loop — markers are redrawn from [setMarkers] and the camera is
  /// only moved by explicit [animateCamera] / [fitBounds] calls.
  @override
  void setCameraFollowDriver(bool follow) {}

  // ===========================================================================
  // MARK: - Heat map
  // ===========================================================================

  @override
  void setHeatMap(List<HeatMapPoint> points) {
    _heatPoints = points;
    _redrawHeatMap();
  }

  @override
  void clearHeatMap() {
    _heatPoints = const [];
    _redrawHeatMap();
  }

  Future<void> _redrawHeatMap() async {
    final style = _controller?.style;
    if (style == null) return;

    try {
      if (await style.styleLayerExists(_heatLayerId)) {
        await style.removeStyleLayer(_heatLayerId);
      }
      if (await style.styleSourceExists(_heatSourceId)) {
        await style.removeStyleSource(_heatSourceId);
      }

      if (_heatPoints.isEmpty) return;

      final features = _heatPoints
          .map(
            (p) =>
                '{"type":"Feature","properties":{"weight":${p.weight}},'
                '"geometry":{"type":"Point","coordinates":[${p.longitude},${p.latitude}]}}',
          )
          .join(',');

      await style.addSource(
        mb.GeoJsonSource(
          id: _heatSourceId,
          data: '{"type":"FeatureCollection","features":[$features]}',
        ),
      );
      await style.addLayer(
        mb.HeatmapLayer(id: _heatLayerId, sourceId: _heatSourceId),
      );
    } catch (e) {
      debugPrint('🗺️ _redrawHeatMap error: $e');
    }
  }

  // ===========================================================================
  // MARK: - Markers
  // ===========================================================================

  @override
  void setMarkers(List<MapMarker> markers) {
    _updateDriverBearing(markers);
    _markers = markers;
    _redrawMarkers();
  }

  /// Serialises redraws; see [_redrawQueue].
  Future<void> _redrawMarkers() {
    final next = (_redrawQueue ?? Future<void>.value()).then(
      (_) => _syncMarkers(),
    );
    _redrawQueue = next.catchError((Object e) {
      debugPrint('🗺️ marker sync error: $e');
    });
    return _redrawQueue!;
  }

  /// Track the driver's heading between updates so the icon can be rotated —
  /// GoogleMapManager does the same with `_calculateBearing`.
  void _updateDriverBearing(List<MapMarker> markers) {
    final driver = markers.where((m) => m.id == _driverMarkerId).firstOrNull;
    if (driver == null) return;

    final previous = _previousDriverPosition;
    if (previous != null) {
      _driverBearing = _bearingBetween(previous, driver.position);
    }
    _previousDriverPosition = driver.position;
  }

  double _bearingBetween(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLon = (to.longitude - from.longitude) * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  /// Mapbox has no built-in info window, so there is nothing to show. Screens
  /// that need a callout render it as a Flutter overlay instead.
  @override
  void showMarkerInfoWindow(String markerId) {}

  Future<void> _syncMarkers() async {
    final manager = _pointManager;
    if (manager == null) return;

    final all = _markers;

    // Same markers as last time — just move them (and re-aim the driver icon).
    if (all.isNotEmpty &&
        all.length == _annotations.length &&
        all.every((m) => _annotations.containsKey(m.id))) {
      try {
        for (final marker in all) {
          final annotation = _annotations[marker.id]!;
          annotation.geometry = _point(
            marker.position.latitude,
            marker.position.longitude,
          );
          if (marker.id == _driverMarkerId) {
            annotation.iconRotate = _driverBearing;
          }
          await manager.update(annotation);
        }
        return;
      } catch (e) {
        // The annotations went stale (style reload, manager recreated...).
        // Without this the ids still matched, so every later update took this
        // path and silently failed — the map stopped moving altogether.
        debugPrint('🗺️ marker update failed, rebuilding: $e');
        _annotations.clear();
      }
    }

    try {
      await manager.deleteAll();
      _annotations.clear();

      if (all.isEmpty) return;

      final options = <mb.PointAnnotationOptions>[];
      for (final marker in all) {
        final isDriver = marker.id == _driverMarkerId;
        options.add(
          mb.PointAnnotationOptions(
            geometry: _point(
              marker.position.latitude,
              marker.position.longitude,
            ),
            image: await _loadMarkerIcon(marker),
            // Pins are drawn tip-down so the tip sits on the coordinate, which
            // is Google's default anchor. Driver/nearby-driver icons are
            // centred instead (GoogleMapManager passes Offset(0.5, 0.5)).
            iconAnchor: isDriver ? mb.IconAnchor.CENTER : mb.IconAnchor.BOTTOM,
            // The driver icon points along the heading, like the rotated
            // Google marker.
            iconRotate: isDriver ? _driverBearing : null,
          ),
        );
      }
      final created = await manager.createMulti(options);
      for (var i = 0; i < created.length && i < all.length; i++) {
        final annotation = created[i];
        if (annotation != null) _annotations[all[i].id] = annotation;
      }
    } catch (e) {
      debugPrint('🗺️ _syncMarkers error: $e');
    }
  }

  // ===========================================================================
  // MARK: - Polylines
  // ===========================================================================

  @override
  void setPolyline(MapPolyline? polyline) {
    _routePolyline = polyline;
    _redrawPolylines();
  }

  @override
  void setDriverPathPolyline(MapPolyline? polyline) {
    _driverPathPolyline = polyline;
    _redrawPolylines();
  }

  Future<void> _redrawPolylines() async {
    final manager = _polylineManager;
    if (manager == null) return;

    try {
      await manager.deleteAll();

      final lines = [
        _routePolyline,
        _driverPathPolyline,
      ].whereType<MapPolyline>().where((line) => line.points.length >= 2);

      for (final line in lines) {
        await manager.create(
          mb.PolylineAnnotationOptions(
            geometry: mb.LineString(
              coordinates: line.points
                  .map((p) => mb.Position(p.longitude, p.latitude))
                  .toList(),
            ),
            lineColor: line.color,
            lineWidth: line.width,
          ),
        );
      }
    } catch (e) {
      debugPrint('🗺️ _redrawPolylines error: $e');
    }
  }

  // ===========================================================================
  // MARK: - Marker icons
  //
  // Ported from GoogleMapManager — same drawing logic, but Mapbox wants raw
  // PNG bytes instead of a BitmapDescriptor.
  // ===========================================================================

  Future<Uint8List> _loadMarkerIcon(MapMarker marker) async {
    try {
      if (marker.stopNumber != null && marker.iconColor != null) {
        return await _createNumberedMarkerIcon(
          marker.stopNumber!,
          Color(marker.iconColor!),
          marker.iconWidth ?? 32,
          marker.iconHeight ?? 32,
        );
      }

      if (marker.iconUrl != null && marker.iconUrl!.isNotEmpty) {
        final networkIcon = await _loadNetworkMarkerIcon(
          marker.iconUrl!,
          marker.iconWidth ?? 40,
          marker.iconHeight ?? 40,
        );
        if (networkIcon != null) return networkIcon;
      }

      if (marker.iconAsset != null) {
        return await _loadAssetIcon(marker);
      }
    } catch (e) {
      debugPrint(
        '🗺️ Failed to load marker icon: ${marker.iconAsset ?? marker.iconUrl}, error: $e',
      );
    }

    return _createNumberedMarkerIcon(0, const Color(0xFFEA4335), 24, 24);
  }

  /// Pixel size for an icon: scale [boxWidth]x[boxHeight] by the screen density
  /// while keeping the source aspect ratio, and never enlarge past the source
  /// (upscaling a small pin only makes it fuzzy).
  ({int width, int height}) _fitted({
    required int sourceWidth,
    required int sourceHeight,
    required double boxWidth,
    required double boxHeight,
  }) {
    if (sourceWidth <= 0 || sourceHeight <= 0) {
      return (width: boxWidth.round(), height: boxHeight.round());
    }

    final scale = _dpr;
    final fit = math.min(
      boxWidth * scale / sourceWidth,
      boxHeight * scale / sourceHeight,
    );
    final capped = math.min(fit, 1.0);

    return (
      width: math.max(1, (sourceWidth * capped).round()),
      height: math.max(1, (sourceHeight * capped).round()),
    );
  }

  Future<Uint8List> _loadAssetIcon(MapMarker marker) async {
    final width = marker.iconWidth ?? 40;
    final height = marker.iconHeight ?? 40;

    final data = await rootBundle.load(marker.iconAsset!);
    final bytes = data.buffer.asUint8List();

    // Fit inside the requested box without distorting: the car pin asset is
    // 306x173, and forcing it into a square squashed it into a blurry smear.
    final probe = await (await ui.instantiateImageCodec(bytes)).getNextFrame();
    final target = _fitted(
      sourceWidth: probe.image.width,
      sourceHeight: probe.image.height,
      boxWidth: width,
      boxHeight: height,
    );
    final pxWidth = target.width;
    final pxHeight = target.height;

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: pxWidth,
      targetHeight: pxHeight,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    if (marker.iconColor == null) {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes!.buffer.asUint8List();
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..colorFilter = ColorFilter.mode(
        Color(marker.iconColor!),
        BlendMode.srcIn,
      );
    canvas.drawImage(image, Offset.zero, paint);

    final tinted = await recorder.endRecording().toImage(pxWidth, pxHeight);
    final byteData = await tinted.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List?> _loadNetworkMarkerIcon(
    String url,
    double width,
    double height,
  ) async {
    final cacheKey = '$url-$width-$height';
    final cached = _iconCache[cacheKey];
    if (cached != null) return cached;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final originalCodec = await ui.instantiateImageCodec(response.bodyBytes);
      final originalImage = (await originalCodec.getNextFrame()).image;

      final target = _fitted(
        sourceWidth: originalImage.width,
        sourceHeight: originalImage.height,
        boxWidth: width,
        boxHeight: height,
      );

      final codec = await ui.instantiateImageCodec(
        response.bodyBytes,
        targetWidth: target.width,
        targetHeight: target.height,
      );
      final image = (await codec.getNextFrame()).image;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      _iconCache[cacheKey] = bytes;
      return bytes;
    } catch (e) {
      debugPrint('🗺️ Failed to load network icon: $url, error: $e');
      return null;
    }
  }

  Future<Uint8List> _createNumberedMarkerIcon(
    int number,
    Color color,
    double width,
    double height,
  ) async {
    final scale = _dpr;
    final pxWidth = width * scale;
    final pxHeight = height * scale;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, pxWidth, pxHeight),
        Radius.circular(4 * scale),
      ),
      Paint()..color = color,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: pxHeight * 0.6,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (pxWidth - textPainter.width) / 2,
        (pxHeight - textPainter.height) / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
      pxWidth.round(),
      pxHeight.round(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // ===========================================================================
  // MARK: - Places (delegated to Google, exactly like the native MapBoxManager)
  // ===========================================================================

  @override
  Future<DestinationAddress> getPlaceDetailWithCoordinates(
    double latitude,
    double longitude,
  ) => _places.getPlaceDetailWithCoordinates(latitude, longitude);

  @override
  Future<List<DestinationAddress>> searchPlaces(String query) =>
      _places.searchPlaces(query);

  @override
  Future<DestinationAddress?> getPlaceDetails(String placeId) =>
      _places.getPlaceDetails(placeId);

  @override
  void resetAutocompleteSession() => _places.resetAutocompleteSession();

  // ===========================================================================
  // MARK: - Helpers
  // ===========================================================================

  mb.Point _point(double latitude, double longitude) =>
      mb.Point(coordinates: mb.Position(longitude, latitude));

  /// Kept so the manager can read server settings later without another
  /// dependency hop (mirrors GoogleMapManager).
  SharedPreferenceManager? get sharedPref => _sharedPref;
}
