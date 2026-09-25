import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/requests/support_ticket_request.dart';
import 'contact_us_viewmodel.dart';

class TicketDetailState {
  final bool isLoading;
  final String? error;
  final SupportTicketItem? ticket;
  final bool shouldNavigateBack;

  const TicketDetailState({
    this.isLoading = false,
    this.error,
    this.ticket,
    this.shouldNavigateBack = false,
  });

  TicketDetailState copyWith({
    bool? isLoading,
    String? error,
    SupportTicketItem? ticket,
    bool? shouldNavigateBack,
    bool clearError = false,
  }) {
    return TicketDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      ticket: ticket ?? this.ticket,
      shouldNavigateBack: shouldNavigateBack ?? this.shouldNavigateBack,
    );
  }
}

class TicketDetailViewModel extends StateNotifier<TicketDetailState> {
  final AppRepository _appRepository;

  TicketDetailViewModel(this._appRepository) : super(const TicketDetailState());

  void setTicket(SupportTicketItem ticket) =>
      state = state.copyWith(ticket: ticket);

  Future<void> toggleTicketStatus() async {
    final currentStatus = state.ticket?.status;
    if (currentStatus == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    final newStatus = currentStatus == SupportTicketStatus.closed
        ? SupportTicketStatus.reopen
        : SupportTicketStatus.closed;

    final response = await _appRepository.updateTicketStatus(
      ticketId: state.ticket?.supportTicket?.id ?? '',
      request: TicketStatusRequest(status: newStatus),
    );

    switch (response) {
      case Success():
        state = state.copyWith(isLoading: false, shouldNavigateBack: true);
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message ?? '',
        );
      case Loading():
        break;
    }
  }

  void resetNavigateBack() => state = state.copyWith(shouldNavigateBack: false);

  void clearError() => state = state.copyWith(clearError: true);
}

final ticketDetailViewModelProvider =
    StateNotifierProvider.autoDispose<TicketDetailViewModel,
        TicketDetailState>((ref) {
  return TicketDetailViewModel(ref.watch(appRepositoryProvider));
});
