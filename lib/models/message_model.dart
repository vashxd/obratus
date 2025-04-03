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

class ChatModel {
  final String id;
  final List<String> participants; // IDs dos participantes
  final DateTime createdAt; // Data de criação do chat
  final DateTime lastMessageTime; // Hora da última mensagem
  final String lastMessageText; // Texto da última mensagem
  final String lastMessageSenderId; // ID de quem enviou a última mensagem
  final Map<String, int> unreadCount; // Contagem de mensagens não lidas por usuário
  final String? projectId; // ID do projeto relacionado (opcional)

  ChatModel({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.lastMessageTime,
    required this.lastMessageText,
    required this.lastMessageSenderId,
    required this.unreadCount,
    this.projectId,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      participants: List<String>.from(json['participants'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      lastMessageText: json['lastMessageText'] as String,
      lastMessageSenderId: json['lastMessageSenderId'] as String,
      unreadCount: Map<String, int>.from(json['unreadCount'] as Map),
      projectId: json['projectId'] as String?,
    );
  }

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
    };
  }

  ChatModel copyWith({
    String? id,
    List<String>? participants,
    DateTime? createdAt,
    DateTime? lastMessageTime,
    String? lastMessageText,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    String? projectId,
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
    );
  }
}