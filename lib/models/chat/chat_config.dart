/// Configuration for chat screen
class ChatConfig {
  final String? chatType;
  final String? chatId;
  final String? referenceId;
  final String? receiverImage;
  final String? receiverName;
  final bool canChat;

  const ChatConfig({
    this.chatType,
    this.chatId,
    this.referenceId,
    this.receiverImage,
    this.receiverName,
    this.canChat = true,
  });

  factory ChatConfig.fromJson(Map<String, dynamic> json) {
    return ChatConfig(
      chatType: json['chatType'] as String?,
      chatId: json['chatId'] as String?,
      referenceId: json['referenceId'] as String?,
      receiverImage: json['receiverImage'] as String?,
      receiverName: json['receiverName'] as String?,
      canChat: json['canChat'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'chatType': chatType,
        'chatId': chatId,
        'referenceId': referenceId,
        'receiverImage': receiverImage,
        'receiverName': receiverName,
        'canChat': canChat,
      };
}
