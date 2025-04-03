import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/professional_model.dart';
import '../models/user_model.dart';

class ProfessionalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar perfil de profissional
  Future<void> createProfessionalProfile(ProfessionalModel professional) async {
    try {
      await _firestore
          .collection('professionals')
          .doc(professional.id)
          .set(professional.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Obter perfil de profissional por ID
  Future<ProfessionalModel?> getProfessionalById(String id) async {
    try {
      final doc = await _firestore.collection('professionals').doc(id).get();

      if (doc.exists) {
        return ProfessionalModel.fromJson(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Obter perfil de profissional por ID de usuário
  Future<ProfessionalModel?> getProfessionalByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('professionals')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ProfessionalModel.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar perfil de profissional
  Future<void> updateProfessionalProfile(ProfessionalModel professional) async {
    try {
      await _firestore
          .collection('professionals')
          .doc(professional.id)
          .update(professional.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Buscar profissionais por especialidade
  Future<List<Map<String, dynamic>>> searchProfessionalsBySpecialty(
      String specialty) async {
    try {
      final querySnapshot = await _firestore
          .collection('professionals')
          .where('specialties', arrayContains: specialty)
          .where('available', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(20)
          .get();

      List<Map<String, dynamic>> results = [];

      for (var doc in querySnapshot.docs) {
        final professional = ProfessionalModel.fromJson(
            doc.data() as Map<String, dynamic>);

        // Buscar dados do usuário associado
        final userDoc = await _firestore
            .collection('users')
            .doc(professional.userId)
            .get();

        if (userDoc.exists) {
          final user =
              UserModel.fromJson(userDoc.data() as Map<String, dynamic>);

          results.add({
            'professional': professional,
            'user': user,
          });
        }
      }

      return results;
    } catch (e) {
      rethrow;
    }
  }

  // Buscar profissionais por localização
  Future<List<Map<String, dynamic>>> searchProfessionalsByLocation(
      GeoPoint location, double radiusInKm) async {
    try {
      // Implementação simplificada - em um app real, seria necessário usar
      // uma solução mais robusta para busca geoespacial como Geohash ou
      // uma extensão específica do Firestore para consultas geoespaciais

      // Buscar todos os profissionais disponíveis
      final querySnapshot = await _firestore
          .collection('professionals')
          .where('available', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> results = [];

      for (var doc in querySnapshot.docs) {
        final professional = ProfessionalModel.fromJson(
            doc.data() as Map<String, dynamic>);

        // Verificar se o profissional tem localização
        if (professional.location != null) {
          // Calcular distância (implementação simplificada)
          final distance = _calculateDistance(
            location.latitude,
            location.longitude,
            professional.location!.latitude,
            professional.location!.longitude,
          );

          // Se estiver dentro do raio de busca
          if (distance <= radiusInKm) {
            // Buscar dados do usuário associado
            final userDoc = await _firestore
                .collection('users')
                .doc(professional.userId)
                .get();

            if (userDoc.exists) {
              final user =
                  UserModel.fromJson(userDoc.data() as Map<String, dynamic>);

              results.add({
                'professional': professional,
                'user': user,
                'distance': distance,
              });
            }
          }
        }
      }

      // Ordenar por distância
      results.sort((a, b) => (a['distance'] as double)
          .compareTo(b['distance'] as double));

      return results;
    } catch (e) {
      rethrow;
    }
  }

  // Método auxiliar para calcular distância entre dois pontos (fórmula de Haversine)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Raio da Terra em km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = (
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
        _sin(dLon / 2) * _sin(dLon / 2)
    );
    
    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (3.141592653589793 / 180);
  }

  double _sin(double x) {
    return _customSin(x);
  }

  double _cos(double x) {
    return _customCos(x);
  }

  double _sqrt(double x) {
    return _customSqrt(x);
  }

  double _atan2(double y, double x) {
    return _customAtan2(y, x);
  }

  // Implementações simplificadas das funções matemáticas
  // Em um app real, você usaria as funções da biblioteca dart:math
  double _customSin(double x) {
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  double _customCos(double x) {
    return 1 - (x * x) / 2 + (x * x * x * x) / 24;
  }

  double _customSqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _customAtan2(double y, double x) {
    if (x > 0) {
      return _customAtan(y / x);
    } else if (x < 0) {
      return y >= 0 ? _customAtan(y / x) + 3.141592653589793 : _customAtan(y / x) - 3.141592653589793;
    } else {
      return y > 0 ? 1.5707963267948966 : -1.5707963267948966;
    }
  }

  double _customAtan(double x) {
    return x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
  }
}