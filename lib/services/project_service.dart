import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar novo projeto
  Future<String> createProject(ProjectModel project) async {
    try {
      final docRef = _firestore.collection('projects').doc();
      final newProject = project.copyWith(id: docRef.id);
      await docRef.set(newProject.toJson());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Obter projeto por ID
  Future<ProjectModel?> getProjectById(String id) async {
    try {
      final doc = await _firestore.collection('projects').doc(id).get();

      if (doc.exists) {
        return ProjectModel.fromJson(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar projeto
  Future<void> updateProject(ProjectModel project) async {
    try {
      await _firestore
          .collection('projects')
          .doc(project.id)
          .update(project.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Obter projetos de um cliente
  Future<List<ProjectModel>> getClientProjects(String clientId) async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .where('clientId', isEqualTo: clientId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProjectModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obter projetos de um profissional
  Future<List<ProjectModel>> getProfessionalProjects(String professionalId) async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .where('professionalId', isEqualTo: professionalId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProjectModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Adicionar material ao projeto
  Future<void> addMaterialToProject(String projectId, MaterialItem material) async {
    try {
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception('Projeto não encontrado');
      }

      final updatedMaterials = [...project.materials, material];
      await _firestore.collection('projects').doc(projectId).update({
        'materials': updatedMaterials.map((m) => m.toJson()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar material do projeto
  Future<void> updateMaterialInProject(String projectId, MaterialItem material) async {
    try {
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception('Projeto não encontrado');
      }

      final updatedMaterials = project.materials.map((m) {
        if (m.id == material.id) {
          return material;
        }
        return m;
      }).toList();

      await _firestore.collection('projects').doc(projectId).update({
        'materials': updatedMaterials.map((m) => m.toJson()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Remover material do projeto
  Future<void> removeMaterialFromProject(String projectId, String materialId) async {
    try {
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception('Projeto não encontrado');
      }

      final updatedMaterials = project.materials.where((m) => m.id != materialId).toList();
      await _firestore.collection('projects').doc(projectId).update({
        'materials': updatedMaterials.map((m) => m.toJson()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Atribuir profissional ao projeto
  Future<void> assignProfessionalToProject(String projectId, String professionalId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'professionalId': professionalId,
        'status': 'em_andamento',
      });
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar status do projeto
  Future<void> updateProjectStatus(String projectId, String status) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'status': status,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Adicionar fotos ao projeto
  Future<void> addPhotosToProject(String projectId, List<String> photoUrls) async {
    try {
      final project = await getProjectById(projectId);
      if (project == null) {
        throw Exception('Projeto não encontrado');
      }

      final updatedPhotoUrls = [...(project.photoUrls ?? []), ...photoUrls];
      await _firestore.collection('projects').doc(projectId).update({
        'photoUrls': updatedPhotoUrls,
      });
    } catch (e) {
      rethrow;
    }
  }
}