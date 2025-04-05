import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String clientId; // ID do cliente que criou o projeto
  final String? professionalId; // ID do profissional contratado (pode ser nulo se ainda não contratado)
  final String title; // Título do projeto
  final String description; // Descrição do projeto
  final DateTime createdAt; // Data de criação
  final DateTime? startDate; // Data de início do projeto
  final DateTime? endDate; // Data de conclusão prevista
  final String status; // Status do projeto (pendente, em andamento, concluído, etc)
  final List<MaterialItem> materials; // Lista de materiais necessários
  final double? budget; // Orçamento total
  final GeoPoint? location; // Localização do projeto
  final List<String>? photoUrls; // Fotos do projeto

  ProjectModel({
    required this.id,
    required this.clientId,
    this.professionalId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.startDate,
    this.endDate,
    required this.status,
    required this.materials,
    this.budget,
    this.location,
    this.photoUrls,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      professionalId: json['professionalId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      startDate: json['startDate'] != null
          ? (json['startDate'] as Timestamp).toDate()
          : null,
      endDate: json['endDate'] != null
          ? (json['endDate'] as Timestamp).toDate()
          : null,
      status: json['status'] as String,
      materials: (json['materials'] as List)
          .map((e) => MaterialItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      budget: json['budget'] != null ? (json['budget'] as num).toDouble() : null,
      location: json['location'] as GeoPoint?,
      photoUrls: json['photoUrls'] != null
          ? List<String>.from(json['photoUrls'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'professionalId': professionalId,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status,
      'materials': materials.map((e) => e.toJson()).toList(),
      'budget': budget,
      'location': location,
      'photoUrls': photoUrls,
    };
  }
  
  // Método para converter para JSON compatível com Hive
  Map<String, dynamic> toHiveJson() {
    return {
      'id': id,
      'clientId': clientId,
      'professionalId': professionalId,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status,
      'materials': materials.map((e) => e.toJson()).toList(),
      'budget': budget,
      'location': location,
      'photoUrls': photoUrls,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? clientId,
    String? professionalId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    List<MaterialItem>? materials,
    double? budget,
    GeoPoint? location,
    List<String>? photoUrls,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      professionalId: professionalId ?? this.professionalId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      materials: materials ?? this.materials,
      budget: budget ?? this.budget,
      location: location ?? this.location,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }
}

class MaterialItem {
  final String id;
  final String name; // Nome do material
  final String? description; // Descrição opcional
  final int quantity; // Quantidade
  final String unit; // Unidade (kg, m², unidades, etc)
  final double? price; // Preço unitário (pode ser nulo se ainda não orçado)
  final bool provided; // Se o material será fornecido pelo cliente ou profissional
  final String? notes; // Observações adicionais

  MaterialItem({
    required this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.unit,
    this.price,
    required this.provided,
    this.notes,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      provided: json['provided'] as bool,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'provided': provided,
      'notes': notes,
    };
  }

  MaterialItem copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    String? unit,
    double? price,
    bool? provided,
    String? notes,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      provided: provided ?? this.provided,
      notes: notes ?? this.notes,
    );
  }
}