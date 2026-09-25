import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/app_repository.dart';
import '../../data/api/response_state.dart';
import '../../models/responses/auth/city_response.dart';
import '../../core/providers/app_providers.dart';

class CityState {
  final bool isLoading;
  final String? error;
  final List<City> cityList;
  final List<City> filteredCityList;

  CityState({
    this.isLoading = false,
    this.error,
    this.cityList = const [],
    this.filteredCityList = const [],
  });

  CityState copyWith({
    bool? isLoading,
    String? error,
    List<City>? cityList,
    List<City>? filteredCityList,
    bool clearError = false,
  }) {
    return CityState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      cityList: cityList ?? this.cityList,
      filteredCityList: filteredCityList ?? this.filteredCityList,
    );
  }
}

class CityViewModel extends StateNotifier<CityState> {
  final AppRepository _appRepository;

  CityViewModel(this._appRepository) : super(CityState());

  Future<void> getCities(String countryId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _appRepository.getCities(countryId: countryId);

    switch (response) {
      case Success<CityResponse>():
        final cities = response.data?.cities ?? [];
        state = state.copyWith(
          isLoading: false,
          cityList: cities,
          filteredCityList: cities,
        );
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message ?? 'Failed to load cities',
        );
      case Loading():
        break;
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredCityList: state.cityList);
      return;
    }
    final filtered = state.cityList
        .where((city) => city.doesMatchSearchQuery(query))
        .toList();
    state = state.copyWith(filteredCityList: filtered);
  }
}

final cityViewModelProvider =
    StateNotifierProvider.autoDispose<CityViewModel, CityState>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  return CityViewModel(appRepository);
});
