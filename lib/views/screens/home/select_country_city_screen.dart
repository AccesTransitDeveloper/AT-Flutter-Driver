import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../viewmodels/select_country_city_viewmodel.dart';
import '../../../views/widgets/app_scaffold.dart';
import '../../../views/widgets/app_text.dart';
import '../../../views/widgets/app_text_field.dart';

class SelectCountryCityScreen extends ConsumerStatefulWidget {
  final bool needsCountry;
  final String? existingCountryId;

  const SelectCountryCityScreen({
    super.key,
    this.needsCountry = true,
    this.existingCountryId,
  });

  @override
  ConsumerState<SelectCountryCityScreen> createState() =>
      _SelectCountryCityScreenState();
}

class _SelectCountryCityScreenState
    extends ConsumerState<SelectCountryCityScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectCountryCityViewModelProvider.notifier).init(
            needsCountry: widget.needsCountry,
            existingCountryId: widget.existingCountryId,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(selectCountryCityViewModelProvider.notifier).searchFilter(query);
  }

  void _onClearSearch() {
    _searchController.clear();
    ref.read(selectCountryCityViewModelProvider.notifier).searchFilter('');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(selectCountryCityViewModelProvider);
    final colors = context.colors;

    ref.listen<SelectCountryCityState>(selectCountryCityViewModelProvider,
        (prev, next) {
      if (next.savedSuccessfully && prev?.savedSuccessfully != true) {
        context.goBack(true);
      }
      if (next.errorMessage.isNotEmpty &&
          next.errorMessage != prev?.errorMessage) {
        context.showErrorSnackBar(next.errorMessage);
      }
    });

    final isCountryStep = state.step == SelectionStep.country;
    final title = isCountryStep
        ? getString(appStr.textSelectCountry, 'text_select_country')
        : getString(appStr.textSelectCity, 'text_select_city');

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back arrow + search
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!isCountryStep && widget.needsCountry) {
                        _searchController.clear();
                        ref
                            .read(
                                selectCountryCityViewModelProvider.notifier)
                            .goBackToCountry();
                      } else {
                        context.goBack();
                      }
                    },
                    child: Icon(Icons.arrow_back,
                        color: colors.colorText, size: AppDimens.iconSize),
                  ),
                  const SizedBox(width: AppDimens.paddingM),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingM),
                      decoration: BoxDecoration(
                        color: colors.colorBackgroundGray,
                        borderRadius:
                            BorderRadius.circular(AppDimens.buttonRadius),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: _onSearchChanged,
                              hintText: isCountryStep
                                  ? getString(appStr.hintSearchCountry,
                                      'hint_search_country')
                                  : getString(appStr.hintSearchCity,
                                      'hint_search_city'),
                              fillColor: Colors.transparent,
                              borderColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: AppDimens.paddingM),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: _onClearSearch,
                              child: Icon(Icons.close,
                                  color: colors.colorText, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText.title(title, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: AppDimens.paddingS),

            // Selected country header (city step only)
            if (!isCountryStep && state.selectedCountry != null)
              _buildSelectedCountryHeader(colors, state),

            // Content
            Expanded(child: _buildContent(colors, state)),

            // Saving indicator
            if (state.isSaving)
              const Padding(
                padding: EdgeInsets.all(AppDimens.padding),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCountryHeader(
      AppColorPalette colors, SelectCountryCityState state) {
    return GestureDetector(
      onTap: widget.needsCountry
          ? () {
              _searchController.clear();
              ref
                  .read(selectCountryCityViewModelProvider.notifier)
                  .goBackToCountry();
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDimens.padding),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding,
          vertical: AppDimens.paddingM,
        ),
        decoration: BoxDecoration(
          color: colors.colorPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
        ),
        child: Row(
          children: [
            Icon(Icons.flag_outlined,
                color: colors.colorPrimary, size: 20),
            const SizedBox(width: AppDimens.paddingM),
            Expanded(
              child: AppText.body(
                state.selectedCountry?.name ?? '',
                color: colors.colorPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.needsCountry)
              Icon(Icons.edit_outlined,
                  color: colors.colorPrimary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      AppColorPalette colors, SelectCountryCityState state) {
    final isCountryStep = state.step == SelectionStep.country;

    if (isCountryStep && state.isLoadingCountries) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isCountryStep && state.isLoadingCities) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = isCountryStep
        ? state.filteredCountries
        : state.filteredCities;

    if (items.isEmpty) {
      return Center(
        child: AppText.body(
          isCountryStep
              ? getString(appStr.errorNoCountriesFound, 'error_no_countries_found')
              : getString(appStr.errorNoCitiesFound, 'error_no_cities_found'),
          color: colors.colorTextHint,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding),
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (isCountryStep) {
          final country = state.filteredCountries[index];
          return _buildCountryItem(colors, country);
        } else {
          final city = state.filteredCities[index];
          return _buildCityItem(colors, city);
        }
      },
    );
  }

  Widget _buildCountryItem(AppColorPalette colors, country) {
    return InkWell(
      onTap: () {
        _searchController.clear();
        ref
            .read(selectCountryCityViewModelProvider.notifier)
            .selectCountry(country);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingM),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.colorBackgroundGray,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.flag_outlined, size: 20, color: colors.colorText),
            ),
            const SizedBox(width: AppDimens.paddingM),
            Expanded(
              child: AppText.body(
                country.name ?? '',
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right,
                color: colors.colorTextHint, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCityItem(AppColorPalette colors, city) {
    return InkWell(
      onTap: () {
        ref
            .read(selectCountryCityViewModelProvider.notifier)
            .selectCity(city);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingM),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.colorBackgroundGray,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_city_outlined,
                  size: 20, color: colors.colorText),
            ),
            const SizedBox(width: AppDimens.paddingM),
            Expanded(
              child: AppText.body(
                city.name ?? '',
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right,
                color: colors.colorTextHint, size: 20),
          ],
        ),
      ),
    );
  }
}
