import 'dart:io';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../models/requests/device_token_request.dart';

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static Future<String> getManufacturer() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.manufacturer;
      } else if (Platform.isIOS) {
        return 'Apple';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.model;
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static DeviceType getDeviceType() {
    if (Platform.isAndroid) {
      return DeviceType.android;
    } else if (Platform.isIOS) {
      return DeviceType.ios;
    }
    return DeviceType.android;
  }

  static Future<String> getOS() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return 'iOS ${iosInfo.systemVersion}';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '1.0.0';
    }
  }

  static String getDeviceCountry() {
    final locale = ui.PlatformDispatcher.instance.locale;
    return locale.countryCode ?? 'US';
  }

  static Future<DeviceTokenRequest> buildDeviceTokenRequest() async {
    return DeviceTokenRequest(
      deviceId: await getDeviceId(),
      manufacturer: await getManufacturer(),
      deviceName: await getDeviceName(),
      deviceType: getDeviceType(),
      os: await getOS(),
      appVersion: await getAppVersion(),
    );
  }
}
