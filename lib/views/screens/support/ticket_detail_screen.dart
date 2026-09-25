import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/support_ticket_utils.dart';
import '../../../data/api/server_config.dart';
import '../../../models/chat/chat_config.dart';
import '../../../viewmodels/contact_us_viewmodel.dart';
import '../../../viewmodels/ticket_detail_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final SupportTicketItem ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  ConsumerState<TicketDetailScreen> createState() =>
      _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(ticketDetailViewModelProvider.notifier)
          .setTicket(widget.ticket);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(ticketDetailViewModelProvider);
    final viewModel = ref.read(ticketDetailViewModelProvider.notifier);

    final ticket = state.ticket ?? widget.ticket;
    final supportTicket = ticket.supportTicket;
    final statusColor =
        SupportTicketUtils.getStatusColor(ticket.status ?? '');
    final statusText =
        SupportTicketUtils.getStatusText(ticket.status ?? '');
    final isClosed = ticket.status == SupportTicketStatus.closed;

    ref.listen<TicketDetailState>(ticketDetailViewModelProvider,
        (previous, next) {
      if (next.error != null && previous?.error == null) {
        context.showErrorSnackBar(next.error!);
        viewModel.clearError();
      }
      if (next.shouldNavigateBack && !(previous?.shouldNavigateBack ?? false)) {
        viewModel.resetNavigateBack();
        context.goBack(true);
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(
                  appStr.headingTicketDetail, 'heading_ticket_detail'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ticket header card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimens.padding),
                      decoration: BoxDecoration(
                        color: colors.colorBackgroundGray,
                        borderRadius:
                            BorderRadius.circular(AppDimens.buttonRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppText.title(
                                  ticket.ticketTitle,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: AppDimens.paddingS),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimens.paddingS,
                                  vertical: AppDimens.paddingXS,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                      AppDimens.buttonRadiusSmall),
                                ),
                                child: AppText.caption(
                                  statusText,
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.paddingS),
                          AppText.caption(
                            ticket.dateTimeStr,
                            color: colors.colorText,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimens.paddingXL),

                    // Subject
                    AppText.caption(
                      getString(appStr.hintSubject, 'hint_subject'),
                      color: colors.colorText,
                    ),
                    const SizedBox(height: AppDimens.paddingS),
                    AppText.body(
                      supportTicket?.subject ?? '',
                      fontWeight: FontWeight.w500,
                    ),

                    const SizedBox(height: AppDimens.paddingXL),

                    // Description
                    AppText.caption(
                      getString(appStr.hintMessage, 'hint_message'),
                      color: colors.colorText,
                    ),
                    const SizedBox(height: AppDimens.paddingS),
                    AppText.body(
                      supportTicket?.description ?? '',
                    ),

                    // Image
                    if (supportTicket?.imageUrl != null &&
                        supportTicket!.imageUrl!.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.paddingXL),
                      AppText.caption(
                        getString(
                            appStr.descriptionImage, 'description_image'),
                        color: colors.colorText,
                      ),
                      const SizedBox(height: AppDimens.paddingS),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimens.buttonRadius),
                        child: CachedNetworkImage(
                          imageUrl: ServerConfig.getFullImageUrl(
                              supportTicket.imageUrl),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: colors.colorBackgroundGray,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: colors.colorBackgroundGray,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: colors.colorText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppFilledButton(
                    text: getString(
                            appStr.headingChatWithAppName,
                            'heading_chat_with_app_name')
                        .replacePlaceholders({
                      StringConstant.appName:
                          getString(appStr.appName, 'app_name'),
                    }),
                    onPressed: () {
                      context.navigateToChat(
                        chatConfig: ChatConfig(
                          chatType: 'SUPPORT_CHAT',
                          referenceId: supportTicket?.id,
                          receiverName: getString(
                                  appStr.headingChatWithAppName,
                                  'heading_chat_with_app_name')
                              .replacePlaceholders({
                            StringConstant.appName:
                                getString(appStr.appName, 'app_name'),
                          }),
                          canChat:
                              ticket.status == SupportTicketStatus.open ||
                                  ticket.status == SupportTicketStatus.reopen,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimens.paddingM),
                  AppFilledButton(
                    text: isClosed
                        ? getString(appStr.buttonReopenTicket,
                            'button_reopen_ticket')
                        : getString(appStr.buttonCloseTicket,
                            'button_close_ticket'),
                    onPressed: viewModel.toggleTicketStatus,
                    isLoading: state.isLoading,
                    backgroundColor:
                        isClosed ? colors.colorPrimary : colors.colorWarning,
                    textColor: colors.colorBackground,
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
