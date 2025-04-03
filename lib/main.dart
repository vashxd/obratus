import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/auth_provider.dart' as app_provider;
import 'screens/auth/login_screen.dart';
import 'screens/home/user_type_screen.dart';
import 'screens/home/client_home_screen.dart';
import 'screens/home/professional_home_screen.dart';
import 'screens/materials/material_list_screen.dart';
import 'screens/materials/client_quotes_screen.dart';
import 'screens/materials/professional_quotes_screen.dart';
import 'constants/app_theme.dart';
import 'services/local_storage_service.dart';
import 'services/local_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        },
      ),
    );
  }
}
