// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentListResponse _$DocumentListResponseFromJson(
  Map<String, dynamic> json,
) => DocumentListResponse(
  documents: (json['documents'] as List<dynamic>?)
      ?.map((e) => Document.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DocumentListResponseToJson(
  DocumentListResponse instance,
) => <String, dynamic>{'documents': instance.documents};

Document _$DocumentFromJson(Map<String, dynamic> json) => Document(
  documentDetail: json['documentDetail'] == null
      ? null
      : DocumentDetail.fromJson(json['documentDetail'] as Map<String, dynamic>),
  documentId: json['documentId'] as String?,
  id: json['_id'] as String?,
  status: (json['status'] as num?)?.toInt(),
  type: (json['type'] as num?)?.toInt(),
  typeId: json['typeId'] as String?,
  reason: json['reason'] as String?,
  expiryDate: json['expiryDate'] as String?,
  uniqueCode: json['uniqueCode'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
  'documentDetail': instance.documentDetail,
  'documentId': instance.documentId,
  '_id': instance.id,
  'status': instance.status,
  'type': instance.type,
  'typeId': instance.typeId,
  'reason': instance.reason,
  'expiryDate': instance.expiryDate,
  'uniqueCode': instance.uniqueCode,
  'imageUrl': instance.imageUrl,
};

DocumentDetail _$DocumentDetailFromJson(Map<String, dynamic> json) =>
    DocumentDetail(
      countryId: json['countryId'] as String?,
      isExpiry: json['isExpiry'] as bool?,
      isMandatory: json['isMandatory'] as bool?,
      isUniqueCode: json['isUniqueCode'] as bool?,
      isVisible: json['isVisible'] as bool?,
      name: json['name'] as String?,
      type: (json['type'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$DocumentDetailToJson(DocumentDetail instance) =>
    <String, dynamic>{
      'countryId': instance.countryId,
      'isExpiry': instance.isExpiry,
      'isMandatory': instance.isMandatory,
      'isUniqueCode': instance.isUniqueCode,
      'isVisible': instance.isVisible,
      'name': instance.name,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
    };

UploadDocumentResponse _$UploadDocumentResponseFromJson(
  Map<String, dynamic> json,
) => UploadDocumentResponse(
  documentStatus: (json['documentStatus'] as num?)?.toInt(),
);

Map<String, dynamic> _$UploadDocumentResponseToJson(
  UploadDocumentResponse instance,
) => <String, dynamic>{'documentStatus': instance.documentStatus};
