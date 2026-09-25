import 'package:json_annotation/json_annotation.dart';

part 'support_ticket_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SupportTicketRequest {
  final String? subject;
  final String? description;
  final String? category;
  final String? bookingId;

  SupportTicketRequest({
    this.subject,
    this.description,
    this.category,
    this.bookingId,
  });

  factory SupportTicketRequest.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SupportTicketRequestToJson(this);
}

@JsonSerializable()
class TicketStatusRequest {
  final String? status;

  TicketStatusRequest({this.status});

  factory TicketStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$TicketStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TicketStatusRequestToJson(this);
}
