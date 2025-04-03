class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String gender;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isClient; // true para cliente, false para profissional

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.gender,
    this.photoUrl,
    required this.createdAt,
    required this.isClient,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      birthDate: json['birthDate'] as String,
      gender: json['gender'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isClient: json['isClient'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'gender': gender,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'isClient': isClient,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? birthDate,
    String? gender,
    String? photoUrl,
    DateTime? createdAt,
    bool? isClient,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isClient: isClient ?? this.isClient,
    );
  }
}