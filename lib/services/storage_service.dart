import 'dart:io';
import 'package:flutter/foundation.dart';
import 'local_storage_file_service.dart';

/// Serviço responsável por gerenciar o armazenamento de arquivos
/// Esta classe serve como uma fachada para o LocalStorageFileService
class StorageService {
  final LocalStorageFileService _storageFileService = LocalStorageFileService();

  // Upload de imagem de perfil
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      return await _storageFileService.uploadProfileImage(imageFile, userId);
    } catch (e) {
      debugPrint('Erro ao fazer upload de imagem de perfil: $e');
      rethrow;
    }
  }

  // Upload de imagem para portfólio de profissional
  Future<String> uploadPortfolioImage(File imageFile, String professionalId) async {
    try {
      return await _storageFileService.uploadPortfolioImage(imageFile, professionalId);
    } catch (e) {
      debugPrint('Erro ao fazer upload de imagem de portfólio: $e');
      rethrow;
    }
  }

  // Upload de imagem para projeto
  Future<String> uploadProjectImage(File imageFile, String projectId) async {
    try {
      return await _storageFileService.uploadProjectImage(imageFile, projectId);
    } catch (e) {
      debugPrint('Erro ao fazer upload de imagem de projeto: $e');
      rethrow;
    }
  }

  // Upload de imagem para avaliação
  Future<String> uploadReviewImage(File imageFile, String reviewId) async {
    try {
      return await _storageFileService.uploadReviewImage(imageFile, reviewId);
    } catch (e) {
      debugPrint('Erro ao fazer upload de imagem de avaliação: $e');
      rethrow;
    }
  }

  // Upload de imagem para mensagem
  Future<String> uploadMessageImage(File imageFile, String chatId) async {
    try {
      return await _storageFileService.uploadMessageImage(imageFile, chatId);
    } catch (e) {
      debugPrint('Erro ao fazer upload de imagem de mensagem: $e');
      rethrow;
    }
  }

  // Excluir imagem
  Future<void> deleteImage(String imagePath) async {
    try {
      await _storageFileService.deleteImage(imagePath);
    } catch (e) {
      debugPrint('Erro ao excluir imagem: $e');
      rethrow;
    }
  }

  // Upload de múltiplas imagens
  Future<List<String>> uploadMultipleImages(List<File> imageFiles, String directory, String prefix) async {
    try {
      return await _storageFileService.uploadMultipleImages(imageFiles, directory, prefix);
    } catch (e) {
      debugPrint('Erro ao fazer upload de múltiplas imagens: $e');
      rethrow;
    }
  }
}