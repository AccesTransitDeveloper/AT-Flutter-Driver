import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:http/http.dart' as http;

import '../../../data/repository/app_repository.dart';
import '../../../models/destination_address.dart';
import '../../preferences/shared_preference_manager.dart';
import '../interface/map_interface.dart';
import '../models/map_types.dart';

/// Google Maps implementation of MapInterface.
class GoogleMapManager implements MapInterface {
  final AppRepository _appRepository;
  final SharedPreferenceManager? _sharedPref;

  gm.GoogleMapController? _controller;
  bool _buildCalled = false;
  bool _disposed = false;
  void Function(void Function())? _setMapState;

  LatLng? _pendingCameraTarget;
  double? _pendingCameraZoom;
  List<LatLng>? _pendingBoundsPoints;
  double? _pendingBoundsPadding;
  OnCameraIdleCallback? _onCameraIdleCallback;

  Set<gm.Marker> _markers = {};
  final Map<String, gm.BitmapDescriptor> _networkIconCache = {};

  // Driver moving marker state (Kotlin-style polling + animation)
  LatLng? _movingMarkerTarget;
  gm.BitmapDescriptor _movingMarkerIcon = gm.BitmapDescriptor.defaultMarker;
  Timer? _driverPollTimer;
  Timer? _driverAnimTimer;
  LatLng? _driverAnimatedPosition;
  double _driverAnimatedBearing = 0;
  LatLng? _driverLastPolledTarget;
  double _driverTargetBearing = 0;
  double _driverStartBearing = 0;
  LatLng? _driverAnimStartPos;
  bool _driverVisible = false;
  Set<gm.Marker> _staticMarkers = {};
  bool _cameraFollowsDriver = true;

  Set<gm.Polyline> _polylines = {};
  gm.Polyline? _routePolyline;
  gm.Polyline? _driverPathPolyline;

  EdgeInsets _mapPadding = EdgeInsets.zero;
  Set<gm.Heatmap> _heatmaps = {};
  String? _mapStyle;

  places.FlutterGooglePlacesSdk? _placesSdk;
  bool _startNewSession = true;

  GoogleMapManager({
    required AppRepository appRepository,
    SharedPreferenceManager? sharedPref,
  })  : _appRepository = appRepository,
        _sharedPref = sharedPref {
    _initPlacesSdk();
  }

  Set<gm.Marker> get markers => _markers;
  Set<gm.Polyline> get polylines => _polylines;

  @override
  bool get isReady => _controller != null;

  @override
  set onCameraIdle(OnCameraIdleCallback? callback) {
    _onCameraIdleCallback = callback;
  }

  @override
  void setCameraFollowDriver(bool follow) {
    _cameraFollowsDriver = follow;
  }

  @override
  void setMapPadding(EdgeInsets padding) {
    _mapPadding = padding;
    _notifyMapDataChanged();
  }

  @override
  void showMarkerInfoWindow(String markerId) {
    _controller?.showMarkerInfoWindow(gm.MarkerId(markerId));
  }

  @override
  Widget build() {
    if (_buildCalled) {
      debugPrint(
          'GoogleMapManager.build() called AGAIN - THIS SHOULD NOT HAPPEN!');
    } else {
      _buildCalled = true;
    }

    return StatefulBuilder(
      builder: (context, setMapState) {
        _setMapState = setMapState;
        return gm.GoogleMap(
          initialCameraPosition: const gm.CameraPosition(
            target: gm.LatLng(20.5937, 78.9629),
            zoom: 5,
          ),
          markers: _markers,
          polylines: _polylines,
          heatmaps: _heatmaps,
          padding: _mapPadding,
          onMapCreated: _onMapCreated,
          onCameraIdle: _handleCameraIdle,
          style: _mapStyle,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        );
      },
    );
  }

  @override
  void setMapStyle(String? styleJson) {
    _mapStyle = (styleJson != null && styleJson.isNotEmpty) ? styleJson : null;
    _notifyMapDataChanged();
  }

  @override
  void applyMapStyleFromSettings(Brightness brightness) {
    final setting = _sharedPref?.getSetting();
    final isDark = brightness == Brightness.dark;
    final style = isDark
        ? setting?.mapThemeSetting?.darkMode
        : setting?.mapThemeSetting?.lightMode;
    debugPrint('🗺️ applyMapStyleFromSettings: isDark=$isDark, hasStyle=${style != null}, styleLength=${style?.length ?? 0}');
    setMapStyle(style);
  }

  void _onMapCreated(gm.GoogleMapController controller) {
    _controller = controller;

    if (_pendingCameraTarget != null) {
      _applyPendingCameraPosition();
    }

    if (_pendingBoundsPoints != null) {
      _applyPendingBounds();
    }
  }

  void _notifyMapDataChanged() {
    if (_disposed) return;
    _setMapState?.call(() {});
  }

  @override
  void detachView() {
    _setMapState = null;
    _buildCalled = false;
    _controller?.dispose();
    _controller = null;
  }

  @override
  void setController(dynamic controller) {
    if (controller is gm.GoogleMapController) {
      _controller = controller;
    }
  }

  @override
  void handleCameraIdle() {
    _handleCameraIdle();
  }

  @override
  void dispose() {
    _disposed = true;
    detachView();
    _driverPollTimer?.cancel();
    _driverPollTimer = null;
    _driverAnimTimer?.cancel();
    _driverAnimTimer = null;
    _onCameraIdleCallback = null;
  }

  // ===== Camera Operations =====

  @override
  Future<LatLng?> getCameraCenter() async {
    if (_controller == null) return null;
    try {
      final bounds = await _controller!.getVisibleRegion();
      final centerLat =
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
      final centerLng =
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
      return LatLng(centerLat, centerLng);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> animateCamera(LatLng target, {double? zoom}) async {
    _pendingCameraTarget = target;
    _pendingCameraZoom = zoom;
    _pendingBoundsPoints = null;
    _pendingBoundsPadding = null;

    if (_controller == null) {
      return;
    }

    try {
      final currentZoom = zoom ?? await _controller!.getZoomLevel();
      await _controller!.animateCamera(
        gm.CameraUpdate.newCameraPosition(
          gm.CameraPosition(
            target: gm.LatLng(target.latitude, target.longitude),
            zoom: currentZoom,
          ),
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> fitBounds(List<LatLng> points, {double padding = 50}) async {
    if (points.isEmpty) return;

    _pendingBoundsPoints = List<LatLng>.from(points);
    _pendingBoundsPadding = padding;
    _pendingCameraTarget = null;
    _pendingCameraZoom = null;

    if (_controller == null) {
      return;
    }

    if (points.length == 1) {
      await animateCamera(points.first, zoom: 16);
      return;
    }

    await _applyFitBounds(points, padding);
  }

  Future<void> _handleCameraIdle() async {
    if (_onCameraIdleCallback == null || _controller == null) return;

    try {
      final center = await getCameraCenter();
      if (center != null && _onCameraIdleCallback != null) {
        _onCameraIdleCallback!(center);
      }
    } catch (_) {}
  }

  Future<void> _applyPendingCameraPosition() async {
    if (_pendingCameraTarget == null || _controller == null) return;

    final target = _pendingCameraTarget!;
    final zoom = _pendingCameraZoom ?? 16;

    await _controller!.animateCamera(
      gm.CameraUpdate.newCameraPosition(
        gm.CameraPosition(
          target: gm.LatLng(target.latitude, target.longitude),
          zoom: zoom,
        ),
      ),
    );
  }

  Future<void> _applyPendingBounds() async {
    if (_pendingBoundsPoints == null || _controller == null) return;

    final points = _pendingBoundsPoints!;
    final padding = _pendingBoundsPadding ?? 50;

    await Future.delayed(const Duration(milliseconds: 300));
    await _applyFitBounds(points, padding);
  }

  Future<void> _applyFitBounds(List<LatLng> points, double padding) async {
    if (_controller == null || points.isEmpty) return;

    if (points.length == 1) {
      await animateCamera(points.first, zoom: 16);
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = gm.LatLngBounds(
      southwest: gm.LatLng(minLat, minLng),
      northeast: gm.LatLng(maxLat, maxLng),
    );

    try {
      await _controller!.animateCamera(
        gm.CameraUpdate.newLatLngBounds(bounds, padding),
      );
    } catch (_) {}
  }

  // ===== Markers =====

  @override
  void setMarkers(List<MapMarker> markers) {
    _loadMarkersWithIcons(markers);
  }

  /// Separates driver marker from static markers.
  /// Driver marker is animated via polling timer (Kotlin-style).
  /// Static markers are updated immediately.
  Future<void> _loadMarkersWithIcons(List<MapMarker> markers) async {
    final Set<gm.Marker> newStaticMarkers = {};

    for (final m in markers) {
      final icon = await _loadMarkerIcon(m);

      if (m.id == 'driver') {
        // Store target for polling timer to pick up (like Kotlin's movingMarker)
        _movingMarkerTarget = m.position;
        _movingMarkerIcon = icon;
        if (!_driverVisible) {
          _driverVisible = true;
          // Show immediately at initial position (matches Kotlin's Animatable initialization)
          _driverAnimatedPosition = m.position;
          _driverLastPolledTarget = m.position;
          _startDriverPolling();
        }
      } else {
        newStaticMarkers.add(gm.Marker(
          markerId: gm.MarkerId(m.id),
          position: gm.LatLng(m.position.latitude, m.position.longitude),
          icon: icon,
          infoWindow: gm.InfoWindow(
            title: m.title,
            snippet: m.snippet,
          ),
        ));
      }
    }

    _staticMarkers = newStaticMarkers;
    _rebuildMarkerSet();
  }

  // ===== Driver Marker Animation (Kotlin-style polling + animation) =====

  /// Combines static markers with the current animated driver marker.
  void _rebuildMarkerSet() {
    if (_driverVisible && _driverAnimatedPosition != null) {
      final driverMarker = gm.Marker(
        markerId: const gm.MarkerId('driver'),
        position: gm.LatLng(
          _driverAnimatedPosition!.latitude,
          _driverAnimatedPosition!.longitude,
        ),
        icon: _movingMarkerIcon,
        rotation: _driverAnimatedBearing,
        anchor: const Offset(0.5, 0.5),
        flat: true,
      );
      _markers = {..._staticMarkers, driverMarker};
    } else {
      _markers = {..._staticMarkers};
    }
    _notifyMapDataChanged();
  }

  /// Starts the 1300ms polling timer (matches Kotlin's LaunchedEffect(Unit) { while(true) { delay(1300) ... } })
  void _startDriverPolling() {
    _driverPollTimer?.cancel();
    _driverPollTimer = Timer.periodic(
      const Duration(milliseconds: 1300),
      (_) => _pollDriverPosition(),
    );
  }

  /// Called every 1300ms. Checks if driver position changed and starts animation.
  /// Matches Kotlin's polling logic inside LaunchedEffect(Unit).
  void _pollDriverPosition() {
    if (_movingMarkerTarget == null) return;

    final newTarget = _movingMarkerTarget!;
    final previousTarget = _driverLastPolledTarget;

    // Skip if position hasn't changed since last poll
    if (previousTarget != null &&
        previousTarget.latitude == newTarget.latitude &&
        previousTarget.longitude == newTarget.longitude) {
      return;
    }

    _driverLastPolledTarget = newTarget;

    if (previousTarget != null) {
      // Calculate bearing (Kotlin-style: atan with quadrant logic)
      final bearing = _calculateBearing(previousTarget, newTarget);

      // Animation start = current animated position (smooth continuation)
      _driverAnimStartPos = _driverAnimatedPosition ?? previousTarget;
      _driverStartBearing = _driverAnimatedBearing;
      _driverTargetBearing =
          bearing >= 0 ? bearing : _driverAnimatedBearing;

      // Start frame-by-frame animation
      _startDriverAnimation(newTarget);

      // Animate camera to target (single call, matches Kotlin's MapEffect)
      if (_cameraFollowsDriver) {
        _animateCameraToDriver(newTarget, _driverTargetBearing);
      }
    } else {
      // First position — snap immediately
      _driverAnimatedPosition = newTarget;
      _driverAnimatedBearing = 0;
      _rebuildMarkerSet();

      if (_cameraFollowsDriver) {
        _animateCameraToDriver(newTarget, 0);
      }
    }
  }

  /// Runs a 1300ms linear animation from current position to target.
  /// Matches Kotlin's 3 parallel Animatable.animateTo(tween(1300ms, LinearEasing)).
  void _startDriverAnimation(LatLng target) {
    _driverAnimTimer?.cancel();

    const animDuration = Duration(milliseconds: 1300);
    const frameRate = Duration(milliseconds: 16);
    final totalFrames = animDuration.inMilliseconds ~/ frameRate.inMilliseconds;

    final startPos = _driverAnimStartPos!;
    final startBearing = _driverStartBearing;
    final endBearing = _driverTargetBearing;

    int currentFrame = 0;

    _driverAnimTimer = Timer.periodic(frameRate, (timer) {
      currentFrame++;
      final progress = (currentFrame / totalFrames).clamp(0.0, 1.0);

      // Linear interpolation (LinearEasing)
      final lat =
          startPos.latitude + (target.latitude - startPos.latitude) * progress;
      final lng = startPos.longitude +
          (target.longitude - startPos.longitude) * progress;
      final bearing = _interpolateBearing(startBearing, endBearing, progress);

      _driverAnimatedPosition = LatLng(lat, lng);
      _driverAnimatedBearing = bearing;
      _rebuildMarkerSet();

      if (progress >= 1.0) {
        timer.cancel();
      }
    });
  }

  /// Animates camera to follow driver with bearing rotation.
  /// Matches Kotlin's animateCameraPosition(target, zoom=16f, bearing, duration=1300L).
  Future<void> _animateCameraToDriver(
      LatLng position, double bearing) async {
    if (_controller == null) return;

    try {
      await _controller!.animateCamera(
        gm.CameraUpdate.newCameraPosition(
          gm.CameraPosition(
            target: gm.LatLng(position.latitude, position.longitude),
            zoom: 16,
            bearing: bearing,
            tilt: 0,
          ),
        ),
      );
    } catch (_) {}
  }

  /// Bearing calculation matching Kotlin's GoogleMapManager.calculateBearing() exactly.
  /// Uses atan(lng/lat) with quadrant logic instead of haversine.
  double _calculateBearing(LatLng start, LatLng end) {
    final lat = (start.latitude - end.latitude).abs();
    final lng = (start.longitude - end.longitude).abs();

    // Same point
    if (lat == 0 && lng == 0) return -1;

    // Division by zero protection (matches Kotlin MapBoxManager)
    if (lat == 0) {
      return start.longitude < end.longitude ? 90 : 270;
    }

    final v = math.atan(lng / lat) * (180 / math.pi);

    if (start.latitude < end.latitude && start.longitude < end.longitude) {
      return v;
    } else if (start.latitude >= end.latitude &&
        start.longitude < end.longitude) {
      return 90 - v + 90;
    } else if (start.latitude >= end.latitude &&
        start.longitude >= end.longitude) {
      return v + 180;
    } else if (start.latitude < end.latitude &&
        start.longitude >= end.longitude) {
      return 90 - v + 270;
    }

    return -1;
  }

  /// Interpolates bearing using shortest-arc logic.
  double _interpolateBearing(double from, double to, double progress) {
    var diff = to - from;

    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    var result = from + diff * progress;
    return (result + 360) % 360;
  }

  // ===== Marker Icon Loading =====

  Future<gm.BitmapDescriptor> _loadMarkerIcon(MapMarker marker) async {
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
        if (networkIcon != null) {
          return networkIcon;
        }
        if (marker.iconAsset != null) {
          return await _loadAssetIcon(marker);
        }
      }

      if (marker.iconAsset != null) {
        return await _loadAssetIcon(marker);
      }
    } catch (_) {}

    return gm.BitmapDescriptor.defaultMarker;
  }

  Future<gm.BitmapDescriptor> _loadAssetIcon(MapMarker marker) async {
    if (marker.iconColor != null) {
      return await _loadTintedMarkerIcon(
        marker.iconAsset!,
        Color(marker.iconColor!),
        marker.iconWidth ?? 32,
        marker.iconHeight ?? 32,
      );
    }
    return await _loadResizedAssetIcon(
      marker.iconAsset!,
      marker.iconWidth ?? 40,
      marker.iconHeight ?? 40,
    );
  }

  /// google_maps_flutter treats byte bitmaps as 1x unless told otherwise, so a
  /// 40px pin was stretched to 40 logical points (120px on a 3x screen) and
  /// came out blurry and washed out. Rasterise at the screen density and
  /// declare it via `imagePixelRatio`.
  double get _dpr => ui.PlatformDispatcher.instance.views.isEmpty
      ? 1.0
      : ui.PlatformDispatcher.instance.views.first.devicePixelRatio;

  /// Pixel size that fills [boxWidth]x[boxHeight] at screen density without
  /// distorting the source or enlarging past it.
  ({int width, int height}) _fitted({
    required int sourceWidth,
    required int sourceHeight,
    required double boxWidth,
    required double boxHeight,
  }) {
    if (sourceWidth <= 0 || sourceHeight <= 0) {
      return (width: boxWidth.round(), height: boxHeight.round());
    }
    final fit = math.min(
      boxWidth * _dpr / sourceWidth,
      boxHeight * _dpr / sourceHeight,
    );
    final capped = math.min(fit, 1.0);
    return (
      width: math.max(1, (sourceWidth * capped).round()),
      height: math.max(1, (sourceHeight * capped).round()),
    );
  }

  Future<gm.BitmapDescriptor> _loadResizedAssetIcon(
    String assetPath,
    double width,
    double height,
  ) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();

    // Decode original to get aspect ratio
    final originalCodec = await ui.instantiateImageCodec(bytes);
    final originalFrame = await originalCodec.getNextFrame();
    final originalImage = originalFrame.image;

    final target = _fitted(
      sourceWidth: originalImage.width,
      sourceHeight: originalImage.height,
      boxWidth: width,
      boxHeight: height,
    );

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: target.width,
      targetHeight: target.height,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final resizedBytes = byteData!.buffer.asUint8List();

    return gm.BitmapDescriptor.bytes(resizedBytes, imagePixelRatio: _dpr);
  }

  Future<gm.BitmapDescriptor?> _loadNetworkMarkerIcon(
    String url,
    double width,
    double height,
  ) async {
    final cacheKey = '$url-$width-$height';
    if (_networkIconCache.containsKey(cacheKey)) {
      return _networkIconCache[cacheKey]!;
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final originalCodec =
            await ui.instantiateImageCodec(response.bodyBytes);
        final originalFrame = await originalCodec.getNextFrame();
        final originalImage = originalFrame.image;

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
        final frame = await codec.getNextFrame();
        final image = frame.image;

        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();

        final icon = gm.BitmapDescriptor.bytes(bytes, imagePixelRatio: _dpr);
        _networkIconCache[cacheKey] = icon;
        return icon;
      }
    } catch (_) {}

    return null;
  }

  Future<gm.BitmapDescriptor> _createNumberedMarkerIcon(
    int number,
    Color color,
    double width,
    double height,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw at screen density so the number stays sharp; the canvas keeps using
    // logical coordinates after the scale.
    final scale = _dpr;
    canvas.scale(scale);

    final paint = Paint()..color = color;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: height * 0.6,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textX = (width - textPainter.width) / 2;
    final textY = (height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textX, textY));

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (width * scale).round(),
      (height * scale).round(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return gm.BitmapDescriptor.bytes(bytes, imagePixelRatio: scale);
  }

  Future<gm.BitmapDescriptor> _loadTintedMarkerIcon(
    String assetPath,
    Color tintColor,
    double width,
    double height,
  ) async {
    final data = await rootBundle.load(assetPath);
    final raw = data.buffer.asUint8List();

    // Forcing both dimensions squashed non-square pins; fit instead.
    final probe = await (await ui.instantiateImageCodec(raw)).getNextFrame();
    final target = _fitted(
      sourceWidth: probe.image.width,
      sourceHeight: probe.image.height,
      boxWidth: width,
      boxHeight: height,
    );

    final codec = await ui.instantiateImageCodec(
      raw,
      targetWidth: target.width,
      targetHeight: target.height,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..colorFilter = ColorFilter.mode(tintColor, BlendMode.srcIn);

    canvas.drawImage(image, Offset.zero, paint);

    final picture = recorder.endRecording();
    final tintedImage =
        await picture.toImage(target.width, target.height);

    final byteData =
        await tintedImage.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return gm.BitmapDescriptor.bytes(bytes, imagePixelRatio: _dpr);
  }

  // ===== Polylines =====

  @override
  void setPolyline(MapPolyline? polyline) {
    if (polyline == null) {
      _routePolyline = null;
    } else {
      _routePolyline = _createGooglePolyline(polyline);
    }
    _updateCombinedPolylines();
  }

  @override
  void setDriverPathPolyline(MapPolyline? polyline) {
    if (polyline == null) {
      _driverPathPolyline = null;
    } else {
      _driverPathPolyline = _createGooglePolyline(polyline);
    }
    _updateCombinedPolylines();
  }

  gm.Polyline _createGooglePolyline(MapPolyline polyline) {
    return gm.Polyline(
      polylineId: gm.PolylineId(polyline.id),
      points: polyline.points
          .map((p) => gm.LatLng(p.latitude, p.longitude))
          .toList(),
      color: Color(polyline.color),
      width: polyline.width.toInt(),
    );
  }

  void _updateCombinedPolylines() {
    final Set<gm.Polyline> combined = {};
    if (_routePolyline != null) {
      combined.add(_routePolyline!);
    }
    if (_driverPathPolyline != null) {
      combined.add(_driverPathPolyline!);
    }
    _polylines = combined;
    _notifyMapDataChanged();
  }

  // ===== Heat Map =====

  @override
  void setHeatMap(List<HeatMapPoint> points) {
    if (points.isEmpty) {
      clearHeatMap();
      return;
    }

    final weightedPoints = points
        .map((p) => gm.WeightedLatLng(
              gm.LatLng(p.latitude, p.longitude),
              weight: p.weight,
            ))
        .toList();

    _heatmaps = {
      gm.Heatmap(
        heatmapId: const gm.HeatmapId('heat_map'),
        data: weightedPoints,
        radius: const gm.HeatmapRadius.fromPixels(20),
        opacity: 0.7,
      ),
    };
    _notifyMapDataChanged();
  }

  @override
  void clearHeatMap() {
    _heatmaps = {};
    _notifyMapDataChanged();
  }

  // ===== Places SDK =====

  void _initPlacesSdk() {
    final setting = _sharedPref?.getSetting();
    final apiKey = setting?.mapKey?.placesAutoCompleteApiKey;

    if (apiKey != null && apiKey.isNotEmpty) {
      _placesSdk = places.FlutterGooglePlacesSdk(apiKey);
      debugPrint('Places SDK initialized');
    } else {
      debugPrint('Places API key not found, SDK not initialized');
    }
  }

  @override
  void resetAutocompleteSession() {
    _startNewSession = true;
  }

  @override
  Future<List<DestinationAddress>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    if (_placesSdk == null) {
      debugPrint('Places SDK not initialized');
      return [];
    }

    try {
      final response = await _placesSdk!.findAutocompletePredictions(
        query,
        newSessionToken: _startNewSession,
      );

      _startNewSession = false;

      final predictions = response.predictions;
      if (predictions.isNotEmpty) {
        return predictions
            .map((p) => DestinationAddress(
                  address: p.fullText,
                  placeId: p.placeId,
                  title: p.primaryText,
                  city: p.secondaryText,
                ))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('searchPlaces error: $e');
      return [];
    }
  }

  @override
  Future<DestinationAddress?> getPlaceDetails(String placeId) async {
    if (_placesSdk == null) {
      debugPrint('Places SDK not initialized');
      return null;
    }

    try {
      final response = await _placesSdk!.fetchPlace(
        placeId,
        fields: [
          places.PlaceField.Address,
          places.PlaceField.AddressComponents,
          places.PlaceField.Location,
          places.PlaceField.Name,
        ],
      );

      final result = response.place;
      if (result != null) {
        String? city;
        String? countryCode;
        String? country;
        String? postalCode;

        final addressComponents = result.addressComponents;
        if (addressComponents != null) {
          for (final component in addressComponents) {
            final types = component.types;
            if (types.contains('locality')) {
              city = component.name;
            } else if (types.contains('country')) {
              countryCode = component.shortName;
              country = component.name;
            } else if (types.contains('postal_code')) {
              postalCode = component.shortName;
            }
          }
        }

        return DestinationAddress(
          address: result.address,
          latitude: result.latLng?.lat,
          longitude: result.latLng?.lng,
          city: city,
          countryCode: countryCode,
          country: country,
          postalCode: postalCode,
          placeId: placeId,
          title: result.name,
        );
      }
      return null;
    } catch (e) {
      debugPrint('getPlaceDetails error: $e');
      return null;
    }
  }

  @override
  Future<DestinationAddress> getPlaceDetailWithCoordinates(
    double latitude,
    double longitude,
  ) async {
    final setting = _sharedPref?.getSetting();
    final apiKey = setting?.mapKey?.geocodingApiKey;

    if (apiKey == null || apiKey.isEmpty) {
      return DestinationAddress(latitude: latitude, longitude: longitude);
    }

    final result = await _appRepository.reverseGeocode(
      latitude: latitude,
      longitude: longitude,
      apiKey: apiKey,
    );

    return result ??
        DestinationAddress(latitude: latitude, longitude: longitude);
  }
}
