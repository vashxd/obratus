import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'providers/auth_provider.dart' as app_provider;
import 'screens/auth/login_screen.dart';
import 'screens/home/user_type_screen.dart';
import 'screens/home/client_home_screen.dart';
import 'screens/home/professional_home_screen.dart';
import 'screens/materials/material_list_screen.dart';
import 'screens/materials/client_quotes_screen.dart';
import 'screens/materials/professional_quotes_screen.dart';
import 'screens/professionals/professional_specialties_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'constants/app_theme.dart';
import 'services/local_storage_service.dart';
import 'services/local_auth_service.dart';
import 'utils/timestamp_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Registrar o adaptador para o tipo Timestamp
  Hive.registerAdapter(TimestampAdapter());
  
  // Inicializar o armazenamento local com Hive
  final storageService = LocalStorageService();
  await storageService.init();
  
  // Criar um usuário de teste no armazenamento local
  final authService = LocalAuthService();
  await authService.createTestUser();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_provider.AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Obratus',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const LoginScreen(),
          '/user_type': (context) => const UserTypeScreen(),
          '/client_home': (context) => const ClientHomeScreen(),
          '/professional_home': (context) => const ProfessionalHomeScreen(),
          '/material_list': (context) => const MaterialListScreen(),
          '/client_quotes': (context) => const ClientQuotesScreen(),
          '/professional_quotes': (context) => const ProfessionalQuotesScreen(),
          '/professionals': (context) => const ProfessionalSpecialtiesScreen(),
          '/chat': (context) => const ChatListScreen(),
          '/notifications': (context) => const NotificationsScreen(),
        },
        onGenerateRoute: (settings) {
          // Manipular rotas dinâmicas
          if (settings.name == '/chat_detail') {
            // Extrair os argumentos da rota
            final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
            final String receiverId = args['receiverId'];
            final String receiverName = args['receiverName'] ?? 'Usuário';
            final String? receiverPhotoUrl = args['receiverPhotoUrl'];
            final String? projectId = args['projectId'];
            
            return MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiverId: receiverId,
                receiverName: receiverName,
                receiverPhotoUrl: receiverPhotoUrl,
                projectId: projectId,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
