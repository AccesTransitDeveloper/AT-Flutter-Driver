import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_constants.dart';
import '../core/localization/app_strings.dart';
import '../core/localization/string_constants.dart';
import '../core/preferences/shared_preference_manager.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/date_utils.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/responses/support/support_ticket_response.dart';

/// UI model for a support ticket list item
class SupportTicketItem {
  final SupportTicket? supportTicket;
  final String ticketTitle;
  final String dateTimeStr;
  final String dateStr;
  final String? status;

  SupportTicketItem({
    this.supportTicket,
    this.ticketTitle = '',
    this.dateTimeStr = '',
    this.dateStr = '',
    this.status,
  });
}

/// Contact Us screen state
class ContactUsState {
  final bool isLoading;
  final bool isDataLoading;
  final String? error;
  final Map<String, List<SupportTicketItem>> supportTicketMap;
  final bool showSupportTicketBottomSheet;
  final String? contactEmail;
  final String? contactPhone;

  const ContactUsState({
    this.isLoading = false,
    this.isDataLoading = false,
    this.error,
    this.supportTicketMap = const {},
    this.showSupportTicketBottomSheet = false,
    this.contactEmail,
    this.contactPhone,
  });

  ContactUsState copyWith({
    bool? isLoading,
    bool? isDataLoading,
    String? error,
    Map<String, List<SupportTicketItem>>? supportTicketMap,
    bool? showSupportTicketBottomSheet,
    String? contactEmail,
    String? contactPhone,
    bool clearError = false,
  }) {
    return ContactUsState(
      isLoading: isLoading ?? this.isLoading,
      isDataLoading: isDataLoading ?? this.isDataLoading,
      error: clearError ? null : (error ?? this.error),
      supportTicketMap: supportTicketMap ?? this.supportTicketMap,
      showSupportTicketBottomSheet:
          showSupportTicketBottomSheet ?? this.showSupportTicketBottomSheet,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }
}

class ContactUsViewModel extends StateNotifier<ContactUsState> {
  final AppRepository _appRepository;
  final SharedPreferenceManager _sharedPref;
  bool _isFirstLoad = true;

  ContactUsViewModel(this._appRepository, this._sharedPref)
      : super(const ContactUsState()) {
    _loadContactDetails();
    getSupportTicketHistory();
  }

  void _loadContactDetails() {
    final setting = _sharedPref.getSetting();
    state = state.copyWith(
      contactEmail: setting?.contactDetail?.email,
      contactPhone: setting?.contactDetail?.phone,
    );
  }

  Future<void> getSupportTicketHistory() async {
    if (_isFirstLoad) {
      state = state.copyWith(isDataLoading: true);
    }
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _appRepository.getSupportTicketHistory();

    switch (response) {
      case Success<SupportTicketHistoryResponse>():
        _isFirstLoad = false;
        state = state.copyWith(
          isLoading: false,
          isDataLoading: false,
          supportTicketMap:
              _createSupportTicketMap(response.data?.supportTickets),
        );
      case Error():
        state = state.copyWith(
          isLoading: false,
          isDataLoading: false,
          error: response.error?.message ?? '',
        );
      case Loading():
        break;
    }
  }

  Map<String, List<SupportTicketItem>> _createSupportTicketMap(
      List<SupportTicket>? list) {
    if (list == null || list.isEmpty) return {};

    final items = list.map((ticket) {
      return SupportTicketItem(
        supportTicket: ticket,
        ticketTitle: _getTicketTitle(ticket),
        dateTimeStr: AppDateUtils.formatString(
            ticket.createdAt, DateFormat.dateMonthHourMinuteFormat),
        dateStr: AppDateUtils.formatString(
            ticket.createdAt, DateFormat.dateFormatWithSpace),
        status: ticket.status,
      );
    }).toList();

    // Sort by createdAt descending
    items.sort((a, b) {
      final dateA = a.supportTicket?.createdAt ?? '';
      final dateB = b.supportTicket?.createdAt ?? '';
      return dateB.compareTo(dateA);
    });

    // Group by date key
    final map = <String, List<SupportTicketItem>>{};
    for (final item in items) {
      final key = item.dateStr;
      if (map.containsKey(key)) {
        map[key]!.add(item);
      } else {
        map[key] = [item];
      }
    }
    return map;
  }

  String _getTicketTitle(SupportTicket ticket) {
    if (ticket.bookingUniqueId?.isNotEmpty == true) {
      return getString(appStr.descriptionBookingId, 'description_booking_id')
          .replacePlaceholders({
        StringConstant.bookingNo: ticket.bookingUniqueId ?? '',
      });
    }
    return getString(
            appStr.descriptionSupportTicketId, 'description_support_ticket_id')
        .replacePlaceholders({
      StringConstant.supportId: ticket.uniqueId ?? ticket.id ?? '',
    });
  }

  void showNewTicketSheet() =>
      state = state.copyWith(showSupportTicketBottomSheet: true);

  void hideNewTicketSheet() =>
      state = state.copyWith(showSupportTicketBottomSheet: false);

  Future<void> sendEmail() async {
    final email = state.contactEmail;
    if (email != null && email.isNotEmpty) {
      try {
        await launchUrl(Uri.parse('mailto:$email'),
            mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  Future<void> makeCall() async {
    final phone = state.contactPhone;
    if (phone != null && phone.isNotEmpty) {
      try {
        await launchUrl(Uri.parse('tel:$phone'),
            mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  Future<void> refresh() => getSupportTicketHistory();

  void clearError() => state = state.copyWith(clearError: true);
}

final contactUsViewModelProvider =
    StateNotifierProvider.autoDispose<ContactUsViewModel, ContactUsState>((ref) {
  final repo = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => throw Exception('SharedPreferences not initialized'),
      );
  return ContactUsViewModel(repo, sharedPref);
});
