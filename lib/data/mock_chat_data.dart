import '../models/message_model.dart';
import 'package:uuid/uuid.dart';

/// Classe para fornecer dados mockados (simulados) para o chat
class MockChatData {
  static final Uuid _uuid = Uuid();
  
  /// Gera uma lista de conversas mockadas
  static List<ChatModel> getMockChats(String currentUserId) {
    final now = DateTime.now();
    
    return [
      ChatModel(
        id: '1',
        participants: [currentUserId, 'user1'],
        createdAt: now.subtract(const Duration(days: 5)),
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        lastMessageText: 'Quando você pode começar a obra?',
        lastMessageSenderId: 'user1',
        unreadCount: {currentUserId: 2, 'user1': 0},
        participantNames: {currentUserId: 'Você', 'user1': 'João Silva'},
        participantPhotos: {currentUserId: null, 'user1': null},
      ),
      ChatModel(
        id: '2',
        participants: [currentUserId, 'user2'],
        createdAt: now.subtract(const Duration(days: 3)),
        lastMessageTime: now.subtract(const Duration(days: 1)),
        lastMessageText: 'O orçamento ficou ótimo, vamos fechar!',
        lastMessageSenderId: currentUserId,
        unreadCount: {currentUserId: 0, 'user2': 1},
        participantNames: {currentUserId: 'Você', 'user2': 'Maria Pereira'},
        participantPhotos: {currentUserId: null, 'user2': null},
      ),
      ChatModel(
        id: '3',
        participants: [currentUserId, 'user3'],
        createdAt: now.subtract(const Duration(days: 10)),
        lastMessageTime: now.subtract(const Duration(hours: 12)),
        lastMessageText: 'Preciso de um pedreiro para reforma',
        lastMessageSenderId: 'user3',
        unreadCount: {currentUserId: 1, 'user3': 0},
        participantNames: {currentUserId: 'Você', 'user3': 'Carlos Mendes'},
        participantPhotos: {currentUserId: null, 'user3': null},
      ),
      ChatModel(
        id: '4',
        participants: [currentUserId, 'user4'],
        createdAt: now.subtract(const Duration(days: 7)),
        lastMessageTime: now.subtract(const Duration(hours: 36)),
        lastMessageText: 'Você tem disponibilidade na próxima semana?',
        lastMessageSenderId: currentUserId,
        unreadCount: {currentUserId: 0, 'user4': 1},
        participantNames: {currentUserId: 'Você', 'user4': 'Ana Oliveira'},
        participantPhotos: {currentUserId: null, 'user4': null},
      ),
    ];
  }
  
  /// Gera mensagens mockadas para um chat específico
  static List<MessageModel> getMockMessages(String chatId, String currentUserId) {
    final now = DateTime.now();
    String otherUserId;
    String otherUserName;
    
    switch (chatId) {
      case '1':
        otherUserId = 'user1';
        otherUserName = 'João Silva';
        break;
      case '2':
        otherUserId = 'user2';
        otherUserName = 'Maria Pereira';
        break;
      case '3':
        otherUserId = 'user3';
        otherUserName = 'Carlos Mendes';
        break;
      case '4':
        otherUserId = 'user4';
        otherUserName = 'Ana Oliveira';
        break;
      default:
        otherUserId = 'user1';
        otherUserName = 'João Silva';
    }
    
    return [
      MessageModel(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: otherUserId,
        receiverId: currentUserId,
        text: 'Olá, tudo bem?',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        read: true,
      ),
      MessageModel(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: currentUserId,
        receiverId: otherUserId,
        text: 'Tudo ótimo! Como posso ajudar?',
        timestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 45)),
        read: true,
      ),
      MessageModel(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: otherUserId,
        receiverId: currentUserId,
        text: 'Estou precisando de um orçamento para reforma da minha cozinha',
        timestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 30)),
        read: true,
      ),
      MessageModel(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: currentUserId,
        receiverId: otherUserId,
        text: 'Claro! Qual o tamanho aproximado da sua cozinha?',
        timestamp: now.subtract(const Duration(days: 1, hours: 1)),
        read: true,
      ),
      MessageModel(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: otherUserId,
        receiverId: currentUserId,
        text: 'Tem cerca de 12 metros quadrados',
        timestamp: now.subtract(const Duration(hours: 23)),
        read: true,
      ),
      MessageModel(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: currentUserId,
        receiverId: otherUserId,
        text: 'Perfeito. Você já tem alguma ideia do que quer fazer?',
        timestamp: now.subtract(const Duration(hours: 22)),
        read: true,
      ),
      MessageModel(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: otherUserId,
        receiverId: currentUserId,
        text: 'Quero trocar os armários e o piso',
        timestamp: now.subtract(const Duration(hours: 5)),
        read: true,
      ),
      MessageModel(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: otherUserId,
        receiverId: currentUserId,
        text: 'Quando você pode começar a obra?',
        timestamp: now.subtract(const Duration(hours: 2)),
        read: chatId != '1', // Não lida apenas para o chat 1
      ),
    ];
  }
}