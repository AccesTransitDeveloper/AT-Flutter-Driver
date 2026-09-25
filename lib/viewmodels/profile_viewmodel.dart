import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/app_strings.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/parse_response.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/requests/entity_detail_request.dart';
import '../core/constants/app_constants.dart';
import '../models/responses/auth/entity_detail_response.dart';

/// Profile picture verification status (matches Kotlin ProfilePicStatus)
class ProfilePicStatus {
  static const int pending = 10;
  static const int uploaded = 20;
  static const int accepted = 30;
  static const int rejected = 40;
}

/// Document status constants (matches Kotlin DocumentStatus)
class DocumentStatus {
  static const int pending = 10;
  static const int uploaded = 20;
  static const int accepted = 30;
  static const int rejected = 40;
  static const int expired = 50;
}

/// Profile screen state
class ProfileState {
  final Entity? entity;
  final bool isLoading;
  final bool isUploadingImage;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.entity,
    this.isLoading = false,
    this.isUploadingImage = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    Entity? entity,
    bool? isLoading,
    bool? isUploadingImage,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      entity: entity ?? this.entity,
      isLoading: isLoading ?? this.isLoading,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  /// Full name display
  String get fullName {
    final firstName = entity?.firstName ?? '';
    final lastName = entity?.lastName ?? '';
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty
        ? name
        : getString(appStr.descriptionNotSet, 'description_not_set');
  }

  /// Formatted phone number
  String get phoneNumber {
    final code = entity?.countryPhoneCode ?? '';
    final phone = entity?.phone ?? '';
    if (code.isNotEmpty && phone.isNotEmpty) return '$code $phone';
    if (phone.isNotEmpty) return phone;
    return getString(appStr.descriptionNotSet, 'description_not_set');
  }

  /// Email
  String get email =>
      entity?.email?.isNotEmpty == true
          ? entity!.email!
          : getString(appStr.descriptionNotSet, 'description_not_set');

  /// Unique ID
  String get drivingLicense => entity?.drivingLicense ?? '';

  String get uniqueId => entity?.uniqueId ?? '';

  /// Rating display (e.g. "4.8 (23)")
  String get ratingDisplay {
    final rate = entity?.rate;
    final count = entity?.rateCount ?? 0;
    if (rate == null) return getString(appStr.descriptionNotSet, 'description_not_set');
    return '${rate.toStringAsFixed(1)} ($count)';
  }

  /// Profile picture status
  int get profilePicStatus => entity?.profilePicStatus ?? ProfilePicStatus.pending;

  /// Document status
  int get documentStatus => entity?.documentStatus ?? DocumentStatus.pending;

  /// Whether vehicle has been added
  bool get isVehicleAdded => entity?.isVehicleAdded ?? false;

  /// Whether this is a partner driver (certain fields are read-only)
  bool get isPartnerDriver {
    return entity?.type == EntityType.partner;
  }

  /// Whether profile pic is verified (accepted)
  bool get isProfileVerified =>
      profilePicStatus == ProfilePicStatus.accepted;

  /// Whether this is a social account (email is read-only)
  bool get isSocialAccount => entity?.isSocialAccount ?? false;

  /// Whether a field can be edited (partner/merchant cannot edit)
  bool get canEditProfile => !isPartnerDriver;

  /// Whether profile pic status badge should be shown
  bool get showProfilePicBadge =>
      entity?.profilePicStatus != null &&
      entity!.profilePicStatus != ProfilePicStatus.accepted;
}

/// Profile screen ViewModel
class ProfileViewModel extends StateNotifier<ProfileState> {
  final SharedPreferenceManager _sharedPref;
  final AppRepository _appRepository;

  ProfileViewModel(this._sharedPref, this._appRepository)
      : super(const ProfileState()) {
    _loadProfileData();
  }

  void _loadProfileData() {
    final entity = _sharedPref.getEntity();
    if (entity != null) {
      state = state.copyWith(entity: entity);
    }
  }

  void refreshProfile() {
    _loadProfileData();
  }

  Future<bool> uploadProfilePicture(String filePath) async {
    state = state.copyWith(
        isUploadingImage: true, clearError: true, clearSuccess: true);

    final response = await _appRepository.uploadProfilePicture(filePath);

    switch (response) {
      case Success():
        await _refreshEntityData();
        state = state.copyWith(
          isUploadingImage: false,
          successMessage: response.message ?? '',
        );
        return true;
      case Error():
        state = state.copyWith(
          isUploadingImage: false,
          error: response.error?.message ?? '',
        );
        return false;
      case Loading():
        return false;
    }
  }

  Future<void> _refreshEntityData() async {
    final entity = _sharedPref.getEntity();
    final countryCode = entity?.countryCode ?? 'IN';

    final request = EntityDetailRequest(countryCode: countryCode);
    final response = await _appRepository.getEntityDetail(request);

    switch (response) {
      case Success<EntityDetailResponse>():
        final data = response.data;
        if (data != null) {
          parseEntityDetailResponse(data, _sharedPref);
          _loadProfileData();
        }
      case Error():
        break;
      case Loading():
        break;
    }
  }
}

final profileViewModelProvider =
    StateNotifierProvider.autoDispose<ProfileViewModel, ProfileState>((ref) {
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => throw Exception('SharedPreferences not initialized'),
      );
  final appRepository = ref.watch(appRepositoryProvider);
  return ProfileViewModel(sharedPref, appRepository);
});
