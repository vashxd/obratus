import '../models/message_model.dart';
import 'local_storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class MessageService {
  final LocalStorageService _storage = LocalStorageService();
  final Uuid _uuid = Uuid();

  // Criar ou obter chat entre dois usuários
  Future<String> createOrGetChat(String userId1, String userId2, {String? projectId}) async {
    try {
      // Ordenar os IDs para garantir consistência
      final List<String> participants = [userId1, userId2];
      participants.sort();

      final chatsBox = _storage.getBox(LocalStorageService.chatsBoxName);
      
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
      rethrow;
    }
  }

  // Enviar mensagem
  Future<String> sendMessage(MessageModel message) async {
    try {
      final messagesBox = _storage.getBox(LocalStorageService.messagesBoxName);
      final chatsBox = _storage.getBox(LocalStorageService.chatsBoxName);
      
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
      rethrow;
    }
  }

  // Marcar mensagens como lidas
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final chatsBox = _storage.getBox(LocalStorageService.chatsBoxName);
      final messagesBox = _storage.getBox(LocalStorageService.messagesBoxName);

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
      final messages = messagesBox.values.where((msg) =>
        msg['chatId'] == chatId &&
        msg['receiverId'] == userId &&
        msg['read'] == false
      ).toList();

      for (var msg in messages) {
        msg['read'] = true;
        await messagesBox.put(msg['id'], msg);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obter mensagens de um chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    try {
      final messagesBox = _storage.getBox(LocalStorageService.messagesBoxName);
      
      // Criar um stream que emite uma nova lista quando há mudanças
      return messagesBox.watch().map((event) {
        final messages = messagesBox.values
            .where((msg) => msg['chatId'] == chatId)
            .map((msg) => MessageModel.fromJson(Map<String, dynamic>.from(msg)))
            .toList();
        
        // Ordenar por timestamp
        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return messages;
      });
    } catch (e) {
      debugPrint('Erro ao obter mensagens: $e');
      return Stream.value([]);
    }
  }

  // Obter chats de um usuário
  Stream<List<ChatModel>> getUserChats(String userId) {
    try {
      final chatsBox = _storage.getBox(LocalStorageService.chatsBoxName);
      
      // Criar um stream que emite uma nova lista quando há mudanças
      return chatsBox.watch().map((event) {
        final chats = chatsBox.values
            .where((chat) {
              final participants = List<String>.from(chat['participants']);
              return participants.contains(userId);
            })
            .map((chat) => ChatModel.fromJson(Map<String, dynamic>.from(chat)))
            .toList();
        
        // Ordenar por timestamp da última mensagem
        chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        return chats;
      });
    } catch (e) {
      debugPrint('Erro ao obter chats do usuário: $e');
      return Stream.value([]);
    }
  }

  // Obter número total de mensagens não lidas para um usuário
  Future<int> getTotalUnreadMessages(String userId) async {
    try {
      final chatsBox = _storage.getBox(LocalStorageService.chatsBoxName);
      
      int total = 0;
      for (var key in chatsBox.keys) {
        final chat = chatsBox.get(key);
        if (chat == null) continue;
        
        final participants = List<String>.from(chat['participants']);
        
        if (participants.contains(userId)) {
          final unreadCount = Map<String, dynamic>.from(chat['unreadCount']);
          total += (unreadCount[userId] as int?) ?? 0;
        }
      }

      return total;
    } catch (e) {
      rethrow;
    }
  }

  // Enviar mensagem com imagem
  Future<String> sendImageMessage(String chatId, String senderId, String receiverId, String imageUrl) async {
    try {
      final now = DateTime.now();
      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        text: '[Imagem]',
        timestamp: now,
        read: false,
        imageUrl: imageUrl,
      );

      return await sendMessage(message);
    } catch (e) {
      rethrow;
    }
  }

  // Excluir mensagem
  Future<void> deleteMessage(String messageId) async {
    try {
      final messagesBox = _storage.getBox(LocalStorageService.messagesBoxName);
      await messagesBox.delete(messageId);
    } catch (e) {
      rethrow;
    }
  }
}