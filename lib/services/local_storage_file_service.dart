import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

/// Serviço responsável por gerenciar o armazenamento de arquivos localmente
class LocalStorageFileService {
  final Uuid _uuid = Uuid();
  
  // Diretórios para armazenamento de imagens
  static const String _profileImagesDir = 'profile_images';
  static const String _portfolioImagesDir = 'portfolio_images';
  static const String _projectImagesDir = 'project_images';
  static const String _reviewImagesDir = 'review_images';
  static const String _messageImagesDir = 'message_images';
  
  // Upload de imagem de perfil
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      return await _saveImage(imageFile, _profileImagesDir, userId);
    } catch (e) {
      debugPrint('Erro ao salvar imagem de perfil: $e');
      rethrow;
    }
  }
  
  // Upload de imagem para portfólio de profissional
  Future<String> uploadPortfolioImage(File imageFile, String professionalId) async {
    try {
      return await _saveImage(imageFile, _portfolioImagesDir, professionalId);
    } catch (e) {
      debugPrint('Erro ao salvar imagem de portfólio: $e');
      rethrow;
    }
  }
  
  // Upload de imagem para projeto
  Future<String> uploadProjectImage(File imageFile, String projectId) async {
    try {
      return await _saveImage(imageFile, _projectImagesDir, projectId);
    } catch (e) {
      debugPrint('Erro ao salvar imagem de projeto: $e');
      rethrow;
    }
  }
  
  // Upload de imagem para avaliação
  Future<String> uploadReviewImage(File imageFile, String reviewId) async {
    try {
      return await _saveImage(imageFile, _reviewImagesDir, reviewId);
    } catch (e) {
      debugPrint('Erro ao salvar imagem de avaliação: $e');
      rethrow;
    }
  }
  
  // Upload de imagem para mensagem
  Future<String> uploadMessageImage(File imageFile, String chatId) async {
    try {
      return await _saveImage(imageFile, _messageImagesDir, chatId);
    } catch (e) {
      debugPrint('Erro ao salvar imagem de mensagem: $e');
      rethrow;
    }
  }
  
  // Método privado para salvar imagem
  Future<String> _saveImage(File imageFile, String directory, String prefix) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final storageDir = Directory('${appDocDir.path}/$directory');
    
    // Criar diretório se não existir
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    
    // Gerar nome único para o arquivo
    final fileName = '${prefix}_${_uuid.v4()}${path.extension(imageFile.path)}';
    final filePath = '${storageDir.path}/$fileName';
    
    // Copiar arquivo para o diretório de armazenamento
    await imageFile.copy(filePath);
    
    return filePath;
  }
  
  // Upload de múltiplas imagens
  Future<List<String>> uploadMultipleImages(List<File> imageFiles, String directory, String prefix) async {
    try {
      final List<String> imagePaths = [];
      
      for (var imageFile in imageFiles) {
        final imagePath = await _saveImage(imageFile, directory, prefix);
        imagePaths.add(imagePath);
      }
      
      return imagePaths;
    } catch (e) {
      debugPrint('Erro ao salvar múltiplas imagens: $e');
      rethrow;
    }
  }
  
  // Excluir imagem
  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Erro ao excluir imagem: $e');
      rethrow;
    }
  }
}