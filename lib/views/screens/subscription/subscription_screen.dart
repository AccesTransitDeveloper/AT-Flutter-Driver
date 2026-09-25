import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../viewmodels/subscription_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';
import 'components/subscription_item_widget.dart';
import 'components/subscription_action_bottom_sheet.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  Future<void> _navigateToPaymentAndProceed(SubscriptionViewModel viewModel) async {
    final result = await context.navigateToWalletForSubscription();
    if (result == true && mounted) {
      viewModel.proceedAfterCardSelect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(subscriptionViewModelProvider);
    final viewModel = ref.read(subscriptionViewModelProvider.notifier);

    // Listen for snackbar messages and navigation
    ref.listen<SubscriptionState>(subscriptionViewModelProvider, (prev, next) {
      if (next.snackBarMessage != null &&
          next.snackBarMessage != prev?.snackBarMessage) {
        context.showErrorSnackBar(next.snackBarMessage!);
      }
      if (next.error != null && next.error != prev?.error) {
        context.showErrorSnackBar(next.error!);
      }
      if (next.isNavigateToWebView &&
          next.navigateWebViewData != null &&
          prev != null &&
          !prev.isNavigateToWebView) {
        viewModel.clearWebViewNavigation();
        context.navigateToWebView(
          webViewData: next.navigateWebViewData,
          onPaymentData: (_) {
            context.goBack();
            viewModel.loadSubscriptions();
          },
        );
      }
      if (next.isNavigateToPayment &&
          (prev == null || !prev.isNavigateToPayment)) {
        viewModel.clearPaymentNavigation();
        _navigateToPaymentAndProceed(viewModel);
      }
      if (next.showActionBottomSheet &&
          (prev == null || !prev.showActionBottomSheet)) {
        SubscriptionActionBottomSheet.show(
          context,
          onYesClick: () => viewModel.confirmAction(),
          onCloseClick: () => viewModel.dismissActionSheet(),
        );
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppToolbar(
                  title: getString(
                      appStr.headingSubscription, 'heading_subscription'),
                ),
                Expanded(
                  child: _buildContent(context, colors, state, viewModel),
                ),
              ],
            ),

            // Progress dialog overlay (matching Kotlin ProgressDialog)
            if (state.isMainLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppColorPalette colors,
    SubscriptionState state,
    SubscriptionViewModel viewModel,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: AppDimens.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shimmer loading (5x items like Kotlin)
                      if (state.isListLoading)
                        ...List.generate(
                            5, (_) => const ShimmerSubscriptionItem()),

                      // Active subscriptions section
                      if (state.activeSubscriptionList.isNotEmpty) ...[
                        Padding(
                          padding:
                              const EdgeInsets.only(top: AppDimens.padding),
                          child: AppText.body(
                            getString(
                                appStr.subHeadingActiveSubscription ?? '',
                                'sub_heading_active_subscription'),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ...state.activeSubscriptionList.map(
                          (item) => SubscriptionItemWidget(
                            item: item,
                            // Active items: NO onTap (no selection), only action button
                            onActionTap: () =>
                                viewModel.onActionButtonTap(item),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Divider between sections (5dp thick like Kotlin)
                if (state.activeSubscriptionList.isNotEmpty &&
                    state.subscriptionList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimens.padding),
                    child: Divider(
                      color: colors.colorBackgroundGray,
                      thickness: 5,
                      height: 5,
                    ),
                  ),

                Padding(
                  padding: AppDimens.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Available subscriptions section
                      if (state.subscriptionList.isNotEmpty) ...[
                        Padding(
                          padding:
                              const EdgeInsets.only(top: AppDimens.padding),
                          child: AppText.body(
                            getString(appStr.subHeadingSubscription ?? '',
                                'sub_heading_subscription'),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ...state.subscriptionList.map(
                          (item) => SubscriptionItemWidget(
                            item: item,
                            // Available items: both selection and action button
                            onTap: () =>
                                viewModel.selectSubscription(item),
                            onActionTap: () =>
                                viewModel.onActionButtonTap(item),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppDimens.padding),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Empty state (centered, like Kotlin)
        if (!state.isListLoading &&
            state.subscriptionList.isEmpty &&
            state.activeSubscriptionList.isEmpty)
          Expanded(
            child: Center(
              child: AppText.body(
                getString(
                    appStr.errorNoRecordFound ?? '', 'error_no_record_found'),
                color: colors.colorTextHint,
              ),
            ),
          ),

        // Purchase Subscription button at bottom
        if (!state.isListLoading && state.subscriptionList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.padding)
                .copyWith(bottom: AppDimens.padding),
            child: AppFilledButton(
              text: getString(appStr.buttonPurchaseSubscription ?? '',
                  'button_purchase_subscription'),
              onPressed: () => viewModel.onPurchaseTap(),
            ),
          ),
      ],
    );
  }
}
