/// Chat message model for display in UI
class ChatMessage {
  final String? id;
  final String? image;
  final String? message;
  final bool isSender;
  final String? dateTime;
  final String? createdAt;
  final String? messageType;

  const ChatMessage({
    this.id,
    this.image,
    this.message,
    this.isSender = false,
    this.dateTime,
    this.createdAt,
    this.messageType,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String?,
      image: json['image'] as String?,
      message: json['message'] as String?,
      isSender: json['isSender'] as bool? ?? false,
      dateTime: json['dateTime'] as String?,
      createdAt: json['createdAt'] as String?,
      messageType: json['messageType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'message': message,
        'isSender': isSender,
        'dateTime': dateTime,
        'createdAt': createdAt,
        'messageType': messageType,
      };
}

/// Attachment types for chat messages
class AttachmentsType {
  static const String text = 'TEXT';
  static const String image = 'IMAGE';
}
