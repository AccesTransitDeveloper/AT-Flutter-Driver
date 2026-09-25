// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_ticket_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportTicketHistoryResponse _$SupportTicketHistoryResponseFromJson(
  Map<String, dynamic> json,
) => SupportTicketHistoryResponse(
  supportTickets: (json['supportTickets'] as List<dynamic>?)
      ?.map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SupportTicketHistoryResponseToJson(
  SupportTicketHistoryResponse instance,
) => <String, dynamic>{'supportTickets': instance.supportTickets};

SupportTicketCategoriesResponse _$SupportTicketCategoriesResponseFromJson(
  Map<String, dynamic> json,
) => SupportTicketCategoriesResponse(
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => SupportCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SupportTicketCategoriesResponseToJson(
  SupportTicketCategoriesResponse instance,
) => <String, dynamic>{'categories': instance.categories};

SupportTicket _$SupportTicketFromJson(Map<String, dynamic> json) =>
    SupportTicket(
      id: json['_id'] as String?,
      type: (json['type'] as num?)?.toInt(),
      typeId: json['typeId'] as String?,
      bookingId: json['bookingId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      bookingUniqueId: json['bookingUniqueId'] as String?,
      subject: json['subject'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      priority: json['priority'] as String?,
      status: json['status'] as String?,
      cityId: json['cityId'] as String?,
      countryId: json['countryId'] as String?,
      chatId: json['chatId'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      name: json['name'] as String?,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      uniqueId: _uniqueIdFromJson(json['uniqueId']),
      version: (json['__v'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SupportTicketToJson(SupportTicket instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'type': instance.type,
      'typeId': instance.typeId,
      'bookingId': instance.bookingId,
      'imageUrl': instance.imageUrl,
      'bookingUniqueId': instance.bookingUniqueId,
      'subject': instance.subject,
      'description': instance.description,
      'category': instance.category,
      'priority': instance.priority,
      'status': instance.status,
      'cityId': instance.cityId,
      'countryId': instance.countryId,
      'chatId': instance.chatId,
      'profileImageUrl': instance.profileImageUrl,
      'name': instance.name,
      'comments': instance.comments,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'uniqueId': instance.uniqueId,
      '__v': instance.version,
    };

SupportCategory _$SupportCategoryFromJson(Map<String, dynamic> json) =>
    SupportCategory(
      key: json['key'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SupportCategoryToJson(SupportCategory instance) =>
    <String, dynamic>{'key': instance.key, 'message': instance.message};
