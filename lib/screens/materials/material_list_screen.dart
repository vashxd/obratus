import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_colors.dart';
import '../../models/material_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_material_service.dart';
import 'material_quote_confirmation_screen.dart';

class MaterialListScreen extends StatefulWidget {
  final String? projectId; // ID do projeto ao qual os materiais serão associados
  
  const MaterialListScreen({Key? key, this.projectId}) : super(key: key);

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  final LocalMaterialService _materialService = LocalMaterialService();
  final List<MaterialItem> _materialItems = [];
  final Uuid _uuid = Uuid();
  
  // Controladores para os campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Adicionar um novo item à lista
  void _addItem() {
    if (_nameController.text.isEmpty ||
        _brandController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final int quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantidade deve ser maior que zero')),
      );
      return;
    }

    setState(() {
      _materialItems.add(
        MaterialItem(
          id: _uuid.v4(),
          name: _nameController.text.trim(),
          brand: _brandController.text.trim(),
          quantity: quantity,
        ),
      );
    });

    // Limpar os campos após adicionar
    _nameController.clear();
    _brandController.clear();
    _quantityController.clear();
  }

  // Remover um item da lista
  void _removeItem(int index) {
    setState(() {
      _materialItems.removeAt(index);
    });
  }

  // Enviar a lista para orçamento
  Future<void> _submitQuote() async {
    if (_materialItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um item à lista')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

    try {
      // Criar o orçamento, associando ao projeto se o projectId estiver disponível
      final quote = await _materialService.createMaterialQuote(
        userId,
        List.from(_materialItems), // Criar uma cópia da lista
        projectId: widget.projectId, // Associar ao projeto, se fornecido
      );

      if (!mounted) return;

      // Navegar para a tela de confirmação
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MaterialQuoteConfirmationScreen(quote: quote),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar orçamento: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userModel?.name.split(' ')[0] ?? 'Usuário';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JOÃO PEDROSA (5)',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.white, size: 14),
                Icon(Icons.star, color: Colors.white, size: 14),
                Icon(Icons.star, color: Colors.white, size: 14),
                Icon(Icons.star, color: Colors.white, size: 14),
                Icon(Icons.star, color: Colors.white, size: 14),
              ],
            ),
            Text(
              'ALGUMA CLASSIFICAÇÃO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Text(
              '$userName,',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'faça sua lista de materiais',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            
            // Cabeçalho dos campos
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nome',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Marca',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'QTD.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Campos para adicionar novo item
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Botão para adicionar item
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('ADICIONAR ITEM'),
              ),
            ),
            const SizedBox(height: 24),
            
            // Cabeçalho da lista
            const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nome',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Marca',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'QTD.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 40), // Espaço para o botão de remover
              ],
            ),
            const Divider(color: Colors.white30),
            
            // Lista de itens
            Expanded(
              child: _materialItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum item adicionado',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _materialItems.length,
                      itemBuilder: (context, index) {
                        final item = _materialItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
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
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () => _removeItem(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Botão para enviar orçamento
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('PEDIR ORÇAMENTO'),
              ),
            ),
            const SizedBox(height: 16),
            // Botões adicionais
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Funcionalidade para anexar lista existente
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('JÁ TEM UMA LISTA? CLIQUE PARA ANEXAR'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navegar para a tela de seleção de especialidades profissionais
                  Navigator.pushNamed(context, '/professionals');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('QUER CONTRATAR UM PROFISSIONAL?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}