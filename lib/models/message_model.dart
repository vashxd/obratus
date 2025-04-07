class MessageModel {
  final String id;
  final String chatId; // ID da conversa
  final String senderId; // ID do usuário que enviou a mensagem
  final String receiverId; // ID do usuário que recebeu a mensagem
  final String text; // Conteúdo da mensagem
  final DateTime timestamp; // Data e hora da mensagem
  final bool read; // Se a mensagem foi lida
  final String? imageUrl; // Caminho da imagem local (opcional)

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    required this.read,
    this.imageUrl,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      read: json['read'] as bool,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'imageUrl': imageUrl,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    bool? read,
    String? imageUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// Add this to your ChatModel class:

class ChatModel {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final DateTime lastMessageTime;
  final String lastMessageText;
  final String lastMessageSenderId;
  final Map<String, int> unreadCount;
  final String? projectId;
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final bool notified; // Add this field

  ChatModel({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.lastMessageTime,
    this.lastMessageText = '',
    this.lastMessageSenderId = '',
    required this.unreadCount,
    this.projectId,
    required this.participantNames,
    required this.participantPhotos,
    this.notified = false, // Default value
  });

  // Update the copyWith method
  ChatModel copyWith({
    String? id,
    List<String>? participants,
    DateTime? createdAt,
    DateTime? lastMessageTime,
    String? lastMessageText,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    String? projectId,
    Map<String, String>? participantNames,
    Map<String, String?>? participantPhotos,
    bool? notified,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      projectId: projectId ?? this.projectId,
      participantNames: participantNames ?? this.participantNames,
      participantPhotos: participantPhotos ?? this.participantPhotos,
      notified: notified ?? this.notified,
    );
  }

  // Update the fromJson method
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      participants: List<String>.from(json['participants']),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastMessageTime: DateTime.parse(json['lastMessageTime'] ?? DateTime.now().toIso8601String()),
      lastMessageText: json['lastMessageText'] ?? '',
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      unreadCount: Map<String, int>.from(json['unreadCount'] ?? {}),
      projectId: json['projectId'],
      participantNames: Map<String, String>.from(json['participantNames'] ?? {}),
      participantPhotos: Map<String, String?>.from(json['participantPhotos'] ?? {}),
      notified: json['notified'] ?? false,
    );
  }

  // Update the toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessageText': lastMessageText,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'projectId': projectId,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'notified': notified,
    };
  }
}