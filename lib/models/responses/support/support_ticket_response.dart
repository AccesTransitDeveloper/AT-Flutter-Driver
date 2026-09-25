import 'package:json_annotation/json_annotation.dart';

part 'support_ticket_response.g.dart';

String? _uniqueIdFromJson(dynamic value) => value?.toString();

@JsonSerializable()
class SupportTicketHistoryResponse {
  final List<SupportTicket>? supportTickets;

  SupportTicketHistoryResponse({this.supportTickets});

  factory SupportTicketHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SupportTicketHistoryResponseToJson(this);
}

@JsonSerializable()
class SupportTicketCategoriesResponse {
  final List<SupportCategory>? categories;

  SupportTicketCategoriesResponse({this.categories});

  factory SupportTicketCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketCategoriesResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SupportTicketCategoriesResponseToJson(this);
}

@JsonSerializable()
class SupportTicket {
  @JsonKey(name: '_id')
  final String? id;
  final int? type;
  final String? typeId;
  final String? bookingId;
  final String? imageUrl;
  final String? bookingUniqueId;
  final String? subject;
  final String? description;
  final String? category;
  final String? priority;
  final String? status;
  final String? cityId;
  final String? countryId;
  final String? chatId;
  final String? profileImageUrl;
  final String? name;
  final List<String>? comments;
  final String? createdAt;
  final String? updatedAt;
  @JsonKey(fromJson: _uniqueIdFromJson)
  final String? uniqueId;
  @JsonKey(name: '__v')
  final int? version;

  SupportTicket({
    this.id,
    this.type,
    this.typeId,
    this.bookingId,
    this.imageUrl,
    this.bookingUniqueId,
    this.subject,
    this.description,
    this.category,
    this.priority,
    this.status,
    this.cityId,
    this.countryId,
    this.chatId,
    this.profileImageUrl,
    this.name,
    this.comments,
    this.createdAt,
    this.updatedAt,
    this.uniqueId,
    this.version,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketFromJson(json);

  Map<String, dynamic> toJson() => _$SupportTicketToJson(this);
}

@JsonSerializable()
class SupportCategory {
  final String? key;
  final String? message;

  SupportCategory({this.key, this.message});

  factory SupportCategory.fromJson(Map<String, dynamic> json) =>
      _$SupportCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$SupportCategoryToJson(this);
}
