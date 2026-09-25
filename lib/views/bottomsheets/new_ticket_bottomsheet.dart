import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_strings.dart';
import '../../core/localization/string_constants.dart';
import '../../core/managers/permission_manager.dart';
import '../../core/router/app_navigation.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../viewmodels/support_ticket_viewmodel.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/app_text_field.dart';
import 'image_picker_bottom_sheet.dart';

class NewTicketBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback? onTicketCreated;
  final String? bookingId;
  final String? uniqueId;

  const NewTicketBottomSheet({
    super.key,
    this.onTicketCreated,
    this.bookingId,
    this.uniqueId,
  });

  @override
  ConsumerState<NewTicketBottomSheet> createState() =>
      _NewTicketBottomSheetState();
}

class _NewTicketBottomSheetState extends ConsumerState<NewTicketBottomSheet> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.bookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(supportTicketViewModelProvider.notifier)
            .setBookingId(widget.bookingId);
      });
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(supportTicketViewModelProvider);
    final viewModel = ref.read(supportTicketViewModelProvider.notifier);

    ref.listen<SupportTicketState>(supportTicketViewModelProvider,
        (previous, next) {
      if (next.error != null && previous?.error == null) {
        context.showErrorSnackBar(next.error!);
        viewModel.clearError();
      }
      if (next.isTicketCreated && !(previous?.isTicketCreated ?? false)) {
        viewModel.resetTicketCreated();
        context.goBack();
        widget.onTicketCreated?.call();
      }
    });

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: AppText.title(
                    widget.uniqueId != null && widget.uniqueId!.isNotEmpty
                        ? getString(appStr.descriptionBookingId,
                                'description_booking_id')
                            .replacePlaceholders(
                                {StringConstant.bookingNo: widget.uniqueId!})
                        : getString(appStr.headingRaiseNewTicket,
                            'heading_raise_new_ticket'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingXL),

                // Category dropdown
                _buildCategoryDropdown(colors, state, viewModel),
                const SizedBox(height: AppDimens.padding),

                // Subject field
                AppTextField(
                  controller: _subjectController,
                  hintText: getString(appStr.hintSubject, 'hint_subject'),
                  onChanged: viewModel.updateSubject,
                ),
                const SizedBox(height: AppDimens.padding),

                // Message field
                AppTextField(
                  controller: _messageController,
                  hintText: getString(appStr.hintMessage, 'hint_message'),
                  maxLines: 4,
                  onChanged: viewModel.updateMessage,
                ),
                const SizedBox(height: AppDimens.padding),

                // Image picker
                _buildImagePicker(colors, state, viewModel),
                const SizedBox(height: AppDimens.paddingXL),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: AppOutlinedButton(
                        text: getString(appStr.buttonCancel, 'button_cancel'),
                        onPressed: () => context.goBack(),
                      ),
                    ),
                    const SizedBox(width: AppDimens.padding),
                    Expanded(
                      child: AppFilledButton(
                        text: getString(appStr.buttonSubmit, 'button_submit'),
                        onPressed: viewModel.submitTicket,
                        isLoading: state.isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(
    AppColorPalette colors,
    SupportTicketState state,
    SupportTicketViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding),
      decoration: BoxDecoration(
        border: Border.all(color: colors.colorText.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppDimens.textFieldRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: AppText.body(
            getString(appStr.descriptionSelectCategory,
                'description_select_category'),
            color: colors.colorTextHint,
          ),
          value: state.selectedCategory != null
              ? state.categoryList.indexOf(state.selectedCategory!)
              : null,
          icon: Icon(Icons.keyboard_arrow_down, color: colors.colorText),
          items: state.categoryNames.asMap().entries.map((entry) {
            return DropdownMenuItem<int>(
              value: entry.key,
              child: AppText.body(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) viewModel.selectCategory(value);
          },
        ),
      ),
    );
  }

  Widget _buildImagePicker(
    AppColorPalette colors,
    SupportTicketState state,
    SupportTicketViewModel viewModel,
  ) {
    if (state.ticketImage.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
            child: Image.file(
              File(state.ticketImage),
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => viewModel.setImage(''),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.colorBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: colors.colorText,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => _showImagePickerOptions(viewModel),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.colorText.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 32,
                color: colors.colorText,
              ),
              const SizedBox(height: AppDimens.paddingS),
              AppText.caption(
                getString(appStr.descriptionImage, 'description_image'),
                color: colors.colorText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showImagePickerOptions(SupportTicketViewModel viewModel) async {
    final source = await ImagePickerBottomSheet.show(context);
    if (source == null) return;

    final isCamera = source == ImagePickerSource.camera;
    final permissionResult = isCamera
        ? await PermissionManager.instance.requestCamera()
        : await PermissionManager.instance.requestPhotos();

    if (permissionResult != PermissionResult.granted) {
      if (mounted && permissionResult == PermissionResult.permanentlyDenied) {
        PermissionManager.instance.openSettings();
      }
      return;
    }

    final imageSource = isCamera ? ImageSource.camera : ImageSource.gallery;

    final pickedFile = await _imagePicker.pickImage(
      source: imageSource,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      viewModel.setImage(pickedFile.path);
    }
  }
}
