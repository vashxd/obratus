import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String projectId; // ID do projeto relacionado à avaliação
  final String reviewerId; // ID do usuário que fez a avaliação
  final String reviewedId; // ID do usuário que foi avaliado
  final bool isClientReview; // true se cliente avaliando profissional, false se profissional avaliando cliente
  final double rating; // Avaliação de 1 a 5 estrelas
  final String comment; // Comentário sobre a avaliação
  final DateTime createdAt; // Data da avaliação
  final List<String>? photoUrls; // Fotos opcionais do serviço

  ReviewModel({
    required this.id,
    required this.projectId,
    required this.reviewerId,
    required this.reviewedId,
    required this.isClientReview,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.photoUrls,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      reviewerId: json['reviewerId'] as String,
      reviewedId: json['reviewedId'] as String,
      isClientReview: json['isClientReview'] as bool,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      photoUrls: json['photoUrls'] != null
          ? List<String>.from(json['photoUrls'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'reviewerId': reviewerId,
      'reviewedId': reviewedId,
      'isClientReview': isClientReview,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'photoUrls': photoUrls,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? projectId,
    String? reviewerId,
    String? reviewedId,
    bool? isClientReview,
    double? rating,
    String? comment,
    DateTime? createdAt,
    List<String>? photoUrls,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewedId: reviewedId ?? this.reviewedId,
      isClientReview: isClientReview ?? this.isClientReview,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }
}