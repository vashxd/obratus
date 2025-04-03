import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/material_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_material_service.dart';

class ClientQuotesScreen extends StatefulWidget {
  const ClientQuotesScreen({Key? key}) : super(key: key);

  @override
  State<ClientQuotesScreen> createState() => _ClientQuotesScreenState();
}

class _ClientQuotesScreenState extends State<ClientQuotesScreen> {
  final LocalMaterialService _materialService = LocalMaterialService();
  List<MaterialQuote> _clientQuotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientQuotes();
  }

  Future<void> _loadClientQuotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final quotes = await _materialService.getClientQuotes(userId);
      setState(() {
        _clientQuotes = quotes;
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

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'quoted':
        return 'Orçado';
      case 'accepted':
        return 'Aceito';
      case 'rejected':
        return 'Rejeitado';
      default:
        return 'Desconhecido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'quoted':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Meus Orçamentos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClientQuotes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clientQuotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Você ainda não tem orçamentos',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/material_list');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('CRIAR NOVO ORÇAMENTO'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _clientQuotes.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final quote = _clientQuotes[index];
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(quote.status),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getStatusText(quote.status),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Data: ${_formatDate(quote.createdAt)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
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
                            ...quote.items.take(3).map((item) => Padding(
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
                            if (quote.items.length > 3)
                              Text(
                                '... e mais ${quote.items.length - 3} itens',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            if (quote.status == 'quoted')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  const Divider(color: Colors.white30),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Preço Total:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'R\$ ${quote.totalPrice?.toStringAsFixed(2) ?? "0.00"}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (quote.notes != null && quote.notes!.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Observações:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          quote.notes!,
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              await _materialService.updateQuoteStatus(
                                                quote.id,
                                                'accepted',
                                              );
                                              _loadClientQuotes();
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Erro: ${e.toString()}')),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: const Text('ACEITAR'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              await _materialService.updateQuoteStatus(
                                                quote.id,
                                                'rejected',
                                              );
                                              _loadClientQuotes();
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Erro: ${e.toString()}')),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('REJEITAR'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _showQuoteDetailsDialog(quote);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white24,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('VER DETALHES'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/material_list');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showQuoteDetailsDialog(MaterialQuote quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Orçamento #${quote.id.substring(0, 8)}',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(quote.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(quote.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Data: ${_formatDate(quote.createdAt)}',
                style: const TextStyle(color: Colors.white70),
              ),
              if (quote.updatedAt != null)
                Text(
                  'Atualizado: ${_formatDate(quote.updatedAt!)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              const SizedBox(height: 16),
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
              if (quote.status == 'quoted' || quote.status == 'accepted')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Preço Total:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'R\$ ${quote.totalPrice?.toStringAsFixed(2) ?? "0.00"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (quote.notes != null && quote.notes!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Observações:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            quote.notes!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FECHAR'),
          ),
        ],
      ),
    );
  }
}