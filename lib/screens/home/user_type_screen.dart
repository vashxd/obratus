import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'client_home_screen.dart';
import 'professional_home_screen.dart';

class UserTypeScreen extends StatefulWidget {
  const UserTypeScreen({Key? key}) : super(key: key);

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              SizedBox(
                height: 100,
                width: 100,
                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              // Nome do app
              const Text(
                'OBRATUS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'CONECTANDO SUA OBRA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              // Título
              const Text(
                'Como você deseja utilizar o aplicativo?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Opção Cliente
              _buildOptionCard(
                context,
                title: 'Cliente',
                description: 'Buscar profissionais e materiais para sua obra',
                icon: Icons.person,
                onTap: () async {
                  // Atualizar perfil para cliente se necessário
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final user = authProvider.userModel;
                  
                  if (user != null && !user.isClient) {
                    // Atualizar para cliente
                    final updatedUser = user.copyWith(isClient: true);
                    await authProvider.updateUserProfile(updatedUser);
                  }
                  
                  // Navegar para a tela de cliente
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ClientHomeScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // Opção Profissional
              _buildOptionCard(
                context,
                title: 'Profissional',
                description: 'Oferecer seus serviços e encontrar novos clientes',
                icon: Icons.work,
                onTap: () async {
                  // Atualizar perfil para profissional se necessário
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final user = authProvider.userModel;
                  
                  if (user != null && user.isClient) {
                    // Atualizar para profissional
                    final updatedUser = user.copyWith(isClient: false);
                    await authProvider.updateUserProfile(updatedUser);
                  }
                  
                  // Navegar para a tela de profissional
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfessionalHomeScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 40),
              // Botão de logout
              TextButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Sair',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required String title,
      required String description,
      required IconData icon,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}