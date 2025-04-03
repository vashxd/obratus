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
    required this.items,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    this.totalPrice,
    this.notes,
  });

  factory MaterialQuote.fromJson(Map<String, dynamic> json) {
    return MaterialQuote(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      professionalId: json['professionalId'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => MaterialItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
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
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
      'totalPrice': totalPrice,
      'notes': notes,
    };
  }
}