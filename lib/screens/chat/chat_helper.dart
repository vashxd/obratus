import 'package:flutter/material.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../services/message_service.dart';
import 'chat_screen.dart';

/// Classe auxiliar para gerenciar a inicialização de chats entre usuários
class ChatHelper {
  static final MessageService _messageService = MessageService();

  /// Inicia ou abre um chat existente entre dois usuários
  /// 
  /// [context] - Contexto atual para navegação
  /// [currentUser] - Usuário atual (cliente ou profissional)
  /// [receiverId] - ID do usuário com quem se deseja conversar
  /// [receiverName] - Nome do usuário com quem se deseja conversar
  /// [receiverPhotoUrl] - URL da foto do usuário com quem se deseja conversar (opcional)
  /// [projectId] - ID do projeto relacionado (opcional)
  static Future<void> startChat({
    required BuildContext context,
    required UserModel currentUser,
    required String receiverId,
    required String receiverName,
    String? receiverPhotoUrl,
    String? projectId,
  }) async {
    try {
      // Mostrar indicador de carregamento
      final scaffold = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      
      // Criar ou obter chat existente
      final chatId = await _messageService.createOrGetChat(
        currentUser.id,
        receiverId,
        projectId: projectId,
      );
      
      // Navegar para a tela de chat
      navigator.push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            receiverId: receiverId,
            receiverName: receiverName,
            receiverPhotoUrl: receiverPhotoUrl,
            projectId: projectId,
          ),
        ),
      );
    } catch (e) {
      // Mostrar mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar chat: $e')),
      );
    }
  }
}