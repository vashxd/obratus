import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/professional_model.dart';
import 'professionals_list_screen.dart';

class ProfessionalSpecialtiesScreen extends StatefulWidget {
  const ProfessionalSpecialtiesScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalSpecialtiesScreen> createState() => _ProfessionalSpecialtiesScreenState();
}

class _ProfessionalSpecialtiesScreenState extends State<ProfessionalSpecialtiesScreen> {
  // Lista de especialidades disponíveis
  final List<Map<String, dynamic>> _specialties = [
    {
      'name': 'Arquiteto e Urbanista',
      'icon': Icons.architecture,
      'color': Colors.blue.shade700,
    },
    {
      'name': 'Engenheiro Civil',
      'icon': Icons.engineering,
      'color': Colors.orange.shade700,
    },
    {
      'name': 'Mestre de Obras',
      'icon': Icons.construction,
      'color': Colors.red.shade700,
    },
    {
      'name': 'Pedreiro',
      'icon': Icons.build,
      'color': Colors.brown.shade700,
    },
    {
      'name': 'Pintor',
      'icon': Icons.format_paint,
      'color': Colors.purple.shade700,
    },
    {
      'name': 'Encanador',
      'icon': Icons.plumbing,
      'color': Colors.blue.shade700,
    },
    {
      'name': 'Eletricista',
      'icon': Icons.electrical_services,
      'color': Colors.yellow.shade700,
    },
    {
      'name': 'Carpinteiro',
      'icon': Icons.handyman,
      'color': Colors.brown.shade700,
    },
    {
      'name': 'Marceneiro',
      'icon': Icons.weekend,
      'color': Colors.amber.shade700,
    },
    {
      'name': 'Serralheiro',
      'icon': Icons.iron,
      'color': Colors.grey.shade700,
    },
    {
      'name': 'Gesseiro',
      'icon': Icons.wallpaper,
      'color': Colors.white70,
    },
    {
      'name': 'Vidraceiro',
      'icon': Icons.window,
      'color': Colors.lightBlue.shade700,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Especialidades',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escolha uma especialidade',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Selecione o tipo de profissional que você está procurando',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _specialties.length,
                  itemBuilder: (context, index) {
                    final specialty = _specialties[index];
                    return _buildSpecialtyCard(
                      name: specialty['name'],
                      icon: specialty['icon'],
                      color: specialty['color'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfessionalsListScreen(
                              specialty: specialty['name'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard({
    required String name,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}