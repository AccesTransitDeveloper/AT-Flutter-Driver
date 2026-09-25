import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/socket_constants.dart';
import '../core/managers/socket_manager.dart';
import '../models/responses/common/webview_dismiss_response.dart';
import '../models/webview_data_model.dart';

/// WebView screen state
class WebViewState {
  final bool isLoading;
  final WebViewDataModel? webViewData;
  final String? webViewMessage;
  final bool isNavigateToBackScreen;
  final bool isPaymentDone;
  final String snackBarMessage;

  const WebViewState({
    this.isLoading = true,
    this.webViewData,
    this.webViewMessage,
    this.isNavigateToBackScreen = false,
    this.isPaymentDone = false,
    this.snackBarMessage = '',
  });

  WebViewState copyWith({
    bool? isLoading,
    WebViewDataModel? webViewData,
    String? webViewMessage,
    bool? isNavigateToBackScreen,
    bool? isPaymentDone,
    String? snackBarMessage,
  }) {
    return WebViewState(
      isLoading: isLoading ?? this.isLoading,
      webViewData: webViewData ?? this.webViewData,
      webViewMessage: webViewMessage ?? this.webViewMessage,
      isNavigateToBackScreen:
          isNavigateToBackScreen ?? this.isNavigateToBackScreen,
      isPaymentDone: isPaymentDone ?? this.isPaymentDone,
      snackBarMessage: snackBarMessage ?? this.snackBarMessage,
    );
  }
}

/// WebView screen ViewModel
class WebViewViewModel extends StateNotifier<WebViewState> {
  final SocketManager _socketManager;

  WebViewViewModel(this._socketManager) : super(const WebViewState()) {
    _socketForPaymentBackstack();
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Set web view data
  void setWebViewData(WebViewDataModel? webViewData) {
    state = state.copyWith(webViewData: webViewData);
  }

  /// Handle web view message from JavaScript interface
  void onWebViewMessage(String? message) {
    debugPrint('WebViewMessage: $message');
    state = state.copyWith(
      webViewMessage: message,
      isNavigateToBackScreen: !state.isNavigateToBackScreen,
    );
  }

  /// Show snack bar message
  void showSnackBar(String message) {
    state = state.copyWith(snackBarMessage: message);
    _dismissSnackBar();
  }

  /// Dismiss snack bar after delay
  void _dismissSnackBar() {
    Future.delayed(const Duration(seconds: 1), () {
      state = state.copyWith(snackBarMessage: '');
    });
  }

  /// Listen for socket event to dismiss webview
  void _socketForPaymentBackstack() {
    debugPrint('SocketCalled: Socket Called 0');

    _socketManager.listenEvent(
      SocketConstants.eventDismissWebview,
      (data) {
        debugPrint('SocketCalled: DISMISS_WEBVIEW received - $data');
        try {
          final jsonData = data is String ? jsonDecode(data) : data;
          if (jsonData is Map<String, dynamic>) {
            WebViewDismissResponse.fromJson(jsonData);
          }
        } catch (e) {
          debugPrint('Error parsing WebViewDismissResponse: $e');
        }
        state = state.copyWith(isPaymentDone: true);
      },
    );
  }

  @override
  void dispose() {
    _socketManager.offEvent(SocketConstants.eventDismissWebview);
    super.dispose();
  }
}

/// Provider for WebViewViewModel
final webViewViewModelProvider =
    StateNotifierProvider.autoDispose<WebViewViewModel, WebViewState>((ref) {
  final socketManager = ref.watch(socketManagerProvider);
  return WebViewViewModel(socketManager);
});
