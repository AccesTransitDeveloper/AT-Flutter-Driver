import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/localization/app_strings.dart';
import '../models/responses/auth/country_response.dart';
import '../core/managers/firebase_topic_manager.dart';
import '../core/managers/notification_manager.dart';
import '../core/utils/device_info_helper.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../data/repository/app_repository.dart';
import '../data/api/response_state.dart';
import '../models/responses/auth/entity_detail_response.dart' hide LoginBy;
import '../models/responses/auth/verify_otp_response.dart';
import '../models/requests/set_language_request.dart';
import '../models/requests/emergency_contact_request.dart';
import '../models/requests/add_address_request.dart';
import '../models/requests/select_address_request.dart';
import '../models/requests/generate_otp_request.dart';
import '../models/requests/verify_otp_request.dart';
import '../models/destination_address.dart';
import '../core/theme/theme_notifier.dart';

/// Language item for UI list
class LanguageItem {
  final String? id;
  final String code;
  final String name;
  final bool isSelected;

  const LanguageItem({
    this.id,
    required this.code,
    required this.name,
    this.isSelected = false,
  });

  LanguageItem copyWith({bool? isSelected}) {
    return LanguageItem(
      id: id,
      code: code,
      name: name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Emergency contact item for UI
class EmergencyContactItem {
  final String? id;
  final String name;
  final String phone;
  final String countryPhoneCode;
  final String? image;

  const EmergencyContactItem({
    this.id,
    required this.name,
    required this.phone,
    this.countryPhoneCode = '',
    this.image,
  });

  factory EmergencyContactItem.fromApiModel(dynamic contact) {
    return EmergencyContactItem(
      id: contact.id,
      name: contact.name ?? '',
      phone: contact.phone ?? '',
      countryPhoneCode: contact.countryPhoneCode ?? '',
      image: contact.image,
    );
  }
}

/// Saved address item for UI
class SavedAddressItem {
  final String? id;
  final String title;
  final String address;
  final bool isSelected;

  const SavedAddressItem({
    this.id,
    required this.title,
    required this.address,
    this.isSelected = false,
  });
}

/// Navigation map type constants
class NavigationMapType {
  static const String inAppGoogle = 'IN_APP_GOOGLE';
  static const String google = 'GOOGLE';
  static const String waze = 'WAZE';
}

/// Delete account verification step
enum DeleteStep { confirm, authOptions, password, otp }

/// Authentication option for delete account verification
class AuthenticationOption {
  final String name;
  final bool isSelected;
  final bool isPasswordOption;

  const AuthenticationOption({
    required this.name,
    this.isSelected = false,
    this.isPasswordOption = false,
  });

  AuthenticationOption copyWith({bool? isSelected}) {
    return AuthenticationOption(
      name: name,
      isSelected: isSelected ?? this.isSelected,
      isPasswordOption: isPasswordOption,
    );
  }
}

/// Settings screen state
class SettingsState {
  final Entity? entity;
  final String appVersion;

  // Theme
  final AppThemeMode selectedTheme;

  // App Language
  final String selectedLanguage;
  final List<LanguageItem> languageList;
  final bool isLanguageLoading;

  // Speaking Language
  final String selectedSpeakingLanguage;
  final List<LanguageItem> speakingLanguageList;

  // Heat Map
  final bool isHeatMap;

  // Navigation Map
  final String navigationMap;

  // Emergency Contacts
  final List<EmergencyContactItem> emergencyContacts;
  final bool showAddContactBottomSheet;
  final bool isContactLoading;
  final String contactName;
  final String contactPhone;
  final String contactCountryCode;
  final String? editingContactId;
  final List<Country> countries;
  final List<Country> multiplePhoneCodeCountryList;
  final bool showContactCountryPhoneCodeBottomSheet;

  // Going Home Address
  final List<SavedAddressItem> addressList;
  final bool isGoingToAddress;
  final bool isAddressLoading;

  // Delete Account
  final bool isDeleteLoading;
  final DeleteStep deleteStep;
  final List<AuthenticationOption> authenticationOptions;
  final String deletePassword;
  final String deleteOtp;
  final String otpSendTo;
  final int? sendTo;
  final GenerateOtpRequest? resendOtpRequest;
  final int resendOtpTimer;

  // Logout
  final bool isLogoutLoading;

  // Navigation
  final bool navigateToLogin;

  // Feedback
  final String? snackBarMessage;

  const SettingsState({
    this.entity,
    this.appVersion = '',
    this.selectedTheme = AppThemeMode.system,
    this.selectedLanguage = 'English',
    this.languageList = const [],
    this.isLanguageLoading = false,
    this.selectedSpeakingLanguage = '',
    this.speakingLanguageList = const [],
    this.isHeatMap = false,
    this.navigationMap = '',
    this.emergencyContacts = const [],
    this.showAddContactBottomSheet = false,
    this.isContactLoading = false,
    this.contactName = '',
    this.contactPhone = '',
    this.contactCountryCode = '',
    this.editingContactId,
    this.countries = const [],
    this.multiplePhoneCodeCountryList = const [],
    this.showContactCountryPhoneCodeBottomSheet = false,
    this.addressList = const [],
    this.isGoingToAddress = false,
    this.isAddressLoading = false,
    this.isDeleteLoading = false,
    this.deleteStep = DeleteStep.confirm,
    this.authenticationOptions = const [],
    this.deletePassword = '',
    this.deleteOtp = '',
    this.otpSendTo = '',
    this.sendTo,
    this.resendOtpRequest,
    this.resendOtpTimer = 0,
    this.isLogoutLoading = false,
    this.navigateToLogin = false,
    this.snackBarMessage,
  });

  SettingsState copyWith({
    Entity? entity,
    String? appVersion,
    AppThemeMode? selectedTheme,
    String? selectedLanguage,
    List<LanguageItem>? languageList,
    bool? isLanguageLoading,
    String? selectedSpeakingLanguage,
    List<LanguageItem>? speakingLanguageList,
    bool? isHeatMap,
    String? navigationMap,
    List<EmergencyContactItem>? emergencyContacts,
    bool? showAddContactBottomSheet,
    bool? isContactLoading,
    String? contactName,
    String? contactPhone,
    String? contactCountryCode,
    String? editingContactId,
    List<Country>? countries,
    List<Country>? multiplePhoneCodeCountryList,
    bool? showContactCountryPhoneCodeBottomSheet,
    List<SavedAddressItem>? addressList,
    bool? isGoingToAddress,
    bool? isAddressLoading,
    bool? isDeleteLoading,
    DeleteStep? deleteStep,
    List<AuthenticationOption>? authenticationOptions,
    String? deletePassword,
    String? deleteOtp,
    String? otpSendTo,
    int? sendTo,
    GenerateOtpRequest? resendOtpRequest,
    int? resendOtpTimer,
    bool clearDeleteState = false,
    bool? isLogoutLoading,
    bool? navigateToLogin,
    String? snackBarMessage,
    bool clearSnackBar = false,
    bool clearEditingContact = false,
  }) {
    return SettingsState(
      entity: entity ?? this.entity,
      appVersion: appVersion ?? this.appVersion,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      languageList: languageList ?? this.languageList,
      isLanguageLoading: isLanguageLoading ?? this.isLanguageLoading,
      selectedSpeakingLanguage: selectedSpeakingLanguage ?? this.selectedSpeakingLanguage,
      speakingLanguageList: speakingLanguageList ?? this.speakingLanguageList,
      isHeatMap: isHeatMap ?? this.isHeatMap,
      navigationMap: navigationMap ?? this.navigationMap,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      showAddContactBottomSheet: showAddContactBottomSheet ?? this.showAddContactBottomSheet,
      isContactLoading: isContactLoading ?? this.isContactLoading,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactCountryCode: contactCountryCode ?? this.contactCountryCode,
      editingContactId: clearEditingContact ? null : (editingContactId ?? this.editingContactId),
      countries: countries ?? this.countries,
      multiplePhoneCodeCountryList: multiplePhoneCodeCountryList ?? this.multiplePhoneCodeCountryList,
      showContactCountryPhoneCodeBottomSheet: showContactCountryPhoneCodeBottomSheet ?? this.showContactCountryPhoneCodeBottomSheet,
      addressList: addressList ?? this.addressList,
      isGoingToAddress: isGoingToAddress ?? this.isGoingToAddress,
      isAddressLoading: isAddressLoading ?? this.isAddressLoading,
      isDeleteLoading: isDeleteLoading ?? this.isDeleteLoading,
      deleteStep: clearDeleteState ? DeleteStep.confirm : (deleteStep ?? this.deleteStep),
      authenticationOptions: clearDeleteState ? const [] : (authenticationOptions ?? this.authenticationOptions),
      deletePassword: clearDeleteState ? '' : (deletePassword ?? this.deletePassword),
      deleteOtp: clearDeleteState ? '' : (deleteOtp ?? this.deleteOtp),
      otpSendTo: clearDeleteState ? '' : (otpSendTo ?? this.otpSendTo),
      sendTo: clearDeleteState ? null : (sendTo ?? this.sendTo),
      resendOtpRequest: clearDeleteState ? null : (resendOtpRequest ?? this.resendOtpRequest),
      resendOtpTimer: clearDeleteState ? 0 : (resendOtpTimer ?? this.resendOtpTimer),
      isLogoutLoading: isLogoutLoading ?? this.isLogoutLoading,
      navigateToLogin: navigateToLogin ?? this.navigateToLogin,
      snackBarMessage: clearSnackBar ? null : (snackBarMessage ?? this.snackBarMessage),
    );
  }

  String get themeDisplayName {
    switch (selectedTheme) {
      case AppThemeMode.light:
        return getString(appStr.descriptionLightMode, 'description_light_mode');
      case AppThemeMode.dark:
        return getString(appStr.descriptionDarkMode, 'description_dark_mode');
      case AppThemeMode.system:
        return getString(appStr.descriptionSystemDefault, 'description_system_default');
    }
  }
}

/// Settings ViewModel
class SettingsViewModel extends StateNotifier<SettingsState> {
  final AppRepository _appRepository;
  final SharedPreferenceManager _sharedPref;

  SettingsViewModel(this._appRepository, this._sharedPref)
      : super(const SettingsState()) {
    _loadInitialData();
  }

  void _loadInitialData() {
    final entity = _sharedPref.getEntity();
    state = state.copyWith(
      entity: entity,
      selectedTheme: _parseThemeMode(_sharedPref.getTheme()),
      isHeatMap: _sharedPref.getIsHeatMap(),
      navigationMap: _sharedPref.getNavigationMap(),
      isGoingToAddress: _sharedPref.getGoingToAddress(),
      contactCountryCode: entity?.countryPhoneCode ?? '',
    );
    _loadAppVersion();
    _loadLanguages();
    _loadEmergencyContacts();
    _loadAddresses();
  }

  Future<void> _loadAppVersion() async {
    final version = await DeviceInfoHelper.getAppVersion();
    state = state.copyWith(appVersion: version);
  }

  AppThemeMode _parseThemeMode(String theme) {
    switch (theme) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  // ============ THEME ============

  Future<void> setTheme(AppThemeMode mode) async {
    final s = mode == AppThemeMode.light ? 'light' : mode == AppThemeMode.dark ? 'dark' : 'system';
    await _sharedPref.setTheme(s);
    state = state.copyWith(selectedTheme: mode);
  }

  // ============ APP LANGUAGE ============

  Future<void> _loadLanguages() async {
    final response = await _appRepository.getLanguages();
    switch (response) {
      case Success():
        final languages = response.data ?? [];
        final currentLang = _sharedPref.getLanguage();


        final appItems = languages.map((lang) => LanguageItem(
              id: lang.id,
              code: lang.code ?? 'en',
              name: lang.name ?? 'Unknown',
              isSelected: lang.code == currentLang,
            )).toList();

        if (appItems.isNotEmpty && !appItems.any((l) => l.isSelected)) {
          appItems[0] = appItems[0].copyWith(isSelected: true);
        }

        final entitySpeakingCodes = _sharedPref.getEntity()?.speakingLanguages ?? [];

        final speakingItems = languages.map((lang) => LanguageItem(
              id: lang.id,
              code: lang.code ?? 'en',
              name: lang.name ?? 'Unknown',
              isSelected: entitySpeakingCodes.contains(lang.code),
            )).toList();

        final selectedApp = appItems.firstWhere((l) => l.isSelected,
            orElse: () => appItems.isNotEmpty
                ? appItems.first
                : const LanguageItem(code: 'en', name: 'English'));

        final selectedSpeakingNames = speakingItems
            .where((l) => l.isSelected)
            .map((l) => l.name)
            .join(', ');

        state = state.copyWith(
          languageList: appItems,
          selectedLanguage: selectedApp.name,
          speakingLanguageList: speakingItems,
          selectedSpeakingLanguage: selectedSpeakingNames,
        );

      case Error():
        state = state.copyWith(
          languageList: [const LanguageItem(code: 'en', name: 'English', isSelected: true)],
          selectedLanguage: 'English',
          speakingLanguageList: [const LanguageItem(code: 'en', name: 'English')],
        );

      case Loading():
        break;
    }
  }

  void selectLanguage(int index) {
    final updated = state.languageList
        .asMap()
        .entries
        .map((e) => e.value.copyWith(isSelected: e.key == index))
        .toList();
    state = state.copyWith(languageList: updated);
  }

  Future<void> applyLanguage() async {
    if (state.languageList.isEmpty) return;
    final selected = state.languageList.firstWhere((l) => l.isSelected,
        orElse: () => state.languageList.first);
    if (selected.code == _sharedPref.getLanguage()) return;

    state = state.copyWith(isLanguageLoading: true);
    final response = await _appRepository.setLanguage(SetLanguageRequest(language: selected.code));
    switch (response) {
      case Success():
        await _sharedPref.setLanguage(selected.code);
        await _getLanguageStrings(selected.code);
        state = state.copyWith(isLanguageLoading: false, selectedLanguage: selected.name);
        _showSnackBar('Language changed to ${selected.name}');

      case Error():
        state = state.copyWith(isLanguageLoading: false);
        _showSnackBar(response.message ?? '');

      case Loading():
        break;
    }
  }

  Future<void> _getLanguageStrings(String code) async {
    final response = await _appRepository.getLanguageStrings(code);
    if (response case Success()) {
      if (response.data != null) appStr.updateFromJson(response.data!);
    }
  }

  // ============ SPEAKING LANGUAGE ============

  void selectSpeakingLanguage(int index) {
    final updated = state.speakingLanguageList
        .asMap()
        .entries
        .map((e) => e.key == index
            ? e.value.copyWith(isSelected: !e.value.isSelected)
            : e.value)
        .toList();
    state = state.copyWith(speakingLanguageList: updated);
  }

  Future<void> applySpeakingLanguage() async {
    if (state.speakingLanguageList.isEmpty) return;
    final selectedCodes = state.speakingLanguageList
        .where((l) => l.isSelected)
        .map((l) => l.code)
        .toList();
    final selectedNames = state.speakingLanguageList
        .where((l) => l.isSelected)
        .map((l) => l.name)
        .join(', ');

    final currentLang = _sharedPref.getLanguage();
    state = state.copyWith(isLanguageLoading: true);
    final response = await _appRepository.setLanguage(
      SetLanguageRequest(language: currentLang, speakingLanguages: selectedCodes),
    );
    state = state.copyWith(isLanguageLoading: false);
    switch (response) {
      case Success():
        state = state.copyWith(selectedSpeakingLanguage: selectedNames);
      case Error():
        _showSnackBar(response.message ?? '');
      case Loading():
        break;
    }
  }

  // ============ HEAT MAP ============

  Future<void> toggleHeatMap() async {
    final newValue = !state.isHeatMap;
    await _sharedPref.putIsHeatMap(newValue);
    state = state.copyWith(isHeatMap: newValue);
  }

  // ============ NAVIGATION MAP ============

  Future<void> setNavigationMap(String enumName) async {
    await _sharedPref.putNavigationMap(enumName);
    state = state.copyWith(navigationMap: enumName);
  }

  // ============ EMERGENCY CONTACTS ============

  Future<void> _loadEmergencyContacts() async {
    final response = await _appRepository.getEmergencyContacts();
    switch (response) {
      case Success():
        final contacts = response.data?.emergencyContacts ?? [];
        state = state.copyWith(
          emergencyContacts: contacts
              .map((c) => EmergencyContactItem.fromApiModel(c))
              .toList(),
        );

      case Error():
        state = state.copyWith(emergencyContacts: []);

      case Loading():
        break;
    }
  }

  void showAddContactSheet({EmergencyContactItem? contact}) {
    state = state.copyWith(
      showAddContactBottomSheet: true,
      contactName: contact?.name ?? '',
      contactPhone: contact?.phone ?? '',
      contactCountryCode: contact?.countryPhoneCode ?? state.entity?.countryPhoneCode ?? '',
      editingContactId: contact?.id,
    );
    getCountries();
  }

  Future<void> getCountries() async {
    if (state.countries.isNotEmpty) return;
    final response = await _appRepository.getCountries();
    if (response case Success<CountryResponse>(data: final d)) {
      state = state.copyWith(countries: d?.countries ?? []);
    }
  }

  Future<void> toggleContactCountryPhoneCodeBottomSheet() async {
    await getCountries();

    final entity = _sharedPref.getEntity();

    Country? country;
    if (entity?.countryCode != null) {
      country = state.countries.where((c) =>
        c.code == entity!.countryCode || c.alpha2 == entity.countryCode
      ).firstOrNull;
    }
    if (country == null && entity?.countryPhoneCode != null) {
      country = state.countries.where((c) =>
        c.phoneCodes?.contains(entity!.countryPhoneCode) == true
      ).firstOrNull;
    }

    final phoneCodes = country?.phoneCodes;
    if (country == null || phoneCodes == null || phoneCodes.isEmpty) return;
    final c = country;

    final list = phoneCodes
        .map((code) => Country(
              id: c.id,
              name: c.name,
              phoneCodes: [code],
              phoneCode: code,
              currencyCode: c.currencyCode,
              currencySign: c.currencySign,
              alpha2: c.alpha2,
              code: c.code,
              code2: c.code2,
              timezones: c.timezones,
              isBusiness: c.isBusiness,
            ))
        .toList();

    state = state.copyWith(
      multiplePhoneCodeCountryList: list,
      showContactCountryPhoneCodeBottomSheet: true,
    );
  }

  void dismissContactCountryPhoneCodeBottomSheet() {
    state = state.copyWith(showContactCountryPhoneCodeBottomSheet: false);
  }

  void updateContactCountryPhoneCode(Country country) {
    state = state.copyWith(
      contactCountryCode: country.phoneCodes?.firstOrNull ?? '',
    );
  }

  void hideAddContactSheet() {
    state = state.copyWith(
      showAddContactBottomSheet: false,
      contactName: '',
      contactPhone: '',
      clearEditingContact: true,
    );
  }

  void updateContactName(String name) => state = state.copyWith(contactName: name);
  void updateContactPhone(String phone) => state = state.copyWith(contactPhone: phone);
  void updateContactCountryCode(String code) => state = state.copyWith(contactCountryCode: code);

  bool _validateEmergencyContact() {
    // 1. Name must not be empty
    if (state.contactName.trim().isEmpty) {
      _showSnackBar(getString(appStr.errorPleaseEnterContactName, 'error_please_enter_contact_name'));
      return false;
    }

    // 2. Country phone code must be selected
    if (state.contactCountryCode.trim().isEmpty) {
      _showSnackBar(getString(null, 'error_please_select_country_phone_code'));
      return false;
    }

    // 3. Phone number must not be empty
    if (state.contactPhone.trim().isEmpty) {
      _showSnackBar(getString(appStr.errorPleaseEnterPhoneNumber, 'error_please_enter_phone_number'));
      return false;
    }

    // 4. Phone format: 6–12 digits, all numeric
    final phone = state.contactPhone.trim();
    final isValidFormat = phone.length >= 6 &&
        phone.length <= 12 &&
        phone.codeUnits.every((c) => c >= 48 && c <= 57);
    if (!isValidFormat) {
      _showSnackBar(getString(appStr.errorPleaseEnterValidPhoneNumber, 'error_please_enter_valid_phone_number'));
      return false;
    }

    // 5. Phone must not be the user's own phone number
    final ownPhone = state.entity?.phone ?? '';
    if (ownPhone.isNotEmpty && phone == ownPhone) {
      _showSnackBar(getString(appStr.errorPleaseEnterValidPhoneNumber, 'error_please_enter_valid_phone_number'));
      return false;
    }

    return true;
  }

  Future<void> saveEmergencyContact() async {
    if (!_validateEmergencyContact()) return;

    state = state.copyWith(isContactLoading: true);
    final request = EmergencyContactRequest(
      name: state.contactName,
      phone: state.contactPhone,
      countryPhoneCode: state.contactCountryCode.isNotEmpty
          ? state.contactCountryCode
          : state.entity?.countryPhoneCode,
    );

    final isEditing = state.editingContactId != null;
    final response = isEditing
        ? await _appRepository.updateEmergencyContact(state.editingContactId!, request)
        : await _appRepository.addEmergencyContact(request);

    switch (response) {
      case Success():
        state = state.copyWith(
          isContactLoading: false,
          showAddContactBottomSheet: false,
          contactName: '',
          contactPhone: '',
          clearEditingContact: true,
        );
        _showSnackBar(isEditing
            ? getString(appStr.descriptionContactUpdated, 'description_contact_updated')
            : getString(appStr.descriptionContactAdded, 'description_contact_added'));
        await _loadEmergencyContacts();

      case Error():
        state = state.copyWith(isContactLoading: false);
        _showSnackBar(response.message ?? '');

      case Loading():
        break;
    }
  }

  Future<void> deleteEmergencyContact(int index) async {
    if (index < 0 || index >= state.emergencyContacts.length) return;
    final contact = state.emergencyContacts[index];
    if (contact.id == null) return;

    state = state.copyWith(isContactLoading: true);
    final response = await _appRepository.deleteEmergencyContact(contact.id!);
    switch (response) {
      case Success():
        state = state.copyWith(isContactLoading: false);
        _showSnackBar(getString(appStr.descriptionContactRemoved, 'description_contact_removed'));
        await _loadEmergencyContacts();

      case Error():
        state = state.copyWith(isContactLoading: false);
        _showSnackBar(response.message ?? '');

      case Loading():
        break;
    }
  }

  // ============ GOING HOME ADDRESS ============

  Future<void> _loadAddresses() async {
    final response = await _appRepository.getAddresses();
    switch (response) {
      case Success():
        final addresses = response.data?.addresses ?? [];
        final items = addresses
            .map((a) => SavedAddressItem(
                  id: a.id,
                  title: a.title ?? a.address ?? '',
                  address: a.address ?? '',
                  isSelected: a.isAddressSelected ?? false,
                ))
            .toList();
        // Derive going-to-address state from actual API data
        final hasSelected = items.any((a) => a.isSelected);
        state = state.copyWith(
          addressList: items,
          isGoingToAddress: hasSelected,
        );

      case Error():
        state = state.copyWith(addressList: []);

      case Loading():
        break;
    }
  }

  Future<void> toggleGoingToAddress(bool value) async {
    if (state.addressList.isEmpty) return;

    state = state.copyWith(isAddressLoading: true);

    final String? targetId;
    if (value) {
      // Enable — select the first address
      targetId = state.addressList.first.id;
    } else {
      // Disable — deselect the currently selected address
      final selected = state.addressList.firstWhere(
        (a) => a.isSelected,
        orElse: () => state.addressList.first,
      );
      targetId = selected.id;
    }

    if (targetId == null) {
      state = state.copyWith(isAddressLoading: false);
      return;
    }

    final response = await _appRepository.selectAddress(
      targetId,
      SelectAddressRequest(isAddressSelected: value),
    );

    switch (response) {
      case Success():
        state = state.copyWith(isAddressLoading: false, isGoingToAddress: value);
        await _loadAddresses();

      case Error():
        state = state.copyWith(isAddressLoading: false);
        _showSnackBar(response.message ?? '');

      case Loading():
        break;
    }
  }

  Future<void> addAddress(DestinationAddress destination) async {
    state = state.copyWith(isAddressLoading: true);
    final request = AddAddressRequest(
      addressType: 1, // HOME
      title: destination.title,
      address: destination.address,
      latitude: destination.latitude,
      longitude: destination.longitude,
      city: destination.city,
      countryCode: destination.countryCode,
      country: destination.country,
      postalCode: destination.postalCode,
      placeId: destination.placeId,
    );
    final response = await _appRepository.addAddress(request);
    switch (response) {
      case Success():
        state = state.copyWith(isAddressLoading: false);
        await _loadAddresses();

      case Error():
        state = state.copyWith(isAddressLoading: false);
        _showSnackBar(response.message ?? '');

      case Loading():
        break;
    }
  }

  Future<void> deleteAddress(SavedAddressItem address) async {
    if (address.id == null) return;
    state = state.copyWith(isAddressLoading: true);
    final response = await _appRepository.deleteAddress(address.id!);
    switch (response) {
      case Success():
        state = state.copyWith(isAddressLoading: false);
        await _loadAddresses();

      case Error():
        state = state.copyWith(isAddressLoading: false);
        _showSnackBar(response.message ?? '');

      case Loading():
        break;
    }
  }

  // ============ DELETE ACCOUNT ============

  Timer? _resendOtpTimer;

  /// Called when user confirms "Yes Delete" in the initial confirmation sheet.
  /// Checks login type to decide flow: social → direct delete, else → show auth options.
  void confirmDeleteAccount() {
    final entity = state.entity;
    final loginBy = entity?.loginBy;

    // Social login users → direct delete with empty body
    if (loginBy == LoginBy.google ||
        loginBy == LoginBy.apple) {
      _deleteAccount({});
      return;
    }

    // Build authentication options from setting.entitySetting.deleteBy
    final setting = _sharedPref.getSetting();
    final deleteBy = setting?.entitySetting?.deleteBy ?? [];
    final options = <AuthenticationOption>[];

    if (deleteBy.contains(LoginBy.password)) {
      options.add(AuthenticationOption(
        name: getString(appStr.descriptionPassword, 'description_password'),
        isPasswordOption: true,
      ));
    }

    if (deleteBy.contains(LoginBy.otp)) {
      if (entity?.email != null && entity!.email!.isNotEmpty) {
        options.add(AuthenticationOption(name: entity.email!));
      }
      if (entity?.phone != null && entity!.phone!.isNotEmpty) {
        final phoneDisplay = '${entity.countryPhoneCode ?? ''} ${entity.phone!}';
        options.add(AuthenticationOption(name: phoneDisplay.trim()));
      }
    }

    if (options.isEmpty) {
      // No verification methods configured, direct delete
      _deleteAccount({});
      return;
    }

    state = state.copyWith(
      deleteStep: DeleteStep.authOptions,
      authenticationOptions: options,
    );
  }

  void selectAuthenticationOption(int index) {
    final updated = state.authenticationOptions
        .asMap()
        .entries
        .map((e) => e.value.copyWith(isSelected: e.key == index))
        .toList();
    state = state.copyWith(authenticationOptions: updated);
  }

  /// Called when user confirms the selected authentication option.
  void confirmAuthenticationOption() {
    final selected = state.authenticationOptions
        .where((o) => o.isSelected)
        .firstOrNull;
    if (selected == null) {
      _showSnackBar(getString(appStr.errorPleaseSelectOption, 'error_please_select_option'));
      return;
    }

    if (selected.isPasswordOption) {
      state = state.copyWith(
        deleteStep: DeleteStep.password,
        deletePassword: '',
      );
    } else {
      // OTP flow: determine if email or phone
      final entity = state.entity;
      final isEmailVerify = selected.name == entity?.email;
      final phoneDisplay = '${entity?.countryPhoneCode ?? ''} ${entity?.phone ?? ''}'.trim();
      final isPhoneVerify = selected.name == phoneDisplay;

      GenerateOtpRequest request;
      String maskedSendTo;

      if (isEmailVerify) {
        request = GenerateOtpRequest(
          sendTo: OtpSendMode.email,
          email: entity?.email,
        );
        maskedSendTo = _maskEmail(entity?.email ?? '');
      } else if (isPhoneVerify) {
        request = GenerateOtpRequest(
          sendTo: OtpSendMode.sms,
          phone: entity?.phone,
          countryPhoneCode: entity?.countryPhoneCode,
        );
        maskedSendTo = _maskPhone(entity?.phone ?? '');
      } else {
        return;
      }

      state = state.copyWith(
        deleteStep: DeleteStep.otp,
        otpSendTo: maskedSendTo,
        deleteOtp: '',
      );
      _generateOtp(request);
    }
  }

  void updateDeletePassword(String password) {
    state = state.copyWith(deletePassword: password);
  }

  void updateDeleteOtp(String otp) {
    state = state.copyWith(deleteOtp: otp);
  }

  /// Verify password and delete account
  void verifyPasswordAndDelete() {
    if (state.deletePassword.isEmpty) {
      _showSnackBar(getString(appStr.errorPleaseEnterPassword, 'error_please_enter_password'));
      return;
    }
    _deleteAccount({'password': state.deletePassword});
  }

  /// Verify OTP, get verification token, then delete account
  Future<void> verifyOtpAndDelete() async {
    if (state.deleteOtp.isEmpty) {
      _showSnackBar(getString(appStr.errorPleaseEnterOtp, 'error_please_enter_otp'));
      return;
    }

    state = state.copyWith(isDeleteLoading: true);

    final entity = state.entity;
    final request = VerifyOtpRequest(
      sendTo: state.sendTo,
      countryPhoneCode: entity?.countryPhoneCode,
      phone: entity?.phone,
      email: entity?.email,
      enteredOTP: state.deleteOtp,
    );

    final response = await _appRepository.verifyOtp(request);
    switch (response) {
      case Success<VerifyOtpResponse>():
        final token = response.data?.verificationToken ?? '';
        state = state.copyWith(isDeleteLoading: false);
        _deleteAccount({'verificationToken': token});

      case Error<VerifyOtpResponse>():
        state = state.copyWith(isDeleteLoading: false);
        _showSnackBar(response.message ?? '');

      case Loading():
        break;
    }
  }

  /// Resend OTP for delete verification
  void resendDeleteOtp() {
    final request = state.resendOtpRequest;
    if (request == null) return;
    state = state.copyWith(deleteOtp: '');
    _generateOtp(request);
  }

  /// Reset delete flow state
  void resetDeleteState() {
    _resendOtpTimer?.cancel();
    state = state.copyWith(clearDeleteState: true);
  }

  Future<void> _generateOtp(GenerateOtpRequest request) async {
    state = state.copyWith(isDeleteLoading: true);

    final response = await _appRepository.generateOtp(request);
    switch (response) {
      case Success():
        _startResendTimer();
        state = state.copyWith(
          isDeleteLoading: false,
          resendOtpRequest: request,
          sendTo: request.sendTo,
        );

      case Error():
        state = state.copyWith(isDeleteLoading: false, deleteStep: DeleteStep.authOptions);
        _showSnackBar(response.message ?? '');

      case Loading():
        break;
    }
  }

  Future<void> _deleteAccount(Map<String, String> body) async {
    state = state.copyWith(isDeleteLoading: true);
    final response = await _appRepository.deleteAccount(body: body);
    switch (response) {
      case Success():
        _resendOtpTimer?.cancel();
        if (response.message != null && response.message!.isNotEmpty) {
          _showSnackBar(response.message!);
        }
        await NotificationManager.instance.deleteToken();
        await NotificationManager.instance.cancelAllNotifications();
        await FirebaseTopicManager.instance.unsubscribeFromTopics();
        await _sharedPref.signOut();
        state = state.copyWith(
          isDeleteLoading: false,
          clearDeleteState: true,
          navigateToLogin: true,
        );

      case Error():
        state = state.copyWith(isDeleteLoading: false);
        _showSnackBar(response.message ?? '');

      case Loading():
        break;
    }
  }

  void _startResendTimer() {
    _resendOtpTimer?.cancel();
    final setting = _sharedPref.getSetting();
    final interval = setting?.entitySetting?.secOtpResendInterval ?? 30;
    state = state.copyWith(resendOtpTimer: interval);
    _resendOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.resendOtpTimer - 1;
      if (remaining <= 0) {
        timer.cancel();
        state = state.copyWith(resendOtpTimer: 0);
      } else {
        state = state.copyWith(resendOtpTimer: remaining);
      }
    });
  }

  String _maskEmail(String email) {
    if (email.length < 4) return email;
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return email;
    return '${name.substring(0, 2)}${'*' * (name.length - 2)}@$domain';
  }

  String _maskPhone(String phone) {
    if (phone.length <= 4) return phone;
    return '${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
  }

  // ============ LOGOUT ============

  Future<void> logout() async {
    state = state.copyWith(isLogoutLoading: true);
    final response = await _appRepository.signOut();
    switch (response) {
      case Success():
        await NotificationManager.instance.deleteToken();
        await NotificationManager.instance.cancelAllNotifications();
        await FirebaseTopicManager.instance.unsubscribeFromTopics();
        await _sharedPref.signOut();
        state = state.copyWith(isLogoutLoading: false, navigateToLogin: true);

      case Error():
        state = state.copyWith(isLogoutLoading: false);
        _showSnackBar(response.message ?? '');

      case Loading():
        break;
    }
  }

  // ============ HELPERS ============

  void _showSnackBar(String message) => state = state.copyWith(snackBarMessage: message);
  void clearSnackBar() => state = state.copyWith(clearSnackBar: true);
  void clearNavigationFlag() => state = state.copyWith(navigateToLogin: false);
  void refreshUserData() => state = state.copyWith(entity: _sharedPref.getEntity());
}

final settingsViewModelProvider =
    StateNotifierProvider.autoDispose<SettingsViewModel, SettingsState>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => throw Exception('SharedPreferences not initialized'),
      );
  return SettingsViewModel(appRepository, sharedPref);
});
