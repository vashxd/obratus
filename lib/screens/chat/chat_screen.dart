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
import '../../data/mock_chat_data.dart';
import 'chat_list_screen.dart';

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

        // Carregar mensagens com timeout para evitar carregamento infinito
        bool messagesLoaded = false;
        
        // Iniciar carregamento de mensagens
        _loadMessages().then((_) {
          messagesLoaded = true;
        });
        
        // Definir timeout
        Future.delayed(const Duration(seconds: 5), () {
          if (!messagesLoaded && mounted) {
            setState(() {
              _isLoading = false;
              _messages = []; // Definir lista vazia
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tempo esgotado ao carregar mensagens. Tente novamente.')),
            );
          }
        });

        // Marcar mensagens como lidas
        await _messageService.markMessagesAsRead(_chatId!, _currentUser!.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao inicializar chat: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Variável para armazenar a inscrição no stream de mensagens
  StreamSubscription? _messagesSubscription;

  Future<void> _loadMessages() async {
    try {
      if (_chatId != null && _currentUser != null) {
        // Usar dados mockados em vez de carregar do serviço real
        await Future.delayed(const Duration(milliseconds: 800)); // Simular carregamento
        
        // Obter mensagens mockadas para este chat
        final messages = MockChatData.getMockMessages(_chatId!, _currentUser!.id);
        
        if (mounted) {
          setState(() {
            _messages = messages;
            _isLoading = false;
          });
          
          // Rolar para a última mensagem após carregar
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_messages.isNotEmpty && _scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar mensagens: $e')),
        );
      }
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

  Future<String?> _getProjectName(String projectId) async {
    // Implementation to fetch project name
    // This would typically call a service to get the project details
    return 'Project Name'; // Placeholder
  }

  void _showClearChatConfirmation() {
    // Show confirmation dialog for clearing chat
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Limpar conversa?', style: TextStyle(color: Colors.white)),
        content: const Text('Todas as mensagens serão excluídas permanentemente.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement clear chat functionality
            },
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String? userId = authProvider.userId;
    
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.projectId != null)
                    FutureBuilder<String?>(
                      future: _getProjectName(widget.projectId!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Text(
                            'Projeto: ${snapshot.data}',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Opções adicionais do chat
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.cardBackground,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Limpar conversa', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        _showClearChatConfirmation();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Lista de mensagens
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma mensagem ainda',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Envie uma mensagem para iniciar a conversa',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final bool isMe = message.senderId == _currentUser?.id;
                            
                            return _buildMessageItem(message, isMe);
                          },
                        ),
                ),

                // Campo de entrada de mensagem
                _buildMessageInput(),
              ],
            ),
      bottomNavigationBar: _buildBottomNavigationBar(userId),
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
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
    );
  }
  
  // Construir a barra de navegação inferior
  Widget _buildBottomNavigationBar(String? userId) {
    if (userId == null) {
      return _buildSimpleBottomNavigationBar();
    }
    
    return StreamBuilder<List<ChatModel>>(
      stream: _messageService.getUserChats(userId),
      builder: (context, snapshot) {
        // Calcular total de mensagens não lidas
        int unreadCount = 0;
        if (snapshot.hasData) {
          for (var chat in snapshot.data!) {
            unreadCount += chat.unreadCount[userId] ?? 0;
          }
        }
        
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          currentIndex: 1, // Índice 1 corresponde ao chat
          onTap: (index) {
            if (index == 0) {
              // Botão de início - redirecionar para a tela inicial
              Navigator.pushReplacementNamed(context, '/user_type');
            } else if (index == 1) {
              // Navegar para a lista de chats
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatListScreen(),
                ),
              );
            } else if (index == 2) {
              // Navegar para a tela de notificações
              Navigator.pushNamed(context, '/notifications');
            } else if (index == 3) {
              // Fale conosco - implementação futura
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
              );
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: _buildBadgeIcon(Icons.chat, unreadCount),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notificações',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail),
              label: 'Fale Conosco',
            ),
          ],
        );
      },
    );
  }
  
  // Versão simples da barra de navegação sem indicadores
  Widget _buildSimpleBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      currentIndex: 1, // Índice 1 corresponde ao chat
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/user_type');
        } else if (index == 1) {
          // Navegar para a lista de chats
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatListScreen(),
            ),
          );
        } else if (index == 2) {
          Navigator.pushNamed(context, '/notifications');
        } else if (index == 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
          );
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notificações',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mail),
          label: 'Fale Conosco',
        ),
      ],
    );
  }
  
  // Construir ícone com badge de notificação
  Widget _buildBadgeIcon(IconData icon, int count) {
    if (count <= 0) {
      return Icon(icon);
    }
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          top: -5,
          right: -5,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              count > 9 ? '9+' : count.toString(),
              style: TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
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