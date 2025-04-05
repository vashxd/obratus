import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/professional_model.dart';
import '../../models/user_model.dart';
import '../../services/professional_service.dart';
import 'professional_detail_screen.dart';

class ProfessionalsListScreen extends StatefulWidget {
  final String specialty;

  const ProfessionalsListScreen({
    Key? key,
    required this.specialty,
  }) : super(key: key);

  @override
  State<ProfessionalsListScreen> createState() => _ProfessionalsListScreenState();
}

class _ProfessionalsListScreenState extends State<ProfessionalsListScreen> {
  final ProfessionalService _professionalService = ProfessionalService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _professionals = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfessionals();
  }

  Future<void> _loadProfessionals() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Usar o serviço de profissionais para buscar dados
      final professionals = await _professionalService.searchProfessionalsBySpecialty(widget.specialty);
      
      // Se não houver dados, usar dados simulados do serviço filtrados por especialidade
      if (professionals.isEmpty) {
        final mockData = await _professionalService.getMockProfessionals(specialty: widget.specialty);
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

  // Os dados simulados agora são fornecidos pelo serviço local
  // Não precisamos mais do método _getMockProfessionals()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.specialty,
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProfessionals,
                          child: Text('Tentar novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                : _professionals.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum profissional encontrado para esta especialidade.',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _professionals.length,
                        itemBuilder: (context, index) {
                          final item = _professionals[index];
                          final professional = ProfessionalModel.fromJson(Map<String, dynamic>.from(item['professional']));
                          final user = UserModel.fromJson(Map<String, dynamic>.from(item['user']));
                          
                          return _buildProfessionalCard(
                            professional: professional,
                            user: user,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfessionalDetailScreen(
                                    professional: professional,
                                    user: user,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildProfessionalCard({
    required ProfessionalModel professional,
    required UserModel user,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 24,
                    child: user.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user.photoUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '${professional.rating.toStringAsFixed(1)} (${professional.ratingCount})',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Experiência:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                professional.experience,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone, color: AppColors.primary, size: 16),
                      SizedBox(width: 4),
                      Text(
                        user.phone,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Ver perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}