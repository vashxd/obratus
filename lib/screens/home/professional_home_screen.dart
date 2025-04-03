import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class ProfessionalHomeScreen extends StatefulWidget {
  const ProfessionalHomeScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends State<ProfessionalHomeScreen> {
  int _selectedIndex = 0;
  List<String> _selectedSpecialties = [];
  
  // Lista de especialidades disponíveis
  final List<String> _availableSpecialties = [
    'Arquiteto e Urbanista',
    'Engenheiro Civil',
    'Mestre de Obras',
    'Pedreiro',
    'Pintor',
    'Encanador',
    'Eletricista',
    'Carpinteiro',
    'Marceneiro',
    'Serralheiro',
    'Gesseiro',
    'Vidraceiro',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.userModel;

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
              Row(
                children: [
                  Expanded(
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
                          'Selecione suas especialidades',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Avaliação
                  Column(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                      ),
                      Text(
                        'Avaliação (0)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Lista de especialidades
              Expanded(
                child: ListView.builder(
                  itemCount: _availableSpecialties.length,
                  itemBuilder: (context, index) {
                    final specialty = _availableSpecialties[index];
                    final isSelected = _selectedSpecialties.contains(specialty);
                    
                    return Card(
                      color: AppColors.cardBackground,
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          specialty,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: AppColors.primary)
                            : Icon(Icons.circle_outlined, color: Colors.grey),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedSpecialties.remove(specialty);
                            } else {
                              _selectedSpecialties.add(specialty);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              // Botão para salvar especialidades
              ElevatedButton(
                onPressed: () {
                  // Aqui implementaremos a lógica para salvar as especialidades
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Especialidades salvas com sucesso!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Salvar Especialidades'),
              ),
              SizedBox(height: 16),
              // Opção para alterar para perfil de cliente
              InkWell(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/user_type');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Alterar para perfil de cliente',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Botão para comprar material
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'QUER COMPRAR MATERIAL?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Botão para acessar orçamentos pendentes
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/professional_quotes');
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'ORÇAMENTOS PENDENTES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
}