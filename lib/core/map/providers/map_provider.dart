import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repository/app_repository.dart';
import '../../preferences/shared_preference_manager.dart';
import '../../providers/app_providers.dart';
import '../interface/map_interface.dart';
import '../managers/google_map_manager.dart';
import '../managers/mapbox_map_manager.dart';
import '../models/map_types.dart';

/// Factory provider for MapInterface.
/// Returns a function that creates a new MapInterface instance each time it's called.
/// Each screen should call this once in initState and dispose it manually.
///
/// Usage:
/// ```dart
/// late final MapInterface _mapManager;
///
/// @override
/// void initState() {
///   super.initState();
///   _mapManager = ref.read(mapManagerProvider)();
/// }
///
/// @override
/// void dispose() {
///   _mapManager.dispose();
///   super.dispose();
/// }
/// ```
final mapManagerProvider = Provider<MapInterface Function()>((ref) {
  final sharedPref = ref.read(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => null,
      );
  final appRepository = ref.read(appRepositoryProvider);

  // Get map type from settings, default to Google
  final mapTypeValue = sharedPref?.getSetting()?.mapType;
  final mapType = MapProviderType.fromValue(mapTypeValue);

  // Return factory function that creates new instance each time
  return () {
    return _createMapManager(
      type: mapType,
      appRepository: appRepository,
      sharedPref: sharedPref,
    );
  };
});

/// Factory function to create map manager based on type
MapInterface _createMapManager({
  required MapProviderType type,
  required AppRepository appRepository,
  SharedPreferenceManager? sharedPref,
}) {
  switch (type) {
    case MapProviderType.google:
      return GoogleMapManager(appRepository: appRepository, sharedPref: sharedPref);
    case MapProviderType.mapbox:
      return MapboxMapManager(appRepository: appRepository, sharedPref: sharedPref);
    case MapProviderType.apple:
      return GoogleMapManager(appRepository: appRepository, sharedPref: sharedPref);
    case MapProviderType.openStreet:
      return GoogleMapManager(appRepository: appRepository, sharedPref: sharedPref);
  }
}
