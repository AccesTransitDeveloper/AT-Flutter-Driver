import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/responses/hub/nearest_hub_list_response.dart';

/// Hub screen state
class HubState {
  final bool isLoading;
  final String snackBarMessage;
  final List<Hub> hubs;
  final Hub? selectedHub;

  const HubState({
    this.isLoading = false,
    this.snackBarMessage = '',
    this.hubs = const [],
    this.selectedHub,
  });

  HubState copyWith({
    bool? isLoading,
    String? snackBarMessage,
    List<Hub>? hubs,
    Hub? selectedHub,
    bool clearSelectedHub = false,
  }) {
    return HubState(
      isLoading: isLoading ?? this.isLoading,
      snackBarMessage: snackBarMessage ?? this.snackBarMessage,
      hubs: hubs ?? this.hubs,
      selectedHub:
          clearSelectedHub ? null : (selectedHub ?? this.selectedHub),
    );
  }
}

/// Hub screen ViewModel
class HubViewModel extends StateNotifier<HubState> {
  final AppRepository _appRepository;

  HubViewModel(this._appRepository) : super(const HubState()) {
    getNearestHubList();
  }

  /// Fetch nearest hubs from API
  Future<void> getNearestHubList() async {
    state = state.copyWith(isLoading: true, snackBarMessage: '');

    final response = await _appRepository.getNearestHubList();

    switch (response) {
      case Success<NearestHubListResponse>():
        final hubList = response.data?.hubs ?? [];
        state = state.copyWith(
          isLoading: false,
          hubs: hubList,
          selectedHub: hubList.isNotEmpty ? hubList[0] : null,
        );
      case Error():
        state = state.copyWith(
          isLoading: false,
          snackBarMessage: response.error?.message ?? '',
        );
      case Loading():
        break;
    }
  }

  /// Select a hub by index
  void onHubSelection(int index) {
    if (index >= 0 && index < state.hubs.length) {
      state = state.copyWith(selectedHub: state.hubs[index]);
    }
  }

  /// Clear snack bar message
  void clearSnackBar() {
    state = state.copyWith(snackBarMessage: '');
  }

  /// Refresh hub list
  Future<void> refresh() async => getNearestHubList();
}

/// Provider for HubViewModel
final hubViewModelProvider =
    StateNotifierProvider.autoDispose<HubViewModel, HubState>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  return HubViewModel(appRepository);
});
