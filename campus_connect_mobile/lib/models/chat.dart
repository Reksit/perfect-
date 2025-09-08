class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String messageType;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.messageType = 'text',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      recipientId: json['recipientId'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
      messageType: json['messageType'] ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'messageType': messageType,
    };
  }
}

class Conversation {
  final String id;
  final String participantId;
  final String participantName;
  final String participantRole;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;

  Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantRole,
    this.lastMessage,
    this.unreadCount = 0,
    required this.lastActivity,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      participantId: json['participantId'] ?? '',
      participantName: json['participantName'] ?? '',
      participantRole: json['participantRole'] ?? '',
      lastMessage: json['lastMessage'] != null 
          ? ChatMessage.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      lastActivity: DateTime.parse(json['lastActivity'] ?? DateTime.now().toIso8601String()),
    );
  }
}
