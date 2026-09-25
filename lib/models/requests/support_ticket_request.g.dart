// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_ticket_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportTicketRequest _$SupportTicketRequestFromJson(
  Map<String, dynamic> json,
) => SupportTicketRequest(
  subject: json['subject'] as String?,
  description: json['description'] as String?,
  category: json['category'] as String?,
  bookingId: json['bookingId'] as String?,
);

Map<String, dynamic> _$SupportTicketRequestToJson(
  SupportTicketRequest instance,
) => <String, dynamic>{
  'subject': ?instance.subject,
  'description': ?instance.description,
  'category': ?instance.category,
  'bookingId': ?instance.bookingId,
};

TicketStatusRequest _$TicketStatusRequestFromJson(Map<String, dynamic> json) =>
    TicketStatusRequest(status: json['status'] as String?);

Map<String, dynamic> _$TicketStatusRequestToJson(
  TicketStatusRequest instance,
) => <String, dynamic>{'status': instance.status};
