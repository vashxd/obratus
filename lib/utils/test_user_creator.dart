import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class TestUserCreator {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria um usuário de teste no Firebase Auth e Firestore
  static Future<void> createTestUser() async {
    const String email = 'teste@obratus.com';
    const String password = 'teste123';
    const String name = 'Usuário Teste';
    const String phone = '(11) 99999-9999';
    const String birthDate = '01/01/1990';
    const String gender = 'Masculino';
    
    try {
      // Verificar se o usuário já existe
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('Usuário de teste já existe');
      } catch (e) {
        // Se o usuário não existir, criar um novo
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        // Adicionar informações do usuário no Firestore
        if (userCredential.user != null) {
          final userModel = UserModel(
            id: userCredential.user!.uid,
            name: name,
            email: email,
            phone: phone,
            birthDate: birthDate,
            gender: gender,
            createdAt: DateTime.now(),
            isClient: true, // Usuário de teste como cliente
          );
          
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toJson());
              
          print('Usuário de teste criado com sucesso');
        }
      }
      
      // Fazer logout para que o usuário possa fazer login manualmente
      await _auth.signOut();
    } catch (e) {
      print('Erro ao criar usuário de teste: $e');
    }
  }
}