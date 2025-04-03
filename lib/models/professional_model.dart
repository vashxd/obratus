import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalModel {
  final String id;
  final String userId; // Referência ao UserModel
  final List<String> specialties; // Lista de especialidades (pedreiro, eletricista, etc)
  final String experience; // Descrição da experiência
  final List<String>? portfolioUrls; // URLs de fotos do portfólio
  final double rating; // Média das avaliações
  final int ratingCount; // Quantidade de avaliações
  final GeoPoint? location; // Localização para busca por proximidade
  final bool available; // Disponibilidade para novos trabalhos

  ProfessionalModel({
    required this.id,
    required this.userId,
    required this.specialties,
    required this.experience,
    this.portfolioUrls,
    required this.rating,
    required this.ratingCount,
    this.location,
    required this.available,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      specialties: List<String>.from(json['specialties'] as List),
      experience: json['experience'] as String,
      portfolioUrls: json['portfolioUrls'] != null
          ? List<String>.from(json['portfolioUrls'] as List)
          : null,
      rating: (json['rating'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int,
      location: json['location'] as GeoPoint?,
      available: json['available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'specialties': specialties,
      'experience': experience,
      'portfolioUrls': portfolioUrls,
      'rating': rating,
      'ratingCount': ratingCount,
      'location': location,
      'available': available,
    };
  }

  ProfessionalModel copyWith({
    String? id,
    String? userId,
    List<String>? specialties,
    String? experience,
    List<String>? portfolioUrls,
    double? rating,
    int? ratingCount,
    GeoPoint? location,
    bool? available,
  }) {
    return ProfessionalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      specialties: specialties ?? this.specialties,
      experience: experience ?? this.experience,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      location: location ?? this.location,
      available: available ?? this.available,
    );
  }
}