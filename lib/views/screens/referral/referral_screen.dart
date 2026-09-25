import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../viewmodels/referral_viewmodel.dart';
import '../../bottomsheets/referral_policy_bottomsheet.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  void _showReferralPolicy(BuildContext context, List<String> policy) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.colorBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ReferralPolicyBottomSheet(policy: policy),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(referralViewModelProvider);
    final viewModel = ref.read(referralViewModelProvider.notifier);

    ref.listen<ReferralState>(referralViewModelProvider, (previous, next) {
      if (next.successMessage != null &&
          previous?.successMessage == null) {
        context.showSnackBar(next.successMessage!);
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(appStr.headingReferral, 'heading_referral'),
              rightIcon:
                  state.showReferralHistory ? Icons.list_alt : null,
              onRightIconPressed: state.showReferralHistory
                  ? () => context.navigateToReferralList()
                  : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.padding),
                child: Column(
                  children: [
                    const SizedBox(height: AppDimens.paddingXL),

                    // Title
                    AppText.title(
                      getString(
                          appStr.descriptionInviteYourFriendAndEarnMoney,
                          'description_invite_your_friend_and_earn_money'),
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppDimens.paddingXL),

                    // Illustration
                    SizedBox(
                      height: 180,
                      child: Image.asset(
                        'assets/images/referral.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: colors.colorBackgroundGray,
                              borderRadius: BorderRadius.circular(
                                  AppDimens.buttonRadius),
                            ),
                            child: Icon(
                              Icons.people_outline,
                              size: 80,
                              color: colors.colorText,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppDimens.paddingXL),

                    // View Referral Policy
                    if (state.referralPolicy.isNotEmpty)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: colors.colorText.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(
                              AppDimens.buttonRadius),
                        ),
                        child: InkWell(
                          onTap: () => _showReferralPolicy(
                              context, state.referralPolicy),
                          borderRadius: BorderRadius.circular(
                              AppDimens.buttonRadius),
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimens.padding),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  color: colors.colorText,
                                ),
                                const SizedBox(width: AppDimens.paddingM),
                                AppText.body(
                                  getString(appStr.buttonViewReferralPolicy,
                                      'button_view_referral_policy'),
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: AppDimens.paddingXL),

                    // Your Referral Code label
                    AppText.body(
                      getString(appStr.descriptionYourReferralCode,
                          'description_your_referral_code'),
                      fontWeight: FontWeight.w500,
                    ),

                    const SizedBox(height: AppDimens.paddingM),

                    // Referral code box
                    GestureDetector(
                      onTap: viewModel.copyReferralCode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingL,
                          vertical: AppDimens.paddingM,
                        ),
                        decoration: BoxDecoration(
                          color: colors.colorSecondary.withValues(alpha: 0.1),
                          border: Border.all(
                            color: colors.colorSecondary,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppDimens.buttonRadius),
                        ),
                        child: AppText.body(
                          state.referralCode.isNotEmpty
                              ? state.referralCode
                              : '—',
                          color: colors.colorSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimens.paddingS),

                    // Tap to copy
                    GestureDetector(
                      onTap: viewModel.copyReferralCode,
                      child: AppText.caption(
                        getString(appStr.descriptionTapToCopy,
                            'description_tap_to_copy'),
                        color: colors.colorText,
                        letterSpacing: 1.0,
                      ),
                    ),

                    const SizedBox(height: AppDimens.paddingXXL),
                  ],
                ),
              ),
            ),

            // Refer Your Friend button
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: AppFilledButton(
                text: getString(
                    appStr.buttonReferYourFriend, 'button_refer_your_friend'),
                onPressed: viewModel.shareReferralCode,
                icon: Icons.share,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
