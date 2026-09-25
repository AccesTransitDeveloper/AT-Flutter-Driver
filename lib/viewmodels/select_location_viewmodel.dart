import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/managers/location_manager.dart';
import '../core/map/interface/map_interface.dart';
import '../core/map/models/map_types.dart';
import '../models/destination_address.dart';

class SelectLocationState {
  final bool isSearching;
  final bool isLoadingMapAddress;
  final bool isMapSelectionMode;
  final String searchQuery;
  final List<DestinationAddress> searchResults;
  final DestinationAddress? mapSelectionAddress;
  final LatLng? currentLocation;
  final DestinationAddress? initialAddress;

  SelectLocationState({
    this.isSearching = false,
    this.isLoadingMapAddress = false,
    this.isMapSelectionMode = false,
    this.searchQuery = '',
    this.searchResults = const [],
    this.mapSelectionAddress,
    this.currentLocation,
    this.initialAddress,
  });

  SelectLocationState copyWith({
    bool? isSearching,
    bool? isLoadingMapAddress,
    bool? isMapSelectionMode,
    String? searchQuery,
    List<DestinationAddress>? searchResults,
    DestinationAddress? mapSelectionAddress,
    LatLng? currentLocation,
    DestinationAddress? initialAddress,
    bool clearMapSelectionAddress = false,
    bool clearInitialAddress = false,
  }) {
    return SelectLocationState(
      isSearching: isSearching ?? this.isSearching,
      isLoadingMapAddress: isLoadingMapAddress ?? this.isLoadingMapAddress,
      isMapSelectionMode: isMapSelectionMode ?? this.isMapSelectionMode,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      mapSelectionAddress: clearMapSelectionAddress
          ? null
          : (mapSelectionAddress ?? this.mapSelectionAddress),
      currentLocation: currentLocation ?? this.currentLocation,
      initialAddress: clearInitialAddress
          ? null
          : (initialAddress ?? this.initialAddress),
    );
  }
}

class SelectLocationViewModel extends StateNotifier<SelectLocationState> {
  final MapInterface _mapManager;

  SelectLocationViewModel({required MapInterface mapManager})
      : _mapManager = mapManager,
        super(SelectLocationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final result = await LocationManager.instance.getCurrentLocation();
    switch (result) {
      case LocationSuccess(location: final loc):
        state = state.copyWith(
          currentLocation: LatLng(loc.latitude, loc.longitude),
        );
      default:
        debugPrint('SelectLocationViewModel: Could not get current location');
    }
  }

  Future<void> searchPlaces(String query) async {
    state = state.copyWith(searchQuery: query);
    if (query.length < 3) {
      state = state.copyWith(searchResults: [], isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true);
    final results = await _mapManager.searchPlaces(query);
    state = state.copyWith(searchResults: results, isSearching: false);
  }

  Future<DestinationAddress?> getPlaceDetails(DestinationAddress place) async {
    if (place.latitude != null && place.longitude != null) return place;
    if (place.placeId != null) {
      final details = await _mapManager.getPlaceDetails(place.placeId!);
      if (details != null) {
        _mapManager.resetAutocompleteSession();
        return details;
      }
    }
    return null;
  }

  void setInitialAddress(DestinationAddress address) {
    state = state.copyWith(initialAddress: address);
  }

  Future<void> enterMapSelectionMode() async {
    _mapManager.onCameraIdle = _onCameraIdle;

    final initial = state.initialAddress;
    if (initial != null &&
        initial.latitude != null &&
        initial.longitude != null) {
      state = state.copyWith(
        isMapSelectionMode: true,
        mapSelectionAddress: initial,
      );
      await _mapManager.animateCamera(
        LatLng(initial.latitude!, initial.longitude!),
        zoom: 16,
      );
    } else if (state.currentLocation != null) {
      state = state.copyWith(
        isMapSelectionMode: true,
        clearMapSelectionAddress: true,
      );
      await _mapManager.animateCamera(state.currentLocation!, zoom: 16);
    } else {
      state = state.copyWith(
        isMapSelectionMode: true,
        clearMapSelectionAddress: true,
      );
    }
  }

  void exitMapSelectionMode() {
    state = state.copyWith(isMapSelectionMode: false);
    _mapManager.onCameraIdle = null;
  }

  void _onCameraIdle(LatLng center) {
    if (!state.isMapSelectionMode) return;
    _fetchAddressForLocation(center.latitude, center.longitude);
  }

  Future<void> _fetchAddressForLocation(double lat, double lng) async {
    state = state.copyWith(isLoadingMapAddress: true);
    final address = await _mapManager.getPlaceDetailWithCoordinates(lat, lng);
    if (state.isMapSelectionMode) {
      state = state.copyWith(
        mapSelectionAddress: address,
        isLoadingMapAddress: false,
      );
    }
  }

  DestinationAddress? confirmMapSelection() {
    final address = state.mapSelectionAddress;
    if (address == null) return null;
    state = state.copyWith(
      isMapSelectionMode: false,
      clearMapSelectionAddress: true,
    );
    _mapManager.onCameraIdle = null;
    return address;
  }

  Future<void> moveToCurrentLocation() async {
    final result = await LocationManager.instance.getCurrentLocation();
    switch (result) {
      case LocationSuccess(location: final loc):
        await _mapManager.animateCamera(
          LatLng(loc.latitude, loc.longitude),
          zoom: 16,
        );
      default:
        break;
    }
  }

  double? calculateDistanceMiles(DestinationAddress address) {
    if (state.currentLocation == null ||
        address.latitude == null ||
        address.longitude == null) {
      return null;
    }
    final meters = LocationManager.instance.calculateDistance(
      state.currentLocation!.latitude,
      state.currentLocation!.longitude,
      address.latitude!,
      address.longitude!,
    );
    return meters / 1609.344;
  }
}

final selectLocationViewModelProvider = StateNotifierProvider.autoDispose
    .family<SelectLocationViewModel, SelectLocationState, MapInterface>(
  (ref, mapManager) => SelectLocationViewModel(mapManager: mapManager),
);
