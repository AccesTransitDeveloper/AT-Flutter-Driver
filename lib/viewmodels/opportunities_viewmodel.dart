import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/responses/opportunity/incentive_policy_response.dart';
import '../models/responses/opportunity/penalty_policy_response.dart';

class OpportunitiesState {
  final bool isLoading;
  final List<IncentivePolicy> incentivePolicies;
  final List<String> penaltyPolicies;
  final String? snackBarMessage;

  const OpportunitiesState({
    this.isLoading = false,
    this.incentivePolicies = const [],
    this.penaltyPolicies = const [],
    this.snackBarMessage,
  });

  OpportunitiesState copyWith({
    bool? isLoading,
    List<IncentivePolicy>? incentivePolicies,
    List<String>? penaltyPolicies,
    String? snackBarMessage,
    bool clearSnackBar = false,
  }) {
    return OpportunitiesState(
      isLoading: isLoading ?? this.isLoading,
      incentivePolicies: incentivePolicies ?? this.incentivePolicies,
      penaltyPolicies: penaltyPolicies ?? this.penaltyPolicies,
      snackBarMessage:
          clearSnackBar ? null : (snackBarMessage ?? this.snackBarMessage),
    );
  }
}

class OpportunitiesViewModel extends StateNotifier<OpportunitiesState> {
  final AppRepository _repository;
  final SharedPreferenceManager? _sharedPref;

  OpportunitiesViewModel(this._repository, this._sharedPref)
      : super(const OpportunitiesState()) {
    _fetchPolicies();
  }

  void _fetchPolicies() {
    final cityId = _sharedPref?.getEntity()?.cityId;
    if (cityId == null || cityId.isEmpty) return;

    _fetchIncentivePolicy(cityId);
    _fetchPenaltyPolicy(cityId);
  }

  Future<void> _fetchIncentivePolicy(String cityId) async {
    state = state.copyWith(isLoading: true);

    final response = await _repository.getIncentivePolicy(cityId);

    if (response is Success<IncentivePolicyResponse>) {
      state = state.copyWith(
        isLoading: false,
        incentivePolicies: response.data?.incentivePolicies ?? [],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        snackBarMessage: response.message,
      );
    }
  }

  Future<void> _fetchPenaltyPolicy(String cityId) async {
    final response = await _repository.getPenaltyPolicy(cityId);

    if (response is Success<PenaltyPolicyResponse>) {
      state = state.copyWith(
        penaltyPolicies: response.data?.penaltyPolicy ?? [],
      );
    } else {
      state = state.copyWith(
        snackBarMessage: response.message,
      );
    }
  }

  void clearSnackBar() {
    state = state.copyWith(clearSnackBar: true);
  }
}

final opportunitiesViewModelProvider = StateNotifierProvider.autoDispose<
    OpportunitiesViewModel, OpportunitiesState>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).valueOrNull;
  return OpportunitiesViewModel(repo, sharedPref);
});
