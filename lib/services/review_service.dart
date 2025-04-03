import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../models/professional_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar nova avaliação
  Future<String> createReview(ReviewModel review) async {
    try {
      // Criar a avaliação no Firestore
      final docRef = _firestore.collection('reviews').doc();
      final newReview = review.copyWith(id: docRef.id);
      await docRef.set(newReview.toJson());

      // Se for uma avaliação de cliente para profissional, atualizar a média de avaliações do profissional
      if (review.isClientReview) {
        await _updateProfessionalRating(review.reviewedId);
      }

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Obter avaliação por ID
  Future<ReviewModel?> getReviewById(String id) async {
    try {
      final doc = await _firestore.collection('reviews').doc(id).get();

      if (doc.exists) {
        return ReviewModel.fromJson(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Obter avaliações recebidas por um usuário
  Future<List<ReviewModel>> getReviewsForUser(String userId, {bool isClient = true}) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('reviewedId', isEqualTo: userId)
          .where('isClientReview', isEqualTo: !isClient) // Se isClient=true, buscamos avaliações onde isClientReview=false (profissionais avaliando clientes)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obter avaliações feitas por um usuário
  Future<List<ReviewModel>> getReviewsByUser(String userId, {bool isClient = true}) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('reviewerId', isEqualTo: userId)
          .where('isClientReview', isEqualTo: isClient) // Se isClient=true, buscamos avaliações onde isClientReview=true (clientes avaliando profissionais)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obter avaliações de um projeto específico
  Future<List<ReviewModel>> getReviewsForProject(String projectId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('projectId', isEqualTo: projectId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar a média de avaliações de um profissional
  Future<void> _updateProfessionalRating(String professionalId) async {
    try {
      // Buscar todas as avaliações do profissional
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('reviewedId', isEqualTo: professionalId)
          .where('isClientReview', isEqualTo: true)
          .get();

      final reviews = querySnapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      if (reviews.isEmpty) return;

      // Calcular a média das avaliações
      final totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
      final averageRating = totalRating / reviews.length;

      // Atualizar o documento do profissional
      await _firestore.collection('professionals').doc(professionalId).update({
        'rating': averageRating,
        'ratingCount': reviews.length,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Verificar se um usuário já avaliou um projeto
  Future<bool> hasUserReviewedProject(String userId, String projectId, bool isClientReview) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('reviewerId', isEqualTo: userId)
          .where('projectId', isEqualTo: projectId)
          .where('isClientReview', isEqualTo: isClientReview)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  // Adicionar fotos a uma avaliação existente
  Future<void> addPhotosToReview(String reviewId, List<String> photoUrls) async {
    try {
      final review = await getReviewById(reviewId);
      if (review == null) {
        throw Exception('Avaliação não encontrada');
      }

      final updatedPhotoUrls = [...(review.photoUrls ?? []), ...photoUrls];
      await _firestore.collection('reviews').doc(reviewId).update({
        'photoUrls': updatedPhotoUrls,
      });
    } catch (e) {
      rethrow;
    }
  }
}