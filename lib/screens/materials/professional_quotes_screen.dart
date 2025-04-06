import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/material_model.dart';
import '../../models/project_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_material_service.dart';
import '../../services/local_project_service.dart';

class ProfessionalQuotesScreen extends StatefulWidget {
  const ProfessionalQuotesScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalQuotesScreen> createState() => _ProfessionalQuotesScreenState();
}

class _ProfessionalQuotesScreenState extends State<ProfessionalQuotesScreen> {
  final LocalMaterialService _materialService = LocalMaterialService();
  final LocalProjectService _projectService = LocalProjectService();
  List<MaterialQuote> _quotes = [];
  bool _isLoading = true;
  String _currentStatus = 'pending'; // Status inicial: pendente

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obter o ID do profissional logado
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final professionalId = authProvider.userId;

      if (professionalId == null) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário não autenticado')),
          );
        }
        return;
      }

      // Buscar orçamentos pelo status selecionado das obras vinculadas ao profissional
      final quotes = await _materialService.getQuotesByStatusAndProfessional(professionalId, _currentStatus);
      setState(() {
        _quotes = quotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar orçamentos: ${e.toString()}')),
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
        title: Text(_getStatusTitle()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuotes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('pending', 'Pendentes'),
                _buildFilterChip('quoted', 'Orçados'),
                _buildFilterChip('accepted', 'Aceitos'),
                _buildFilterChip('rejected', 'Rejeitados'),
              ],
            ),
          ),
          // Lista de orçamentos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _quotes.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum orçamento ${_getStatusText(_currentStatus).toLowerCase()}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _quotes.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final quote = _quotes[index];
                          return Card(
                            color: Colors.white10,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Orçamento #${quote.id.substring(0, 8)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Data: ${_formatDate(quote.createdAt)}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Mostrar informações do projeto
                                  if (quote.projectId != null)
                                    FutureBuilder(
                                      future: _getProjectInfo(quote.projectId!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: Text(
                                              'Carregando informações da obra...',
                                              style: TextStyle(color: Colors.white70, fontSize: 14),
                                            ),
                                          );
                                        }
                                        if (snapshot.hasError || !snapshot.hasData) {
                                          return const SizedBox.shrink();
                                        }
                                        final projectInfo = snapshot.data!;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Obra: ${projectInfo['title']}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                projectInfo['description'],
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  const Divider(color: Colors.white30),
                                  const Text(
                                    'Itens:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...quote.items.map((item) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                item.name,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                item.brand,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                item.quantity.toString(),
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: quote.status == 'pending' ? () => _showQuoteDialog(quote) : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: quote.status == 'pending' ? AppColors.primary : Colors.grey,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: Text(_getButtonText(quote.status)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Construir chip de filtro
  Widget _buildFilterChip(String status, String label) {
    final isSelected = _currentStatus == status;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: Colors.black26,
      selectedColor: AppColors.primary,
      onSelected: (selected) {
        setState(() {
          _currentStatus = status;
        });
        _loadQuotes();
      },
    );
  }

  // Obter título baseado no status atual
  String _getStatusTitle() {
    switch (_currentStatus) {
      case 'pending':
        return 'Orçamentos Pendentes';
      case 'quoted':
        return 'Orçamentos Respondidos';
      case 'accepted':
        return 'Orçamentos Aceitos';
      case 'rejected':
        return 'Orçamentos Rejeitados';
      default:
        return 'Orçamentos';
    }
  }

  // Obter texto do botão baseado no status
  String _getButtonText(String status) {
    switch (status) {
      case 'pending':
        return 'RESPONDER ORÇAMENTO';
      case 'quoted':
        return 'ORÇAMENTO ENVIADO';
      case 'accepted':
        return 'ORÇAMENTO ACEITO';
      case 'rejected':
        return 'ORÇAMENTO REJEITADO';
      default:
        return 'VER DETALHES';
    }
  }

  // Obter texto do status
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendentes';
      case 'quoted':
        return 'Orçados';
      case 'accepted':
        return 'Aceitos';
      case 'rejected':
        return 'Rejeitados';
      default:
        return 'Desconhecidos';
    }
  }
  
  // Buscar informações do projeto
  Future<Map<String, dynamic>> _getProjectInfo(String projectId) async {
    final project = _projectService.getProjectById(projectId);
    if (project == null) {
      return {'title': 'Obra não encontrada', 'description': ''};
    }
    return {
      'title': project.title,
      'description': project.description,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showQuoteDialog(MaterialQuote quote) {
    final TextEditingController priceController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          'Responder Orçamento',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço Total (R\$)',
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Informe o preço total')),
                );
                return;
              }

              final double? price = double.tryParse(priceController.text);
              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preço inválido')),
                );
                return;
              }

              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final professionalId = authProvider.userId;

              if (professionalId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuário não autenticado')),
                );
                return;
              }

              try {
                await _materialService.updateQuote(
                  quoteId: quote.id,
                  professionalId: professionalId,
                  totalPrice: price,
                  notes: notesController.text.trim(),
                );

                if (!mounted) return;
                Navigator.pop(context); // Fechar o diálogo

                // Atualizar a lista de orçamentos
                _loadQuotes();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orçamento enviado com sucesso')),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context); // Fechar o diálogo

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao enviar orçamento: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('ENVIAR'),
          ),
        ],
      ),
    );
  }
}