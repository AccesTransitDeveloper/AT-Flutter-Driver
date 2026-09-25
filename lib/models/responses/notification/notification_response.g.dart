// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponse _$NotificationResponseFromJson(
  Map<String, dynamic> json,
) => NotificationResponse(
  notifications: (json['notifications'] as List<dynamic>?)
      ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  dataCount: (json['dataCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$NotificationResponseToJson(
  NotificationResponse instance,
) => <String, dynamic>{
  'notifications': instance.notifications,
  'dataCount': instance.dataCount,
};

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    NotificationItem(
      id: json['_id'] as String?,
      entity: json['entity'] == null
          ? null
          : NotificationEntity.fromJson(json['entity'] as Map<String, dynamic>),
      userType: (json['userType'] as num?)?.toInt(),
      deviceType: json['deviceType'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      message: json['message'] as String?,
      title: json['title'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$NotificationItemToJson(NotificationItem instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'entity': instance.entity,
      'userType': instance.userType,
      'deviceType': instance.deviceType,
      'country': instance.country,
      'city': instance.city,
      'message': instance.message,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt,
    };

NotificationEntity _$NotificationEntityFromJson(Map<String, dynamic> json) =>
    NotificationEntity(
      typeId: json['typeId'] as String?,
      type: (json['type'] as num?)?.toInt(),
      email: json['email'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$NotificationEntityToJson(NotificationEntity instance) =>
    <String, dynamic>{
      'typeId': instance.typeId,
      'type': instance.type,
      'email': instance.email,
      'name': instance.name,
    };
