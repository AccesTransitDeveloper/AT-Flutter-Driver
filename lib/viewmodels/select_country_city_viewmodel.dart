import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repository/app_repository.dart';
import '../data/api/response_state.dart';
import '../models/responses/auth/country_response.dart';
import '../models/responses/auth/city_response.dart';
import '../models/requests/country_city_request.dart';

enum SelectionStep { country, city }

class SelectCountryCityState {
  final bool isLoadingCountries;
  final bool isLoadingCities;
  final bool isSaving;
  final List<Country> countries;
  final List<Country> filteredCountries;
  final List<City> cities;
  final List<City> filteredCities;
  final Country? selectedCountry;
  final City? selectedCity;
  final SelectionStep step;
  final String searchQuery;
  final String errorMessage;
  final bool savedSuccessfully;

  SelectCountryCityState({
    this.isLoadingCountries = false,
    this.isLoadingCities = false,
    this.isSaving = false,
    this.countries = const [],
    this.filteredCountries = const [],
    this.cities = const [],
    this.filteredCities = const [],
    this.selectedCountry,
    this.selectedCity,
    this.step = SelectionStep.country,
    this.searchQuery = '',
    this.errorMessage = '',
    this.savedSuccessfully = false,
  });

  SelectCountryCityState copyWith({
    bool? isLoadingCountries,
    bool? isLoadingCities,
    bool? isSaving,
    List<Country>? countries,
    List<Country>? filteredCountries,
    List<City>? cities,
    List<City>? filteredCities,
    Country? selectedCountry,
    City? selectedCity,
    SelectionStep? step,
    String? searchQuery,
    String? errorMessage,
    bool? savedSuccessfully,
  }) {
    return SelectCountryCityState(
      isLoadingCountries: isLoadingCountries ?? this.isLoadingCountries,
      isLoadingCities: isLoadingCities ?? this.isLoadingCities,
      isSaving: isSaving ?? this.isSaving,
      countries: countries ?? this.countries,
      filteredCountries: filteredCountries ?? this.filteredCountries,
      cities: cities ?? this.cities,
      filteredCities: filteredCities ?? this.filteredCities,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedCity: selectedCity ?? this.selectedCity,
      step: step ?? this.step,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      savedSuccessfully: savedSuccessfully ?? this.savedSuccessfully,
    );
  }
}

class SelectCountryCityViewModel
    extends StateNotifier<SelectCountryCityState> {
  final AppRepository _appRepository;
  String? _existingCountryId;

  SelectCountryCityViewModel(this._appRepository)
      : super(SelectCountryCityState());

  void init({required bool needsCountry, String? existingCountryId}) {
    _existingCountryId = existingCountryId;
    if (needsCountry) {
      state = state.copyWith(step: SelectionStep.country);
      fetchCountries();
    } else {
      state = state.copyWith(step: SelectionStep.city);
      if (existingCountryId != null) {
        fetchCities(existingCountryId);
      }
    }
  }

  Future<void> fetchCountries() async {
    state = state.copyWith(isLoadingCountries: true, errorMessage: '');

    final response = await _appRepository.getCountries();

    switch (response) {
      case Success<CountryResponse>():
        final allCountries = response.data?.countries ?? [];
        final businessCountries =
            allCountries.where((c) => c.isBusiness == true).toList();
        state = state.copyWith(
          isLoadingCountries: false,
          countries: businessCountries,
          filteredCountries: businessCountries,
        );
        break;
      case Error<CountryResponse>():
        state = state.copyWith(
          isLoadingCountries: false,
          errorMessage: response.message ?? 'Failed to load countries',
        );
        break;
      case Loading():
        break;
    }
  }

  void selectCountry(Country country) {
    state = state.copyWith(
      selectedCountry: country,
      step: SelectionStep.city,
      searchQuery: '',
      cities: [],
      filteredCities: [],
    );
    if (country.id != null) {
      fetchCities(country.id!);
    }
  }

  Future<void> fetchCities(String countryId) async {
    state = state.copyWith(isLoadingCities: true, errorMessage: '');

    final response = await _appRepository.getCities(countryId: countryId);

    switch (response) {
      case Success<CityResponse>():
        final allCities = response.data?.cities ?? [];
        state = state.copyWith(
          isLoadingCities: false,
          cities: allCities,
          filteredCities: allCities,
        );
        break;
      case Error<CityResponse>():
        state = state.copyWith(
          isLoadingCities: false,
          errorMessage: response.message ?? 'Failed to load cities',
        );
        break;
      case Loading():
        break;
    }
  }

  Future<void> selectCity(City city) async {
    state = state.copyWith(selectedCity: city, isSaving: true, errorMessage: '');
    await _saveCountryCity();
  }

  Future<void> _saveCountryCity() async {
    final countryId = state.selectedCountry?.id ?? _existingCountryId;
    final cityId = state.selectedCity?.id;

    if (cityId == null || countryId == null) return;

    final request = CountryCityRequest(
      countryId: countryId,
      cityId: cityId,
    );

    final response = await _appRepository.setCountryCity(request);

    switch (response) {
      case Success<dynamic>():
        state = state.copyWith(isSaving: false, savedSuccessfully: true);
        break;
      case Error<dynamic>():
        state = state.copyWith(
          isSaving: false,
          errorMessage: response.message ?? 'Failed to save',
        );
        break;
      case Loading():
        break;
    }
  }

  void searchFilter(String query) {
    state = state.copyWith(searchQuery: query);

    if (state.step == SelectionStep.country) {
      if (query.isEmpty) {
        state = state.copyWith(filteredCountries: state.countries);
      } else {
        final filtered = state.countries
            .where((c) => c.doesMatchSearchQuery(query))
            .toList();
        state = state.copyWith(filteredCountries: filtered);
      }
    } else {
      if (query.isEmpty) {
        state = state.copyWith(filteredCities: state.cities);
      } else {
        final filtered =
            state.cities.where((c) => c.doesMatchSearchQuery(query)).toList();
        state = state.copyWith(filteredCities: filtered);
      }
    }
  }

  void goBackToCountry() {
    state = state.copyWith(
      step: SelectionStep.country,
      searchQuery: '',
      cities: [],
      filteredCities: [],
      filteredCountries: state.countries,
    );
  }
}

final selectCountryCityViewModelProvider = StateNotifierProvider.autoDispose<
    SelectCountryCityViewModel, SelectCountryCityState>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  return SelectCountryCityViewModel(appRepository);
});
