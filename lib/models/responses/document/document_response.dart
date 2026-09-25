import 'package:json_annotation/json_annotation.dart';

part 'document_response.g.dart';

@JsonSerializable()
class DocumentListResponse {
  final List<Document>? documents;

  DocumentListResponse({
    this.documents,
  });

  factory DocumentListResponse.fromJson(Map<String, dynamic> json) =>
      _$DocumentListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentListResponseToJson(this);
}

@JsonSerializable()
class Document {
  final DocumentDetail? documentDetail;
  final String? documentId;
  @JsonKey(name: '_id')
  final String? id;
  final int? status;
  final int? type;
  final String? typeId;
  final String? reason;
  final String? expiryDate;
  final String? uniqueCode;
  final String? imageUrl;

  Document({
    this.documentDetail,
    this.documentId,
    this.id,
    this.status,
    this.type,
    this.typeId,
    this.reason,
    this.expiryDate,
    this.uniqueCode,
    this.imageUrl,
  });

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentToJson(this);
}

@JsonSerializable()
class DocumentDetail {
  final String? countryId;
  final bool? isExpiry;
  final bool? isMandatory;
  final bool? isUniqueCode;
  final bool? isVisible;
  final String? name;
  final int? type;
  final String? title;
  final String? description;

  DocumentDetail({
    this.countryId,
    this.isExpiry,
    this.isMandatory,
    this.isUniqueCode,
    this.isVisible,
    this.name,
    this.type,
    this.title,
    this.description,
  });

  factory DocumentDetail.fromJson(Map<String, dynamic> json) =>
      _$DocumentDetailFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentDetailToJson(this);
}

String resolveDocumentUploadId(Document document) {
  return document.documentId ?? document.id ?? '';
}

@JsonSerializable()
class UploadDocumentResponse {
  final int? documentStatus;

  UploadDocumentResponse({
    this.documentStatus,
  });

  factory UploadDocumentResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadDocumentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadDocumentResponseToJson(this);
}
