import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import 'local_storage_service.dart';

class NotificationService {
  final LocalStorageService _storage = LocalStorageService();
  final Uuid _uuid = Uuid();
  
  // Nome da caixa de armazenamento para notificações
  static const String notificationsBoxName = 'notifications';

  // Criar uma nova notificação
  Future<String> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? sourceId,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationsBox = _storage.getBox(notificationsBoxName);
      
      // Criar a notificação
      final notificationId = _uuid.v4();
      final now = DateTime.now();
      
      final notification = NotificationModel(
        id: notificationId,
        userId: userId,
        title: title,
        message: message,
        timestamp: now,
        read: false,
        type: type,
        sourceId: sourceId,
        imageUrl: imageUrl,
      );

      await notificationsBox.put(notificationId, notification.toJson());
      return notificationId;
    } catch (e) {
      debugPrint('Erro ao criar notificação: $e');
      rethrow;
    }
  }

  // Marcar uma notificação como lida
  Future<void> markAsRead(String notificationId) async {
    try {
      final notificationsBox = _storage.getBox(notificationsBoxName);
      
      final notification = notificationsBox.get(notificationId);
      if (notification != null) {
        notification['read'] = true;
        await notificationsBox.put(notificationId, notification);
      }
    } catch (e) {
      debugPrint('Erro ao marcar notificação como lida: $e');
      rethrow;
    }
  }

  // Marcar todas as notificações de um usuário como lidas
  Future<void> markAllAsRead(String userId) async {
    try {
      final notificationsBox = _storage.getBox(notificationsBoxName);
      
      final notifications = notificationsBox.values.where(
        (notification) => notification['userId'] == userId && notification['read'] == false
      ).toList();

      for (var notification in notifications) {
        notification['read'] = true;
        await notificationsBox.put(notification['id'], notification);
      }
    } catch (e) {
      debugPrint('Erro ao marcar todas notificações como lidas: $e');
      rethrow;
    }
  }

  // Obter todas as notificações de um usuário
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    try {
      final notificationsBox = _storage.getBox(notificationsBoxName);
      
      // Criar um stream que emite uma nova lista quando há mudanças
      return notificationsBox.watch().map((event) {
        final notifications = notificationsBox.values
            .where((notification) => notification['userId'] == userId)
            .map((notification) => NotificationModel.fromJson(Map<String, dynamic>.from(notification)))
            .toList();
        
        // Ordenar por timestamp (mais recentes primeiro)
        notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return notifications;
      });
    } catch (e) {
      debugPrint('Erro ao obter notificações do usuário: $e');
      return Stream.value([]);
    }
  }

  // Contar notificações não lidas de um usuário
  Stream<int> getUnreadCount(String userId) {
    try {
      final notificationsBox = _storage.getBox(notificationsBoxName);
      
      // Criar um stream que emite um novo contador quando há mudanças
      return notificationsBox.watch().map((event) {
        final count = notificationsBox.values
            .where((notification) => 
                notification['userId'] == userId && 
                notification['read'] == false)
            .length;
        
        return count;
      });
    } catch (e) {
      debugPrint('Erro ao contar notificações não lidas: $e');
      return Stream.value(0);
    }
  }

  // Excluir uma notificação
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notificationsBox = _storage.getBox(notificationsBoxName);
      await notificationsBox.delete(notificationId);
    } catch (e) {
      debugPrint('Erro ao excluir notificação: $e');
      rethrow;
    }
  }

  // Excluir todas as notificações de um usuário
  Future<void> deleteAllUserNotifications(String userId) async {
    try {
      final notificationsBox = _storage.getBox(notificationsBoxName);
      
      final notifications = notificationsBox.values
          .where((notification) => notification['userId'] == userId)
          .toList();

      for (var notification in notifications) {
        await notificationsBox.delete(notification['id']);
      }
    } catch (e) {
      debugPrint('Erro ao excluir todas as notificações: $e');
      rethrow;
    }
  }

  // Criar notificação para nova mensagem
  Future<String> createMessageNotification({
    required String userId,
    required String senderName,
    required String messageText,
    required String chatId,
    String? senderPhotoUrl,
  }) async {
    final title = 'Nova mensagem de $senderName';
    final message = messageText.length > 50 
        ? '${messageText.substring(0, 47)}...'
        : messageText;
    
    return createNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'message',
      sourceId: chatId,
      imageUrl: senderPhotoUrl,
    );
  }

  // Criar notificação para novo projeto
  Future<String> createProjectNotification({
    required String userId,
    required String projectTitle,
    required String projectId,
    String? imageUrl,
  }) async {
    return createNotification(
      userId: userId,
      title: 'Novo projeto',
      message: 'O projeto "$projectTitle" foi criado',
      type: 'project',
      sourceId: projectId,
      imageUrl: imageUrl,
    );
  }

  // Criar notificação para novo orçamento
  Future<String> createQuoteNotification({
    required String userId,
    required String professionalName,
    required String projectTitle,
    required String projectId,
    String? professionalPhotoUrl,
  }) async {
    return createNotification(
      userId: userId,
      title: 'Novo orçamento',
      message: '$professionalName enviou um orçamento para "$projectTitle"',
      type: 'quote',
      sourceId: projectId,
      imageUrl: professionalPhotoUrl,
    );
  }
}