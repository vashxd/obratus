import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialItem {
  final String id;
  final String name;
  final String brand;
  final int quantity;
  final String? unit; // unidade de medida (kg, m, unidade, etc)
  final String? notes; // observações adicionais

  MaterialItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.quantity,
    this.unit,
    this.notes,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
    };
  }
}

class MaterialQuote {
  final String id;
  final String clientId;
  final String? professionalId; // pode ser nulo se ainda não foi atribuído
  final String? projectId; // ID do projeto ao qual este orçamento está associado
  final List<MaterialItem> items;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status; // 'pending', 'quoted', 'accepted', 'rejected'
  final double? totalPrice; // preço total do orçamento (quando respondido)
  final String? notes; // observações do profissional

  MaterialQuote({
    required this.id,
    required this.clientId,
    this.professionalId,
    this.projectId,
    required this.items,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    this.totalPrice,
    this.notes,
  });


  factory MaterialQuote.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para converter diferentes tipos de data para DateTime
    DateTime? convertToDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return null;
    }
    
    return MaterialQuote(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      professionalId: json['professionalId'] as String?,
      projectId: json['projectId'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => MaterialItem.fromJson(
                // Converter Map<dynamic, dynamic> para Map<String, dynamic>
                (item is Map<String, dynamic>)
                    ? item
                    : Map<String, dynamic>.from(item as Map)
              ))
          .toList(),
      createdAt: convertToDateTime(json['createdAt'])!,
      updatedAt: convertToDateTime(json['updatedAt']),
      status: json['status'] as String,
      totalPrice: json['totalPrice'] as double?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'professionalId': professionalId,
      'projectId': projectId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
      'totalPrice': totalPrice,
      'notes': notes,
    };
  }
  
  // Método para converter para JSON compatível com Hive
  Map<String, dynamic> toHiveJson() {
    return {
      'id': id,
      'clientId': clientId,
      'professionalId': professionalId,
      'projectId': projectId,
      'items': items.map((e) => e.toJson()).toList(),
      'createdAt': createdAt is DateTime ? Timestamp.fromDate(createdAt) : createdAt,
      'updatedAt': updatedAt != null ? (updatedAt is DateTime ? Timestamp.fromDate(updatedAt!) : updatedAt) : null,
      'status': status,
      'totalPrice': totalPrice,
      'notes': notes,
    };
  }
}