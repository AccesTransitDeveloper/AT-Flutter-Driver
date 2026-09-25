import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../models/responses/opportunity/incentive_policy_response.dart';
import '../../../viewmodels/opportunities_viewmodel.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class OpportunitiesScreen extends ConsumerStatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  ConsumerState<OpportunitiesScreen> createState() =>
      _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends ConsumerState<OpportunitiesScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(opportunitiesViewModelProvider);

    ref.listen<OpportunitiesState>(opportunitiesViewModelProvider,
        (prev, next) {
      if (next.snackBarMessage != null &&
          next.snackBarMessage!.isNotEmpty &&
          next.snackBarMessage != prev?.snackBarMessage) {
        context.showErrorSnackBar(next.snackBarMessage!);
        ref.read(opportunitiesViewModelProvider.notifier).clearSnackBar();
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(
                  appStr.headingOpportunities, 'heading_opportunities'),
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.padding,
                vertical: AppDimens.padding,
              ),
              child: _TabBar(
                selectedIndex: _selectedTab,
                onTabChanged: (index) => setState(() => _selectedTab = index),
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedTab == 0
                      ? _IncentivesList(
                          incentives: state.incentivePolicies,
                          colors: colors,
                        )
                      : _PenaltiesList(
                          penalties: state.penaltyPolicies,
                          colors: colors,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const _TabBar({
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tabs = [
      getString(appStr.buttonIncentives, 'button_incentives'),
      getString(appStr.buttonPenalties, 'button_penalties'),
    ];

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.colorPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? colors.colorPrimary : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppDimens.buttonRadius),
                ),
                child: AppText.body(
                  tabs[index],
                  color: isSelected
                      ? colors.colorSelectedText
                      : colors.colorPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _IncentivesList extends StatelessWidget {
  final List<IncentivePolicy> incentives;
  final AppColorPalette colors;

  const _IncentivesList({
    required this.incentives,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    if (incentives.isEmpty) {
      return Center(
        child: AppText.body(
          getString(appStr.descriptionNoDataFound, 'description_no_data_found'),
          color: colors.colorTextHint,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding),
      itemCount: incentives.length,
      itemBuilder: (context, index) {
        final item = incentives[index];
        return _IncentivePolicyItem(item: item, colors: colors);
      },
    );
  }
}

class _IncentivePolicyItem extends StatelessWidget {
  final IncentivePolicy item;
  final AppColorPalette colors;

  const _IncentivePolicyItem({
    required this.item,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.body(
            item.incentive ?? '',
            fontWeight: FontWeight.w600,
          ),
          if (item.conditions != null)
            ...item.conditions!.map(
              (condition) => Padding(
                padding: const EdgeInsets.only(
                    left: AppDimens.paddingXS, top: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.caption('• ', fontSize: 12),
                    Expanded(
                      child: AppText.caption(
                        condition,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PenaltiesList extends StatelessWidget {
  final List<String> penalties;
  final AppColorPalette colors;

  const _PenaltiesList({
    required this.penalties,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    if (penalties.isEmpty) {
      return Center(
        child: AppText.body(
          getString(appStr.descriptionNoDataFound, 'description_no_data_found'),
          color: colors.colorTextHint,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding,
        vertical: AppDimens.paddingS,
      ),
      itemCount: penalties.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: AppDimens.paddingS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.body(
                '• ',
                color: colors.colorText,
              ),
              Expanded(
                child: AppText.body(
                  penalties[index],
                  color: colors.colorText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
