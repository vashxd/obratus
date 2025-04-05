import '../models/professional_model.dart';
import '../models/user_model.dart';
import 'local_professional_service.dart';

class ProfessionalService {
  // Usando o serviço local enquanto o Firebase não está configurado
  final LocalProfessionalService _localService = LocalProfessionalService();

  // Criar perfil de profissional
  Future<void> createProfessionalProfile(ProfessionalModel professional) async {
    try {
      await _localService.createProfessionalProfile(professional.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Obter perfil de profissional por ID
  Future<ProfessionalModel?> getProfessionalById(String id) async {
    try {
      final data = await _localService.getProfessionalById(id);
      
      if (data != null) {
        return ProfessionalModel.fromJson(data);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Obter perfil de profissional por ID de usuário
  Future<ProfessionalModel?> getProfessionalByUserId(String userId) async {
    try {
      final data = await _localService.getProfessionalByUserId(userId);
      
      if (data != null) {
        return ProfessionalModel.fromJson(data);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar perfil de profissional
  Future<void> updateProfessionalProfile(ProfessionalModel professional) async {
    try {
      await _localService.updateProfessionalProfile(professional.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Buscar profissionais por especialidade
  Future<List<Map<String, dynamic>>> searchProfessionalsBySpecialty(
      String specialty) async {
    try {
      // Usar o serviço local para buscar profissionais
      final professionals = await _localService.searchProfessionalsBySpecialty(specialty);
      
      // Se não houver profissionais reais, usar dados simulados filtrados por especialidade
      if (professionals.isEmpty) {
        return await _localService.getMockProfessionals(specialty: specialty);
      }
      
      return professionals;
    } catch (e) {
      rethrow;
    }
  }

  // Buscar profissionais por proximidade geográfica
  Future<List<Map<String, dynamic>>> searchProfessionalsByLocation(
      GeoPoint location, double radiusInKm) async {
    // Implementação simplificada para modo local
    // Em um ambiente real, isso usaria cálculos de distância geográfica
    try {
      // Por enquanto, retorna dados simulados
      return await _localService.getMockProfessionals();
    } catch (e) {
      rethrow;
    }
  }

  // Buscar profissionais por especialidade e localização
  Future<List<Map<String, dynamic>>> searchProfessionalsBySpecialtyAndLocation(
      String specialty, GeoPoint location, double radiusInKm) async {
    try {
      // Implementação simplificada para modo local
      final professionals = await searchProfessionalsBySpecialty(specialty);
      
      // Em um ambiente real, filtraria por distância
      return professionals;
    } catch (e) {
      rethrow;
    }
  }

  // Obter dados simulados para desenvolvimento
  Future<List<Map<String, dynamic>>> getMockProfessionals({String? specialty}) async {
    return await _localService.getMockProfessionals(specialty: specialty);
  }
}