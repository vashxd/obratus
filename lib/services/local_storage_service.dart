import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Serviço responsável por gerenciar o armazenamento local usando Hive
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  final Uuid _uuid = Uuid();
  
  // Nomes das boxes do Hive
  static const String usersBoxName = 'users';
  static const String messagesBoxName = 'messages';
  static const String chatsBoxName = 'chats';
  static const String projectsBoxName = 'projects';
  static const String professionalsBoxName = 'professionals';
  static const String reviewsBoxName = 'reviews';
  static const String imagesBoxName = 'images';
  static const String materialsBoxName = 'materials';
  static const String notificationsBoxName = 'notifications'; // Adicionando box de notificações
  
  // Singleton pattern
  factory LocalStorageService() {
    return _instance;
  }
  
  LocalStorageService._internal();
  
  /// Inicializa o Hive e abre as boxes necessárias
  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    
    // Abrir as boxes
    await Hive.openBox(usersBoxName);
    await Hive.openBox(messagesBoxName);
    await Hive.openBox(chatsBoxName);
    await Hive.openBox(projectsBoxName);
    await Hive.openBox(professionalsBoxName);
    await Hive.openBox(reviewsBoxName);
    await Hive.openBox(imagesBoxName);
    await Hive.openBox(materialsBoxName);
    await Hive.openBox(notificationsBoxName); // Abrindo a box de notificações
  }
  
  /// Obtém uma box do Hive pelo nome
  Box getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      // Se a box não estiver aberta, lança uma exceção
      // A box deve ser aberta de forma assíncrona antes de chamar este método
      throw Exception('Box $boxName não está aberta. Use openBox antes de getBox.');
    }
    return Hive.box(boxName);
  }
  
  /// Abre uma box do Hive de forma assíncrona
  Future<Box> openBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      try {
        return await Hive.openBox(boxName);
      } catch (e) {
        print('Erro ao abrir a box $boxName: $e');
        rethrow;
      }
    }
    return Hive.box(boxName);
  }
  
  /// Salva uma mensagem na box de mensagens
  Future<String> saveMessage(Map<String, dynamic> message) async {
    try {
      final String messageId = message['id'] ?? _uuid.v4();
      message['id'] = messageId;
      
      final messagesBox = await openBox(messagesBoxName);
      await messagesBox.put(messageId, message);
      
      // Atualiza o chat relacionado
      if (message['chatId'] != null) {
        await updateChatLastMessage(message['chatId'], messageId);
      }
      
      return messageId;
    } catch (e) {
      print('Erro ao salvar mensagem: $e');
      rethrow;
    }
  }
  
  /// Atualiza o último ID de mensagem em um chat
  Future<void> updateChatLastMessage(String chatId, String messageId) async {
    try {
      final chatsBox = await openBox(chatsBoxName);
      final chat = chatsBox.get(chatId);
      
      if (chat != null) {
        chat['lastMessageId'] = messageId;
        chat['updatedAt'] = DateTime.now().toIso8601String();
        await chatsBox.put(chatId, chat);
      }
    } catch (e) {
      print('Erro ao atualizar chat: $e');
      rethrow;
    }
  }
  
  /// Obtém todas as mensagens de um chat
  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    try {
      final messagesBox = await openBox(messagesBoxName);
      final List<Map<String, dynamic>> chatMessages = [];
      
      for (var key in messagesBox.keys) {
        final message = Map<String, dynamic>.from(messagesBox.get(key));
        if (message['chatId'] == chatId) {
          chatMessages.add(message);
        }
      }
      
      // Ordenar por data de criação
      chatMessages.sort((a, b) {
        final aDate = DateTime.parse(a['createdAt'] ?? DateTime.now().toIso8601String());
        final bDate = DateTime.parse(b['createdAt'] ?? DateTime.now().toIso8601String());
        return aDate.compareTo(bDate);
      });
      
      return chatMessages;
    } catch (e) {
      print('Erro ao obter mensagens do chat: $e');
      return [];
    }
  }
  
  /// Salva um arquivo localmente e retorna o caminho
  Future<String> saveFile(File file, String directory) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final storageDir = Directory('${appDocDir.path}/$directory');
      
      // Criar diretório se não existir
      if (!await storageDir.exists()) {
        await storageDir.create(recursive: true);
      }
      
      // Gerar nome único para o arquivo
      final fileName = '${_uuid.v4()}${path.extension(file.path)}';
      final filePath = '${storageDir.path}/$fileName';
      
      // Copiar arquivo para o diretório de armazenamento
      await file.copy(filePath);
      
      return filePath;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Exclui um arquivo pelo caminho
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Salva uma notificação de mensagem
  Future<String> saveNotification(Map<String, dynamic> notification) async {
    try {
      final String notificationId = notification['id'] ?? _uuid.v4();
      notification['id'] = notificationId;
      
      final notificationsBox = await openBox(notificationsBoxName);
      await notificationsBox.put(notificationId, notification);
      
      return notificationId;
    } catch (e) {
      print('Erro ao salvar notificação: $e');
      rethrow;
    }
  }
  
  /// Obtém todas as notificações de um usuário
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final notificationsBox = await openBox(notificationsBoxName);
      final List<Map<String, dynamic>> userNotifications = [];
      
      for (var key in notificationsBox.keys) {
        final notification = Map<String, dynamic>.from(notificationsBox.get(key));
        if (notification['userId'] == userId) {
          userNotifications.add(notification);
        }
      }
      
      // Ordenar por data de criação (mais recentes primeiro)
      userNotifications.sort((a, b) {
        final aDate = DateTime.parse(a['createdAt'] ?? DateTime.now().toIso8601String());
        final bDate = DateTime.parse(b['createdAt'] ?? DateTime.now().toIso8601String());
        return bDate.compareTo(aDate);
      });
      
      return userNotifications;
    } catch (e) {
      print('Erro ao obter notificações do usuário: $e');
      return [];
    }
  }
  
  /// Marca uma notificação como lida
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final notificationsBox = await openBox(notificationsBoxName);
      final notification = notificationsBox.get(notificationId);
      
      if (notification != null) {
        notification['isRead'] = true;
        await notificationsBox.put(notificationId, notification);
      }
    } catch (e) {
      print('Erro ao marcar notificação como lida: $e');
      rethrow;
    }
  }
  
  /// Limpa todos os dados armazenados
  Future<void> clearAllData() async {
    await Hive.box(usersBoxName).clear();
    await Hive.box(messagesBoxName).clear();
    await Hive.box(chatsBoxName).clear();
    await Hive.box(projectsBoxName).clear();
    await Hive.box(professionalsBoxName).clear();
    await Hive.box(reviewsBoxName).clear();
    await Hive.box(imagesBoxName).clear();
    await Hive.box(materialsBoxName).clear();
    await Hive.box(notificationsBoxName).clear(); // Adicionando limpeza da box de notificações
  }
}