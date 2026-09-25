import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../models/responses/hub/nearest_hub_list_response.dart';
import '../../../viewmodels/hub_viewmodel.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hubViewModelProvider);
    final colors = context.colors;

    // Listen for snackbar messages
    ref.listen<HubState>(hubViewModelProvider, (prev, next) {
      if (next.snackBarMessage.isNotEmpty &&
          prev?.snackBarMessage != next.snackBarMessage) {
        context.showErrorSnackBar(next.snackBarMessage);
        ref.read(hubViewModelProvider.notifier).clearSnackBar();
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(appStr.headingWorkHub, 'heading_work_hub'),
            ),
            Expanded(
              child: _buildBody(context, state, colors, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, HubState state, AppColorPalette colors, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hubs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingXL),
          child: AppText.body(
            getString(appStr.errorNoHubFound, 'error_no_hub_found'),
            color: colors.colorTextHint,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(hubViewModelProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingS),
        itemCount: state.hubs.length,
        separatorBuilder: (_, _) => Divider(
          color: colors.colorBackgroundGray,
          height: 1,
          indent: AppDimens.paddingL,
          endIndent: AppDimens.paddingL,
        ),
        itemBuilder: (context, index) {
          final hub = state.hubs[index];
          final isSelected = state.selectedHub?.id == hub.id;
          return _HubListItem(
            hub: hub,
            isSelected: isSelected,
            onTap: () =>
                ref.read(hubViewModelProvider.notifier).onHubSelection(index),
            onNavigateTap: () => _openNavigation(
              context,
              hub.address?.latitude,
              hub.address?.longitude,
              hub.name,
            ),
          );
        },
      ),
    );
  }

  void _openNavigation(
    BuildContext context,
    double? latitude,
    double? longitude,
    String? name,
  ) async {
    if (latitude == null || longitude == null) return;

    final googleUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    }
  }
}

// ── Hub List Item ──────────────────────────────────────────────────

class _HubListItem extends StatelessWidget {
  final Hub hub;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onNavigateTap;

  const _HubListItem({
    required this.hub,
    required this.isSelected,
    required this.onTap,
    required this.onNavigateTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected
            ? colors.colorPrimary.withValues(alpha: 0.05)
            : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingL,
          vertical: AppDimens.padding,
        ),
        child: Row(
          children: [
            // Hub icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.colorPrimary.withValues(alpha: 0.1)
                    : colors.colorBackgroundGray,
                borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: isSelected ? colors.colorPrimary : colors.colorTextHint,
                size: AppDimens.iconSize,
              ),
            ),
            const SizedBox(width: AppDimens.paddingM),

            // Hub name + address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.body(
                    hub.name ?? '',
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hub.address?.address != null &&
                      hub.address!.address!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    AppText.caption(
                      hub.address!.address!,
                      color: colors.colorTextHint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Navigation button
            if (hub.address?.latitude != null &&
                hub.address?.longitude != null)
              IconButton(
                onPressed: onNavigateTap,
                icon: Icon(
                  Icons.navigation_outlined,
                  color: colors.colorPrimary,
                  size: AppDimens.iconSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
