import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../data/api/server_config.dart';
import '../constants/socket_constants.dart';
import '../preferences/shared_preference_manager.dart';
import '../providers/app_providers.dart';

/// Callback type for socket events
typedef SocketEventCallback = void Function(dynamic data);

/// Callback type for socket acknowledgment
typedef SocketAckCallback = void Function(dynamic ackData);

/// Manages the socket connection and communication with the server.
///
/// Mirrors Kotlin SocketManager architecture.
class SocketManager {
  static const String _tag = 'SocketManager';

  static SocketManager? _instance;
  static SocketManager get instance => _instance ??= SocketManager._();

  SocketManager._();

  io.Socket? _socket;
  SharedPreferenceManager? _sharedPref;

  /// Initialize with shared preferences
  void init(SharedPreferenceManager sharedPref) {
    _sharedPref = sharedPref;
  }

  /// Creates and configures the socket instance
  io.Socket _createSocket() {
    final token = _sharedPref?.getAuthorization() ?? '';
    final url = ServerConfig.socketBaseUrl;

    debugPrint('$_tag: Creating socket --> URL: $url');
    debugPrint('$_tag: Token: ${token.isNotEmpty ? '${token.substring(0, token.length.clamp(0, 20))}...' : 'EMPTY'}');

    return io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({SocketConstants.authorization: token})
          .setAuth({SocketConstants.authorization: token})
          .setTimeout(10000)
          .build(),
    );
  }

  /// Connects the socket if it's not already connected and executes
  /// the provided action when connected.
  void connect({VoidCallback? onConnected}) {
    try {
      if (_socket == null || !_socket!.connected) {
        _socket = _createSocket();

        listenEvent('connect', (data) {
          debugPrint('$_tag: Socket Connected --> ${_socket!.id}');
          onConnected?.call();
        });

        listenEvent('connect_error', (data) {
          debugPrint('$_tag: --> Socket Connect Error');
        });

        listenEvent('disconnect', (data) {
          debugPrint('$_tag: --> Socket Disconnect');
        });

        listenAnyOutgoingEvent((data) {});
        listenAnyIncomingEvent((data) {});

        _socket!.connect();
      } else {
        onConnected?.call();
      }
    } catch (e) {
      debugPrint('$_tag: Exception --> $e');
    }
  }

  /// Checks if the socket is connected.
  bool isConnected() => _socket?.connected ?? false;

  /// Disconnects the socket if it's connected.
  void disconnect() {
    if (_socket?.connected ?? false) {
      _socket!.disconnect();
      debugPrint('$_tag: Manually disconnected');
    }
  }

  /// Disposes the socket completely.
  void dispose() {
    _socket?.dispose();
    _socket = null;
    debugPrint('$_tag: Disposed');
  }

  /// Emits an event with optional data and acknowledgment listener.
  ///
  /// Data is wrapped as `{"event": eventName, "data": data}` and sent as a
  /// JSON string — matching the iOS client's wire format which the server
  /// expects.
  void emitEvent(
    String eventName, {
    Map<String, dynamic>? data,
    SocketAckCallback? ackCallback,
  }) {
    try {
      final eventData = <String, dynamic>{
        SocketConstants.keyEvent: eventName,
        SocketConstants.keyData: data ?? <String, dynamic>{},
      };

      debugPrint('$_tag: Emit --> event: $eventName, data: $eventData');

      if (ackCallback != null) {
        _socket?.emitWithAck(eventName, eventData, ack: (ackData) {
          debugPrint(
            '$_tag: ackEvent --> eventName: $eventName, Data: $ackData',
          );
          final convertedData = _convertData(ackData);
          ackCallback(convertedData);
        });
      } else {
        _socket?.emit(eventName, eventData);
      }
    } catch (e) {
      debugPrint('$_tag: Emit Error --> $e');
    }
  }

  /// Listens for a specific event.
  void listenEvent(String eventName, SocketEventCallback listener) {
    _socket?.on(eventName, (data) {
      final convertedData = _convertData(data);
      listener(convertedData);
    });
  }

  /// Listens for a specific event once.
  void listenOnceEvent(String eventName, SocketEventCallback listener) {
    _socket?.once(eventName, (data) {
      final convertedData = _convertData(data);
      listener(convertedData);
    });
  }

  /// Listens for any incoming event.
  void listenAnyIncomingEvent(SocketEventCallback listener) {
    _socket?.onAny((event, data) {
      debugPrint('$_tag: listenAnyIncomingEvent --> $event, $data');
      final convertedData = _convertData(data);
      listener(convertedData);
    });
  }

  /// Listens for any outgoing event.
  ///
  /// Note: Dart socket_io_client does not support onAnyOutgoing.
  void listenAnyOutgoingEvent(SocketEventCallback listener) {
    // Not available in socket_io_client Dart package.
  }

  /// Removes the listener for the specified event.
  void offEvent(String eventName) {
    _socket?.off(eventName);
  }

  /// Removes all listeners for all events.
  void offAllEvents() {
    _socket?.clearListeners();
  }

  /// Removes listener for any incoming event.
  void offAnyIncomingEvent() {
    _socket?.offAny();
  }

  /// Removes listener for any outgoing event.
  void offAnyOutgoingEvent() {
    // Not available in socket_io_client Dart package.
  }

  // ── Data conversion (mirrors Kotlin convertData) ─────────────

  dynamic _convertData(dynamic args) {
    if (args == null) return null;

    try {
      if (args is List && args.isNotEmpty) {
        // Kotlin: if args.size == 2 → take args[1], put args[0] as event key
        //         if args.size == 1 → take args[0], extract "data" if present
        final data = args.length == 2 ? args[1] : args[0];
        return _parseJsonData(
          data,
          args.length == 2 ? args[0]?.toString() : null,
        );
      } else if (args is Map) {
        if (args.containsKey(SocketConstants.keyData)) {
          return args[SocketConstants.keyData];
        }
        return args;
      } else if (args is String) {
        return _tryParseJson(args);
      }
      return args;
    } catch (e) {
      debugPrint('$_tag: Convert Error --> $e');
      return args;
    }
  }

  dynamic _parseJsonData(dynamic data, String? eventName) {
    if (data is String) {
      try {
        final jsonObject = jsonDecode(data) as Map<String, dynamic>;
        if (eventName != null) {
          jsonObject[SocketConstants.keyEvent] = eventName;
        }
        if (jsonObject.containsKey(SocketConstants.keyData)) {
          return jsonObject[SocketConstants.keyData];
        }
        return jsonObject;
      } catch (e) {
        return data;
      }
    }
    if (data is Map && data.containsKey(SocketConstants.keyData)) {
      return data[SocketConstants.keyData];
    }
    return data;
  }

  dynamic _tryParseJson(String data) {
    try {
      return jsonDecode(data);
    } catch (e) {
      return data;
    }
  }
}

/// Provider for SocketManager
final socketManagerProvider = Provider<SocketManager>((ref) {
  final sharedPrefAsync = ref.watch(sharedPreferenceManagerProvider);

  sharedPrefAsync.whenData((sharedPref) {
    SocketManager.instance.init(sharedPref);
  });

  return SocketManager.instance;
});
