import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/material_model.dart' hide MaterialItem;
import '../../models/project_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_material_service.dart';
import '../../services/local_project_service.dart';
import '../materials/material_list_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  
  const ProjectDetailScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final LocalProjectService _projectService = LocalProjectService();
  final LocalMaterialService _materialService = LocalMaterialService();
  ProjectModel? _project;
  List<MaterialQuote> _materialQuotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    setState(() {
      _isLoading = true;
    });

    final project = _projectService.getProjectById(widget.projectId);
    
    // Carregar orçamentos de materiais associados ao projeto
    final materialQuotes = await _materialService.getProjectQuotes(widget.projectId);
    
    setState(() {
      _project = project;
      _materialQuotes = materialQuotes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'DETALHES DA OBRA',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primary),
            onPressed: () async {
              // Navegar para a tela de edição
              final result = await Navigator.pushNamed(
                context,
                '/edit_project',
                arguments: _project,
              );

              if (result == true) {
                _loadProject();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmationDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _project == null
              ? _buildProjectNotFound()
              : _buildProjectDetails(),
    );
  }

  Widget _buildProjectNotFound() {
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
            'Obra não encontrada',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'A obra solicitada não existe ou foi removida',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Voltar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetails() {
    final project = _project!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(project.status),
            ],
          ),
          SizedBox(height: 16),
          
          // Descrição
          Text(
            'Descrição',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              project.description,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 24),
          
          // Datas
          Text(
            'Datas',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateRow('Data de criação', project.createdAt),
                if (project.startDate != null) ...[  
                  SizedBox(height: 8),
                  _buildDateRow('Data de início', project.startDate!),
                ],
                if (project.endDate != null) ...[  
                  SizedBox(height: 8),
                  _buildDateRow('Previsão de conclusão', project.endDate!),
                ],
              ],
            ),
          ),
          SizedBox(height: 24),
          
          // Profissional
          Text(
            'Profissional',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: project.professionalId != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profissional atribuído',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ID: ${project.professionalId}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () {
                          // Navegar para o perfil do profissional
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                          );
                        },
                        child: Text('Ver perfil'),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nenhum profissional atribuído',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () {
                          // Navegar para busca de profissionais
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                          );
                        },
                        child: Text('Buscar profissional'),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: 24),
          
          // Materiais
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Materiais',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.add, color: AppColors.primary),
                    label: Text(
                      'Adicionar',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    onPressed: () {
                      // Adicionar material
                      _showAddMaterialDialog();
                    },
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.shopping_cart, color: AppColors.primary),
                    label: Text(
                      'Lista de Materiais',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    onPressed: () {
                      // Navegar para a tela de lista de materiais
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaterialListScreen(projectId: widget.projectId),
                        ),
                      ).then((_) => _loadProject()); // Recarregar o projeto ao voltar
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          project.materials.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Nenhum material adicionado',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: project.materials.length,
                  itemBuilder: (context, index) {
                    final material = project.materials[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      color: AppColors.cardBackground,
                      child: ListTile(
                        title: Text(
                          material.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (material.description != null) ...[  
                              Text(
                                material.description!,
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 4),
                            ],
                            Text(
                              'Quantidade: ${material.quantity} ${material.unit}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            if (material.price != null) ...[  
                              Text(
                                'Preço: R\$ ${material.price!.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                              onPressed: () {
                                // Editar material
                                _showEditMaterialDialog(material);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () {
                                // Remover material
                                _showDeleteMaterialDialog(material.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          SizedBox(height: 24),
          
          // Orçamento
          Text(
            'Orçamento',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.budget != null
                      ? 'R\$ ${project.budget!.toStringAsFixed(2)}'
                      : 'Não definido',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    // Atualizar orçamento
                    _showUpdateBudgetDialog();
                  },
                  child: Text('Atualizar orçamento'),
                ),
              ],
            ),
          ),
          // Orçamentos de Materiais
          Text(
            'Orçamentos de Materiais',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _materialQuotes.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Nenhum orçamento de material solicitado',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _materialQuotes.length,
                  itemBuilder: (context, index) {
                    final quote = _materialQuotes[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      color: AppColors.cardBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Orçamento #${quote.id.substring(0, 8)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                _buildQuoteStatusBadge(quote.status),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Solicitado em: ${_formatDate(quote.createdAt)}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Itens: ${quote.items.length}',
                              style: TextStyle(color: Colors.white),
                            ),
                            if (quote.totalPrice != null) ...[  
                              SizedBox(height: 4),
                              Text(
                                'Valor total: R\$ ${quote.totalPrice!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            SizedBox(height: 12),
                            // Lista de itens do orçamento
                            ExpansionTile(
                              title: Text(
                                'Ver itens',
                                style: TextStyle(color: Colors.white),
                              ),
                              collapsedIconColor: Colors.white,
                              iconColor: AppColors.primary,
                              children: quote.items.map((item) {
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    item.name,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    'Quantidade: ${item.quantity} ${item.unit}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Text(
          _formatDate(date),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String statusText;

    switch (status) {
      case 'pendente':
        badgeColor = Colors.orange;
        statusText = 'Pendente';
        break;
      case 'em_andamento':
        badgeColor = Colors.blue;
        statusText = 'Em andamento';
        break;
      case 'concluido':
        badgeColor = Colors.green;
        statusText = 'Concluído';
        break;
      case 'cancelado':
        badgeColor = Colors.red;
        statusText = 'Cancelado';
        break;
      default:
        badgeColor = Colors.grey;
        statusText = 'Indefinido';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildQuoteStatusBadge(String status) {
    Color badgeColor;
    String statusText;

    switch (status) {
      case 'pending':
        badgeColor = Colors.orange;
        statusText = 'Pendente';
        break;
      case 'quoted':
        badgeColor = Colors.blue;
        statusText = 'Orçado';
        break;
      case 'accepted':
        badgeColor = Colors.green;
        statusText = 'Aceito';
        break;
      case 'rejected':
        badgeColor = Colors.red;
        statusText = 'Rejeitado';
        break;
      default:
        badgeColor = Colors.grey;
        statusText = 'Indefinido';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Confirmar exclusão',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja excluir esta obra? Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _projectService.deleteProject(widget.projectId);
              Navigator.pop(context, true);
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMaterialDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();
    final priceController = TextEditingController();
    bool provided = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Adicionar Material',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nome do material *',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descrição (opcional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityController,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantidade *',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: unitController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Unidade *',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: priceController,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Preço unitário (opcional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Material fornecido pelo cliente:',
                    style: TextStyle(color: Colors.white),
                  ),
                  Spacer(),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Switch(
                        value: provided,
                        onChanged: (value) {
                          setState(() {
                            provided = value;
                          });
                        },
                        activeColor: AppColors.primary,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  quantityController.text.isEmpty ||
                  unitController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Preencha os campos obrigatórios')),
                );
                return;
              }

              final material = MaterialItem(
                id: '', // Será gerado pelo serviço
                name: nameController.text,
                description: descriptionController.text.isNotEmpty
                    ? descriptionController.text
                    : null,
                quantity: int.tryParse(quantityController.text) ?? 0,
                unit: unitController.text,
                price: priceController.text.isNotEmpty
                    ? double.tryParse(priceController.text)
                    : null,
                provided: provided,
                notes: null,
              );

              Navigator.pop(context);
              await _projectService.addMaterialToProject(widget.projectId, material);
              _loadProject();
            },
            child: Text(
              'Adicionar',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditMaterialDialog(MaterialItem material) {
    final nameController = TextEditingController(text: material.name);
    final descriptionController = TextEditingController(text: material.description ?? '');
    final quantityController = TextEditingController(text: material.quantity.toString());
    final unitController = TextEditingController(text: material.unit);
    final priceController = TextEditingController(
        text: material.price != null ? material.price.toString() : '');
    bool provided = material.provided;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Editar Material',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nome do material *',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descrição (opcional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityController,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantidade *',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: unitController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Unidade *',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: priceController,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Preço unitário (opcional)',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Material fornecido pelo cliente:',
                    style: TextStyle(color: Colors.white),
                  ),
                  Spacer(),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Switch(
                        value: provided,
                        onChanged: (value) {
                          setState(() {
                            provided = value;
                          });
                        },
                        activeColor: AppColors.primary,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  quantityController.text.isEmpty ||
                  unitController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Preencha os campos obrigatórios')),
                );
                return;
              }

              final updatedMaterial = MaterialItem(
                id: material.id,
                name: nameController.text,
                description: descriptionController.text.isNotEmpty
                    ? descriptionController.text
                    : null,
                quantity: int.tryParse(quantityController.text) ?? 0,
                unit: unitController.text,
                price: priceController.text.isNotEmpty
                    ? double.tryParse(priceController.text)
                    : null,
                provided: provided,
                notes: material.notes,
              );

              Navigator.pop(context);
              await _projectService.updateMaterialInProject(
                  widget.projectId, updatedMaterial);
              _loadProject();
            },
            child: Text(
              'Salvar',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteMaterialDialog(String materialId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Confirmar exclusão',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja excluir este material?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _projectService.removeMaterialFromProject(
                  widget.projectId, materialId);
              _loadProject();
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showUpdateBudgetDialog() {
    final budgetController = TextEditingController();
    if (_project!.budget != null) {
      budgetController.text = _project!.budget!.toString();
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Atualizar Orçamento',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: budgetController,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Valor do orçamento',
            labelStyle: TextStyle(color: Colors.grey),
            prefixText: 'R\$ ',
            prefixStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              double? budget;
              if (budgetController.text.isNotEmpty) {
                budget = double.tryParse(budgetController.text.replaceAll(',', '.'));
              }
              
              final updatedProject = _project!.copyWith(budget: budget);
              await _projectService.updateProject(updatedProject);
              _loadProject();
            },
            child: Text(
              'Salvar',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}