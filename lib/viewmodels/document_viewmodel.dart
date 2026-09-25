import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/localization/app_strings.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/responses/document/document_response.dart';

/// Document status enum
enum DocumentStatus {
  pending(10),
  uploaded(20),
  accepted(30),
  rejected(40),
  expired(50);

  final int value;
  const DocumentStatus(this.value);

  static DocumentStatus fromValue(int? value) {
    return DocumentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DocumentStatus.pending,
    );
  }

  String get displayText {
    switch (this) {
      case DocumentStatus.pending:
        return getString(appStr.descriptionPending, 'description_pending');
      case DocumentStatus.uploaded:
        return getString(appStr.descriptionUploaded, 'description_uploaded');
      case DocumentStatus.accepted:
        return getString(appStr.descriptionAccepted, 'description_accepted');
      case DocumentStatus.rejected:
        return getString(appStr.descriptionRejected, 'description_rejected');
      case DocumentStatus.expired:
        return getString(appStr.descriptionExpired, 'description_expired');
    }
  }
}

/// Document screen state
class DocumentState {
  final List<Document>? documents;
  final bool isLoading;
  final bool isUploading;
  final String? error;
  final String? uploadError;

  const DocumentState({
    this.documents,
    this.isLoading = false,
    this.isUploading = false,
    this.error,
    this.uploadError,
  });

  DocumentState copyWith({
    List<Document>? documents,
    bool? isLoading,
    bool? isUploading,
    String? error,
    String? uploadError,
    bool clearError = false,
    bool clearUploadError = false,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: clearError ? null : (error ?? this.error),
      uploadError:
          clearUploadError ? null : (uploadError ?? this.uploadError),
    );
  }
}

/// Document screen ViewModel
class DocumentViewModel extends StateNotifier<DocumentState> {
  final AppRepository _appRepository;

  DocumentViewModel(this._appRepository) : super(const DocumentState()) {
    loadDocuments();
  }

  /// Load documents from API
  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _appRepository.getDocuments();

    switch (response) {
      case Success<DocumentListResponse>():
        state = state.copyWith(
          isLoading: false,
          documents: response.data?.documents,
        );
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message ?? 'Failed to load documents',
        );
      case Loading():
        break;
    }
  }

  /// Upload document
  Future<bool> uploadDocument({
    required String documentId,
    String? filePath,
    String? expiryDate,
    String? uniqueCode,
  }) async {
    state = state.copyWith(isUploading: true, clearUploadError: true);

    final response = await _appRepository.uploadDocument(
      documentId: documentId,
      filePath: filePath,
      expiryDate: expiryDate,
      uniqueCode: uniqueCode,
    );

    switch (response) {
      case Success():
        state = state.copyWith(isUploading: false);
        await loadDocuments();
        return true;
      case Error():
        state = state.copyWith(
          isUploading: false,
          uploadError:
              response.error?.message ?? 'Failed to upload document',
        );
        return false;
      case Loading():
        return false;
    }
  }

  /// Load vehicle-specific documents
  Future<void> loadVehicleDocuments(String vehicleId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _appRepository.getVehicleDocuments(
      vehicleId: vehicleId,
      type: DocumentType.vehicle,
    );

    switch (response) {
      case Success<DocumentListResponse>():
        state = state.copyWith(
          isLoading: false,
          documents: response.data?.documents,
        );
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message ?? 'Failed to load documents',
        );
      case Loading():
        break;
    }
  }

  /// Refresh documents
  Future<void> refresh() async {
    await loadDocuments();
  }
}

/// Provider for DocumentViewModel
final documentViewModelProvider =
    StateNotifierProvider.autoDispose<DocumentViewModel, DocumentState>(
        (ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  return DocumentViewModel(appRepository);
});

/// Provider for vehicle-specific documents (takes vehicleId)
final vehicleDocumentProvider = StateNotifierProvider.autoDispose
    .family<VehicleDocumentNotifier, DocumentState, String>(
        (ref, vehicleId) {
  final appRepository = ref.watch(appRepositoryProvider);
  return VehicleDocumentNotifier(appRepository, vehicleId);
});

/// Vehicle document ViewModel
class VehicleDocumentNotifier extends StateNotifier<DocumentState> {
  final AppRepository _appRepository;
  final String vehicleId;

  VehicleDocumentNotifier(this._appRepository, this.vehicleId)
      : super(const DocumentState()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _appRepository.getVehicleDocuments(
      vehicleId: vehicleId,
      type: DocumentType.vehicle,
    );

    switch (response) {
      case Success<DocumentListResponse>():
        state = state.copyWith(
          isLoading: false,
          documents: response.data?.documents,
        );
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message ?? 'Failed to load documents',
        );
      case Loading():
        break;
    }
  }

  Future<bool> uploadDocument({
    required String documentId,
    String? filePath,
    String? expiryDate,
    String? uniqueCode,
  }) async {
    state = state.copyWith(isUploading: true, clearUploadError: true);

    final response = await _appRepository.uploadDocument(
      documentId: documentId,
      filePath: filePath,
      expiryDate: expiryDate,
      uniqueCode: uniqueCode,
    );

    switch (response) {
      case Success():
        state = state.copyWith(isUploading: false);
        await loadDocuments();
        return true;
      case Error():
        state = state.copyWith(
          isUploading: false,
          uploadError:
              response.error?.message ?? 'Failed to upload document',
        );
        return false;
      case Loading():
        return false;
    }
  }

  Future<void> refresh() async => loadDocuments();
}
