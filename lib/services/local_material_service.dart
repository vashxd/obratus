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
  Future<MaterialQuote> createMaterialQuote(String clientId, List<MaterialItem> items, {String? projectId}) async {
    final materialsBox = _getMaterialsBox();
    
    // Criar um novo orçamento
    final MaterialQuote quote = MaterialQuote(
      id: _uuid.v4(),
      clientId: clientId,
      projectId: projectId, // Associar ao projeto, se fornecido
      items: items,
      createdAt: DateTime.now(),
      status: 'pending', // status inicial: pendente
    );
    
    // Salvar no Hive usando o método toHiveJson()
    await materialsBox.put(quote.id, quote.toHiveJson());
    
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
  
  // Obter orçamentos pendentes para um profissional específico
  // Filtra orçamentos de projetos aos quais o profissional está vinculado
  Future<List<MaterialQuote>> getPendingQuotesByProfessional(String professionalId) async {
    final materialsBox = _getMaterialsBox();
    final projectsBox = _storageService.getBox(LocalStorageService.projectsBoxName);
    
    // Lista para armazenar os IDs dos projetos vinculados ao profissional
    final List<String> linkedProjectIds = [];
    
    // Buscar todos os projetos vinculados ao profissional
    for (var key in projectsBox.keys) {
      final projectData = projectsBox.get(key);
      if (projectData != null) {
        final Map<String, dynamic> projectMap = Map<String, dynamic>.from(projectData);
        final List<dynamic> professionalIds = projectMap['professionalIds'] ?? [];
        
        // Verificar se o profissional está vinculado a este projeto
        if (professionalIds.contains(professionalId)) {
          linkedProjectIds.add(key.toString());
        }
      }
    }
    
    // Filtrar orçamentos pendentes dos projetos vinculados ao profissional
    final List<MaterialQuote> quotes = [];
    
    for (var key in materialsBox.keys) {
      final data = materialsBox.get(key);
      if (data != null) {
        final quote = MaterialQuote.fromJson(Map<String, dynamic>.from(data));
        // Verificar se o orçamento está pendente e pertence a um projeto vinculado ao profissional
        if (quote.status == 'pending' && quote.projectId != null && linkedProjectIds.contains(quote.projectId)) {
          quotes.add(quote);
        }
      }
    }
    
    // Ordenar por data de criação (mais antigo primeiro)
    quotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    return quotes;
  }
  
  // Obter orçamentos por status para um profissional específico
  Future<List<MaterialQuote>> getQuotesByStatusAndProfessional(String professionalId, String status) async {
    final materialsBox = _getMaterialsBox();
    final projectsBox = _storageService.getBox(LocalStorageService.projectsBoxName);
    
    // Lista para armazenar os IDs dos projetos vinculados ao profissional
    final List<String> linkedProjectIds = [];
    
    // Buscar todos os projetos vinculados ao profissional
    for (var key in projectsBox.keys) {
      final projectData = projectsBox.get(key);
      if (projectData != null) {
        final Map<String, dynamic> projectMap = Map<String, dynamic>.from(projectData);
        final List<dynamic> professionalIds = projectMap['professionalIds'] ?? [];
        
        // Verificar se o profissional está vinculado a este projeto
        if (professionalIds.contains(professionalId)) {
          linkedProjectIds.add(key.toString());
        }
      }
    }
    
    // Filtrar orçamentos pelo status e dos projetos vinculados ao profissional
    final List<MaterialQuote> quotes = [];
    
    for (var key in materialsBox.keys) {
      final data = materialsBox.get(key);
      if (data != null) {
        final quote = MaterialQuote.fromJson(Map<String, dynamic>.from(data));
        // Verificar se o orçamento tem o status solicitado e pertence a um projeto vinculado ao profissional
        if (quote.status == status && quote.projectId != null && linkedProjectIds.contains(quote.projectId)) {
          quotes.add(quote);
        }
      }
    }
    
    // Ordenar por data de criação (mais recente primeiro para orçamentos já respondidos)
    if (status == 'pending') {
      quotes.sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Mais antigo primeiro para pendentes
    } else {
      quotes.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Mais recente primeiro para outros status
    }
    
    return quotes;
  }
  
  // Obter todos os orçamentos de um projeto específico
  Future<List<MaterialQuote>> getProjectQuotes(String projectId) async {
    final materialsBox = _getMaterialsBox();
    
    // Filtrar orçamentos pelo ID do projeto
    final List<MaterialQuote> quotes = [];
    
    for (var key in materialsBox.keys) {
      final data = materialsBox.get(key);
      if (data != null) {
        final quote = MaterialQuote.fromJson(Map<String, dynamic>.from(data));
        if (quote.projectId == projectId) {
          quotes.add(quote);
        }
      }
    }
    
    // Ordenar por data de criação (mais recente primeiro)
    quotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
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
        projectId: quote.projectId, // Manter o ID do projeto
        items: quote.items,
        createdAt: quote.createdAt,
        updatedAt: DateTime.now(),
        status: 'quoted', // status atualizado: orçado
        totalPrice: totalPrice,
        notes: notes,
      );
      
      // Salvar no Hive usando o método toHiveJson()
      await materialsBox.put(quoteId, updatedQuote.toHiveJson());
      
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
        projectId: quote.projectId, // Manter o ID do projeto
        items: quote.items,
        createdAt: quote.createdAt,
        updatedAt: DateTime.now(),
        status: status, // 'accepted' ou 'rejected'
        totalPrice: quote.totalPrice,
        notes: quote.notes,
      );
      
      // Salvar no Hive usando o método toHiveJson()
      await materialsBox.put(quoteId, updatedQuote.toHiveJson());
      
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