import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/api/server_config.dart';
import '../../widgets/app_text.dart';

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
          data: (data) => data,
          orElse: () => null,
        );
    final entity = sharedPref?.getEntity();
    final setting = sharedPref?.getSetting();

    // Driver type flags (matching Kotlin MenuViewModel logic)
    final isPartnerDriver = entity?.type == EntityType.partner;
    final isReferralActive =
        (setting?.referralConfiguration?.customer?.isActive == true) ||
            (setting?.referralConfiguration?.driver?.isActive == true);
    final isSubscriptionActive =
        setting?.subscriptionConfig?.isActive == true;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.70,
      child: Drawer(
        backgroundColor: colors.colorBackground,
        shape: const RoundedRectangleBorder(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + name + rating (taps to profile)
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                context.navigateToProfile();
              },
              child: _buildHeader(context, colors, entity),
            ),

            // Main menu items (bold text, no icons)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: AppDimens.paddingM),
                children: [
                  _DrawerTextItem(
                    title: getString(appStr.headingInbox, 'heading_inbox'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.navigateToInbox();
                    },
                  ),
                  // Referral — hidden for partner drivers; hidden if referral inactive
                  if (!isPartnerDriver && isReferralActive)
                    _DrawerTextItem(
                      title: getString(appStr.headingReferral, 'heading_referral'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.navigateToReferral();
                      },
                    ),
                  // Activity — visible to all drivers
                  _DrawerTextItem(
                    title: getString(
                        appStr.headingActivity, 'heading_activity'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.navigateToActivity();
                    },
                  ),
                  // Opportunities — hidden for partner drivers
                  if (!isPartnerDriver)
                    _DrawerTextItem(
                      title: getString(
                          appStr.headingOpportunities, 'heading_opportunities'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.navigateToOpportunities();
                      },
                    ),
                  // Marketplace Rides — hidden for partner drivers
                  if (!isPartnerDriver)
                    _DrawerTextItem(
                      title: getString(
                          appStr.headingMarketplaceRide, 'heading_marketplace_ride'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.navigateToMarketplace();
                      },
                    ),
                  // Earnings — hidden for partner drivers
                  if (!isPartnerDriver)
                    _DrawerTextItem(
                      title: getString(appStr.headingEarnings, 'heading_earnings'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.navigateToEarnings();
                      },
                    ),
                  // Subscription — hidden for partner drivers; hidden if inactive
                  if (!isPartnerDriver && isSubscriptionActive)
                    _DrawerTextItem(
                      title: getString(appStr.headingSubscription, 'heading_subscription'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.navigateToSubscription();
                      },
                    ),
                  // Wallet — hidden for partner drivers
                  if (!isPartnerDriver)
                    _DrawerTextItem(
                      title: getString(
                          appStr.headingWallet, 'heading_wallet'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.navigateToWallet();
                      },
                    ),
                  _DrawerTextItem(
                    title: getString(appStr.headingAccount, 'heading_account'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.navigateToAccount();
                    },
                  ),

                  // Divider
                  Divider(
                    color: colors.colorBackgroundGray,
                    height: AppDimens.paddingXXL,
                    indent: AppDimens.paddingL,
                    endIndent: AppDimens.paddingL,
                  ),

                  // Footer items (smaller text)
                  _DrawerTextItem(
                    title: getString(appStr.headingHelp, 'heading_help'),
                    isSmall: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.navigateToContactUs();
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

  Widget _buildHeader(
    BuildContext context,
    AppColorPalette colors,
    dynamic entity,
  ) {
    final topPadding = MediaQuery.of(context).padding.top;
    final firstName = entity?.firstName ?? '';
    final lastName = entity?.lastName ?? '';
    final name = '$firstName $lastName'.trim();
    final displayName = name.isNotEmpty ? name : getString(appStr.descriptionDriver, 'description_driver');
    final rating = entity?.rate?.toStringAsFixed(2) ?? '0.00';
    final imageUrl = entity?.imageUrl;

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding + AppDimens.paddingL,
        left: AppDimens.paddingL,
        right: AppDimens.paddingL,
        bottom: AppDimens.paddingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.colorBackgroundGray,
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: ServerConfig.getFullImageUrl(imageUrl),
                    fit: BoxFit.cover,
                    placeholder: (_, url) => Icon(
                      Icons.person,
                      size: 24,
                      color: colors.colorTextHint,
                    ),
                    errorWidget: (_, e, st) => Icon(
                      Icons.person,
                      size: 24,
                      color: colors.colorTextHint,
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 24,
                    color: colors.colorTextHint,
                  ),
          ),

          const SizedBox(height: AppDimens.paddingS),

          // Name
          AppText.body(
            displayName,
            fontWeight: FontWeight.w500,
          ),

          // Rating
          Row(
            children: [
              Icon(
                Icons.star,
                color: colors.colorText,
                size: 12,
              ),
              const SizedBox(width: 2),
              AppText.caption(
                rating,
                fontSize: AppTypos.textS,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Text-only drawer menu item matching Uber driver drawer style.
class _DrawerTextItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isSmall;

  const _DrawerTextItem({
    required this.title,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.paddingL,
          vertical: isSmall ? AppDimens.paddingS : AppDimens.paddingM,
        ),
        child: isSmall
            ? AppText.body(
                title,
                color: colors.colorText,
              )
            : AppText(
                title,
                fontSize: AppTypos.heading,
                fontWeight: FontWeight.w700,
                color: colors.colorText,
              ),
      ),
    );
  }
}
