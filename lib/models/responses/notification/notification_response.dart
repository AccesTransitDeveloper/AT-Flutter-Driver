import 'package:json_annotation/json_annotation.dart';

part 'notification_response.g.dart';

@JsonSerializable()
class NotificationResponse {
  final List<NotificationItem>? notifications;
  final int? dataCount;

  NotificationResponse({
    this.notifications,
    this.dataCount,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}

@JsonSerializable()
class NotificationItem {
  @JsonKey(name: '_id')
  final String? id;
  final NotificationEntity? entity;
  final int? userType;
  final String? deviceType;
  final String? country;
  final String? city;
  final String? message;
  final String? title;
  final String? imageUrl;
  final String? createdAt;

  NotificationItem({
    this.id,
    this.entity,
    this.userType,
    this.deviceType,
    this.country,
    this.city,
    this.message,
    this.title,
    this.imageUrl,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}

@JsonSerializable()
class NotificationEntity {
  final String? typeId;
  final int? type;
  final String? email;
  final String? name;

  NotificationEntity({
    this.typeId,
    this.type,
    this.email,
    this.name,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) =>
      _$NotificationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationEntityToJson(this);
}
