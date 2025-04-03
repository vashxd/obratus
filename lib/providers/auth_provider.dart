import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final LocalAuthService _authService = LocalAuthService();
  String? _userId;
  UserModel? _userModel;
  bool _isLoading = false;

  String? get userId => _userId;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _userId = _authService.currentUserId;
    if (_userId != null) {
      // Carregar dados do usuário do armazenamento local
      _userModel = await _authService.getCurrentUserData();
    }
    notifyListeners();
  }

  // Método para salvar as credenciais quando o usuário marca "lembrar-me"
  Future<void> saveCredentials(String email, String password, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  // Método para recuperar as credenciais salvas
  Future<Map<String, dynamic>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final password = prefs.getString('password') ?? '';
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }

  // Login com email e senha
  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (success) {
        _userId = _authService.currentUserId;
        _userModel = await _authService.getCurrentUserData();
        
        // Salvar credenciais se rememberMe estiver marcado
        await saveCredentials(email, password, rememberMe);
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login com Google (simulado no armazenamento local)
  Future<bool> loginWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // No armazenamento local, não temos integração real com o Google
      // Podemos mostrar uma mensagem informando que esta funcionalidade não está disponível
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login com Apple (simulado no armazenamento local)
  Future<bool> loginWithApple() async {
    try {
      _isLoading = true;
      notifyListeners();

      // No armazenamento local, não temos integração real com a Apple
      // Podemos mostrar uma mensagem informando que esta funcionalidade não está disponível
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.signOut();
      _userId = null;
      _userModel = null;
      notifyListeners();
    } catch (e) {
      // Tratar erro
    }
  }
  
  // Atualizar perfil do usuário
  Future<void> updateUserProfile(UserModel userModel) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.updateUserProfile(userModel);
      _userModel = userModel;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }
}