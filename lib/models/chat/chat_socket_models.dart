import 'dart:convert';

/// Request to join a chat room
class SocketJoinChatRequest {
  final String? referenceId;
  final String? chatType;

  const SocketJoinChatRequest({
    this.referenceId,
    this.chatType,
  });

  Map<String, dynamic> toJson() => {
        'referenceId': referenceId,
        'chatType': chatType,
      };

  String toJsonString() => jsonEncode(toJson());
}

/// Response when joining a chat room
class SocketJoinChatResponse {
  final String? chatId;
  final int? unreadMessageCount;

  const SocketJoinChatResponse({
    this.chatId,
    this.unreadMessageCount,
  });

  factory SocketJoinChatResponse.fromJson(Map<String, dynamic> json) {
    return SocketJoinChatResponse(
      chatId: json['chatId'] as String?,
      unreadMessageCount: json['unreadMessageCount'] as int?,
    );
  }
}

/// Request to fetch chat messages
class SocketChatMessageFetchRequest {
  final String? chatId;
  final int? uniqueId;

  const SocketChatMessageFetchRequest({
    this.chatId,
    this.uniqueId,
  });

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'uniqueId': uniqueId,
      };

  String toJsonString() => jsonEncode(toJson());
}

/// Response containing fetched chat messages
class SocketChatMessageFetchResponse {
  final String? chatId;
  final List<Message>? messages;

  const SocketChatMessageFetchResponse({
    this.chatId,
    this.messages,
  });

  factory SocketChatMessageFetchResponse.fromJson(Map<String, dynamic> json) {
    return SocketChatMessageFetchResponse(
      chatId: json['chatId'] as String?,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Request to send a chat message
class SocketChatMessageRequest {
  final String? chatId;
  final String? message;
  final String? referenceId;
  final String? chatType;

  const SocketChatMessageRequest({
    this.chatId,
    this.message,
    this.referenceId,
    this.chatType,
  });

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'message': message,
        'referenceId': referenceId,
        'chatType': chatType,
      };

  String toJsonString() => jsonEncode(toJson());
}

/// Response when receiving a chat message
class SocketChatMessageResponse {
  final String? chatId;
  final String? referenceId;
  final String? chatType;
  final Message? message;
  final List<UnreadCount>? unreadCounts;
  final bool? success;

  const SocketChatMessageResponse({
    this.chatId,
    this.referenceId,
    this.chatType,
    this.message,
    this.unreadCounts,
    this.success,
  });

  factory SocketChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return SocketChatMessageResponse(
      chatId: json['chatId'] as String?,
      referenceId: json['referenceId'] as String?,
      chatType: json['chatType'] as String?,
      message: json['message'] != null
          ? Message.fromJson(json['message'] as Map<String, dynamic>)
          : null,
      unreadCounts: (json['unreadCounts'] as List<dynamic>?)
          ?.map((e) => UnreadCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      success: json['success'] as bool?,
    );
  }
}

/// Request to mark messages as read
class SocketChatMessageReadRequest {
  final String? chatId;

  const SocketChatMessageReadRequest({
    this.chatId,
  });

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
      };

  String toJsonString() => jsonEncode(toJson());
}

/// Individual message in chat
class Message {
  final String? typeId;
  final int? type;
  final int? uniqueId;
  final String? message;
  final int? timestamp;
  final bool? isEdited;
  final List<Reaction>? reactions;
  final List<ReadBy>? readBy;
  final bool? isAllRead;
  final bool? isMessageDeleted;
  final String? createdAt;
  final String? updatedAt;
  final String? messageType;

  const Message({
    this.typeId,
    this.type,
    this.uniqueId,
    this.message,
    this.timestamp,
    this.isEdited,
    this.reactions,
    this.readBy,
    this.isAllRead,
    this.isMessageDeleted,
    this.createdAt,
    this.updatedAt,
    this.messageType,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      typeId: json['typeId'] as String?,
      type: json['type'] as int?,
      uniqueId: json['uniqueId'] as int?,
      message: json['message'] as String?,
      timestamp: json['timestamp'] as int?,
      isEdited: json['isEdited'] as bool?,
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => Reaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      readBy: (json['readBy'] as List<dynamic>?)
          ?.map((e) => ReadBy.fromJson(e as Map<String, dynamic>))
          .toList(),
      isAllRead: json['isAllRead'] as bool?,
      isMessageDeleted: json['isMessageDeleted'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      messageType: json['messageType'] as String?,
    );
  }
}

/// Reaction on a message
class Reaction {
  final String? typeId;
  final int? type;
  final String? reaction;
  final int? timestamp;

  const Reaction({
    this.typeId,
    this.type,
    this.reaction,
    this.timestamp,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      typeId: json['typeId'] as String?,
      type: json['type'] as int?,
      reaction: json['reaction'] as String?,
      timestamp: json['timestamp'] as int?,
    );
  }
}

/// Read by information
class ReadBy {
  final String? typeId;
  final int? type;

  const ReadBy({
    this.typeId,
    this.type,
  });

  factory ReadBy.fromJson(Map<String, dynamic> json) {
    return ReadBy(
      typeId: json['typeId'] as String?,
      type: json['type'] as int?,
    );
  }
}

/// Unread count information
class UnreadCount {
  final int? type;
  final int? unreadCount;

  const UnreadCount({
    this.type,
    this.unreadCount,
  });

  factory UnreadCount.fromJson(Map<String, dynamic> json) {
    return UnreadCount(
      type: json['type'] as int?,
      unreadCount: json['unreadCount'] as int?,
    );
  }
}
