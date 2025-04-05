class NotificationModel {
  final String id;
  final String userId; // ID do usuário que receberá a notificação
  final String title; // Título da notificação
  final String message; // Mensagem da notificação
  final DateTime timestamp; // Data e hora da notificação
  final bool read; // Se a notificação foi lida
  final String type; // Tipo de notificação (mensagem, orçamento, projeto, etc)
  final String? sourceId; // ID da origem (mensagem, projeto, etc)
  final String? imageUrl; // URL da imagem (opcional)
  final Map<String, dynamic>? data; // Dados adicionais para navegação

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.read,
    required this.type,
    this.sourceId,
    this.imageUrl,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      read: json['read'] as bool,
      type: json['type'] as String,
      sourceId: json['sourceId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'type': type,
      'sourceId': sourceId,
      'imageUrl': imageUrl,
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? read,
    String? type,
    String? sourceId,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      type: type ?? this.type,
      sourceId: sourceId ?? this.sourceId,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
    );
  }
}