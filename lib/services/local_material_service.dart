import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/material_model.dart';
import 'local_storage_service.dart';

/// Serviço responsável por gerenciar os orçamentos de materiais no armazenamento local
class LocalMaterialService {
  final LocalStorageService _storageService = LocalStorageService();
  final Uuid _uuid = Uuid();
  
  // Nome da box do Hive para orçamentos de materiais
  static const String materialsBoxName = 'materials';
  
  // Obter a box de orçamentos
  Box _getMaterialsBox() {
    return _storageService.getBox(materialsBoxName);
  }
  
  // Criar um novo orçamento de materiais
  Future<MaterialQuote> createMaterialQuote(String clientId, List<MaterialItem> items) async {
    final materialsBox = _getMaterialsBox();
    
    // Criar um novo orçamento
    final MaterialQuote quote = MaterialQuote(
      id: _uuid.v4(),
      clientId: clientId,
      items: items,
      createdAt: DateTime.now(),
      status: 'pending', // status inicial: pendente
    );
    
    // Salvar no Hive
    await materialsBox.put(quote.id, quote.toJson());
    
    return quote;
  }
  
  // Obter todos os orçamentos de um cliente
  Future<List<MaterialQuote>> getClientQuotes(String clientId) async {
    final materialsBox = _getMaterialsBox();
    
    // Filtrar orçamentos pelo ID do cliente
    final List<MaterialQuote> quotes = [];
    
    for (var key in materialsBox.keys) {
      final data = materialsBox.get(key);
      if (data != null) {
        final quote = MaterialQuote.fromJson(Map<String, dynamic>.from(data));
        if (quote.clientId == clientId) {
          quotes.add(quote);
        }
      }
    }
    
    // Ordenar por data de criação (mais recente primeiro)
    quotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return quotes;
  }
  
  // Obter todos os orçamentos pendentes (para profissionais)
  Future<List<MaterialQuote>> getPendingQuotes() async {
    final materialsBox = _getMaterialsBox();
    
    // Filtrar orçamentos pendentes
    final List<MaterialQuote> quotes = [];
    
    for (var key in materialsBox.keys) {
      final data = materialsBox.get(key);
      if (data != null) {
        final quote = MaterialQuote.fromJson(Map<String, dynamic>.from(data));
        if (quote.status == 'pending') {
          quotes.add(quote);
        }
      }
    }
    
    // Ordenar por data de criação (mais antigo primeiro)
    quotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    return quotes;
  }
  
  // Obter um orçamento específico pelo ID
  Future<MaterialQuote?> getQuoteById(String quoteId) async {
    final materialsBox = _getMaterialsBox();
    
    final data = materialsBox.get(quoteId);
    if (data != null) {
      return MaterialQuote.fromJson(Map<String, dynamic>.from(data));
    }
    
    return null;
  }
  
  // Atualizar um orçamento (resposta do profissional)
  Future<MaterialQuote?> updateQuote({
    required String quoteId,
    required String professionalId,
    required double totalPrice,
    String? notes,
  }) async {
    final materialsBox = _getMaterialsBox();
    
    // Obter o orçamento existente
    final data = materialsBox.get(quoteId);
    if (data != null) {
      final quote = MaterialQuote.fromJson(Map<String, dynamic>.from(data));
      
      // Atualizar o orçamento
      final updatedQuote = MaterialQuote(
        id: quote.id,
        clientId: quote.clientId,
        professionalId: professionalId,
        items: quote.items,
        createdAt: quote.createdAt,
        updatedAt: DateTime.now(),
        status: 'quoted', // status atualizado: orçado
        totalPrice: totalPrice,
        notes: notes,
      );
      
      // Salvar no Hive
      await materialsBox.put(quoteId, updatedQuote.toJson());
      
      return updatedQuote;
    }
    
    return null;
  }
  
  // Atualizar o status de um orçamento (aceito/rejeitado pelo cliente)
  Future<MaterialQuote?> updateQuoteStatus(String quoteId, String status) async {
    final materialsBox = _getMaterialsBox();
    
    // Obter o orçamento existente
    final data = materialsBox.get(quoteId);
    if (data != null) {
      final quote = MaterialQuote.fromJson(Map<String, dynamic>.from(data));
      
      // Atualizar o status
      final updatedQuote = MaterialQuote(
        id: quote.id,
        clientId: quote.clientId,
        professionalId: quote.professionalId,
        items: quote.items,
        createdAt: quote.createdAt,
        updatedAt: DateTime.now(),
        status: status, // 'accepted' ou 'rejected'
        totalPrice: quote.totalPrice,
        notes: quote.notes,
      );
      
      // Salvar no Hive
      await materialsBox.put(quoteId, updatedQuote.toJson());
      
      return updatedQuote;
    }
    
    return null;
  }
  
  // Excluir um orçamento
  Future<void> deleteQuote(String quoteId) async {
    final materialsBox = _getMaterialsBox();
    await materialsBox.delete(quoteId);
  }
}