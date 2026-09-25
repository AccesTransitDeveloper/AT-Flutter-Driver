import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/app_repository.dart';
import '../core/utils/device_info_helper.dart';
import '../core/utils/common_utils.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../core/localization/app_strings.dart';
import '../core/theme/theme_notifier.dart';
import '../core/utils/parse_response.dart';
import '../models/requests/entity_detail_request.dart';
import '../models/responses/auth/entity_detail_response.dart';
import '../data/api/response_state.dart';
import '../data/api/server_config.dart';

enum SplashState { loading, apiSuccess, showAppUpdate, imageLoaded, error }

class SplashViewModel extends StateNotifier<SplashState> {
  final AppRepository _appRepository;
  final SharedPreferenceManager _sharedPref;
  final ThemeNotifier _themeNotifier;
  String? errorMessage;
  String? _splashImageUrl;
  bool _isLoggedIn = false;
  bool _isApiDone = false;
  bool _isSplashAnimationDone = false;
  bool _isGif = false;
  Timer? _splashTimeoutTimer;

  // ignore: prefer_final_fields
  bool _isForceUpdate = false;
  String? _storeUrl;

  String? get splashImageUrl => _splashImageUrl;
  bool get isLoggedIn => _isLoggedIn;
  bool get isForceUpdate => _isForceUpdate;
  String? get storeUrl => _storeUrl;

  SplashViewModel(this._appRepository, this._sharedPref, this._themeNotifier)
      : super(SplashState.loading) {
    // Load splash image URL from SharedPreferences on init
    final splashPath = _sharedPref.getSplashPath();
    if (splashPath != null && splashPath.isNotEmpty) {
      _splashImageUrl = ServerConfig.getFullImageUrl(splashPath);
      _isGif = splashPath.toLowerCase().endsWith('.gif');
    }

    // No image → animation wait not needed
    if (_splashImageUrl == null) {
      _isSplashAnimationDone = true;
    }
  }

  void _loadSavedThemeColors() {
    final setting = _sharedPref.getSetting();
    if (setting?.themeSetting != null) {
      _themeNotifier.updateThemeColors(
        lightColors: setting!.themeSetting!.lightMode,
        darkColors: setting.themeSetting!.darkMode,
      );
    }
  }

  Future<void> init() async {
    try {
      state = SplashState.loading;
      errorMessage = null;
      _isApiDone = false;

      // Load theme colors from SharedPreferences (deferred from constructor to avoid Riverpod error)
      _loadSavedThemeColors();

      // Start splash animation timeout for GIFs (3s fallback like Kotlin)
      if (_isGif) {
        _splashTimeoutTimer?.cancel();
        _splashTimeoutTimer =
            Timer(const Duration(seconds: 3), _onSplashAnimationDone);
      }

      // Check if user is logged in
      _isLoggedIn = _sharedPref.isLoggedIn();

      final authToken = _sharedPref.getAuthorization();
      if (authToken == null || authToken.isEmpty) {
        await _getDeviceToken();
      } else {
        await _getEntityDetail();
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      state = SplashState.error;
    }
  }

  Future<void> _getDeviceToken() async {
    try {
      final deviceTokenRequest =
          await DeviceInfoHelper.buildDeviceTokenRequest();

      final response = await _appRepository.getToken(deviceTokenRequest);

      switch (response) {
        case Success():
          // Token is automatically saved via header interceptor
          await _getEntityDetail();
        case Error():
          errorMessage =
              response.error?.message ?? 'Failed to get device token';
          state = SplashState.error;
        case Loading():
          break;
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      state = SplashState.error;
    }
  }

  Future<void> _getEntityDetail() async {
    try {
      final countryCode = DeviceInfoHelper.getDeviceCountry();
      final entityDetailRequest =
          EntityDetailRequest(countryCode: countryCode);

      final response =
          await _appRepository.getEntityDetail(entityDetailRequest);

      switch (response) {
        case Success<EntityDetailResponse>():
          final entityDetail = response.data;
          if (entityDetail != null) {
            parseEntityDetailResponse(entityDetail, _sharedPref);

            // Apply theme colors
            final setting = entityDetail.setting;
            if (setting?.themeSetting != null) {
              _themeNotifier.updateThemeColors(
                lightColors: setting!.themeSetting!.lightMode,
                darkColors: setting.themeSetting!.darkMode,
              );
            }
          }

          // Get language strings after entity detail success
          await _getLanguageStrings();
          _isApiDone = true;
          state = SplashState.apiSuccess;
          _goFurther();
        case Error():
          errorMessage =
              response.error?.message ?? 'Failed to get entity detail';
          state = SplashState.error;
        case Loading():
          break;
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      state = SplashState.error;
    }
  }

  Future<void> _getLanguageStrings() async {
    try {
      final language = _sharedPref.getLanguage();
      final response = await _appRepository.getLanguageStrings(language);

      switch (response) {
        case Success():
          if (response.data != null) {
            appStr.updateFromJson(response.data!);
          }
        case Error():
        case Loading():
          // Silently fail - will use local fallback strings
          break;
      }
    } catch (e) {
      // Silently fail - will use local fallback strings
    }
  }

  /// Called by screen when static image finishes loading
  void onImageLoaded() {
    if (_isGif || _isSplashAnimationDone) return;
    _isSplashAnimationDone = true;
    _goFurther();
  }

  /// Called by screen when image fails to load
  void onImageError() {
    _splashTimeoutTimer?.cancel();
    _isSplashAnimationDone = true;
    _goFurther();
  }

  /// Called when GIF timeout (3s) fires
  void _onSplashAnimationDone() {
    _splashTimeoutTimer?.cancel();
    _isSplashAnimationDone = true;
    _goFurther();
  }

  /// Navigate when both API and splash animation are done
  Future<void> _goFurther() async {
    if (_isApiDone && _isSplashAnimationDone && state != SplashState.error) {
      // Version check + app update logic (uses flutterAppSetting from server config)
      final setting = _sharedPref.getSetting();
      final latestVersion = setting?.flutterAppSetting?.version;
      if (latestVersion != null && latestVersion.isNotEmpty) {
        final currentVersion = await DeviceInfoHelper.getAppVersion();
        if (compareVersions(currentVersion, latestVersion) < 0) {
          _isForceUpdate = setting?.flutterAppSetting?.forceUpdate ?? false;
          _storeUrl = setting?.flutterAppSetting?.url;
          state = SplashState.showAppUpdate;
          return;
        }
      }
      state = SplashState.imageLoaded;
    }
  }

  /// Called when user taps "Skip for now" on the update bottom sheet
  void skipUpdate() {
    state = SplashState.imageLoaded;
  }

  @override
  void dispose() {
    _splashTimeoutTimer?.cancel();
    super.dispose();
  }
}

final splashViewModelProvider =
    StateNotifierProvider<SplashViewModel, SplashState>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  final themeNotifier = ref.read(themeProvider.notifier);
  final sharedPrefAsync = ref.watch(sharedPreferenceManagerProvider);

  if (sharedPrefAsync.hasValue) {
    return SplashViewModel(appRepository, sharedPrefAsync.value!, themeNotifier);
  } else if (sharedPrefAsync.hasError) {
    throw sharedPrefAsync.error!;
  } else {
    throw Exception('SharedPreferences not initialized');
  }
});
