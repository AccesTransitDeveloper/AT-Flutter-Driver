import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/responses/home/additional_terms_item.dart';

class AdditionalTermsState {
  final AdditionalTermsItem? termsItem;
  final bool isLoading;
  final bool isAccepted;
  final String? errorMessage;

  const AdditionalTermsState({
    this.termsItem,
    this.isLoading = false,
    this.isAccepted = false,
    this.errorMessage,
  });

  AdditionalTermsState copyWith({
    AdditionalTermsItem? termsItem,
    bool? isLoading,
    bool? isAccepted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdditionalTermsState(
      termsItem: termsItem ?? this.termsItem,
      isLoading: isLoading ?? this.isLoading,
      isAccepted: isAccepted ?? this.isAccepted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AdditionalTermsViewModel extends StateNotifier<AdditionalTermsState> {
  final AppRepository _repository;

  AdditionalTermsViewModel(this._repository)
      : super(const AdditionalTermsState());

  void setTermsItem(AdditionalTermsItem item) {
    state = state.copyWith(termsItem: item);
  }

  Future<void> acceptTerms() async {
    final id = state.termsItem?.id;
    if (id == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _repository.acceptAdditionalTerms(id);

    if (response is Success) {
      state = state.copyWith(isLoading: false, isAccepted: true);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final additionalTermsViewModelProvider =
    StateNotifierProvider.autoDispose<AdditionalTermsViewModel,
        AdditionalTermsState>((ref) {
  final repository = ref.watch(appRepositoryProvider);
  return AdditionalTermsViewModel(repository);
});
