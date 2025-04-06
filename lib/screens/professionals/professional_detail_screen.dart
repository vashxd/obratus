import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/professional_model.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../services/local_project_service.dart';
import '../../screens/projects/project_detail_screen.dart';

class ProfessionalDetailScreen extends StatefulWidget {
  final ProfessionalModel professional;
  final UserModel user;
  final String? projectId; // ID do projeto opcional

  const ProfessionalDetailScreen({
    Key? key,
    required this.professional,
    required this.user,
    this.projectId,
  }) : super(key: key);

  @override
  State<ProfessionalDetailScreen> createState() => _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState extends State<ProfessionalDetailScreen> {
  final LocalProjectService _projectService = LocalProjectService();
  bool _isLoading = false;
  
  // Método para vincular o profissional ao projeto
  Future<void> _assignProfessionalToProject() async {
    if (widget.projectId == null) return;
    
    try {
      setState(() {
        _isLoading = true;
      });

      // Carregar o projeto atual
      final project = _projectService.getProjectById(widget.projectId!);
      if (project == null) {
        throw Exception('Projeto não encontrado');
      }

      // Atualizar o projeto com o ID do profissional
      // Adicionar o ID do profissional à lista de profissionais vinculados
      List<String> updatedProfessionalIds = List<String>.from(project.professionalIds);
      if (!updatedProfessionalIds.contains(widget.professional.id)) {
        updatedProfessionalIds.add(widget.professional.id);
      }
      
      final updatedProject = project.copyWith(
        professionalId: widget.professional.id,
        professionalIds: updatedProfessionalIds
      );
      await _projectService.updateProject(updatedProject);

      // Mostrar mensagem de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profissional vinculado com sucesso!'))
        );
        
        // Navegar diretamente para a tela de detalhes da obra
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(projectId: widget.projectId!),
          ),
        );
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
          'Perfil do Profissional',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com foto e informações básicas
              _buildHeader(),
              SizedBox(height: 24),
              
              // Especialidades
              _buildSectionTitle('Especialidades'),
              SizedBox(height: 8),
              _buildSpecialtiesList(),
              SizedBox(height: 24),
              
              // Experiência
              _buildSectionTitle('Experiência'),
              SizedBox(height: 8),
              _buildExperienceSection(),
              SizedBox(height: 24),
              
              // Portfólio (se disponível)
              if (widget.professional.portfolioUrls != null && 
                  widget.professional.portfolioUrls!.isNotEmpty) ...[  
                _buildSectionTitle('Portfólio'),
                SizedBox(height: 8),
                _buildPortfolioGallery(),
                SizedBox(height: 24),
              ],
              
              // Avaliações
              _buildSectionTitle('Avaliações'),
              SizedBox(height: 8),
              _buildRatingsSection(),
              SizedBox(height: 32),
              
              // Botões de contato
              _buildContactButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Foto do profissional
        CircleAvatar(
          backgroundColor: AppColors.primary,
          radius: 40,
          child: widget.user.photoUrl != null
              ? ClipOval(
                  child: Image.network(
                    widget.user.photoUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(Icons.person, color: Colors.white, size: 40),
        ),
        SizedBox(width: 16),
        
        // Informações básicas
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${widget.professional.rating.toStringAsFixed(1)} (${widget.professional.ratingCount} avaliações)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.grey, size: 16),
                  SizedBox(width: 4),
                  Text(
                    widget.user.phone ?? 'Não informado',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.email, color: Colors.grey, size: 16),
                  SizedBox(width: 4),
                  Text(
                    widget.user.email,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (widget.professional.professionalId != null) ...[  
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.badge, color: Colors.grey, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'ID: ${widget.professional.professionalId}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSpecialtiesList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.professional.specialties.map((specialty) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: Text(
            specialty,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.professional.experience,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPortfolioGallery() {
    // Simulação de portfólio para desenvolvimento
    final List<String> mockPortfolio = [
      'https://images.unsplash.com/photo-1503387762-592deb58ef4e',
      'https://images.unsplash.com/photo-1556156653-e5a7676bf6cf',
      'https://images.unsplash.com/photo-1541123437800-1bb1317badc2',
      'https://images.unsplash.com/photo-1565008447742-97f6f38c985c',
    ];
    
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mockPortfolio.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            height: 120,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage('${mockPortfolio[index]}?w=120&h=120&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingsSection() {
    // Simulação de avaliações para desenvolvimento
    final List<Map<String, dynamic>> mockRatings = [
      {
        'name': 'Cliente Exemplo 1',
        'rating': 5.0,
        'comment': 'Excelente profissional, muito atencioso e pontual.',
        'date': '15/04/2023',
      },
      {
        'name': 'Cliente Exemplo 2',
        'rating': 4.0,
        'comment': 'Bom trabalho, recomendo.',
        'date': '02/03/2023',
      },
    ];
    
    return Column(
      children: mockRatings.map((rating) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rating['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    rating['date'],
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating['rating'] ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              SizedBox(height: 8),
              Text(
                rating['comment'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactButtons() {
    // Se temos um ID de projeto, mostramos o botão de adicionar à obra
    if (widget.projectId != null) {
      return Column(
        children: [
          // Botão de adicionar à obra
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _assignProfessionalToProject,
            icon: _isLoading 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Icon(Icons.add_business),
            label: Text('Adicionar à Obra'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 12),
              minimumSize: Size(double.infinity, 48),
            ),
          ),
          SizedBox(height: 16),
          // Botões de contato
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Funcionalidade de chat em desenvolvimento')),
                    );
                  },
                  icon: Icon(Icons.chat),
                  label: Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Funcionalidade de orçamento em desenvolvimento')),
                    );
                  },
                  icon: Icon(Icons.request_quote),
                  label: Text('Orçamento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Versão original sem o botão de adicionar à obra
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Funcionalidade de chat em desenvolvimento')),
                );
              },
              icon: Icon(Icons.chat),
              label: Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Funcionalidade de orçamento em desenvolvimento')),
                );
              },
              icon: Icon(Icons.request_quote),
              label: Text('Orçamento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    }
  }
}