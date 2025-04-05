import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/professional_model.dart';
import '../../services/professional_service.dart';
import '../professionals/professional_profile_edit_screen.dart';

class ProfessionalHomeScreen extends StatefulWidget {
  const ProfessionalHomeScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends State<ProfessionalHomeScreen> {
  int _selectedIndex = 0;
  List<String> _selectedSpecialties = [];
  bool _isLoading = false;
  bool _hasProfile = false;
  final ProfessionalService _professionalService = ProfessionalService();
  ProfessionalModel? _professionalModel;
  
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
  void initState() {
    super.initState();
    _loadProfessionalData();
  }
  
  Future<void> _loadProfessionalData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final UserModel? user = authProvider.userModel;
      
      if (user != null) {
        // Carregar dados do profissional
        final professional = await _professionalService.getProfessionalByUserId(user.id);
        
        if (professional != null) {
          setState(() {
            _professionalModel = professional;
            _selectedSpecialties = professional.specialties;
            // Garantir que _hasProfile seja true se o profissional existir e tiver especialidades
            _hasProfile = professional.specialties.isNotEmpty;
            
            // Verificar nas preferências se o usuário já selecionou especialidades
            SharedPreferences.getInstance().then((prefs) {
              final hasSelectedSpecialties = prefs.getBool('specialties_selected_${user.id}') ?? false;
              if (hasSelectedSpecialties && _hasProfile != true) {
                setState(() {
                  _hasProfile = true;
                });
              }
            });
          });
        }
      }
    } catch (e) {
      // Tratar erro
      print('Erro ao carregar dados do profissional: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveSpecialties() async {
    // Verificar se há especialidades selecionadas
    if (_selectedSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione pelo menos uma especialidade')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final UserModel? user = authProvider.userModel;
      
      if (user != null) {
        if (_professionalModel != null) {
          // Atualizar especialidades do profissional existente
          final updatedProfessional = _professionalModel!.copyWith(
            specialties: _selectedSpecialties,
          );
          
          await _professionalService.updateProfessionalProfile(updatedProfessional);
          _professionalModel = updatedProfessional;
        } else {
          // Criar novo perfil profissional com as especialidades selecionadas
          final newProfessional = ProfessionalModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: user.id,
            specialties: _selectedSpecialties,
            experience: '',
            rating: 0.0,
            ratingCount: 0,
            available: true,
          );
          
          await _professionalService.createProfessionalProfile(newProfessional);
          _professionalModel = newProfessional;
        }
        
        // Marcar que o usuário já selecionou especialidades
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('specialties_selected_${user.id}', true);
        
        // IMPORTANTE: Atualizar o estado para mostrar o perfil imediatamente
        // Isso deve ser feito antes de qualquer navegação
        if (mounted) {
          setState(() {
            _hasProfile = true;
            _isLoading = false; // Desativar loading aqui
          });
          
          // Garantir que a interface seja atualizada
          await Future.delayed(Duration(milliseconds: 100));
          
          // Mostrar mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Especialidades salvas com sucesso!')),
          );
          
          // Aguardar um momento antes de mostrar o diálogo
          await Future.delayed(Duration(milliseconds: 300));
          
          if (mounted) {
            // Perguntar ao usuário se deseja editar o perfil completo
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: AppColors.cardBackground,
                  title: Text('Perfil criado com sucesso!', style: TextStyle(color: Colors.white)),
                  content: Text(
                    'Deseja completar seu perfil profissional agora?',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Fecha o diálogo
                      },
                      child: Text('Depois', style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Fecha o diálogo
                        // Redirecionar para a tela de edição de perfil
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfessionalProfileEditScreen(),
                          ),
                        ).then((_) {
                          // Recarregar dados do profissional quando voltar
                          _loadProfessionalData();
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: Text('Sim', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } catch (e) {
      print('Erro ao salvar especialidades: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar especialidades: $e')),
        );
      }
    }
    // Removido o finally para evitar conflito com outros setState
  }

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
            backgroundImage: user?.photoUrl != null
                ? NetworkImage(user!.photoUrl!)
                : null,
            child: user?.photoUrl == null
                ? Icon(Icons.person, color: Colors.white)
                : null,
          ),
          SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
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
                          _hasProfile ? 'Perfil Profissional' : 'Selecione suas especialidades',
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
              // Conteúdo condicional: Lista de especialidades ou Perfil do profissional
              Expanded(
                child: _hasProfile ? _buildProfessionalProfile() : _buildSpecialtiesSelector(),
              ),
              SizedBox(height: 16),
              // Botão para salvar especialidades (apenas se não tiver perfil)
              if (!_hasProfile)
                ElevatedButton(
                  onPressed: _saveSpecialties,
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
              // Espaço removido - botão de edição de perfil foi mantido apenas na seção de perfil
              SizedBox(height: 16),
              // Botão para comprar material
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/material_list');
                },
                child: Container(
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
  
  // Widget para exibir o seletor de especialidades
  Widget _buildSpecialtiesSelector() {
    return ListView.builder(
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
    );
  }
  
  // Widget para exibir o perfil do profissional
  Widget _buildProfessionalProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Foto de perfil
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                backgroundImage: Provider.of<AuthProvider>(context).userModel?.photoUrl != null
                    ? NetworkImage(Provider.of<AuthProvider>(context).userModel!.photoUrl!)
                    : null,
                child: Provider.of<AuthProvider>(context).userModel?.photoUrl == null
                    ? Icon(Icons.person, size: 50, color: AppColors.primary)
                    : null,
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
        SizedBox(height: 16),
        // Seção de especialidades
        Text(
          'Suas especialidades:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedSpecialties.map((specialty) => Chip(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            label: Text(
              specialty,
              style: TextStyle(color: Colors.white),
            ),
            avatar: Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          )).toList(),
        ),
        SizedBox(height: 16),
        
        // Seção de experiência
        Text(
          'Experiência:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _professionalModel?.experience.isNotEmpty == true
                ? _professionalModel!.experience
                : 'Adicione sua experiência no perfil profissional',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(height: 16),
        
        // Seção de disponibilidade
        Row(
          children: [
            Icon(
              _professionalModel?.available == true
                  ? Icons.check_circle
                  : Icons.cancel,
              color: _professionalModel?.available == true
                  ? Colors.green
                  : Colors.red,
            ),
            SizedBox(width: 8),
            Text(
              _professionalModel?.available == true
                  ? 'Disponível para novos trabalhos'
                  : 'Indisponível para novos trabalhos',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        
        Spacer(),
        
        // Botão para editar perfil
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfessionalProfileEditScreen(),
              ),
            ).then((_) => _loadProfessionalData());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('Editar Perfil Profissional'),
        ),
      ],
    );
  }
}