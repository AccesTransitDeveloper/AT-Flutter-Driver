import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../core/router/app_navigation.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_divider.dart';
import '../widgets/app_text.dart';

enum ImagePickerSource { camera, gallery }

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(ImagePickerSource) onSourceSelected;

  const ImagePickerBottomSheet({
    super.key,
    required this.onSourceSelected,
  });

  static Future<ImagePickerSource?> show(BuildContext context) {
    return showModalBottomSheet<ImagePickerSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ImagePickerBottomSheet(
        onSourceSelected: (source) => context.goBack(source),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.colorBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.paddingL),
          topRight: Radius.circular(AppDimens.paddingL),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppDimens.paddingL),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.padding),
              child: AppText.title(
                getString(appStr.descriptionUploadProfile,
                    'description_upload_profile'),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimens.paddingL),
            _OptionItem(
              icon: Icons.camera_alt_outlined,
              title: getString(
                  appStr.descriptionCamera, 'description_camera'),
              onTap: () => onSourceSelected(ImagePickerSource.camera),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.padding),
              child: AppDivider(),
            ),
            _OptionItem(
              icon: Icons.photo_library_outlined,
              title: getString(appStr.descriptionImage, 'description_image'),
              onTap: () => onSourceSelected(ImagePickerSource.gallery),
            ),
            const SizedBox(height: AppDimens.padding),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.padding),
              child: AppTextButton(
                text: getString(appStr.buttonCancel, 'button_cancel'),
                onPressed: () => context.goBack(),
                textColor: colors.colorText,
              ),
            ),
            const SizedBox(height: AppDimens.paddingS),
          ],
        ),
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _OptionItem({
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
          horizontal: AppDimens.padding,
          vertical: AppDimens.paddingM,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.colorPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
              ),
              child: Icon(
                icon,
                color: colors.colorPrimary,
                size: AppDimens.iconSize,
              ),
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
              color: colors.colorText,
            ),
          ],
        ),
      ),
    );
  }
}
