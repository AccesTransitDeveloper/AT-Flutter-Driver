import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/webview_data_model.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';


class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
          data: (data) => data,
          orElse: () => null,
        );
    final entity = sharedPref?.getEntity();
    final setting = sharedPref?.getSetting();
    final termsUrl = setting?.termsAndConditionsURL;
    final privacyUrl = setting?.privacyPolicyURL;

    // Driver type flags (matching Kotlin MenuViewModel logic)
    final isAdminDriver = entity?.type == EntityType.admin;
    final isPartnerDriver = entity?.type == EntityType.partner;
    final isRewardPointActive = setting?.rewardPointConfig?.isActive == true;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppToolbar(
              title: getString(appStr.headingAccount, 'heading_account'),
              backIcon: Icons.close,
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: AppDimens.paddingS),
                children: [
                  _AccountMenuItem(
                    icon: Icons.directions_car_outlined,
                    title: getString(appStr.headingVehicles, 'heading_vehicles'),
                    onTap: () => context.navigateToVehicles(),
                  ),
                  // Work Hub — only for admin (hub) drivers
                  if (isAdminDriver)
                    _AccountMenuItem(
                      icon: Icons.work_outline,
                      title: getString(appStr.headingWorkHub, 'heading_work_hub'),
                      onTap: () => context.navigateToHub(),
                    ),
                  _AccountMenuItem(
                    icon: Icons.description_outlined,
                    title: getString(
                        appStr.headingDocument, 'heading_document'),
                    onTap: () => context.navigateToDocuments(),
                  ),
                  // Payment — hidden for partner drivers
                  if (!isPartnerDriver)
                    _AccountMenuItem(
                      icon: Icons.payment_outlined,
                      title: getString(appStr.headingPayment, 'heading_payment'),
                      onTap: () => context.navigateToWallet(),
                    ),
                  _AccountMenuItem(
                    icon: Icons.person_outline,
                    title: getString(appStr.headingManageAccount, 'heading_manage_account'),
                    onTap: () => context.navigateToProfile(),
                  ),
                  _AccountMenuItem(
                    icon: Icons.settings_outlined,
                    title: getString(appStr.headingSettings, 'heading_settings'),
                    onTap: () => context.navigateToSettings(),
                  ),
                  // Redeem — hidden for partner drivers; hidden if reward points inactive
                  if (!isPartnerDriver && isRewardPointActive)
                    _AccountMenuItem(
                      icon: Icons.redeem_outlined,
                      title: getString(appStr.headingRedeem, 'heading_redeem'),
                      onTap: () => context.navigateToRedeem(),
                    ),
                  _AccountMenuItem(
                    icon: Icons.lock_outline,
                    title: getString(appStr.headingPrivacy, 'heading_privacy'),
                    onTap: () {
                      if (privacyUrl != null && privacyUrl.isNotEmpty) {
                        context.navigateToWebView(
                          webViewData: WebViewDataModel(
                            webURL: privacyUrl,
                            name: getString(appStr.headingPrivacy, 'heading_privacy'),
                          ),
                        );
                      }
                    },
                  ),
                  _AccountMenuItem(
                    icon: Icons.verified_user_outlined,
                    title: getString(appStr.headingTermsAndConditions, 'heading_terms_and_conditions'),
                    onTap: () {
                      if (termsUrl != null && termsUrl.isNotEmpty) {
                        context.navigateToWebView(
                          webViewData: WebViewDataModel(
                            webURL: termsUrl,
                            name: getString(appStr.headingTermsAndConditions, 'heading_terms_and_conditions'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AccountMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingL,
          vertical: AppDimens.paddingM,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: colors.colorText,
              size: AppDimens.iconSize,
            ),
            const SizedBox(width: AppDimens.padding),
            Expanded(
              child: AppText.body(
                title,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.colorTextHint,
              size: AppDimens.iconSize,
            ),
          ],
        ),
      ),
    );
  }
}
