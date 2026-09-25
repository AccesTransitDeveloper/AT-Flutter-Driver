import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/socket_constants.dart';
import '../core/localization/app_strings.dart';
import '../core/managers/socket_manager.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/validator/validator.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/requests/pick_vehicle_request.dart';
import '../models/requests/vehicle_add_update_request.dart';
import '../models/responses/vehicle/accessibility_response.dart';
import '../models/responses/vehicle/vehicle_color_response.dart';
import '../models/responses/vehicle/vehicle_list_response.dart';

/// Invoice item for vehicle price display
class VehicleInvoice {
  final String? title;
  final String? subTitle;

  VehicleInvoice({this.title, this.subTitle});
}

/// Vehicle screen state — mirrors Kotlin VehicleState
class VehicleState {
  // Lists
  final List<Vehicle> vehicleList;
  final List<Vehicle> totalVehicleList;
  final List<String> vehicleTypeList;
  final List<Accessibility>? accessibilityList;
  final List<Brand>? brandsList;
  final List<VehicleColor>? colorList;
  final List<VehicleModel>? modelList;
  final List<VehicleInvoice> vehicleInvoiceList;

  // Selected vehicle
  final Vehicle? selectedVehicle;
  final Vehicle? pickedVehicle;
  final Vehicle? vehicleTypeSelection;
  final String? vehicleId;

  // Form fields
  final String? vehicleName;
  final String? plateNo;
  final String? vehicleLicense;
  final String? vehicleColor;
  final String? vehicleYear;
  final String? vehicleSelectedYear;
  final int? vehicleType;
  final int? selectedVehicleTypeIndex;
  final Brand? selectedBrands;
  final Brand? vehicleBrandSelection;
  final VehicleModel? selectedModels;
  final VehicleModel? vehicleModelSelection;
  final String? countryId;
  final List<FallBackType>? fallbackTypes;
  final List<String>? fallbackTypeIds;
  final List<String>? accessibilityIdList;

  // UI state
  final bool isLoading;
  final bool isDataLoading;
  final bool isFieldsEnabled;
  final bool isNavigateBack;
  final String snackBarMessage;
  final bool isSnackBarError;

  // Bottom sheets
  final bool isShowYearBottomSheet;
  final bool isShowBrandBottomSheet;
  final bool isShowModelBottomSheet;
  final bool showSelectVehicleSheet;
  final String selectVehicleMessage;
  final bool isShowQrCodeBottomSheet;
  final String qrData;

  // Driver type
  final bool isHubDriver;
  final bool isPartnerDriver;
  final bool isOnline;

  // Permissions
  final bool isCameraPermissionGranted;
  final bool showPermissionDialog;

  const VehicleState({
    this.vehicleList = const [],
    this.totalVehicleList = const [],
    this.vehicleTypeList = const [],
    this.accessibilityList,
    this.brandsList,
    this.colorList,
    this.modelList,
    this.vehicleInvoiceList = const [],
    this.selectedVehicle,
    this.pickedVehicle,
    this.vehicleTypeSelection,
    this.vehicleId,
    this.vehicleName,
    this.plateNo,
    this.vehicleLicense,
    this.vehicleColor,
    this.vehicleYear,
    this.vehicleSelectedYear,
    this.vehicleType,
    this.selectedVehicleTypeIndex,
    this.selectedBrands,
    this.vehicleBrandSelection,
    this.selectedModels,
    this.vehicleModelSelection,
    this.countryId,
    this.fallbackTypes,
    this.fallbackTypeIds,
    this.accessibilityIdList,
    this.isLoading = false,
    this.isDataLoading = true,
    this.isFieldsEnabled = true,
    this.isNavigateBack = false,
    this.snackBarMessage = '',
    this.isSnackBarError = false,
    this.isShowYearBottomSheet = false,
    this.isShowBrandBottomSheet = false,
    this.isShowModelBottomSheet = false,
    this.showSelectVehicleSheet = false,
    this.selectVehicleMessage = '',
    this.isShowQrCodeBottomSheet = false,
    this.qrData = '',
    this.isHubDriver = false,
    this.isPartnerDriver = false,
    this.isOnline = false,
    this.isCameraPermissionGranted = false,
    this.showPermissionDialog = false,
  });

  VehicleState copyWith({
    List<Vehicle>? vehicleList,
    List<Vehicle>? totalVehicleList,
    List<String>? vehicleTypeList,
    List<Accessibility>? accessibilityList,
    List<Brand>? brandsList,
    List<VehicleColor>? colorList,
    List<VehicleModel>? modelList,
    List<VehicleInvoice>? vehicleInvoiceList,
    Vehicle? selectedVehicle,
    Vehicle? pickedVehicle,
    Vehicle? vehicleTypeSelection,
    String? vehicleId,
    String? vehicleName,
    String? plateNo,
    String? vehicleLicense,
    String? vehicleColor,
    String? vehicleYear,
    String? vehicleSelectedYear,
    int? vehicleType,
    int? selectedVehicleTypeIndex,
    Brand? selectedBrands,
    Brand? vehicleBrandSelection,
    VehicleModel? selectedModels,
    VehicleModel? vehicleModelSelection,
    String? countryId,
    List<FallBackType>? fallbackTypes,
    List<String>? fallbackTypeIds,
    List<String>? accessibilityIdList,
    bool? isLoading,
    bool? isDataLoading,
    bool? isFieldsEnabled,
    bool? isNavigateBack,
    String? snackBarMessage,
    bool? isSnackBarError,
    bool? isShowYearBottomSheet,
    bool? isShowBrandBottomSheet,
    bool? isShowModelBottomSheet,
    bool? showSelectVehicleSheet,
    String? selectVehicleMessage,
    bool? isShowQrCodeBottomSheet,
    String? qrData,
    bool? isHubDriver,
    bool? isPartnerDriver,
    bool? isOnline,
    bool? isCameraPermissionGranted,
    bool? showPermissionDialog,
    // Nullable clear helpers
    bool clearSelectedVehicle = false,
    bool clearPickedVehicle = false,
    bool clearVehicleTypeSelection = false,
    bool clearSelectedBrands = false,
    bool clearSelectedModels = false,
  }) {
    return VehicleState(
      vehicleList: vehicleList ?? this.vehicleList,
      totalVehicleList: totalVehicleList ?? this.totalVehicleList,
      vehicleTypeList: vehicleTypeList ?? this.vehicleTypeList,
      accessibilityList: accessibilityList ?? this.accessibilityList,
      brandsList: brandsList ?? this.brandsList,
      colorList: colorList ?? this.colorList,
      modelList: modelList ?? this.modelList,
      vehicleInvoiceList: vehicleInvoiceList ?? this.vehicleInvoiceList,
      selectedVehicle: clearSelectedVehicle ? null : (selectedVehicle ?? this.selectedVehicle),
      pickedVehicle: clearPickedVehicle ? null : (pickedVehicle ?? this.pickedVehicle),
      vehicleTypeSelection: clearVehicleTypeSelection ? null : (vehicleTypeSelection ?? this.vehicleTypeSelection),
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      plateNo: plateNo ?? this.plateNo,
      vehicleLicense: vehicleLicense ?? this.vehicleLicense,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleSelectedYear: vehicleSelectedYear ?? this.vehicleSelectedYear,
      vehicleType: vehicleType ?? this.vehicleType,
      selectedVehicleTypeIndex: selectedVehicleTypeIndex ?? this.selectedVehicleTypeIndex,
      selectedBrands: clearSelectedBrands ? null : (selectedBrands ?? this.selectedBrands),
      vehicleBrandSelection: vehicleBrandSelection ?? this.vehicleBrandSelection,
      selectedModels: clearSelectedModels ? null : (selectedModels ?? this.selectedModels),
      vehicleModelSelection: vehicleModelSelection ?? this.vehicleModelSelection,
      countryId: countryId ?? this.countryId,
      fallbackTypes: fallbackTypes ?? this.fallbackTypes,
      fallbackTypeIds: fallbackTypeIds ?? this.fallbackTypeIds,
      accessibilityIdList: accessibilityIdList ?? this.accessibilityIdList,
      isLoading: isLoading ?? this.isLoading,
      isDataLoading: isDataLoading ?? this.isDataLoading,
      isFieldsEnabled: isFieldsEnabled ?? this.isFieldsEnabled,
      isNavigateBack: isNavigateBack ?? this.isNavigateBack,
      snackBarMessage: snackBarMessage ?? this.snackBarMessage,
      isSnackBarError: isSnackBarError ?? this.isSnackBarError,
      isShowYearBottomSheet: isShowYearBottomSheet ?? this.isShowYearBottomSheet,
      isShowBrandBottomSheet: isShowBrandBottomSheet ?? this.isShowBrandBottomSheet,
      isShowModelBottomSheet: isShowModelBottomSheet ?? this.isShowModelBottomSheet,
      showSelectVehicleSheet: showSelectVehicleSheet ?? this.showSelectVehicleSheet,
      selectVehicleMessage: selectVehicleMessage ?? this.selectVehicleMessage,
      isShowQrCodeBottomSheet: isShowQrCodeBottomSheet ?? this.isShowQrCodeBottomSheet,
      qrData: qrData ?? this.qrData,
      isHubDriver: isHubDriver ?? this.isHubDriver,
      isPartnerDriver: isPartnerDriver ?? this.isPartnerDriver,
      isOnline: isOnline ?? this.isOnline,
      isCameraPermissionGranted: isCameraPermissionGranted ?? this.isCameraPermissionGranted,
      showPermissionDialog: showPermissionDialog ?? this.showPermissionDialog,
    );
  }
}

/// Vehicle ViewModel — ports Kotlin VehicleViewModel (1191 lines)
class VehicleViewModel extends StateNotifier<VehicleState> {
  final AppRepository _appRepository;
  final SharedPreferenceManager? _sharedPref;
  final SocketManager _socketManager;

  bool _isVehicleListCallsFirstTime = true;
  bool _isHubVehicleListCallsFirstTime = true;

  VehicleViewModel(
    this._appRepository,
    this._sharedPref,
    this._socketManager,
  ) : super(const VehicleState()) {
    _initialize();
  }

  void _initialize() {
    final entity = _sharedPref?.getEntity();

    final vehicleTypeList = [
      getString(appStr.descriptionNormal, 'description_normal'),
      getString(appStr.descriptionEv, 'description_ev'),
    ];

    state = state.copyWith(
      isOnline: false,
      vehicleTypeList: vehicleTypeList,
      vehicleType: VehicleTypeConst.normal,
      countryId: entity?.countryId,
      isHubDriver: entity?.type == EntityType.admin,
      isPartnerDriver: entity?.type == EntityType.partner,
    );

    if (state.isHubDriver) {
      getHubVehicleList();
    }
    _socketForVehicleDrop();
  }

  // ── Socket ─────────────────────────────────────────────────────

  void _socketForVehicleDrop() {
    _socketManager.listenEvent(
      SocketConstants.eventDropVehicle,
      (data) {
        debugPrint('Socket: DROP_VEHICLE received');
        state = state.copyWith(
          isLoading: false,
          clearPickedVehicle: true,
          isShowQrCodeBottomSheet: false,
          qrData: '',
        );
        _isHubVehicleListCallsFirstTime = false;
        getHubVehicleList();
      },
    );
  }

  // ── Vehicle List ─────────────────────────────────────────────

  Future<void> getVehicleList() async {
    if (_isVehicleListCallsFirstTime) {
      state = state.copyWith(isDataLoading: true);
    }
    state = state.copyWith(isLoading: true);

    final result = await _appRepository.getVehicleList();

    switch (result) {
      case Success(data: final data):
        final vehicles = data?.vehicles ?? [];

        final selectedVehicle = vehicles.length == 1
            ? vehicles.first
            : vehicles.where((v) => v.isVehicleSelected == true).firstOrNull;

        final otherVehicles =
            vehicles.where((v) => v.isVehicleSelected != true).toList();

        state = state.copyWith(
          isLoading: false,
          isDataLoading: false,
          vehicleList: otherVehicles,
          selectedVehicle: selectedVehicle,
          totalVehicleList: vehicles,
        );
        _isVehicleListCallsFirstTime = false;
        _setPriceData(data?.vehiclePrice);

      case Error(error: final error):
        state = state.copyWith(isLoading: false, isDataLoading: false);
        if (error?.message != null) _showSnackBar(error!.message!);

      case Loading():
        break;
    }
  }

  Future<void> getHubVehicleList() async {
    if (_isHubVehicleListCallsFirstTime) {
      state = state.copyWith(isDataLoading: true);
    }
    state = state.copyWith(isLoading: true, isDataLoading: true);

    final result = await _appRepository.getHubVehicleList();

    switch (result) {
      case Success(data: final data):
        final vehicles = data?.vehicles ?? [];
        final picked =
            vehicles.where((v) => v.isVehicleSelected == true).firstOrNull;

        state = state.copyWith(
          isLoading: false,
          isDataLoading: false,
          vehicleList: vehicles,
          totalVehicleList: vehicles,
          pickedVehicle: picked,
        );
        if (_isHubVehicleListCallsFirstTime) {
          state = state.copyWith(isDataLoading: false);
        }
        _setPriceData(data?.vehiclePrice);

      case Error(error: final error):
        state = state.copyWith(isLoading: false, isDataLoading: false);
        if (error?.message != null) _showSnackBar(error!.message!);

      case Loading():
        break;
    }
  }

  // ── Vehicle Details (for edit) ─────────────────────────────

  Future<void> getVehicleDetails(String vehicleId) async {
    state = state.copyWith(isLoading: true);

    final result = await _appRepository.getVehicleDetails(vehicleId: vehicleId);

    switch (result) {
      case Success(data: final data):
        final vehicle = data?.vehicle;
        final indexOfType =
            vehicle?.vehicleType == VehicleTypeConst.normal ? 0 : 1;

        state = state.copyWith(
          selectedVehicle: vehicle,
          vehicleYear: vehicle?.year,
          vehicleSelectedYear: vehicle?.year,
          vehicleColor: vehicle?.color,
          vehicleName: vehicle?.name,
          plateNo: vehicle?.plateNo,
          vehicleLicense: vehicle?.vehicleLicense,
          vehicleType: vehicle?.vehicleType,
          vehicleId: vehicle?.id,
          selectedVehicleTypeIndex: indexOfType,
          accessibilityIdList: vehicle?.accessibilityIds,
          selectedBrands: vehicle?.brandDetail,
          selectedModels: vehicle?.modelDetail,
          isLoading: false,
          isDataLoading: false,
          fallbackTypes: vehicle?.vehicleTypeDetail?.fallbackTypes,
          fallbackTypeIds: vehicle?.fallbackTypeIds,
        );

        // Mark fallback types as checked
        if (state.fallbackTypes != null && state.fallbackTypeIds != null) {
          for (final fb in state.fallbackTypes!) {
            fb.isChecked = state.fallbackTypeIds!.contains(fb.vehicleTypeId);
          }
        }

        // Disable fields if vehicle is approved
        if (vehicle?.status == VehicleStatus.approved) {
          state = state.copyWith(isFieldsEnabled: false);
        } else {
          state = state.copyWith(isFieldsEnabled: true);
        }

        getAccessibility(isForEdit: true);

      case Error():
        state = state.copyWith(isLoading: false, isDataLoading: false);

      case Loading():
        break;
    }
  }

  // ── Edit Vehicle Items (init add/edit screen) ──────────────

  void editVehicleItems(Vehicle? vehicle) {
    if (vehicle != null) {
      // Edit mode: show full-page loading while vehicle details load
      state = state.copyWith(isDataLoading: true);
      if (vehicle.id != null) getVehicleDetails(vehicle.id!);
      getAccessibility(isForEdit: true);
    } else {
      // Add mode: reset form fields and make immediately available
      state = state.copyWith(
        isDataLoading: false,
        isFieldsEnabled: true,
        clearSelectedBrands: true,
        clearSelectedModels: true,
        vehicleYear: '',
        vehicleSelectedYear: '',
        vehicleName: '',
        plateNo: '',
        vehicleLicense: '',
        vehicleColor: '',
        selectedVehicleTypeIndex: 0,
        vehicleType: VehicleTypeConst.normal,
      );
      getAccessibility(isForEdit: false);
    }
    getVehicleBrand();
    getVehicleColor();
  }

  // ── Add Vehicle ─────────────────────────────────────────────

  Future<void> addVehicle() async {
    if (!_validateFields()) return;

    final filteredIds = state.accessibilityList
            ?.where((a) => a.isChecked)
            .map((a) => a.id ?? '')
            .where((id) => id.isNotEmpty)
            .toList() ??
        [];

    final request = VehicleAddUpdateRequest(
      name: state.vehicleName,
      color: state.vehicleColor,
      plateNo: state.plateNo,
      vehicleLicense: state.vehicleLicense,
      modelId: state.selectedModels?.id ?? '',
      brandId: state.selectedBrands?.id ?? '',
      year: state.vehicleYear,
      vehicleType: state.vehicleType,
      countryId: state.countryId,
      accessibilityIds: filteredIds,
    );

    state = state.copyWith(isLoading: true);

    final result = await _appRepository.addVehicle(request: request);

    switch (result) {
      case Success(message: final message):
        // Extract vehicleId from response header
        final responseData = result.data;
        String? newVehicleId;
        if (responseData is Map<String, dynamic>) {
          newVehicleId = responseData['_id']?.toString();
        }

        state = state.copyWith(
          isLoading: false,
          vehicleId: newVehicleId,
          isFieldsEnabled: false,
          isNavigateBack: true,
        );
        if (message != null) _showSnackBar(message);

      case Error(error: final error):
        state = state.copyWith(isLoading: false);
        if (error?.message != null) _showSnackBar(error!.message!);

      case Loading():
        break;
    }
  }

  // ── Update Vehicle ──────────────────────────────────────────

  Future<void> updateVehicle() async {
    if (!_validateFields()) return;

    final filteredAccessibilityIds = state.accessibilityList
            ?.where((a) => a.isChecked)
            .map((a) => a.id ?? '')
            .where((id) => id.isNotEmpty)
            .toList() ??
        [];

    final filteredFallBackTypeIds = state.fallbackTypes
            ?.where((f) => f.isChecked)
            .map((f) => f.vehicleTypeId ?? '')
            .where((id) => id.isNotEmpty)
            .toList();

    final request = VehicleAddUpdateRequest(
      name: state.vehicleName?.trim(),
      color: state.vehicleColor?.trim(),
      plateNo: state.plateNo?.trim(),
      vehicleLicense: state.vehicleLicense?.trim(),
      year: state.vehicleYear?.trim(),
      vehicleType: state.vehicleType,
      countryId: state.countryId,
      accessibilityIds: filteredAccessibilityIds,
      fallbackTypeIds: state.fallbackTypes != null ? filteredFallBackTypeIds : null,
    );

    final vehicleId = state.vehicleId;
    if (vehicleId == null) return;

    state = state.copyWith(isLoading: true);

    final result = await _appRepository.updateVehicle(
      vehicleId: vehicleId,
      request: request,
    );

    switch (result) {
      case Success(message: final message):
        state = state.copyWith(isLoading: false, isNavigateBack: true);
        if (message != null) _showSnackBar(message);

      case Error(error: final error):
        state = state.copyWith(isLoading: false);
        if (error?.message != null) _showSnackBar(error!.message!);

      case Loading():
        break;
    }
  }

  /// Called when save/add button pressed
  void addUpdateVehicle() {
    if (state.vehicleId == null || state.vehicleId!.isEmpty) {
      addVehicle();
    } else {
      updateVehicle();
    }
  }

  // ── Select Vehicle ──────────────────────────────────────────

  Future<void> selectVehicle(String vehicleId) async {
    state = state.copyWith(isLoading: true);

    final result = await _appRepository.selectVehicle(vehicleId: vehicleId);

    switch (result) {
      case Success(message: final message):
        state = state.copyWith(
          selectedVehicle: state.vehicleTypeSelection,
        );
        if (message != null) _showSnackBar(message);
        _isVehicleListCallsFirstTime = false;
        getVehicleList();

      case Error(error: final error):
        state = state.copyWith(isLoading: false);
        if (error?.message != null) _showSnackBar(error!.message!);

      case Loading():
        break;
    }
  }

  // ── Accessibility ──────────────────────────────────────────

  Future<void> getAccessibility({bool isForEdit = false}) async {
    final result = await _appRepository.getAccessibility();

    switch (result) {
      case Success(data: final data):
        final accessibilities = data?.accessibilities;

        state = state.copyWith(
          accessibilityList: accessibilities,
        );

        if (isForEdit && accessibilities != null && state.accessibilityIdList != null) {
          for (final a in accessibilities) {
            a.isChecked = state.accessibilityIdList!.contains(a.id);
          }
        }

      case Error():
        break;

      case Loading():
        break;
    }
  }

  // ── Vehicle Brand / Model ──────────────────────────────────

  Future<void> getVehicleBrand() async {
    final result = await _appRepository.getVehicleBrand();

    switch (result) {
      case Success(data: final data):
        state = state.copyWith(brandsList: data?.brands);

      case Error():
        break;

      case Loading():
        break;
    }
  }

  Future<void> getVehicleColor() async {
    final result = await _appRepository.getVehicleColor();

    switch (result) {
      case Success(data: final data):
        state = state.copyWith(colorList: data?.colors);

      case Error():
        break;

      case Loading():
        break;
    }
  }

  Future<void> getVehicleModel() async {
    final brandId = state.selectedBrands?.id;
    if (brandId == null) return;

    state = state.copyWith(isLoading: true);

    final result = await _appRepository.getVehicleModel(brandId: brandId);

    switch (result) {
      case Success(data: final data):
        state = state.copyWith(modelList: data?.models, isLoading: false);

      case Error():
        state = state.copyWith(isLoading: false, modelList: []);

      case Loading():
        break;
    }
  }

  // ── Drop Vehicle (hub driver) ──────────────────────────────

  Future<void> dropVehicle(String vehicleId) async {
    state = state.copyWith(isLoading: true);

    final result = await _appRepository.dropVehicle(vehicleId: vehicleId);

    switch (result) {
      case Success(message: final message):
        state = state.copyWith(isLoading: false, clearPickedVehicle: true);
        _isHubVehicleListCallsFirstTime = false;
        getHubVehicleList();
        if (message != null) _showSnackBar(message);

      case Error(error: final error):
        state = state.copyWith(isLoading: false);
        if (error?.message != null) _showSnackBar(error!.message!);

      case Loading():
        break;
    }
  }

  // ── Pick Vehicle (hub driver) ──────────────────────────────

  Future<void> pickVehicle(String vehicleId, {String? driverId}) async {
    final request = PickVehicleRequest(scannedDriverId: driverId);

    state = state.copyWith(isLoading: true);

    final result = await _appRepository.pickVehicle(
      vehicleId: vehicleId,
      request: request,
    );

    switch (result) {
      case Success(message: final message):
        state = state.copyWith(isLoading: false);
        _isHubVehicleListCallsFirstTime = false;
        getHubVehicleList();
        if (message != null) _showSnackBar(message);

      case Error(error: final error):
        state = state.copyWith(isLoading: false);
        if (error?.message != null) _showSnackBar(error!.message!);

      case Loading():
        break;
    }
  }

  // ── Form Field Changes ─────────────────────────────────────

  void onVehicleNameChange(String? name) {
    state = state.copyWith(vehicleName: name);
  }

  void onVehicleLicenseChange(String? vehicleLicense) {
    state = state.copyWith(vehicleLicense: vehicleLicense);
  }

  /// Colour comes from the admin-managed list now, so this takes the picked
  /// entry rather than free text.
  void onVehicleColorSelect(VehicleColor color) {
    state = state.copyWith(vehicleColor: color.name);
  }

  void onVehicleTypeSelect(int index) {
    state = state.copyWith(
      vehicleType: index + 1,
      selectedVehicleTypeIndex: index,
    );
  }

  // ── Year Picker ─────────────────────────────────────────────

  void openYearPicker() {
    if (state.isFieldsEnabled) {
      state = state.copyWith(isShowYearBottomSheet: !state.isShowYearBottomSheet);
    }
  }

  void dismissYearPicker() {
    state = state.copyWith(isShowYearBottomSheet: false);
  }

  void onYearSelected(String year) {
    state = state.copyWith(vehicleSelectedYear: year);
  }

  void onYearSelectedDone() {
    state = state.copyWith(
      vehicleYear: state.vehicleSelectedYear,
      isShowYearBottomSheet: false,
    );
  }

  // ── Brand Picker ────────────────────────────────────────────

  void openBrandBottomSheet() {
    if (state.isFieldsEnabled) {
      state = state.copyWith(isShowBrandBottomSheet: !state.isShowBrandBottomSheet);
    }
  }

  void dismissBrandSelection() {
    state = state.copyWith(isShowBrandBottomSheet: false);
  }

  void onBrandSelectionChange(Brand brand) {
    state = state.copyWith(vehicleBrandSelection: brand);
  }

  void onBrandSelectedDone() {
    state = state.copyWith(
      selectedBrands: state.vehicleBrandSelection,
      isShowBrandBottomSheet: false,
      clearSelectedModels: true,
    );
    getVehicleModel();
  }

  // ── Model Picker ────────────────────────────────────────────

  void openModelBottomSheet() {
    if (!state.isFieldsEnabled) return;
    if (state.selectedBrands == null) {
      _showSnackBar(
        getString(appStr.errorPleaseSelectBrandFirst, 'error_please_select_brand_first'),
      );
      return;
    }
    state = state.copyWith(isShowModelBottomSheet: !state.isShowModelBottomSheet);
  }

  void dismissModelSelection() {
    state = state.copyWith(isShowModelBottomSheet: false);
  }

  void onModelSelectionChange(VehicleModel model) {
    state = state.copyWith(vehicleModelSelection: model);
  }

  void onModelSelectedDone() {
    state = state.copyWith(
      selectedModels: state.vehicleModelSelection,
      isShowModelBottomSheet: false,
    );
  }

  // ── Accessibility Toggle ────────────────────────────────────

  void onAccessibilityChange(int index, bool isEnabled) {
    if (!isEnabled) return;
    final list = state.accessibilityList?.toList();
    if (list != null && index < list.length) {
      list[index].isChecked = !list[index].isChecked;
      state = state.copyWith(accessibilityList: list);
    }
  }

  // ── Fallback Type Toggle ────────────────────────────────────

  void onFallBackTypeChange(int index, bool isEnabled) {
    if (!isEnabled) return;
    final list = state.fallbackTypes?.toList();
    if (list != null && index < list.length) {
      list[index].isChecked = !list[index].isChecked;
      state = state.copyWith(fallbackTypes: list);
    }
  }

  // ── Vehicle Selection Sheet ─────────────────────────────────

  void showChangeVehicleSheet(Vehicle vehicle) {
    state = state.copyWith(
      vehicleTypeSelection: vehicle,
      selectVehicleMessage: getString(
        appStr.descriptionVehicleChangeAlertTitle,
        'description_vehicle_change_alert_title',
      ),
      showSelectVehicleSheet: true,
    );
  }

  void dismissSelectVehicleSheet() {
    state = state.copyWith(
      clearVehicleTypeSelection: true,
      showSelectVehicleSheet: false,
    );
  }

  void confirmVehicleChange() {
    final vehicle = state.vehicleTypeSelection;
    if (vehicle?.id != null) selectVehicle(vehicle!.id!);
    state = state.copyWith(showSelectVehicleSheet: false);
  }

  // ── QR Code (hub driver) ────────────────────────────────────

  void onQrCodeClick(String vehicleId) {
    final entity = _sharedPref?.getEntity();
    final qrData = jsonEncode({
      'vehicleId': vehicleId,
      'driverId': entity?.id ?? '',
    });
    state = state.copyWith(
      isShowQrCodeBottomSheet: true,
      qrData: qrData,
    );
  }

  void dismissQrCodeBottomSheet() {
    state = state.copyWith(isShowQrCodeBottomSheet: false);
  }

  void onScanResult(String result) {
    try {
      final jsonObject = jsonDecode(result) as Map<String, dynamic>;
      final vehicleId = jsonObject['vehicleId']?.toString();
      final driverId = jsonObject['driverId']?.toString();
      if (vehicleId == null || vehicleId.isEmpty ||
          driverId == null || driverId.isEmpty) {
        return;
      }
      pickVehicle(vehicleId, driverId: driverId);
    } catch (e) {
      debugPrint('Error parsing QR: $e');
    }
  }

  // ── Camera Permission ──────────────────────────────────────

  void onCameraPermissionGranted(bool isGranted) {
    state = state.copyWith(isCameraPermissionGranted: isGranted);
  }

  void onPermissionDialogChange(bool show) {
    state = state.copyWith(showPermissionDialog: show);
  }

  // ── Price Data ──────────────────────────────────────────────

  void _setPriceData(VehiclePrice? vehiclePrice) {
    if (vehiclePrice == null) return;
    // Simplified price display — complex slot pricing can be added later
    final invoiceList = <VehicleInvoice>[];

    if (vehiclePrice.bookingFee?.value != null && vehiclePrice.bookingFee!.value! > 0) {
      invoiceList.add(VehicleInvoice(
        title: getString(appStr.descriptionInvoiceBookingFeeUnit, 'description_invoice_booking_fee_unit'),
      ));
    }

    if (vehiclePrice.distancePrice?.value != null && vehiclePrice.distancePrice!.value! > 0) {
      invoiceList.add(VehicleInvoice(
        title: getString(appStr.descriptionDistanceCharge, 'description_distance_charge'),
      ));
    }

    if (vehiclePrice.timePrice?.value != null && vehiclePrice.timePrice!.value! > 0) {
      invoiceList.add(VehicleInvoice(
        title: getString(appStr.descriptionTimeCharge, 'description_time_charge'),
      ));
    }

    state = state.copyWith(vehicleInvoiceList: invoiceList);
  }

  // ── Validation ─────────────────────────────────────────────

  bool _validateFields() {
    if (state.vehicleName?.trim().isEmpty ?? true) {
      _showSnackBar(getString(appStr.errorPleaseEnterVehicleName, 'error_please_enter_vehicle_name'));
      return false;
    }
    if (state.vehicleColor?.trim().isEmpty ?? true) {
      _showSnackBar(getString(appStr.errorPleaseEnterVehicleColor, 'error_please_enter_vehicle_color'));
      return false;
    }
    if (state.vehicleYear?.trim().isEmpty ?? true) {
      _showSnackBar(getString(appStr.errorPleaseSelectVehicleYear, 'error_please_select_vehicle_year'));
      return false;
    }
    if (state.selectedBrands == null) {
      _showSnackBar(getString(appStr.errorPleaseSelectVehicleBrand, 'error_please_select_vehicle_brand'));
      return false;
    }
    if (state.selectedModels == null) {
      _showSnackBar(getString(appStr.errorPleaseSelectVehicleModel, 'error_please_select_vehicle_model'));
      return false;
    }
    if (!Validator.validLicense(state.vehicleLicense?.trim() ?? '').status) {
      _showSnackBar(getString(
          appStr.errorPleaseEnterVehicleLicense, 'error_please_enter_vehicle_license'));
      return false;
    }

    // Check no changes on update
    if (state.selectedVehicle != null) {
      final vehicle = state.selectedVehicle!;
      final selectedAccessibilityIds = state.accessibilityList
              ?.where((a) => a.isChecked)
              .map((a) => a.id)
              .toSet() ??
          {};
      final selectedFallBackIds = state.fallbackTypes
              ?.where((f) => f.isChecked)
              .map((f) => f.vehicleTypeId)
              .toSet() ??
          {};
      final originalAccessibilityIds = vehicle.accessibilityIds?.toSet() ?? {};
      final originalFallBackIds = vehicle.fallbackTypeIds?.toSet() ?? {};

      final isUpdated = selectedAccessibilityIds != originalAccessibilityIds ||
          selectedFallBackIds != originalFallBackIds;

      // plateNo is no longer editable (the vehicle licence number replaced it
      // in the form) but is still carried through so an existing value is not
      // wiped on update — it simply never differs here.
      if (vehicle.name == state.vehicleName &&
          vehicle.plateNo == state.plateNo &&
          vehicle.vehicleLicense == state.vehicleLicense &&
          vehicle.color == state.vehicleColor &&
          vehicle.year == state.vehicleYear &&
          !isUpdated) {
        _showSnackBar(getString(appStr.errorPleaseUpdateVehicle, 'error_please_update_vehicle'));
        return false;
      }
    }
    return true;
  }

  // ── Snackbar ────────────────────────────────────────────────

  void _showSnackBar(String message, {bool isError = false}) {
    state = state.copyWith(snackBarMessage: message, isSnackBarError: isError);
  }

  void clearSnackBar() {
    state = state.copyWith(snackBarMessage: '', isSnackBarError: false);
  }

  // ── Dispose ─────────────────────────────────────────────────

  @override
  void dispose() {
    _socketManager.offEvent(SocketConstants.eventDropVehicle);
    super.dispose();
  }
}

/// Provider for VehicleViewModel
final vehicleViewModelProvider =
    StateNotifierProvider.autoDispose<VehicleViewModel, VehicleState>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).valueOrNull;
  final socketManager = ref.watch(socketManagerProvider);
  return VehicleViewModel(appRepository, sharedPref, socketManager);
});
