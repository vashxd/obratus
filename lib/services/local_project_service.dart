import 'package:uuid/uuid.dart';
import '../models/project_model.dart';
import 'local_storage_service.dart';

/// Serviço responsável por gerenciar os projetos/obras localmente
class LocalProjectService {
  final LocalStorageService _storageService = LocalStorageService();
  final Uuid _uuid = Uuid();
  
  // Obter todos os projetos
  List<ProjectModel> getAllProjects() {
    try {
      final projectsBox = _storageService.getBox(LocalStorageService.projectsBoxName);
      final projectsData = projectsBox.values.toList();
      
      return projectsData
          .map((data) => ProjectModel.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Obter projetos de um cliente
  List<ProjectModel> getClientProjects(String clientId) {
    try {
      final projectsBox = _storageService.getBox(LocalStorageService.projectsBoxName);
      final projectsData = projectsBox.values.toList();
      
      return projectsData
          .map((data) => ProjectModel.fromJson(Map<String, dynamic>.from(data)))
          .where((project) => project.clientId == clientId)
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Obter projeto por ID
  ProjectModel? getProjectById(String projectId) {
    try {
      final projectsBox = _storageService.getBox(LocalStorageService.projectsBoxName);
      final projectData = projectsBox.get(projectId);
      
      if (projectData != null) {
        return ProjectModel.fromJson(Map<String, dynamic>.from(projectData));
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Criar novo projeto
  Future<String> createProject(ProjectModel project) async {
    try {
      final projectsBox = _storageService.getBox(LocalStorageService.projectsBoxName);
      final projectId = _uuid.v4();
      final newProject = project.copyWith(id: projectId);
      
      await projectsBox.put(projectId, newProject.toHiveJson());
      return projectId;
    } catch (e) {
      rethrow;
    }
  }
  
  // Atualizar projeto
  Future<void> updateProject(ProjectModel project) async {
    try {
      final projectsBox = _storageService.getBox(LocalStorageService.projectsBoxName);
      await projectsBox.put(project.id, project.toHiveJson());
    } catch (e) {
      rethrow;
    }
  }
  
  // Excluir projeto
  Future<void> deleteProject(String projectId) async {
    try {
      final projectsBox = _storageService.getBox(LocalStorageService.projectsBoxName);
      await projectsBox.delete(projectId);
    } catch (e) {
      rethrow;
    }
  }
  
  // Adicionar material ao projeto
  Future<void> addMaterialToProject(String projectId, MaterialItem material) async {
    try {
      final project = getProjectById(projectId);
      if (project == null) {
        throw Exception('Projeto não encontrado');
      }
      
      final materialId = _uuid.v4();
      final newMaterial = material.copyWith(id: materialId);
      final updatedMaterials = [...project.materials, newMaterial];
      final updatedProject = project.copyWith(materials: updatedMaterials);
      
      // Usar o método toHiveJson() para salvar no Hive
      final projectsBox = _storageService.getBox(LocalStorageService.projectsBoxName);
      await projectsBox.put(updatedProject.id, updatedProject.toHiveJson());
    } catch (e) {
      rethrow;
    }
  }
  
  // Atualizar material do projeto
  Future<void> updateMaterialInProject(String projectId, MaterialItem material) async {
    try {
      final project = getProjectById(projectId);
      if (project == null) {
        throw Exception('Projeto não encontrado');
      }
      
      final updatedMaterials = project.materials.map((m) {
        if (m.id == material.id) {
          return material;
        }
        return m;
      }).toList();
      
      final updatedProject = project.copyWith(materials: updatedMaterials);
      await updateProject(updatedProject);
    } catch (e) {
      rethrow;
    }
  }
  
  // Remover material do projeto
  Future<void> removeMaterialFromProject(String projectId, String materialId) async {
    try {
      final project = getProjectById(projectId);
      if (project == null) {
        throw Exception('Projeto não encontrado');
      }
      
      final updatedMaterials = project.materials.where((m) => m.id != materialId).toList();
      final updatedProject = project.copyWith(materials: updatedMaterials);
      
      // Usar o método toHiveJson() para salvar no Hive
      final projectsBox = _storageService.getBox(LocalStorageService.projectsBoxName);
      await projectsBox.put(updatedProject.id, updatedProject.toHiveJson());
    } catch (e) {
      rethrow;
    }
  }
  
  // Atribuir profissional ao projeto
  Future<void> assignProfessionalToProject(String projectId, String professionalId) async {
    try {
      final project = getProjectById(projectId);
      if (project == null) {
        throw Exception('Projeto não encontrado');
      }
      
      final updatedProject = project.copyWith(
        professionalId: professionalId,
        status: 'em_andamento',
      );
      
      await updateProject(updatedProject);
    } catch (e) {
      rethrow;
    }
  }
  
  // Atualizar status do projeto
  Future<void> updateProjectStatus(String projectId, String status) async {
    try {
      final project = getProjectById(projectId);
      if (project == null) {
        throw Exception('Projeto não encontrado');
      }
      
      final updatedProject = project.copyWith(status: status);
      await updateProject(updatedProject);
    } catch (e) {
      rethrow;
    }
  }
  
  // Adicionar fotos ao projeto
  Future<void> addPhotosToProject(String projectId, List<String> photoUrls) async {
    try {
      final project = getProjectById(projectId);
      if (project == null) {
        throw Exception('Projeto não encontrado');
      }
      
      final List<String> currentPhotoUrls = project.photoUrls?.cast<String>() ?? [];
      final updatedPhotoUrls = [...currentPhotoUrls, ...photoUrls];
      final updatedProject = project.copyWith(photoUrls: updatedPhotoUrls);
      
      await updateProject(updatedProject);
    } catch (e) {
      rethrow;
    }
  }
}