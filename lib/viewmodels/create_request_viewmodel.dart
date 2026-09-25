import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/managers/location_manager.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/invoice_util.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/destination_address.dart';
import '../models/invoice.dart' show Invoice;
import '../models/requests/create_booking_request.dart';
import '../models/responses/booking/booking_detail_response.dart'
    show InvoiceData, PriceData;
import '../models/responses/vehicle/vehicle_type_response.dart';

/// Ride type constants matching Kotlin RideTypesConstant:
/// Normal(1), Sharing(2), Rental(3)
class RideType {
  final String name;
  final int type;

  const RideType({required this.name, required this.type});

  static const normal = RideType(name: 'Normal', type: 1);
  static const sharing = RideType(name: 'Share', type: 2);
  static const rental = RideType(name: 'Rental', type: 3);

  static const all = [normal, sharing, rental];
}

/// Fare estimate data matching Kotlin FareEstimate
class FareEstimateData {
  final String totalPrice;
  final List<Invoice> invoiceList;
  final String? distance;
  final String? totalTime;
  final bool isMinFareApplied;

  const FareEstimateData({
    required this.totalPrice,
    this.invoiceList = const [],
    this.distance,
    this.totalTime,
    this.isMinFareApplied = false,
  });
}

/// Create request screen state
class CreateRequestState {
  final bool isLoading;
  final bool isFetchingPrice;

  /// True until the vehicle-types call (which carries the city's business
  /// setting) has come back once. The form defaults to every ride type with
  /// Now + Schedule enabled, so rendering before the response flashes options
  /// the city may not actually offer.
  final bool isInitialLoading;
  final int selectedRideType;
  final bool isScheduled;
  final DateTime? scheduledTime;
  final DestinationAddress? pickupAddress;
  final List<DestinationAddress> destinationAddresses;
  final String firstName;
  final String lastName;
  final String phone;
  final String countryPhoneCode;
  final String? errorMessage;
  final String? successMessage;
  final String? bookingId;

  // Fare estimate
  final String fareEstimatePrice;
  final String? vehiclePriceId;
  final String currencySign;

  // Available ride types (filtered from API response)
  final List<RideType> availableRideTypes;

  // Schedule visibility (from admin businessSetting)
  final bool isShowScheduleRide;
  final bool isShowRideNow;
  final int maxScheduleSelectableDays;

  // Business availability
  final bool isBusinessNotAvailable;
  final String? businessNotAvailableMessage;

  // Max intermediate stops from city settings (0 = unlimited)
  final int maxStop;

  const CreateRequestState({
    this.isLoading = false,
    this.isFetchingPrice = false,
    this.isInitialLoading = true,
    this.selectedRideType = 1,
    this.isScheduled = false,
    this.scheduledTime,
    this.pickupAddress,
    this.destinationAddresses = const [],
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.countryPhoneCode = '',
    this.errorMessage,
    this.successMessage,
    this.bookingId,
    this.fareEstimatePrice = '',
    this.vehiclePriceId,
    this.currencySign = '',
    this.availableRideTypes = RideType.all,
    this.isShowScheduleRide = true,
    this.isShowRideNow = true,
    this.maxScheduleSelectableDays = 30,
    this.isBusinessNotAvailable = false,
    this.businessNotAvailableMessage,
    this.maxStop = 0,
  });

  CreateRequestState copyWith({
    bool? isLoading,
    bool? isFetchingPrice,
    bool? isInitialLoading,
    int? selectedRideType,
    bool? isScheduled,
    DateTime? scheduledTime,
    DestinationAddress? pickupAddress,
    List<DestinationAddress>? destinationAddresses,
    String? firstName,
    String? lastName,
    String? phone,
    String? countryPhoneCode,
    String? errorMessage,
    String? successMessage,
    String? bookingId,
    String? fareEstimatePrice,
    String? vehiclePriceId,
    String? currencySign,
    List<RideType>? availableRideTypes,
    bool? isShowScheduleRide,
    bool? isShowRideNow,
    int? maxScheduleSelectableDays,
    bool? isBusinessNotAvailable,
    String? businessNotAvailableMessage,
    int? maxStop,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearPickup = false,
    bool clearSchedule = false,
    bool clearFareEstimate = false,
  }) {
    return CreateRequestState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingPrice: isFetchingPrice ?? this.isFetchingPrice,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      selectedRideType: selectedRideType ?? this.selectedRideType,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduledTime:
          clearSchedule ? null : (scheduledTime ?? this.scheduledTime),
      pickupAddress:
          clearPickup ? null : (pickupAddress ?? this.pickupAddress),
      destinationAddresses: destinationAddresses ?? this.destinationAddresses,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      countryPhoneCode: countryPhoneCode ?? this.countryPhoneCode,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      bookingId: bookingId ?? this.bookingId,
      fareEstimatePrice: clearFareEstimate
          ? ''
          : (fareEstimatePrice ?? this.fareEstimatePrice),
      vehiclePriceId: clearFareEstimate
          ? null
          : (vehiclePriceId ?? this.vehiclePriceId),
      currencySign: currencySign ?? this.currencySign,
      availableRideTypes: availableRideTypes ?? this.availableRideTypes,
      isShowScheduleRide: isShowScheduleRide ?? this.isShowScheduleRide,
      isShowRideNow: isShowRideNow ?? this.isShowRideNow,
      maxScheduleSelectableDays: maxScheduleSelectableDays ?? this.maxScheduleSelectableDays,
      isBusinessNotAvailable: isBusinessNotAvailable ?? this.isBusinessNotAvailable,
      businessNotAvailableMessage: businessNotAvailableMessage ?? this.businessNotAvailableMessage,
      maxStop: maxStop ?? this.maxStop,
    );
  }
}

/// Create request screen ViewModel
class CreateRequestViewModel extends StateNotifier<CreateRequestState> {
  final AppRepository _appRepository;
  final SharedPreferenceManager _sharedPref;

  // Cache the full response for fare detail bottom sheet
  GetVehicleTypeResponse? _vehicleTypeResponse;

  CreateRequestViewModel(this._appRepository, this._sharedPref)
      : super(const CreateRequestState()) {
    final entity = _sharedPref.getEntity();
    final setting = _sharedPref.getSetting();
    state = state.copyWith(
      countryPhoneCode: entity?.countryPhoneCode ?? '',
      currencySign: setting?.currencySign ?? '',
    );
    _initLocation();
  }

  Future<void> _initLocation() async {
    final result = await LocationManager.instance.getCurrentLocation();
    if (result is! LocationSuccess) {
      state = state.copyWith(
        isInitialLoading: false,
        isBusinessNotAvailable: true,
        businessNotAvailableMessage: 'Unable to get your current location',
      );
      return;
    }

    final loc = result.location;
    final apiKey = _sharedPref.getSetting()?.mapKey?.geocodingApiKey;
    DestinationAddress address;

    if (apiKey != null && apiKey.isNotEmpty) {
      final geocoded = await _appRepository.reverseGeocode(
        latitude: loc.latitude,
        longitude: loc.longitude,
        apiKey: apiKey,
      );
      address = geocoded ?? DestinationAddress(latitude: loc.latitude, longitude: loc.longitude);
    } else {
      address = DestinationAddress(latitude: loc.latitude, longitude: loc.longitude);
    }

    state = state.copyWith(pickupAddress: address);
    _fetchVehicleTypes();
  }

  void setRideType(int type) {
    final businessSetting = _vehicleTypeResponse?.citySetting?.businessSetting;
    final driverSetting = _vehicleTypeResponse?.citySetting?.driverSetting;
    final isShowSchedule = businessSetting?.checkAvailability('SCHEDULE', type) ?? true;
    final isShowNow = businessSetting?.checkAvailability('NOW', type) ?? true;
    final maxDays = driverSetting?.getMaxBookingDays(type) ?? 30;

    state = state.copyWith(
      selectedRideType: type,
      isShowScheduleRide: isShowSchedule,
      isShowRideNow: isShowNow,
      maxScheduleSelectableDays: maxDays,
    );
    _updatePriceFromCache();
  }

  void toggleScheduled(bool isScheduled) {
    state = state.copyWith(
      isScheduled: isScheduled,
      clearSchedule: !isScheduled,
    );
  }

  void setScheduledTime(DateTime time) {
    final minFutureTime = DateTime.now().add(const Duration(minutes: 30));
    if (time.isBefore(minFutureTime)) {
      state = state.copyWith(errorMessage: 'Please select a time at least 30 minutes from now');
      return;
    }
    state = state.copyWith(scheduledTime: time, isScheduled: true);
  }

  void setPickupAddress(DestinationAddress address) {
    state = state.copyWith(pickupAddress: address);
    _fetchVehicleTypesIfReady();
  }

  void addDestination(DestinationAddress address) {
    // maxStop=0 means unlimited; stops = destinationAddresses.length - 1 (last is dropoff)
    final stopCount = state.destinationAddresses.length; // existing entries before new one
    if (state.maxStop > 0 && stopCount >= state.maxStop + 1) {
      // +1 because destinationAddresses includes the dropoff
      state = state.copyWith(errorMessage: 'Maximum stop limit reached');
      return;
    }
    state = state.copyWith(
      destinationAddresses: [...state.destinationAddresses, address],
    );
    _fetchVehicleTypesIfReady();
  }

  void updateDestination(int index, DestinationAddress address) {
    final list = [...state.destinationAddresses];
    if (index < list.length) {
      list[index] = address;
      state = state.copyWith(destinationAddresses: list);
      _fetchVehicleTypesIfReady();
    }
  }

  void removeDestination(int index) {
    final list = [...state.destinationAddresses];
    if (index < list.length) {
      list.removeAt(index);
      state = state.copyWith(
        destinationAddresses: list,
        clearFareEstimate: list.isEmpty,
      );
      if (list.isNotEmpty) {
        _fetchVehicleTypesIfReady();
      }
    }
  }

  void updateFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void updateLastName(String value) {
    state = state.copyWith(lastName: value);
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  /// Returns fare detail for the bottom sheet using InvoiceUtil (matches customer app)
  FareEstimateData? getFareDetail() {
    final list = _getVehicleListForType(state.selectedRideType);
    if (list == null || list.isEmpty) return null;

    final invoiceData = list.first.priceDetail;
    if (invoiceData == null) return null;

    final setting = _sharedPref.getSetting();
    final currencyDirection = setting?.setCurrencySign ?? 1;
    final decimalPointValue = setting?.decimalPointValue ?? 2;

    // Map additional price titles from customPrices
    final customPrices = _vehicleTypeResponse?.customPrices;
    final mappedInvoiceData = _mapAdditionalPriceTitles(invoiceData, customPrices);

    final invoiceUtil = InvoiceUtil(
      currencyDirection: currencyDirection,
      currencySign: state.currencySign,
      decimalPointValue: decimalPointValue,
    );

    final invoiceList = invoiceUtil.getInvoiceElements(
      invoiceData: mappedInvoiceData,
      isShowEarning: false,
      isFareEstimate: true,
    );

    // Distance & time from the response
    final dist = _vehicleTypeResponse?.distance;
    final time = _vehicleTypeResponse?.time;

    return FareEstimateData(
      totalPrice: state.fareEstimatePrice,
      invoiceList: invoiceList,
      distance: dist != null ? '${(dist / 1000).toStringAsFixed(1)} km' : null,
      totalTime: time != null ? '${(time / 60).ceil()} min' : null,
      isMinFareApplied: invoiceData.isMinFareApplied ?? false,
    );
  }

  /// Map additionalPrices titles from customPrices using chargeId
  InvoiceData _mapAdditionalPriceTitles(
    InvoiceData invoiceData,
    List<CustomPrice>? customPrices,
  ) {
    if (customPrices == null || customPrices.isEmpty) return invoiceData;

    final mapped = invoiceData.additionalPrices?.map((price) {
      final custom = customPrices.where((cp) => cp.id == price.chargeId).firstOrNull;
      if (custom?.title != null && custom!.title!.isNotEmpty) {
        return PriceData(
          title: custom.title,
          chargeId: price.chargeId,
          price: price.price,
          unit: price.unit,
          unitPrice: price.unitPrice,
          basePrice: price.basePrice,
          basePriceUnit: price.basePriceUnit,
          discountedPrice: price.discountedPrice,
          driverProfit: price.driverProfit,
          driverProfitType: price.driverProfitType,
          driverProfitPercentage: price.driverProfitPercentage,
          isApplySlotPrice: price.isApplySlotPrice,
          appliedSlots: price.appliedSlots,
          slots: price.slots,
          applyOn: price.applyOn,
          childs: price.childs,
          isSlotInPriceWithUnitCalculation: price.isSlotInPriceWithUnitCalculation,
          isSlotInPriceWithSum: price.isSlotInPriceWithSum,
        );
      }
      return price;
    }).toList();

    return InvoiceData(
      distance: invoiceData.distance,
      time: invoiceData.time,
      waitingTime: invoiceData.waitingTime,
      stopWaitingTime: invoiceData.stopWaitingTime,
      trafficTime: invoiceData.trafficTime,
      isMinFareApplied: invoiceData.isMinFareApplied,
      charges: invoiceData.charges,
      additionalPrices: mapped,
      taxPrices: invoiceData.taxPrices,
      total: invoiceData.total,
      driverProfit: invoiceData.driverProfit,
    );
  }

  void _fetchVehicleTypesIfReady() {
    if (state.pickupAddress != null) {
      _fetchVehicleTypes();
    }
  }

  Future<void> _fetchVehicleTypes() async {
    state = state.copyWith(isFetchingPrice: true);

    final pickup = state.pickupAddress!;
    final entity = _sharedPref.getEntity();
    final body = <String, dynamic>{
      'countryCode': entity?.countryCode ?? pickup.countryCode ?? '',
      'pickupAddress': {
        'address': pickup.address,
        'latitude': pickup.latitude,
        'longitude': pickup.longitude,
        'city': pickup.city,
        'country': pickup.country,
        'placeId': pickup.placeId,
      },
      'destinationAddresses': state.destinationAddresses
          .map((d) => {
                'address': d.address,
                'latitude': d.latitude,
                'longitude': d.longitude,
                'city': d.city,
                'country': d.country,
                'placeId': d.placeId,
              })
          .toList(),
    };

    debugPrint('CreateRequestVM: fetching vehicle types...');
    final response = await _appRepository.getVehicleTypes(body);

    switch (response) {
      case Success<GetVehicleTypeResponse>():
        _vehicleTypeResponse = response.data;
        debugPrint('CreateRequestVM: normalList=${response.data?.normalList?.length}, '
            'shareList=${response.data?.shareList?.length}');

        // Filter ride types to only those with data in the response
        final data = response.data;
        var filtered = RideType.all.where((rt) {
          switch (rt.type) {
            case 1: return data?.normalList?.isNotEmpty == true;
            case 2: return data?.shareList?.isNotEmpty == true;
            case 3: return data?.rentalList?.isNotEmpty == true;
            default: return false;
          }
        }).toList();

        // Reorder by bookingTypeOrder if provided
        final order = data?.bookingTypeOrder;
        if (order != null && order.isNotEmpty) {
          filtered = order
              .map((type) => filtered.where((rt) => rt.type == type).firstOrNull)
              .whereType<RideType>()
              .toList();
        }

        if (filtered.isEmpty) {
          state = state.copyWith(
            isFetchingPrice: false,
            isInitialLoading: false,
            isBusinessNotAvailable: true,
            businessNotAvailableMessage: 'Business not available in your area',
            clearFareEstimate: true,
          );
          return;
        }

        // If selected ride type is no longer available, switch to first available
        final selectedStillAvailable = filtered.any((rt) => rt.type == state.selectedRideType);
        final newSelectedType = selectedStillAvailable ? state.selectedRideType : filtered.first.type;

        final businessSetting = data?.citySetting?.businessSetting;
        final driverSetting = data?.citySetting?.driverSetting;
        final isShowSchedule = businessSetting?.checkAvailability('SCHEDULE', newSelectedType) ?? true;
        final isShowNow = businessSetting?.checkAvailability('NOW', newSelectedType) ?? true;
        final maxDays = driverSetting?.getMaxBookingDays(newSelectedType) ?? 30;

        final maxStop = data?.citySetting?.maxStopLimit ?? 0;

        state = state.copyWith(
          isFetchingPrice: false,
          isInitialLoading: false,
          isBusinessNotAvailable: false,
          availableRideTypes: filtered,
          selectedRideType: newSelectedType,
          isShowScheduleRide: isShowSchedule,
          isShowRideNow: isShowNow,
          maxScheduleSelectableDays: maxDays,
          maxStop: maxStop,
          // If Now is disabled but schedule was not set, mark as scheduled
          isScheduled: !isShowNow && state.scheduledTime == null ? true : null,
        );
        _updatePriceFromCache();

      case Error():
        debugPrint('CreateRequestVM: getVehicleTypes error: ${response.error?.message}');
        state = state.copyWith(
          isFetchingPrice: false,
          isInitialLoading: false,
          isBusinessNotAvailable: true,
          businessNotAvailableMessage: response.error?.message ?? 'Business not available',
          clearFareEstimate: true,
        );

      case Loading():
        break;
    }
  }

  void _updatePriceFromCache() {
    final list = _getVehicleListForType(state.selectedRideType);
    if (list == null || list.isEmpty) {
      state = state.copyWith(clearFareEstimate: true);
      return;
    }

    final vehicle = list.first;
    final price = vehicle.itemPrice ?? vehicle.priceDetail?.total?.toStringAsFixed(2);
    final cs = state.currencySign;

    state = state.copyWith(
      fareEstimatePrice: price != null && price.isNotEmpty ? '$cs$price' : '',
      vehiclePriceId: vehicle.id,
    );
  }

  List<VehicleTypeItem>? _getVehicleListForType(int type) {
    if (_vehicleTypeResponse == null) return null;
    switch (type) {
      case 1:
        return _vehicleTypeResponse!.normalList;
      case 2:
        return _vehicleTypeResponse!.shareList;
      case 3:
        return _vehicleTypeResponse!.rentalList;
      default:
        return _vehicleTypeResponse!.normalList;
    }
  }

  /// Haversine distance between two lat/lng points in km (matches iOS Utility.getDistanceFromTwoLocation)
  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const radius = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return radius * c;
  }

  /// Returns error message if consecutive addresses are too close (< 9 meters), else null.
  String? _duplicateAddressError() {
    final pickup = state.pickupAddress;
    if (pickup == null) return null;

    // Build the full address chain: pickup + stops + dropoff
    final allAddresses = <DestinationAddress>[pickup, ...state.destinationAddresses];
    final total = allAddresses.length;

    for (int i = 0; i < total - 1; i++) {
      final src = allAddresses[i];
      final dst = allAddresses[i + 1];
      if (src.latitude == null || src.longitude == null ||
          dst.latitude == null || dst.longitude == null) { continue; }

      final dist = _haversineKm(src.latitude!, src.longitude!, dst.latitude!, dst.longitude!);
      if (dist < 0.009) {
        if (i == 0) {
          return total <= 2
              ? 'Pickup and destination must be different'
              : 'Pickup and stop must be different';
        } else if (i > 0 && total <= 3) {
          return 'Stop and drop-off must be different';
        } else {
          return 'Consecutive stops must be different';
        }
      }
    }
    return null;
  }

  Future<void> createBooking() async {
    // 1. Schedule required: if only SCHEDULE enabled and no date picked
    if (!state.isShowRideNow && state.isShowScheduleRide && state.scheduledTime == null) {
      state = state.copyWith(errorMessage: 'Please select a schedule date');
      return;
    }

    // 2. Pickup address
    if (state.pickupAddress == null || (state.pickupAddress!.address?.isEmpty ?? true)) {
      state = state.copyWith(errorMessage: 'Please select pickup address');
      return;
    }

    // 3. All stop addresses must be filled (non-empty)
    final stops = state.destinationAddresses;
    if (stops.length > 1) {
      final hasEmptyStop = stops.take(stops.length - 1).any(
            (s) => s.address == null || s.address!.trim().isEmpty,
          );
      if (hasEmptyStop) {
        state = state.copyWith(errorMessage: 'Please enter valid stop address');
        return;
      }
    }

    // 4. Dropoff address
    if (stops.isEmpty || (stops.last.address?.isEmpty ?? true)) {
      state = state.copyWith(errorMessage: 'Please add at least one destination');
      return;
    }

    // 5. Duplicate / too-close address check
    final dupError = _duplicateAddressError();
    if (dupError != null) {
      state = state.copyWith(errorMessage: dupError);
      return;
    }

    // 6. Customer details
    if (state.firstName.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter customer first name');
      return;
    }
    if (state.lastName.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter customer last name');
      return;
    }
    if (state.countryPhoneCode.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please select country phone code');
      return;
    }
    if (state.phone.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter customer phone number');
      return;
    }

    // 7. Phone number length validation
    final setting = _sharedPref.getSetting();
    final minLen = setting?.minPhoneLength ?? 0;
    final maxLen = setting?.maxPhoneLength ?? 0;
    final phoneLen = state.phone.trim().length;
    if (minLen > 0 && maxLen > 0 && (phoneLen < minLen || phoneLen > maxLen)) {
      state = state.copyWith(
        errorMessage: phoneLen < minLen
            ? 'Phone number must be at least $minLen characters'
            : 'Phone number must be at most $maxLen characters',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final pickup = state.pickupAddress!;
    final bookingTime = state.isScheduled && state.scheduledTime != null
        ? state.scheduledTime!.millisecondsSinceEpoch
        : DateTime.now().millisecondsSinceEpoch;

    final request = CreateBookingRequest(
      bookingType: state.selectedRideType,
      isBookForOther: true,
      bookingTime: bookingTime,
      paymentMode: 1,
      isFixFare: false,
      isBidding: false,
      bidPrice: 0,
      accessibilityIds: const [],
      promoCodeId: '',
      vehiclePriceId: state.vehiclePriceId,
      pickupAddress: CreateBookingAddress(
        address: pickup.address,
        latitude: pickup.latitude,
        longitude: pickup.longitude,
        city: pickup.city,
        country: pickup.country,
        countryCode: pickup.countryCode ?? _sharedPref.getEntity()?.countryCode,
        placeId: pickup.placeId,
      ),
      destinationAddresses: state.destinationAddresses
          .map((d) => CreateBookingAddress(
                address: d.address,
                latitude: d.latitude,
                longitude: d.longitude,
                city: d.city,
                country: d.country,
                countryCode: d.countryCode,
                placeId: d.placeId,
              ))
          .toList(),
      customerDetail: CreateBookingCustomerDetail(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        phone: state.phone.trim(),
        countryPhoneCode: state.countryPhoneCode,
      ),
    );

    final response = await _appRepository.createBooking(request);

    switch (response) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          successMessage: response.message ?? 'Booking created successfully',
        );

      case Error():
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.error?.message ?? 'Failed to create booking',
        );

      case Loading():
        break;
    }
  }
}

/// Provider for CreateRequestViewModel
final createRequestViewModelProvider = StateNotifierProvider.autoDispose<
    CreateRequestViewModel, CreateRequestState>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => throw Exception('SharedPreferences not initialized'),
      );
  return CreateRequestViewModel(appRepository, sharedPref);
});
