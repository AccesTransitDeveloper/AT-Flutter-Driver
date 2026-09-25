enum DeviceType {
  android,
  ios;

  String toJsonValue() {
    switch (this) {
      case DeviceType.android:
        return 'ANDROID';
      case DeviceType.ios:
        return 'IOS';
    }
  }
}

class DeviceTokenRequest {
  final String deviceId;
  final String manufacturer;
  final String deviceName;
  final DeviceType deviceType;
  final String os;
  final String appVersion;

  const DeviceTokenRequest({
    required this.deviceId,
    required this.manufacturer,
    required this.deviceName,
    required this.deviceType,
    required this.os,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'manufacturer': manufacturer,
        'deviceName': deviceName,
        'deviceType': deviceType.toJsonValue(),
        'os': os,
        'appVersion': appVersion,
      };
}
