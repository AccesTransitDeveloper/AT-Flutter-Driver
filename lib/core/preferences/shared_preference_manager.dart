import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/shared_preferences_constants.dart';
import '../../data/api/server_environment.dart';
import '../../models/theme_colors.dart';
import '../../models/responses/auth/entity_detail_response.dart';

class SharedPreferenceManager {
  final SharedPreferences _prefs;

  SharedPreferenceManager(this._prefs);

  static Future<SharedPreferenceManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferenceManager(prefs);
  }

  // Server Environment
  String getCurrentServer() {
    return _prefs.getString(SharedPreferencesConstants.serverEnvironment) ??
        ServerEnvironment.production.value;
  }

  Future<bool> setCurrentServer(String serverEnvironment) {
    return _prefs.setString(
      SharedPreferencesConstants.serverEnvironment,
      serverEnvironment,
    );
  }

  ServerEnvironment getServerEnvironment() {
    return ServerEnvironment.fromValue(getCurrentServer());
  }

  Future<bool> setServerEnvironment(ServerEnvironment environment) {
    return setCurrentServer(environment.value);
  }

  // Local Base URL (IP address for local development)
  String getLocalBaseUrl() {
    return _prefs.getString(SharedPreferencesConstants.localBaseUrl) ??
        '192.168.1.1';
  }

  Future<bool> setLocalBaseUrl(String baseUrl) {
    return _prefs.setString(
      SharedPreferencesConstants.localBaseUrl,
      baseUrl,
    );
  }

  // Authorization Token
  String? getAuthorization() {
    return _prefs.getString(SharedPreferencesConstants.authorization);
  }

  Future<bool> setAuthorization(String token) {
    return _prefs.setString(SharedPreferencesConstants.authorization, token);
  }

  Future<bool> removeAuthorization() {
    return _prefs.remove(SharedPreferencesConstants.authorization);
  }

  // Is Logged In
  bool isLoggedIn() {
    return _prefs.getBool(SharedPreferencesConstants.isLoggedIn) ?? false;
  }

  Future<bool> setLoggedIn(bool value) {
    return _prefs.setBool(SharedPreferencesConstants.isLoggedIn, value);
  }

  // Language
  String getLanguage() {
    return _prefs.getString(SharedPreferencesConstants.language) ?? 'en';
  }

  Future<bool> setLanguage(String language) {
    return _prefs.setString(SharedPreferencesConstants.language, language);
  }

  // Splash Path (server-driven splash image)
  String? getSplashPath() {
    return _prefs.getString(SharedPreferencesConstants.splashPath);
  }

  Future<bool> setSplashPath(String path) {
    return _prefs.setString(SharedPreferencesConstants.splashPath, path);
  }

  // Theme Colors (Light)
  ThemeColors? getThemeColorsLight() {
    final json = _prefs.getString(SharedPreferencesConstants.themeColorsLight);
    if (json == null) return null;
    try {
      return ThemeColors.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> setThemeColorsLight(ThemeColors colors) {
    return _prefs.setString(
      SharedPreferencesConstants.themeColorsLight,
      jsonEncode(colors.toJson()),
    );
  }

  // Theme Colors (Dark)
  ThemeColors? getThemeColorsDark() {
    final json = _prefs.getString(SharedPreferencesConstants.themeColorsDark);
    if (json == null) return null;
    try {
      return ThemeColors.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> setThemeColorsDark(ThemeColors colors) {
    return _prefs.setString(
      SharedPreferencesConstants.themeColorsDark,
      jsonEncode(colors.toJson()),
    );
  }

  // Entity
  Entity? getEntity() {
    final entityJson = _prefs.getString(SharedPreferencesConstants.entity);
    if (entityJson == null) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(entityJson);
      return Entity.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<bool> setEntity(Entity? entity) {
    if (entity == null) {
      return _prefs.remove(SharedPreferencesConstants.entity);
    }
    return _prefs.setString(
      SharedPreferencesConstants.entity,
      jsonEncode(entity.toJson()),
    );
  }

  // Setting
  Setting? getSetting() {
    final settingJson = _prefs.getString(SharedPreferencesConstants.setting);
    if (settingJson == null) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(settingJson);
      return Setting.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<bool> setSetting(Setting? setting) async {
    if (setting == null) {
      await _prefs.remove(SharedPreferencesConstants.setting);
      return true;
    }
    await _prefs.setString(
      SharedPreferencesConstants.setting,
      jsonEncode(setting.toJson()),
    );

    // Also save splash_path separately if available
    if (setting.splashScreen?.splashPath != null) {
      await setSplashPath(setting.splashScreen!.splashPath!);
    }

    return true;
  }

  // Theme Mode (light / dark / system)
  String getTheme() {
    return _prefs.getString(SharedPreferencesConstants.theme) ?? 'system';
  }

  Future<bool> setTheme(String theme) {
    return _prefs.setString(SharedPreferencesConstants.theme, theme);
  }

  // Heat Map toggle
  bool getIsHeatMap() {
    return _prefs.getBool(SharedPreferencesConstants.isHeatMap) ?? false;
  }

  Future<bool> putIsHeatMap(bool value) {
    return _prefs.setBool(SharedPreferencesConstants.isHeatMap, value);
  }

  // Navigation Map (IN_APP_GOOGLE / GOOGLE / WAZE)
  String getNavigationMap() {
    return _prefs.getString(SharedPreferencesConstants.navigationMap) ?? '';
  }

  Future<bool> putNavigationMap(String value) {
    return _prefs.setString(SharedPreferencesConstants.navigationMap, value);
  }

  // Speaking Language (driver verbal language code)
  String getSpeakingLanguage() {
    return _prefs.getString(SharedPreferencesConstants.speakingLanguage) ?? '';
  }

  Future<bool> setSpeakingLanguage(String languageCode) {
    return _prefs.setString(SharedPreferencesConstants.speakingLanguage, languageCode);
  }

  // Online state (persisted for service restart)
  bool getIsOnline() {
    return _prefs.getBool(SharedPreferencesConstants.isOnline) ?? false;
  }

  Future<bool> putIsOnline(bool value) {
    return _prefs.setBool(SharedPreferencesConstants.isOnline, value);
  }

  // Going To Address (going home mode active)
  bool getGoingToAddress() {
    return _prefs.getBool(SharedPreferencesConstants.goingToAddress) ?? false;
  }

  Future<bool> setGoingToAddress(bool value) {
    return _prefs.setBool(SharedPreferencesConstants.goingToAddress, value);
  }

  // Device Token (FCM)
  String? getDeviceToken() {
    return _prefs.getString(SharedPreferencesConstants.deviceToken);
  }

  Future<bool> setDeviceToken(String token) {
    return _prefs.setString(SharedPreferencesConstants.deviceToken, token);
  }

  // Last Driver Location (for cold restart when standing still)
  ({double latitude, double longitude})? getLastDriverLocation() {
    final lat = _prefs.getDouble(SharedPreferencesConstants.lastDriverLatitude);
    final lng = _prefs.getDouble(SharedPreferencesConstants.lastDriverLongitude);
    if (lat == null || lng == null) return null;
    return (latitude: lat, longitude: lng);
  }

  Future<void> setLastDriverLocation(double latitude, double longitude) async {
    await _prefs.setDouble(SharedPreferencesConstants.lastDriverLatitude, latitude);
    await _prefs.setDouble(SharedPreferencesConstants.lastDriverLongitude, longitude);
  }

  // Prominent location disclosure accepted (Google Play background-location requirement)
  bool getLocationDisclosureAccepted() {
    return _prefs.getBool(SharedPreferencesConstants.locationDisclosureAccepted) ??
        false;
  }

  Future<bool> setLocationDisclosureAccepted(bool value) {
    return _prefs.setBool(
      SharedPreferencesConstants.locationDisclosureAccepted,
      value,
    );
  }

  // Clear auth data only
  Future<void> signOut() async {
    await removeAuthorization();
    await setLoggedIn(false);
    await setEntity(null);
  }

  // Clear all preferences
  Future<bool> clearAll() {
    return _prefs.clear();
  }
}
