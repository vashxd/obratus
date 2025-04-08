import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/message_service.dart';
import '../../data/mock_chat_data.dart';
import 'chat_screen.dart';
import '../home/client_home_screen.dart';
import '../home/professional_home_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final MessageService _messageService = MessageService();
  bool _isLoading = true;
  List<ChatModel> _chats = [];
  String? _userId;
  StreamSubscription? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }
  
  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _userId = authProvider.userId;

      if (_userId != null) {
        // Cancelar assinatura anterior se existir (não necessário para dados mockados)
        _messagesSubscription?.cancel();
        
        // Simular um pequeno atraso para mostrar o carregamento
        await Future.delayed(const Duration(milliseconds: 800));
        
        if (mounted) {
          setState(() {
            // Carregar chats mockados
            _chats = MockChatData.getMockChats(_userId!);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar conversas: $e')),
        );
      }
    }
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
        title: const Text(
          'Conversas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _chats.isEmpty
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
                        'Nenhuma conversa ainda',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicie uma conversa com um profissional ou cliente',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    final chat = _chats[index];
                    final otherUserId = chat.participants.firstWhere(
                      (id) => id != _userId,
                      orElse: () => '',
                    );
                    
                    // Obter informações do outro usuário (nome, foto, etc.)
                    final otherUserName = chat.participantNames[otherUserId] ?? 'Usuário';
                    final otherUserPhotoUrl = chat.participantPhotos[otherUserId];
                    
                    // Verificar se há mensagens não lidas
                    final unreadCount = chat.unreadCount[_userId] ?? 0;
                    
                    return Card(
                      color: AppColors.cardBackground,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          backgroundImage: otherUserPhotoUrl != null
                              ? NetworkImage(otherUserPhotoUrl)
                              : null,
                          child: otherUserPhotoUrl == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          otherUserName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          chat.lastMessageText ?? 'Iniciar conversa',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: unreadCount > 0
                            ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Text(
                                chat.lastMessageTime != null
                                    ? _formatTime(chat.lastMessageTime!)
                                    : '',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                receiverId: otherUserId,
                                receiverName: otherUserName,
                                receiverPhotoUrl: otherUserPhotoUrl,
                                projectId: chat.projectId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: _buildBottomNavigationBar(context, userId),
    );
  }
  
  // Construir a barra de navegação inferior
  Widget _buildBottomNavigationBar(BuildContext context, String? userId) {
    if (userId == null) {
      return _buildSimpleBottomNavigationBar(context);
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
              // Já estamos na tela de chat, não fazer nada
              // Recarregar a lista de chats para garantir que as mensagens sejam exibidas
              _loadChats();
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
  Widget _buildSimpleBottomNavigationBar(BuildContext context) {
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
          // Já estamos na tela de chat, não fazer nada
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'agora';
    }
  }
}