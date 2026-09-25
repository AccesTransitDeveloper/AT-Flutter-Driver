import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/responses/auth/city_response.dart';
import '../../../viewmodels/auth/city_viewmodel.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';

class CityScreen extends ConsumerStatefulWidget {
  final String countryId;

  const CityScreen({super.key, required this.countryId});

  @override
  ConsumerState<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends ConsumerState<CityScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cityViewModelProvider.notifier).getCities(widget.countryId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCitySelected(City city) {
    context.goBack(city);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cityViewModelProvider);
    final colors = context.colors;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppDimens.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimens.paddingXL),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: colors.colorText),
                        onPressed: () => context.goBack(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: AppDimens.paddingM),
                      AppText.heading(
                        getString(appStr.headingCities, 'heading_cities'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingL),
                  AppTextField(
                    controller: _searchController,
                    hintText: getString(
                        appStr.hintSearchCity, 'hint_search_city'),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colors.colorText,
                      size: AppDimens.iconSize,
                    ),
                    onChanged: (query) =>
                        ref.read(cityViewModelProvider.notifier).search(query),
                  ),
                  const SizedBox(height: AppDimens.paddingM),
                ],
              ),
            ),
            Expanded(
              child: _buildContent(state, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CityState state, AppColorPalette colors) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.colorPrimary),
      );
    }

    if (state.error != null) {
      return Center(
        child: AppText.body(
          state.error!,
          color: colors.colorWarning,
        ),
      );
    }

    if (state.filteredCityList.isEmpty) {
      return Center(
        child: AppText.body(
          getString(appStr.textSelectCity, 'text_select_city'),
          color: colors.colorTextHint,
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: state.filteredCityList.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        color: colors.colorTextHint.withValues(alpha: 0.2),
      ),
      itemBuilder: (context, index) {
        final city = state.filteredCityList[index];
        return InkWell(
          onTap: () => _onCitySelected(city),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.padding,
              vertical: AppDimens.paddingL,
            ),
            child: AppText.body(city.name ?? ''),
          ),
        );
      },
    );
  }
}
