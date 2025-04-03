import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/material_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_material_service.dart';

class ProfessionalQuotesScreen extends StatefulWidget {
  const ProfessionalQuotesScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalQuotesScreen> createState() => _ProfessionalQuotesScreenState();
}

class _ProfessionalQuotesScreenState extends State<ProfessionalQuotesScreen> {
  final LocalMaterialService _materialService = LocalMaterialService();
  List<MaterialQuote> _pendingQuotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingQuotes();
  }

  Future<void> _loadPendingQuotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final quotes = await _materialService.getPendingQuotes();
      setState(() {
        _pendingQuotes = quotes;
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
        title: const Text('Orçamentos Pendentes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingQuotes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingQuotes.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum orçamento pendente',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: _pendingQuotes.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final quote = _pendingQuotes[index];
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
                                onPressed: () => _showQuoteDialog(quote),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('RESPONDER ORÇAMENTO'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
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

                // Atualizar a lista de orçamentos pendentes
                _loadPendingQuotes();

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