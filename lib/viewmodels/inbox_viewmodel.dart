import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';
import '../data/api/response_state.dart';
import '../data/repository/app_repository.dart';
import '../models/responses/notification/notification_response.dart';

/// Inbox screen state
class InboxState {
  final List<NotificationItem> notifications;
  final Map<String, List<NotificationItem>> groupedNotifications;
  final bool isLoading;
  final bool isLoadingMore;
  final bool endReached;
  final String? error;
  final int totalCount;

  const InboxState({
    this.notifications = const [],
    this.groupedNotifications = const {},
    this.isLoading = false,
    this.isLoadingMore = false,
    this.endReached = false,
    this.error,
    this.totalCount = 0,
  });

  InboxState copyWith({
    List<NotificationItem>? notifications,
    Map<String, List<NotificationItem>>? groupedNotifications,
    bool? isLoading,
    bool? isLoadingMore,
    bool? endReached,
    String? error,
    int? totalCount,
    bool clearError = false,
  }) {
    return InboxState(
      notifications: notifications ?? this.notifications,
      groupedNotifications:
          groupedNotifications ?? this.groupedNotifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      endReached: endReached ?? this.endReached,
      error: clearError ? null : (error ?? this.error),
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// Inbox screen ViewModel
class InboxViewModel extends StateNotifier<InboxState> {
  final AppRepository _appRepository;

  int _currentPage = 1;
  final int _limit = 10;
  bool _isFirstLoad = true;

  InboxViewModel(this._appRepository) : super(const InboxState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    if (_isFirstLoad) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    final deviceType = Platform.isAndroid ? DeviceType.android : DeviceType.ios;

    final response = await _appRepository.getNotifications(
      page: _currentPage,
      limit: _limit,
      deviceType: deviceType,
      userType: UserType.driver,
      notificationType: NotificationType.push,
    );

    switch (response) {
      case Success<NotificationResponse>():
        final newNotifications = response.data?.notifications ?? [];
        final totalCount = response.data?.dataCount ?? 0;

        if (newNotifications.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            endReached: true,
            totalCount: totalCount,
          );
        } else {
          final List<NotificationItem> allNotifications;
          if (_currentPage == 1) {
            allNotifications = newNotifications;
          } else {
            allNotifications = [...state.notifications, ...newNotifications];
          }

          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            notifications: allNotifications,
            groupedNotifications: _groupByDate(allNotifications),
            endReached: allNotifications.length >= totalCount,
            totalCount: totalCount,
          );
          _currentPage++;
        }
        _isFirstLoad = false;

      case Error():
        debugPrint('📬 InboxViewModel - Error: ${response.error?.message}');
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: response.error?.message ?? '',
        );
        _isFirstLoad = false;

      case Loading():
        break;
    }
  }

  void loadMore() {
    if (!state.isLoading && !state.isLoadingMore && !state.endReached) {
      loadNotifications();
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _isFirstLoad = true;
    state = state.copyWith(
      notifications: [],
      groupedNotifications: {},
      endReached: false,
    );
    await loadNotifications();
  }

  Map<String, List<NotificationItem>> _groupByDate(
      List<NotificationItem> notifications) {
    final Map<String, List<NotificationItem>> grouped = {};
    for (final item in notifications) {
      if (item.createdAt != null) {
        final dateKey = AppDateUtils.formatString(
          item.createdAt,
          DateFormat.dateFormatWithSpace,
        );
        if (dateKey.isNotEmpty) {
          grouped.putIfAbsent(dateKey, () => []);
          grouped[dateKey]!.add(item);
        }
      }
    }
    return grouped;
  }
}

/// Provider for InboxViewModel
final inboxViewModelProvider =
    StateNotifierProvider.autoDispose<InboxViewModel, InboxState>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  return InboxViewModel(appRepository);
});
