import 'package:uuid/uuid.dart';
import '../models/professional_model.dart';
import '../models/user_model.dart';
import '../utils/local_models_adapter.dart';
import 'local_storage_service.dart';

/// Serviço para gerenciar profissionais localmente sem depender do Firebase
class LocalProfessionalService {
  final LocalStorageService _storageService = LocalStorageService();
  final Uuid _uuid = Uuid();
  
  // Criar perfil de profissional
  Future<void> createProfessionalProfile(Map<String, dynamic> professionalData) async {
    try {
      final box = _storageService.getBox(LocalStorageService.professionalsBoxName);
      final id = _uuid.v4();
      
      professionalData['id'] = id;
      
      // Converter para formato compatível com armazenamento local
      final localData = LocalModelsAdapter.mapToLocalStorage(professionalData);
      
      await box.put(id, localData);
    } catch (e) {
      rethrow;
    }
  }

  // Obter perfil de profissional por ID
  Future<Map<String, dynamic>?> getProfessionalById(String id) async {
    try {
      final box = _storageService.getBox(LocalStorageService.professionalsBoxName);
      final data = box.get(id);
      
      if (data != null) {
        return Map<String, dynamic>.from(data);
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Obter perfil de profissional por ID de usuário
  Future<Map<String, dynamic>?> getProfessionalByUserId(String userId) async {
    try {
      final box = _storageService.getBox(LocalStorageService.professionalsBoxName);
      
      for (var key in box.keys) {
        final data = box.get(key);
        if (data != null && data['userId'] == userId) {
          return Map<String, dynamic>.from(data);
        }
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Atualizar perfil de profissional
  Future<void> updateProfessionalProfile(Map<String, dynamic> professionalData) async {
    try {
      final box = _storageService.getBox(LocalStorageService.professionalsBoxName);
      final id = professionalData['id'];
      
      if (id == null) {
        throw Exception('ID do profissional não fornecido');
      }
      
      // Converter para formato compatível com armazenamento local
      final localData = LocalModelsAdapter.mapToLocalStorage(professionalData);
      
      await box.put(id, localData);
    } catch (e) {
      rethrow;
    }
  }

  // Buscar profissionais por especialidade
  Future<List<Map<String, dynamic>>> searchProfessionalsBySpecialty(String specialty) async {
    try {
      final box = _storageService.getBox(LocalStorageService.professionalsBoxName);
      final usersBox = _storageService.getBox(LocalStorageService.usersBoxName);
      
      List<Map<String, dynamic>> results = [];
      
      for (var key in box.keys) {
        final data = box.get(key);
        
        if (data != null) {
          final specialties = List<String>.from(data['specialties'] ?? []);
          
          // Verificação estrita: a especialidade deve corresponder exatamente
          if (specialties.contains(specialty) && data['available'] == true) {
            final professional = Map<String, dynamic>.from(data);
            
            // Buscar dados do usuário associado
            final userData = usersBox.get(professional['userId']);
            
            if (userData != null) {
              final user = Map<String, dynamic>.from(userData);
              
              results.add({
                'professional': professional,
                'user': user,
              });
            }
          }
        }
      }
      
      // Ordenar por avaliação (rating) em ordem decrescente
      results.sort((a, b) {
        final ratingA = a['professional']['rating'] as double? ?? 0.0;
        final ratingB = b['professional']['rating'] as double? ?? 0.0;
        return ratingB.compareTo(ratingA);
      });
      
      return results;
    } catch (e) {
      rethrow;
    }
  }

  // Método para gerar dados de teste
  Future<List<Map<String, dynamic>>> getMockProfessionals({String? specialty}) async {
    // Lista completa de profissionais simulados
    final List<Map<String, dynamic>> mockData = [
      // Pedreiros
      {
        'professional': {
          'id': '1',
          'userId': 'user1',
          'specialties': ['Pedreiro'],
          'experience': '15 anos de experiência em construção civil',
          'portfolioUrls': ['https://example.com/portfolio1.jpg'],
          'rating': 4.8,
          'ratingCount': 45,
          'available': true,
          'location': {
            'latitude': -23.550520,
            'longitude': -46.633308
          },
          'professionalId': 'CPF-123.456.789-00',
        },
        'user': {
          'id': 'user1',
          'name': 'João Silva',
          'email': 'joao@example.com',
          'phone': '(11) 98765-4321',
          'birthDate': '1980-01-15',
          'gender': 'Masculino',
          'photoUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 180)).toIso8601String(),
          'isClient': false,
        }
      },
      {
        'professional': {
          'id': '2',
          'userId': 'user2',
          'specialties': ['Pedreiro'],
          'experience': '8 anos de experiência em reformas residenciais',
          'portfolioUrls': ['https://example.com/portfolio2.jpg'],
          'rating': 4.5,
          'ratingCount': 32,
          'available': true,
          'location': {
            'latitude': -23.557820,
            'longitude': -46.639608
          },
          'professionalId': 'CPF-234.567.890-11',
        },
        'user': {
          'id': 'user2',
          'name': 'Pedro Oliveira',
          'email': 'pedro@example.com',
          'phone': '(11) 91234-5678',
          'birthDate': '1985-03-22',
          'gender': 'Masculino',
          'photoUrl': 'https://randomuser.me/api/portraits/men/2.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 150)).toIso8601String(),
          'isClient': false,
        }
      },
      // Eletricistas
      {
        'professional': {
          'id': '3',
          'userId': 'user3',
          'specialties': ['Eletricista'],
          'experience': '10 anos trabalhando com instalações elétricas residenciais e comerciais',
          'portfolioUrls': ['https://example.com/portfolio3.jpg'],
          'rating': 4.7,
          'ratingCount': 38,
          'available': true,
          'location': {
            'latitude': -23.561520,
            'longitude': -46.655308
          },
          'professionalId': 'CREA-789012',
        },
        'user': {
          'id': 'user3',
          'name': 'Carlos Ferreira',
          'email': 'carlos@example.com',
          'phone': '(11) 99876-5432',
          'birthDate': '1982-07-10',
          'gender': 'Masculino',
          'photoUrl': 'https://randomuser.me/api/portraits/men/3.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 120)).toIso8601String(),
          'isClient': false,
        }
      },
      {
        'professional': {
          'id': '4',
          'userId': 'user4',
          'specialties': ['Eletricista'],
          'experience': '12 anos de experiência em instalações industriais',
          'portfolioUrls': ['https://example.com/portfolio4.jpg'],
          'rating': 4.6,
          'ratingCount': 42,
          'available': true,
          'location': {
            'latitude': -23.550120,
            'longitude': -46.650308
          },
          'professionalId': 'CREA-345678',
        },
        'user': {
          'id': 'user4',
          'name': 'Ricardo Souza',
          'email': 'ricardo@example.com',
          'phone': '(11) 98888-7777',
          'birthDate': '1979-11-05',
          'gender': 'Masculino',
          'photoUrl': 'https://randomuser.me/api/portraits/men/4.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 90)).toIso8601String(),
          'isClient': false,
        }
      },
      // Pintores
      {
        'professional': {
          'id': '5',
          'userId': 'user5',
          'specialties': ['Pintor'],
          'experience': '8 anos de experiência com pinturas residenciais e comerciais',
          'portfolioUrls': ['https://example.com/portfolio5.jpg'],
          'rating': 4.7,
          'ratingCount': 28,
          'available': true,
          'location': {
            'latitude': -23.561520,
            'longitude': -46.655308
          },
          'professionalId': 'CPF-345.678.901-23',
        },
        'user': {
          'id': 'user5',
          'name': 'Ana Oliveira',
          'email': 'ana@example.com',
          'phone': '(11) 97777-6666',
          'birthDate': '1990-07-10',
          'gender': 'Feminino',
          'photoUrl': 'https://randomuser.me/api/portraits/women/1.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 120)).toIso8601String(),
          'isClient': false,
        }
      },
      {
        'professional': {
          'id': '6',
          'userId': 'user6',
          'specialties': ['Pintor'],
          'experience': '15 anos de experiência em pinturas artísticas e decorativas',
          'portfolioUrls': ['https://example.com/portfolio6.jpg'],
          'rating': 4.9,
          'ratingCount': 35,
          'available': true,
          'location': {
            'latitude': -23.540520,
            'longitude': -46.633308
          },
          'professionalId': 'CPF-456.789.012-34',
        },
        'user': {
          'id': 'user6',
          'name': 'Paulo Mendes',
          'email': 'paulo@example.com',
          'phone': '(11) 96666-5555',
          'birthDate': '1975-05-20',
          'gender': 'Masculino',
          'photoUrl': 'https://randomuser.me/api/portraits/men/5.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 110)).toIso8601String(),
          'isClient': false,
        }
      },
      // Arquitetos
      {
        'professional': {
          'id': '7',
          'userId': 'user7',
          'specialties': ['Arquiteto e Urbanista'],
          'experience': '12 anos de experiência em projetos residenciais e comerciais',
          'portfolioUrls': ['https://example.com/portfolio7.jpg'],
          'rating': 4.9,
          'ratingCount': 56,
          'available': true,
          'location': {
            'latitude': -23.550120,
            'longitude': -46.650308
          },
          'professionalId': 'CAU-A123456-7',
        },
        'user': {
          'id': 'user7',
          'name': 'Mariana Santos',
          'email': 'mariana@example.com',
          'phone': '(11) 95555-4444',
          'birthDate': '1988-11-05',
          'gender': 'Feminino',
          'photoUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 90)).toIso8601String(),
          'isClient': false,
        }
      },
      {
        'professional': {
          'id': '8',
          'userId': 'user8',
          'specialties': ['Arquiteto e Urbanista'],
          'experience': '10 anos de experiência em projetos sustentáveis',
          'portfolioUrls': ['https://example.com/portfolio8.jpg'],
          'rating': 4.8,
          'ratingCount': 48,
          'available': true,
          'location': {
            'latitude': -23.555120,
            'longitude': -46.645308
          },
          'professionalId': 'CAU-A789012-3',
        },
        'user': {
          'id': 'user8',
          'name': 'Fernando Costa',
          'email': 'fernando@example.com',
          'phone': '(11) 94444-3333',
          'birthDate': '1986-08-15',
          'gender': 'Masculino',
          'photoUrl': 'https://randomuser.me/api/portraits/men/6.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 85)).toIso8601String(),
          'isClient': false,
        }
      },
      // Engenheiros Civis
      {
        'professional': {
          'id': '9',
          'userId': 'user9',
          'specialties': ['Engenheiro Civil'],
          'experience': '15 anos de experiência em construções de grande porte',
          'portfolioUrls': ['https://example.com/portfolio9.jpg'],
          'rating': 4.8,
          'ratingCount': 52,
          'available': true,
          'location': {
            'latitude': -23.552120,
            'longitude': -46.648308
          },
          'professionalId': 'CREA-123789',
        },
        'user': {
          'id': 'user9',
          'name': 'Roberto Almeida',
          'email': 'roberto@example.com',
          'phone': '(11) 93333-2222',
          'birthDate': '1982-09-18',
          'gender': 'Masculino',
          'photoUrl': 'https://randomuser.me/api/portraits/men/7.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 80)).toIso8601String(),
          'isClient': false,
        }
      },
      {
        'professional': {
          'id': '10',
          'userId': 'user10',
          'specialties': ['Engenheiro Civil'],
          'experience': '8 anos de experiência em cálculos estruturais',
          'portfolioUrls': ['https://example.com/portfolio10.jpg'],
          'rating': 4.7,
          'ratingCount': 45,
          'available': true,
          'location': {
            'latitude': -23.553120,
            'longitude': -46.647308
          },
          'professionalId': 'CREA-456012',
        },
        'user': {
          'id': 'user10',
          'name': 'Juliana Martins',
          'email': 'juliana@example.com',
          'phone': '(11) 92222-1111',
          'birthDate': '1989-04-25',
          'gender': 'Feminino',
          'photoUrl': 'https://randomuser.me/api/portraits/women/3.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 75)).toIso8601String(),
          'isClient': false,
        }
      },
      // Encanadores
      {
        'professional': {
          'id': '11',
          'userId': 'user11',
          'specialties': ['Encanador'],
          'experience': '9 anos trabalhando com instalações hidráulicas',
          'portfolioUrls': ['https://example.com/portfolio11.jpg'],
          'rating': 4.6,
          'ratingCount': 37,
          'available': true,
          'location': {
            'latitude': -23.540520,
            'longitude': -46.633308
          },
          'professionalId': 'CPF-567.890.123-45',
        },
        'user': {
          'id': 'user11',
          'name': 'Marcos Silva',
          'email': 'marcos@example.com',
          'phone': '(11) 91111-0000',
          'birthDate': '1984-12-10',
          'gender': 'Masculino',
          'photoUrl': 'https://randomuser.me/api/portraits/men/8.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 70)).toIso8601String(),
          'isClient': false,
        }
      },
      {
        'professional': {
          'id': '12',
          'userId': 'user12',
          'specialties': ['Encanador'],
          'experience': '12 anos de experiência em sistemas hidráulicos industriais',
          'portfolioUrls': ['https://example.com/portfolio12.jpg'],
          'rating': 4.7,
          'ratingCount': 41,
          'available': true,
          'location': {
            'latitude': -23.542520,
            'longitude': -46.635308
          },
          'professionalId': 'CPF-678.901.234-56',
        },
        'user': {
          'id': 'user12',
          'name': 'José Santos',
          'email': 'jose@example.com',
          'phone': '(11) 90000-9999',
          'birthDate': '1978-06-30',
          'gender': 'Masculino',
          'photoUrl': 'https://randomuser.me/api/portraits/men/9.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 65)).toIso8601String(),
          'isClient': false,
        }
      },
      // Mestres de Obras
      {
        'professional': {
          'id': '13',
          'userId': 'user13',
          'specialties': ['Mestre de Obras'],
          'experience': '20 anos de experiência em gerenciamento de obras',
          'portfolioUrls': ['https://example.com/portfolio13.jpg'],
          'rating': 4.9,
          'ratingCount': 60,
          'available': true,
          'location': {
            'latitude': -23.545520,
            'longitude': -46.638308
          },
          'professionalId': 'CPF-789.012.345-67',
        },
        'user': {
          'id': 'user13',
          'name': 'Antônio Pereira',
          'email': 'antonio@example.com',
          'phone': '(11) 99999-8888',
          'birthDate': '1970-02-15',
          'gender': 'Masculino',
          'photoUrl': 'https://randomuser.me/api/portraits/men/10.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
          'isClient': false,
        }
      },
      {
        'professional': {
          'id': '14',
          'userId': 'user14',
          'specialties': ['Mestre de Obras'],
          'experience': '15 anos de experiência em construções residenciais',
          'portfolioUrls': ['https://example.com/portfolio14.jpg'],
          'rating': 4.7,
          'ratingCount': 55,
          'available': true,
          'location': {
            'latitude': -23.547520,
            'longitude': -46.640308
          },
          'professionalId': 'CPF-890.123.456-78',
        },
        'user': {
          'id': 'user14',
          'name': 'Luiz Gomes',
          'email': 'luiz@example.com',
          'phone': '(11) 98888-7777',
          'birthDate': '1975-09-28',
          'gender': 'Masculino',
          'photoUrl': 'https://randomuser.me/api/portraits/men/11.jpg',
          'createdAt': DateTime.now().subtract(Duration(days: 55)).toIso8601String(),
          'isClient': false,
        }
      },
    ];
    
    // Se não houver especialidade especificada, retorna todos os profissionais
    if (specialty == null) {
      return mockData;
    }
    
    // Filtra os profissionais pela especialidade especificada
    return mockData.where((professional) {
      final specialties = List<String>.from(professional['professional']['specialties'] ?? []);
      return specialties.contains(specialty);
    }).toList();
  }
}