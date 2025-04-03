import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Serviço responsável por gerenciar o armazenamento local usando Hive
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  final Uuid _uuid = Uuid();
  
  // Nomes das boxes do Hive
  static const String usersBoxName = 'users';
  static const String messagesBoxName = 'messages';
  static const String chatsBoxName = 'chats';
  static const String projectsBoxName = 'projects';
  static const String professionalsBoxName = 'professionals';
  static const String reviewsBoxName = 'reviews';
  static const String imagesBoxName = 'images';
  static const String materialsBoxName = 'materials';
  
  // Singleton pattern
  factory LocalStorageService() {
    return _instance;
  }
  
  LocalStorageService._internal();
  
  /// Inicializa o Hive e abre as boxes necessárias
  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    
    // Abrir as boxes
    await Hive.openBox(usersBoxName);
    await Hive.openBox(messagesBoxName);
    await Hive.openBox(chatsBoxName);
    await Hive.openBox(projectsBoxName);
    await Hive.openBox(professionalsBoxName);
    await Hive.openBox(reviewsBoxName);
    await Hive.openBox(imagesBoxName);
    await Hive.openBox(materialsBoxName);
  }
  
  /// Obtém uma box do Hive pelo nome
  Box getBox(String boxName) {
    return Hive.box(boxName);
  }
  
  /// Salva um arquivo localmente e retorna o caminho
  Future<String> saveFile(File file, String directory) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final storageDir = Directory('${appDocDir.path}/$directory');
      
      // Criar diretório se não existir
      if (!await storageDir.exists()) {
        await storageDir.create(recursive: true);
      }
      
      // Gerar nome único para o arquivo
      final fileName = '${_uuid.v4()}${path.extension(file.path)}';
      final filePath = '${storageDir.path}/$fileName';
      
      // Copiar arquivo para o diretório de armazenamento
      await file.copy(filePath);
      
      return filePath;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Exclui um arquivo pelo caminho
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Limpa todos os dados armazenados
  Future<void> clearAllData() async {
    await Hive.box(usersBoxName).clear();
    await Hive.box(messagesBoxName).clear();
    await Hive.box(chatsBoxName).clear();
    await Hive.box(projectsBoxName).clear();
    await Hive.box(professionalsBoxName).clear();
    await Hive.box(reviewsBoxName).clear();
    await Hive.box(imagesBoxName).clear();
  }
}