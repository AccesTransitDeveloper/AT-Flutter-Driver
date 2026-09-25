import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/managers/permission_manager.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat/chat_models.dart';
import '../../../viewmodels/chat_viewmodel.dart';
import '../../../views/bottomsheets/image_picker_bottom_sheet.dart';
import '../../../views/widgets/app_scaffold.dart';
import '../../../views/widgets/app_text.dart';
import '../../../views/widgets/app_toolbar.dart';
import '../../item/sticky_date_header.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatConfig chatConfig;

  const ChatScreen({
    super.key,
    required this.chatConfig,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider.notifier).fetchMessages(widget.chatConfig);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final viewModel = ref.read(chatViewModelProvider.notifier);

    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 100) {
      viewModel.onFirstItemVisible();
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      viewModel.onLastItemVisible();
    }

    viewModel.onScroll();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<bool> _requestCameraPermission() async {
    final result = await PermissionManager.instance.requestCamera();
    switch (result) {
      case PermissionResult.granted:
        return true;
      case PermissionResult.permanentlyDenied:
      case PermissionResult.restricted:
        if (mounted) {
          PermissionManager.instance.openSettings();
        }
        return false;
      case PermissionResult.denied:
      case PermissionResult.limited:
        return false;
    }
  }

  Future<void> _pickImage(ImagePickerSource source) async {
    try {
      if (source == ImagePickerSource.camera) {
        final hasPermission = await _requestCameraPermission();
        if (!hasPermission || !mounted) return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source == ImagePickerSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (!mounted) return;

      if (image != null) {
        ref
            .read(chatViewModelProvider.notifier)
            .onChangeDocumentImage(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _onAttachPressed() async {
    final source = await ImagePickerBottomSheet.show(context);
    if (source != null && mounted) {
      _pickImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(chatViewModelProvider);
    final viewModel = ref.read(chatViewModelProvider.notifier);

    ref.listen<ChatState>(chatViewModelProvider, (previous, next) {
      if (next.isScrollToBottom && !previous!.isScrollToBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }

      if (next.isNavigateBack && !previous!.isNavigateBack) {
        context.goBack();
      }

      if (next.message != _messageController.text && next.message.isEmpty) {
        _messageController.clear();
      }
    });

    return AppScaffold(
        body: SafeArea(
          child: Column(
            children: [
              AppToolbar(
                title: widget.chatConfig.receiverName ??
                    getString(appStr.descriptionChat, 'description_chat'),
                showBackButton: true,
              ),
            Expanded(
              child: state.isLoading && state.finalChatMap.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.finalChatMap.isEmpty
                      ? Center(
                          child: AppText.body(
                            getString(appStr.descriptionNoMessagesYet,
                                'description_no_messages_yet'),
                            color: colors.colorText,
                          ),
                        )
                      : _ChatMessagesList(
                          scrollController: _scrollController,
                          groupedMessages: state.finalChatMap,
                          isLoadingMore: state.isLoading,
                          onImageTap: (imageUrl) {
                            context.navigateToImageViewer(imageUrl: imageUrl);
                          },
                        ),
            ),
            if (widget.chatConfig.canChat)
              _ChatInputField(
                controller: _messageController,
                onChanged: viewModel.onMessageChange,
                onSend: viewModel.onSendMessageClick,
                onAttach: _onAttachPressed,
                selectedImagePath: state.profileImage,
                onClearImage: () => viewModel.clearImage(),
              ),
          ],
        ),
      ),
    );
  }

}

class _ChatMessagesList extends StatelessWidget {
  final ScrollController scrollController;
  final Map<String, List<ChatMessage>> groupedMessages;
  final bool isLoadingMore;
  final Function(String) onImageTap;

  const _ChatMessagesList({
    required this.scrollController,
    required this.groupedMessages,
    required this.isLoadingMore,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final entries = groupedMessages.entries.toList();

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimens.padding),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        for (final entry in entries)
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyDateHeaderDelegate(
                  date: entry.key,
                  colors: colors,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final message = entry.value[index];
                    return _ChatMessageBubble(
                      message: message,
                      onImageTap: onImageTap,
                    );
                  },
                  childCount: entry.value.length,
                ),
              ),
            ],
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppDimens.paddingS),
        ),
      ],
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onImageTap;

  const _ChatMessageBubble({
    required this.message,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSender = message.isSender;
    final isImage = message.messageType == AttachmentsType.image;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding,
        vertical: AppDimens.paddingXS,
      ),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            _buildAvatar(colors),
            const SizedBox(width: AppDimens.paddingS),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: isImage
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingM,
                          vertical: AppDimens.paddingS,
                        ),
                  decoration: BoxDecoration(
                    color: isSender
                        ? colors.colorPrimary
                        : colors.colorBackgroundGray,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppDimens.paddingM),
                      topRight: const Radius.circular(AppDimens.paddingM),
                      bottomLeft: Radius.circular(
                          isSender ? AppDimens.paddingM : AppDimens.paddingXS),
                      bottomRight: Radius.circular(
                          isSender ? AppDimens.paddingXS : AppDimens.paddingM),
                    ),
                  ),
                  child: isImage
                      ? _buildImageMessage(colors)
                      : _buildTextMessage(colors, isSender),
                ),
                const SizedBox(height: AppDimens.paddingXS),
                AppText.caption(
                  message.dateTime ?? '',
                  color: colors.colorText.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ],
            ),
          ),
          if (isSender) ...[
            const SizedBox(width: AppDimens.paddingS),
            _buildAvatar(colors),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(AppColorPalette colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: message.image != null && message.image!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: message.image!,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              placeholder: (context, url) => _defaultAvatar(colors),
              errorWidget: (context, url, error) => _defaultAvatar(colors),
            )
          : _defaultAvatar(colors),
    );
  }

  Widget _defaultAvatar(AppColorPalette colors) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: colors.colorBackgroundGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.person,
        size: 20,
        color: colors.colorText,
      ),
    );
  }

  Widget _buildTextMessage(AppColorPalette colors, bool isSender) {
    return AppText.body(
      message.message ?? '',
      color: isSender ? colors.colorSelectedText : colors.colorText,
    );
  }

  Widget _buildImageMessage(AppColorPalette colors) {
    return GestureDetector(
      onTap: () {
        if (message.message != null && message.message!.isNotEmpty) {
          onImageTap(message.message!);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.paddingM),
        child: CachedNetworkImage(
          imageUrl: message.message ?? '',
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 200,
            height: 200,
            color: colors.colorBackgroundGray,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 200,
            color: colors.colorBackgroundGray,
            child: Icon(
              Icons.broken_image,
              color: colors.colorText,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final String? selectedImagePath;
  final VoidCallback onClearImage;

  const _ChatInputField({
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.onAttach,
    required this.selectedImagePath,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasImage = selectedImagePath != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: colors.colorBackgroundGray),
        if (hasImage)
          Container(
            color: colors.colorBackground,
            padding: const EdgeInsets.fromLTRB(
              AppDimens.padding,
              AppDimens.paddingS,
              AppDimens.padding,
              0,
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimens.paddingS),
                      child: Image.file(
                        File(selectedImagePath!),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: onClearImage,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: colors.colorText,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: colors.colorBackground,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingS,
              vertical: AppDimens.paddingS,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onAttach,
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      color: colors.colorBackgroundGray,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: colors.colorText,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingS),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: colors.colorBackgroundGray,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: getString(
                            appStr.hintMessage, 'hint_type_message'),
                        hintStyle: TextStyle(
                          color: colors.colorText.withValues(alpha: 0.5),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding,
                          vertical: AppDimens.paddingS,
                        ),
                      ),
                      style: TextStyle(
                        color: colors.colorText,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingS),
                GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      color: colors.colorPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasImage ? Icons.image : Icons.arrow_upward,
                      color: colors.colorSelectedText,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
