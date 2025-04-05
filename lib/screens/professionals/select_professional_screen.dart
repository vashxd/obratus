import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/professional_model.dart';
import '../../models/user_model.dart';
import '../../services/professional_service.dart';
import '../../models/project_model.dart';
import '../../services/local_project_service.dart';

class SelectProfessionalScreen extends StatefulWidget {
  final String projectId;
  final String specialty; // Especialidade opcional para filtrar profissionais

  const SelectProfessionalScreen({
    Key? key,
    required this.projectId,
    this.specialty = '',
  }) : super(key: key);

  @override
  State<SelectProfessionalScreen> createState() => _SelectProfessionalScreenState();
}

class _SelectProfessionalScreenState extends State<SelectProfessionalScreen> {
  final ProfessionalService _professionalService = ProfessionalService();
  final LocalProjectService _projectService = LocalProjectService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _professionals = [];
  String? _errorMessage;
  ProjectModel? _project;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Carregar o projeto atual
      final project = _projectService.getProjectById(widget.projectId);
      if (project == null) {
        setState(() {
          _errorMessage = 'Projeto não encontrado';
          _isLoading = false;
        });
        return;
      }
      
      _project = project;

      // Usar o serviço de profissionais para buscar dados
      List<Map<String, dynamic>> professionals = [];
      
      try {
        if (widget.specialty.isNotEmpty) {
          professionals = await _professionalService.searchProfessionalsBySpecialty(widget.specialty);
        } else {
          // Se não houver especialidade específica, buscar todos os profissionais
          professionals = await _professionalService.getAllProfessionals();
        }
      } catch (e) {
        // Em caso de erro, usar dados simulados do serviço
        final mockData = await _professionalService.getMockProfessionals(
          specialty: widget.specialty.isNotEmpty ? widget.specialty : null
        );
        setState(() {
          _professionals = mockData;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _professionals = professionals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar profissionais: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _assignProfessionalToProject(String professionalId, String professionalName) async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_project == null) {
        throw Exception('Projeto não encontrado');
      }

      // Atualizar o projeto com o ID do profissional
      final updatedProject = _project!.copyWith(professionalId: professionalId);
      await _projectService.updateProject(updatedProject);

      // Mostrar mensagem de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profissional vinculado com sucesso!'))
        );
        
        // Retornar para a tela anterior com resultado positivo
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao vincular profissional: ${e.toString()}'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Selecionar Profissional',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? _buildErrorMessage()
              : _buildProfessionalsList(),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Erro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMessage ?? 'Ocorreu um erro desconhecido',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: _loadData,
            child: Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalsList() {
    if (_professionals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum profissional encontrado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.specialty.isNotEmpty
                  ? 'Não há profissionais disponíveis para ${widget.specialty}'
                  : 'Não há profissionais disponíveis no momento',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _professionals.length,
      itemBuilder: (context, index) {
        final professional = _professionals[index];
        final userMap = professional['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);
        final professionalData = ProfessionalModel.fromJson(professional['professional'] as Map<String, dynamic>);

        return Card(
          margin: EdgeInsets.only(bottom: 16),
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Mostrar diálogo de confirmação
              _showConfirmationDialog(professionalData, user);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar do profissional
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Informações do profissional
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          professionalData.specialties.join(', '),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '${professionalData.rating.toStringAsFixed(1)} (${professionalData.ratingCount})',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          professionalData.experience,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(ProfessionalModel professional, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Confirmar profissional',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Deseja vincular ${user.name} a esta obra? Este profissional receberá os pedidos de orçamentos de materiais para esta obra.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              Navigator.pop(context);
              _assignProfessionalToProject(professional.id, user.name);
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}