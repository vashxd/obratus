import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';

/// Serviço responsável por gerenciar a autenticação local
class LocalAuthService {
  final LocalStorageService _storageService = LocalStorageService();
  final Uuid _uuid = Uuid();
  
  // Chaves para SharedPreferences
  static const String _currentUserIdKey = 'currentUserId';
  
  // Controlador de stream para o estado de autenticação
  final StreamController<String?> _authStateController = StreamController<String?>.broadcast();
  
  // Usuário atual
  String? _currentUserId;
  
  // Stream para monitorar mudanças no estado de autenticação
  Stream<String?> get authStateChanges => _authStateController.stream;
  
  // Construtor
  LocalAuthService() {
    _initCurrentUser();
  }
  
  // Inicializar usuário atual
  Future<void> _initCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString(_currentUserIdKey);
    _authStateController.add(_currentUserId);
  }
  
  // Obter ID do usuário atual
  String? get currentUserId => _currentUserId;
  
  // Obter dados do usuário atual
  Future<UserModel?> getCurrentUserData() async {
    if (_currentUserId == null) return null;
    
    final usersBox = _storageService.getBox(LocalStorageService.usersBoxName);
    final userData = usersBox.get(_currentUserId);
    
    if (userData != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    }
    
    return null;
  }
  
  // Registrar com email e senha
  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String birthDate,
    required String gender,
    required bool isClient,
  }) async {
    try {
      // Verificar se o email já está em uso
      final usersBox = _storageService.getBox(LocalStorageService.usersBoxName);
      final users = usersBox.values.toList();
      
      for (var user in users) {
        if (user['email'] == email) {
          throw Exception('Este email já está em uso');
        }
      }
      
      // Criar novo usuário
      final userId = _uuid.v4();
      final userModel = UserModel(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        birthDate: birthDate,
        gender: gender,
        createdAt: DateTime.now(),
        isClient: isClient,
      );
      
      // Salvar usuário no Hive
      await usersBox.put(userId, userModel.toJson());
      
      // Salvar senha em uma box separada (em produção, usar hash)
      final credentialsBox = await Hive.openBox('credentials');
      await credentialsBox.put(email, password);
      
      // Definir como usuário atual
      await _setCurrentUser(userId);
      
      return true;
    } catch (e) {
      debugPrint('Erro ao registrar usuário: $e');
      return false;
    }
  }
  
  // Login com email e senha
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Verificar credenciais
      final credentialsBox = await Hive.openBox('credentials');
      final savedPassword = credentialsBox.get(email);
      
      if (savedPassword != password) {
        throw Exception('Email ou senha inválidos');
      }
      
      // Buscar usuário pelo email
      final usersBox = _storageService.getBox(LocalStorageService.usersBoxName);
      final users = usersBox.values.toList();
      String? userId;
      
      for (var user in users) {
        if (user['email'] == email) {
          userId = user['id'];
          break;
        }
      }
      
      if (userId == null) {
        throw Exception('Usuário não encontrado');
      }
      
      // Definir como usuário atual
      await _setCurrentUser(userId);
      
      return true;
    } catch (e) {
      debugPrint('Erro ao fazer login: $e');
      return false;
    }
  }
  
  // Definir usuário atual
  Future<void> _setCurrentUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserIdKey, userId);
    
    _currentUserId = userId;
    _authStateController.add(_currentUserId);
  }
  
  // Logout
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
    
    _currentUserId = null;
    _authStateController.add(null);
  }
  
  // Recuperar senha (simulação)
  Future<void> resetPassword({required String email}) async {
    // Em um app real, enviaria um email
    // Aqui apenas verificamos se o email existe
    final usersBox = _storageService.getBox(LocalStorageService.usersBoxName);
    final users = usersBox.values.toList();
    bool emailExists = false;
    
    for (var user in users) {
      if (user['email'] == email) {
        emailExists = true;
        break;
      }
    }
    
    if (!emailExists) {
      throw Exception('Email não encontrado');
    }
    
    // Em um app real, enviaria um email com link para redefinir senha
    debugPrint('Email de redefinição de senha enviado para $email');
  }
  
  // Atualizar perfil do usuário
  Future<void> updateUserProfile(UserModel userModel) async {
    try {
      final usersBox = _storageService.getBox(LocalStorageService.usersBoxName);
      await usersBox.put(userModel.id, userModel.toJson());
    } catch (e) {
      rethrow;
    }
  }
  
  // Criar usuário de teste
  Future<void> createTestUser() async {
    const String email = 'teste@obratus.com';
    const String password = 'teste123';
    const String name = 'Usuário Teste';
    const String phone = '(11) 99999-9999';
    const String birthDate = '01/01/1990';
    const String gender = 'Masculino';
    
    try {
      // Verificar se o usuário já existe
      final credentialsBox = await Hive.openBox('credentials');
      final savedPassword = credentialsBox.get(email);
      
      if (savedPassword != null) {
        debugPrint('Usuário de teste já existe');
        return;
      }
      
      // Criar usuário de teste
      await registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
        birthDate: birthDate,
        gender: gender,
        isClient: true,
      );
      
      // Fazer logout para que o usuário possa fazer login manualmente
      await signOut();
      
      debugPrint('Usuário de teste criado com sucesso');
    } catch (e) {
      debugPrint('Erro ao criar usuário de teste: $e');
    }
  }
  
  // Dispose
  void dispose() {
    _authStateController.close();
  }
}