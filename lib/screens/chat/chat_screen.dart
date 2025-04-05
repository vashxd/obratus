import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverPhotoUrl;
  final String? projectId;

  const ChatScreen({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    this.receiverPhotoUrl,
    this.projectId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService();
  
  UserModel? _currentUser;
  String? _chatId;
  List<MessageModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initChat() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _currentUser = authProvider.userModel;

      if (_currentUser != null) {
        // Criar ou obter chat existente
        _chatId = await _messageService.createOrGetChat(
          _currentUser!.id,
          widget.receiverId,
          projectId: widget.projectId,
        );

        // Carregar mensagens
        await _loadMessages();

        // Marcar mensagens como lidas
        await _messageService.markMessagesAsRead(_chatId!, _currentUser!.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao inicializar chat: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Variável para armazenar a inscrição no stream de mensagens
  StreamSubscription? _messagesSubscription;

  Future<void> _loadMessages() async {
    try {
      if (_chatId != null) {
        // Cancelar inscrição anterior se existir
        _messagesSubscription?.cancel();
        
        // Inscrever-se no stream de mensagens
        _messagesSubscription = _messageService.getMessages(_chatId!).listen((messages) {
          setState(() {
            _messages = messages;
          });

          // Rolar para a última mensagem
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && _messages.isNotEmpty) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar mensagens: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatId == null || _currentUser == null) return;

    try {
      final message = MessageModel(
        id: '', // Será gerado pelo serviço
        chatId: _chatId!,
        senderId: _currentUser!.id,
        receiverId: widget.receiverId,
        text: text,
        timestamp: DateTime.now(),
        read: false,
        imageUrl: null,
      );

      await _messageService.sendMessage(message);
      _messageController.clear();
      // Não precisamos chamar _loadMessages() pois o Stream já atualiza automaticamente
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar mensagem: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              backgroundImage: widget.receiverPhotoUrl != null
                  ? NetworkImage(widget.receiverPhotoUrl!)
                  : null,
              child: widget.receiverPhotoUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
              radius: 16,
            ),
            const SizedBox(width: 8),
            Text(
              widget.receiverName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Lista de mensagens
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhuma mensagem ainda. Comece a conversar!',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isMe = message.senderId == _currentUser?.id;

                            return _buildMessageItem(message, isMe);
                          },
                        ),
                ),

                // Campo de entrada de mensagem
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  color: AppColors.cardBackground,
                  child: Row(
                    children: [
                      // Botão de anexar imagem (funcionalidade futura)
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: Colors.white),
                        onPressed: () {
                          // Implementação futura
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                          );
                        },
                      ),
                      // Campo de texto
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Digite sua mensagem...',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          minLines: 1,
                          maxLines: 4,
                        ),
                      ),
                      // Botão de enviar
                      IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageItem(MessageModel message, bool isMe) {
    final time = DateFormat('HH:mm').format(message.timestamp);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[  
            CircleAvatar(
              backgroundColor: AppColors.primary,
              backgroundImage: widget.receiverPhotoUrl != null
                  ? NetworkImage(widget.receiverPhotoUrl!)
                  : null,
              child: widget.receiverPhotoUrl == null
                  ? const Icon(Icons.person, color: Colors.white, size: 12)
                  : null,
              radius: 12,
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}