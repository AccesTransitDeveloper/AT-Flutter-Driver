import 'dart:io';

import '../../../data/api/response_state.dart';
import '../../../data/repository/app_repository.dart';
import '../../../models/responses/document/document_response.dart';
import '../models/ai_driver_registration_draft.dart';

String _normalizeServerName(String? value) {
  return (value ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '')
      .trim();
}

String resolveDocumentIdForAiDriver({
  required String localDocumentId,
  required List<Document> remoteDocuments,
}) {
  for (final document in remoteDocuments) {
    final serverId = document.documentId ?? document.id;
    if (serverId != null &&
        _normalizeServerName(serverId) == _normalizeServerName(localDocumentId)) {
      return serverId;
    }
  }

  final localNormalized = _normalizeServerName(localDocumentId);
  for (final document in remoteDocuments) {
    final candidates = <String?>[
      document.documentId,
      document.id,
      document.documentDetail?.name,
      document.documentDetail?.title,
      document.documentDetail?.description,
    ];

    for (final candidate in candidates) {
      if (candidate != null &&
          _normalizeServerName(candidate) == localNormalized) {
        final serverId = document.documentId ?? document.id;
        if (serverId != null && serverId.isNotEmpty) {
          return serverId;
        }
      }
    }
  }

  for (final document in remoteDocuments) {
    final title = _normalizeServerName(
      document.documentDetail?.name ?? document.documentDetail?.title,
    );
    final localName = _normalizeServerName(localDocumentId);
    if (title.isNotEmpty && title.contains(localName)) {
      final serverId = document.documentId ?? document.id;
      if (serverId != null && serverId.isNotEmpty) {
        return serverId;
      }
    }
    if (localName.contains(title) && title.isNotEmpty) {
      final serverId = document.documentId ?? document.id;
      if (serverId != null && serverId.isNotEmpty) {
        return serverId;
      }
    }
  }

  return localDocumentId;
}

List<String> collectUploadableDocumentIds(AiDriverRegistrationDraft draft) {
  return draft.documents
      .where((document) =>
          document.localFilePath != null &&
          document.localFilePath!.trim().isNotEmpty)
      .map((document) => document.id)
      .toList(growable: false);
}

/// Boundary for AT AI Driver document submission.
abstract interface class AiDriverDocumentSubmissionGateway {
  Future<void> submit(AiDriverRegistrationDraft draft);
}

class AppRepositoryAiDriverDocumentSubmissionGateway
    implements AiDriverDocumentSubmissionGateway {
  final AppRepository _appRepository;

  const AppRepositoryAiDriverDocumentSubmissionGateway(this._appRepository);

  @override
  Future<void> submit(AiDriverRegistrationDraft draft) async {
    final uploadableIds = collectUploadableDocumentIds(draft);
    if (uploadableIds.isEmpty) {
      return;
    }

    final remoteDocumentsResponse = await _appRepository.getDocuments();
    final remoteDocuments = switch (remoteDocumentsResponse) {
      Success<DocumentListResponse>() => remoteDocumentsResponse.data?.documents ?? const [],
      Error() => const <Document>[],
      Loading() => const <Document>[],
    };

    for (final localDocumentId in uploadableIds) {
      final document = draft.documents.firstWhere(
        (item) => item.id == localDocumentId,
      );
      final filePath = document.localFilePath;
      if (filePath == null || filePath.trim().isEmpty) {
        continue;
      }
      final file = File(filePath);
      if (!file.existsSync()) {
        throw StateError(
          'The selected document file is missing and cannot be uploaded: $filePath',
        );
      }

      final resolvedDocumentId = resolveDocumentIdForAiDriver(
        localDocumentId: localDocumentId,
        remoteDocuments: remoteDocuments,
      );
      final uploadDocumentId = resolvedDocumentId.isNotEmpty
          ? resolvedDocumentId
          : localDocumentId;

      final response = await _appRepository.uploadDocument(
        documentId: uploadDocumentId,
        filePath: filePath,
      );

      switch (response) {
        case Success():
          continue;
        case Error():
          throw StateError(
            response.error?.message ??
                'Document upload failed for "$uploadDocumentId".',
          );
        case Loading():
          throw StateError(
            'Document upload is still in progress for "$uploadDocumentId".',
          );
      }
    }
  }
}

class DisabledAiDriverDocumentSubmissionGateway
    implements AiDriverDocumentSubmissionGateway {
  const DisabledAiDriverDocumentSubmissionGateway();

  @override
  Future<void> submit(AiDriverRegistrationDraft draft) {
    return Future.value();
  }
}
