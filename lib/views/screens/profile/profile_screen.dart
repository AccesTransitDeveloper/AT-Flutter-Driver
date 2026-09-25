import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/managers/permission_manager.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/api/server_config.dart';
import '../../../viewmodels/edit_profile_viewmodel.dart';
import '../../../viewmodels/profile_viewmodel.dart';
import '../../bottomsheets/image_picker_bottom_sheet.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_divider.dart';
import '../../widgets/app_toolbar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _navigateToEdit(EditProfileField field) async {
    final result = await context.navigateToEditProfile<bool>(field);
    if (result == true) {
      ref.read(profileViewModelProvider.notifier).refreshProfile();
    }
  }

  Future<bool> _requestCameraPermission() async {
    final result = await PermissionManager.instance.requestCamera();
    switch (result) {
      case PermissionResult.granted:
        return true;
      case PermissionResult.permanentlyDenied:
        if (mounted) _showPermissionDeniedDialog();
        return false;
      default:
        return false;
    }
  }

  void _showPermissionDeniedDialog() {
    final cameraStr = getString(appStr.descriptionCamera, 'description_camera');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: AppText.title(
          getString(appStr.headingPermissionRequired,
                  'heading_permission_required')
              .replacePlaceholders({StringConstant.param: cameraStr}),
          fontWeight: FontWeight.w600,
        ),
        content: AppText.body(
          getString(appStr.descriptionEnablePermissionInSettings,
                  'description_enable_permission_in_settings')
              .replacePlaceholders({StringConstant.param: cameraStr}),
        ),
        actions: [
          AppTextButton(
            text: getString(appStr.buttonCancel, 'button_cancel'),
            onPressed: () => ctx.goBack(),
          ),
          AppTextButton(
            text: getString(
                appStr.buttonOpenSettings, 'button_open_settings'),
            onPressed: () {
              ctx.goBack();
              PermissionManager.instance.openSettings();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await ImagePickerBottomSheet.show(context);
    if (source == null) return;

    if (source == ImagePickerSource.camera) {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission || !mounted) return;
    }

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source == ImagePickerSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final success = await ref
          .read(profileViewModelProvider.notifier)
          .uploadProfilePicture(pickedFile.path);

      if (mounted) {
        final state = ref.read(profileViewModelProvider);
        if (success) {
          if (state.successMessage?.isNotEmpty == true) {
            context.showSnackBar(state.successMessage!);
          }
        } else {
          if (state.error?.isNotEmpty == true) {
            context.showErrorSnackBar(state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(profileViewModelProvider);
    final entity = state.entity;

    final imageUrl = entity?.imageUrl != null && entity!.imageUrl!.isNotEmpty
        ? ServerConfig.getFullImageUrl(entity.imageUrl)
        : null;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(appStr.headingProfile, 'heading_profile'),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimens.paddingL),

                    // ── Profile image ─────────────────────────────────
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Avatar
                          if (state.isUploadingImage)
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: colors.colorBackgroundGray,
                              child: const CircularProgressIndicator(),
                            )
                          else if (imageUrl != null)
                            CachedNetworkImage(
                              imageUrl: imageUrl,
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 50,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) => CircleAvatar(
                                radius: 50,
                                backgroundColor: colors.colorBackgroundGray,
                                child: Icon(Icons.person,
                                    size: 50, color: colors.colorText),
                              ),
                              errorWidget: (context, url, error) => CircleAvatar(
                                radius: 50,
                                backgroundColor: colors.colorBackgroundGray,
                                child: Icon(Icons.person,
                                    size: 50, color: colors.colorText),
                              ),
                            )
                          else
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: colors.colorBackgroundGray,
                              child: Icon(Icons.person,
                                  size: 50, color: colors.colorText),
                            ),

                          // Camera edit button (hidden when profile is verified)
                          if (!state.isProfileVerified)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap:
                                    state.isUploadingImage ? null : _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(AppDimens.paddingXS),
                                  decoration: BoxDecoration(
                                    color: colors.colorPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: AppDimens.iconSizeSmall,
                                    color: colors.colorButtonText,
                                  ),
                                ),
                              ),
                            ),

                          // Verified badge (shown when profile pic is accepted)
                          if (state.isProfileVerified)
                            const Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(
                                Icons.verified,
                                size: 22,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Profile pic status badge (driver-specific)
                    if (state.showProfilePicBadge) ...[
                      const SizedBox(height: AppDimens.paddingM),
                      Center(
                        child: _ProfilePicBadge(
                            status: state.profilePicStatus, colors: colors),
                      ),
                    ],

                    const SizedBox(height: AppDimens.paddingXL),

                    // ── Editable profile fields ───────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding),
                      child: Column(
                        children: [
                          _ProfileField(
                            label: getString(
                                appStr.headingName, 'heading_name'),
                            value: state.fullName,
                            onTap: state.canEditProfile
                                ? () => _navigateToEdit(EditProfileField.name)
                                : null,
                          ),
                          const AppDivider(),
                          _ProfileField(
                            label: getString(
                                appStr.descriptionPhone, 'description_phone'),
                            value: state.phoneNumber,
                            onTap: state.canEditProfile
                                ? () => _navigateToEdit(EditProfileField.phone)
                                : null,
                          ),
                          const AppDivider(),
                          _ProfileField(
                            label: getString(
                                appStr.descriptionEmail, 'description_email'),
                            value: state.email,
                            onTap: state.canEditProfile && !state.isSocialAccount
                                ? () => _navigateToEdit(EditProfileField.email)
                                : null,
                          ),
                          const AppDivider(),
                          _ProfileField(
                            label: getString(appStr.hintDrivingLicense,
                                'hint_driving_license'),
                            value: state.drivingLicense,
                            onTap: state.canEditProfile
                                ? () => _navigateToEdit(EditProfileField.license)
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimens.paddingXXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ProfileField({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.padding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.caption(label, color: colors.colorTextHint),
                  const SizedBox(height: AppDimens.paddingXS),
                  AppText.body(value),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: colors.colorText),
          ],
        ),
      ),
    );
  }
}

class _ProfilePicBadge extends StatelessWidget {
  final int status;
  final AppColorPalette colors;

  const _ProfilePicBadge({required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    final Color badgeColor;
    final String label;
    final IconData icon;

    switch (status) {
      case 30: // accepted
        badgeColor = Colors.green;
        label = getString(appStr.descriptionProfilePicAccepted,
            'description_profile_pic_accepted');
        icon = Icons.verified;
        break;
      case 40: // rejected
        badgeColor = Colors.red;
        label = getString(appStr.descriptionProfilePicRejected,
            'description_profile_pic_rejected');
        icon = Icons.cancel;
        break;
      case 20: // uploaded
        badgeColor = Colors.blue;
        label = getString(appStr.descriptionProfilePicUploaded,
            'description_profile_pic_uploaded');
        icon = Icons.cloud_done;
        break;
      default: // pending
        badgeColor = colors.colorTextHint;
        label = getString(appStr.descriptionProfilePicPending,
            'description_profile_pic_pending');
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingM, vertical: AppDimens.paddingXS),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.paddingL),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: AppDimens.paddingXS),
          AppText.caption(label, color: badgeColor),
        ],
      ),
    );
  }
}

