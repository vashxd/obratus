import '../models/user_model.dart';
import 'local_auth_service.dart';

class AuthService {
  final LocalAuthService _localAuth = LocalAuthService();

  // Obter ID do usuário atual
  String? get currentUserId => _localAuth.currentUserId;

  // Stream para monitorar mudanças no estado de autenticação
  Stream<String?> get authStateChanges => _localAuth.authStateChanges;

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
      return await _localAuth.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
        birthDate: birthDate,
        gender: gender,
        isClient: isClient,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Login com email e senha
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _localAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Obter dados do usuário atual
  Future<UserModel?> getCurrentUserData() async {
    try {
      return await _localAuth.getCurrentUserData();
    } catch (e) {
      rethrow;
    }
  }

  // Login com Apple - Implementação local simplificada
  Future<bool> signInWithApple() async {
    try {
      // Em uma implementação real, aqui seria integrado com o Sign in with Apple
      // Para esta versão local, retornamos false indicando que não está implementado
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Login com Google - Implementação local simplificada
  Future<bool> signInWithGoogle() async {
    try {
      // Em uma implementação real, aqui seria integrado com o Google Sign-In
      // Para esta versão local, retornamos false indicando que não está implementado
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Recuperar senha
  Future<void> resetPassword({required String email}) async {
    try {
      await _localAuth.resetPassword(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _localAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar perfil do usuário
  Future<void> updateUserProfile(UserModel userModel) async {
    try {
      await _localAuth.updateUserProfile(userModel);
    } catch (e) {
      rethrow;
    }
  }
}