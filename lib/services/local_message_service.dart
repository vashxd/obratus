import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import 'local_storage_service.dart';

/// Serviço responsável por gerenciar mensagens localmente
class LocalMessageService {
  final LocalStorageService _storageService = LocalStorageService();
  final Uuid _uuid = Uuid();
  
  // Criar ou obter chat entre dois usuários
  Future<String> createOrGetChat(String userId1, String userId2, {String? projectId}) async {
    try {
      // Ordenar os IDs para garantir consistência
      final List<String> participants = [userId1, userId2];
      participants.sort();
      
      final chatsBox = _storageService.getBox(LocalStorageService.chatsBoxName);
      
      // Verificar se já existe um chat entre esses usuários
      String? existingChatId;
      
      for (var key in chatsBox.keys) {
        final chat = chatsBox.get(key);
        final List<String> chatParticipants = List<String>.from(chat['participants']);
        
        if (chatParticipants.length == participants.length && 
            chatParticipants.every((p) => participants.contains(p))) {
          existingChatId = chat['id'];
          break;
        }
      }
      
      // Se já existe um chat, retornar o ID
      if (existingChatId != null) {
        return existingChatId;
      }
      
      // Caso contrário, criar um novo chat
      final chatId = _uuid.v4();
      final now = DateTime.now();
      
      final chat = ChatModel(
        id: chatId,
        participants: participants,
        createdAt: now,
        lastMessageTime: now,
        lastMessageText: '',
        lastMessageSenderId: '',
        unreadCount: {userId1: 0, userId2: 0},
        projectId: projectId,
      );
      
      await chatsBox.put(chatId, chat.toJson());
      return chatId;
    } catch (e) {
      debugPrint('Erro ao criar ou obter chat: $e');
      rethrow;
    }
  }
  
  // Enviar mensagem
  Future<String> sendMessage(MessageModel message) async {
    try {
      final messagesBox = _storageService.getBox(LocalStorageService.messagesBoxName);
      final chatsBox = _storageService.getBox(LocalStorageService.chatsBoxName);
      
      // Criar a mensagem
      final messageId = _uuid.v4();
      final newMessage = message.copyWith(id: messageId);
      
      await messagesBox.put(messageId, newMessage.toJson());
      
      // Atualizar informações do chat
      final chat = chatsBox.get(message.chatId);
      if (chat != null) {
        final Map<String, dynamic> chatData = Map<String, dynamic>.from(chat);
        final Map<String, dynamic> unreadCount = Map<String, dynamic>.from(chatData['unreadCount']);
        
        // Incrementar contador de mensagens não lidas
        unreadCount[message.receiverId] = (unreadCount[message.receiverId] ?? 0) + 1;
        
        chatData['lastMessageTime'] = message.timestamp.toIso8601String();
        chatData['lastMessageText'] = message.text;
        chatData['lastMessageSenderId'] = message.senderId;
        chatData['unreadCount'] = unreadCount;
        
        await chatsBox.put(message.chatId, chatData);
      }
      
      return messageId;
    } catch (e) {
      debugPrint('Erro ao enviar mensagem: $e');
      rethrow;
    }
  }
  
  // Marcar mensagens como lidas
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final messagesBox = _storageService.getBox(LocalStorageService.messagesBoxName);
      final chatsBox = _storageService.getBox(LocalStorageService.chatsBoxName);
      
      // Atualizar o contador de mensagens não lidas
      final chat = chatsBox.get(chatId);
      if (chat != null) {
        final Map<String, dynamic> chatData = Map<String, dynamic>.from(chat);
        final Map<String, dynamic> unreadCount = Map<String, dynamic>.from(chatData['unreadCount']);
        
        unreadCount[userId] = 0;
        chatData['unreadCount'] = unreadCount;
        
        await chatsBox.put(chatId, chatData);
      }
      
      // Marcar todas as mensagens não lidas como lidas
      for (var key in messagesBox.keys) {
        final message = messagesBox.get(key);
        
        if (message['chatId'] == chatId && 
            message['receiverId'] == userId && 
            message['read'] == false) {
          message['read'] = true;
          await messagesBox.put(key, message);
        }
      }
    } catch (e) {
      debugPrint('Erro ao marcar mensagens como lidas: $e');
      rethrow;
    }
  }
  
  // Obter mensagens de um chat
  List<MessageModel> getMessages(String chatId) {
    try {
      final messagesBox = _storageService.getBox(LocalStorageService.messagesBoxName);
      final List<MessageModel> messages = [];
      
      for (var key in messagesBox.keys) {
        final message = messagesBox.get(key);
        
        if (message['chatId'] == chatId) {
          messages.add(MessageModel.fromJson(Map<String, dynamic>.from(message)));
        }
      }
      
      // Ordenar mensagens por timestamp (mais recentes por último)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      return messages;
    } catch (e) {
      debugPrint('Erro ao obter mensagens: $e');
      return [];
    }
  }
  
  // Obter chats de um usuário
  List<ChatModel> getUserChats(String userId) {
    try {
      final chatsBox = _storageService.getBox(LocalStorageService.chatsBoxName);
      final List<ChatModel> chats = [];
      
      for (var key in chatsBox.keys) {
        final chat = chatsBox.get(key);
        final List<String> participants = List<String>.from(chat['participants']);
        
        if (participants.contains(userId)) {
          chats.add(ChatModel.fromJson(Map<String, dynamic>.from(chat)));
        }
      }
      
      // Ordenar chats por hora da última mensagem (mais recentes primeiro)
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      
      return chats;
    } catch (e) {
      debugPrint('Erro ao obter chats do usuário: $e');
      return [];
    }
  }
  
  // Excluir mensagem
  Future<void> deleteMessage(String messageId) async {
    try {
      final messagesBox = _storageService.getBox(LocalStorageService.messagesBoxName);
      await messagesBox.delete(messageId);
    } catch (e) {
      debugPrint('Erro ao excluir mensagem: $e');
      rethrow;
    }
  }
  
  // Excluir chat
  Future<void> deleteChat(String chatId) async {
    try {
      final chatsBox = _storageService.getBox(LocalStorageService.chatsBoxName);
      final messagesBox = _storageService.getBox(LocalStorageService.messagesBoxName);
      
      // Excluir chat
      await chatsBox.delete(chatId);
      
      // Excluir todas as mensagens do chat
      for (var key in messagesBox.keys) {
        final message = messagesBox.get(key);
        
        if (message['chatId'] == chatId) {
          await messagesBox.delete(key);
        }
      }
    } catch (e) {
      debugPrint('Erro ao excluir chat: $e');
      rethrow;
    }
  }
}