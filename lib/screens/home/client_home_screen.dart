import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;
  
  // Lista de opções do menu principal
  final List<Map<String, dynamic>> _menuOptions = [
    {
      'title': 'Material',
      'subtitle': '(Faça sua lista para orçamento)',
      'route': '/material_list',
      'color': Colors.grey.shade400,
    },
    {
      'title': 'Profissionais',
      'subtitle': '(Escolha o profissional ideal)',
      'route': '/professionals',
      'color': Colors.grey.shade400,
    },
  ];
  
  // Lista de opções secundárias
  final List<Map<String, dynamic>> _secondaryOptions = [
    {
      'icon': Icons.person,
      'title': 'Alterar perfil para profissional',
      'route': '/user_type',
      'color': Colors.grey.shade600,
    },
    {
      'icon': Icons.home_repair_service,
      'title': 'Minhas obras',
      'route': '/my_projects',
      'color': Colors.grey.shade600,
    },
    {
      'icon': Icons.notifications,
      'title': 'Notícias sobre obras',
      'route': '/news',
      'color': Colors.grey.shade600,
    },
    {
      'icon': Icons.list_alt,
      'title': 'Meus orçamentos',
      'route': '/client_quotes',
      'color': Colors.grey.shade600,
    },
  ];
  

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.userModel;
    final userName = user?.name.split(' ')[0] ?? 'Usuário';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OBRATUS',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'CONECTANDO SUA OBRA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 18,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user?.name ?? "Olá"},',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'No que podemos te ajudar?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 32),
              _buildOptionButton(
                title: 'Material',
                subtitle: 'Faça sua lista para orçamento',
                onTap: () {
                  // Navegar para tela de materiais
                  Navigator.pushNamed(context, '/material_list');
                },
              ),
              SizedBox(height: 16),
              _buildOptionButton(
                title: 'Profissionais',
                subtitle: 'Escolha o profissional ideal',
                onTap: () {
                  // Navegar para tela de profissionais
                  Navigator.pushNamed(context, '/professionals');
                },
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  _buildProfileOption(
                    icon: Icons.person,
                    title: 'Alterar perfil para profissional',
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/user_type');
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _buildProfileOption(
                    icon: Icons.construction,
                    title: 'Minhas obras',
                    onTap: () {
                      // Navegar para tela de obras
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _buildProfileOption(
                    icon: Icons.notifications,
                    title: 'Notificações sobre obras',
                    onTap: () {
                      // Navegar para tela de notificações
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _buildProfileOption(
                    icon: Icons.list_alt,
                    title: 'Meus orçamentos',
                    onTap: () {
                      // Navegar para tela de orçamentos do cliente
                      Navigator.pushNamed(context, '/client_quotes');
                    },
                  ),
                ],
              ),
              Spacer(),
              // Instagram link
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Instagram',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
      ),
    );
  }

  Widget _buildOptionButton({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}