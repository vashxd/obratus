import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../../models/professional_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/professional_service.dart';
import '../../services/storage_service.dart';

class ProfessionalProfileEditScreen extends StatefulWidget {
  const ProfessionalProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalProfileEditScreen> createState() => _ProfessionalProfileEditScreenState();
}

class _ProfessionalProfileEditScreenState extends State<ProfessionalProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _professionalIdController = TextEditingController();
  final _cpfController = TextEditingController();
  final _experienceController = TextEditingController();
  
  ProfessionalModel? _professionalModel;
  UserModel? _userModel;
  bool _isLoading = false;
  List<String> _portfolioImages = [];
  File? _profileImage;
  String? _profileImageUrl;
  
  final ProfessionalService _professionalService = ProfessionalService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfessionalData();
  }

  @override
  void dispose() {
    _professionalIdController.dispose();
    _cpfController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadProfessionalData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _userModel = authProvider.userModel;

      if (_userModel != null) {
        // Carregar dados do profissional
        final professional = await _professionalService.getProfessionalByUserId(_userModel!.id);
        
        if (professional != null) {
          setState(() {
            _professionalModel = professional;
            _professionalIdController.text = professional.professionalId ?? '';
            _experienceController.text = professional.experience;
            _portfolioImages = professional.portfolioUrls?.toList() ?? [];
            _profileImageUrl = _userModel?.photoUrl;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  Future<void> _pickPortfolioImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        // Upload da imagem
        if (_professionalModel != null) {
          final imagePath = await _storageService.uploadPortfolioImage(
            File(pickedFile.path),
            _professionalModel!.id,
          );
          
          setState(() {
            _portfolioImages.add(imagePath);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar imagem ao portfólio: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Upload da imagem de perfil se foi selecionada
      String? photoUrl = _userModel?.photoUrl;
      if (_profileImage != null) {
        photoUrl = await _storageService.uploadProfileImage(
          _profileImage!,
          _userModel!.id,
        );
      }

      // Atualizar dados do usuário
      if (_userModel != null) {
        final updatedUser = _userModel!.copyWith(
          photoUrl: photoUrl,
        );
        await authProvider.updateUserProfile(updatedUser);
      }

      // Atualizar ou criar perfil profissional
      if (_professionalModel != null) {
        final updatedProfessional = _professionalModel!.copyWith(
          professionalId: _professionalIdController.text.trim(),
          experience: _experienceController.text.trim(),
          portfolioUrls: _portfolioImages,
        );
        
        await _professionalService.updateProfessionalProfile(updatedProfessional);
      } else if (_userModel != null) {
        // Criar novo perfil profissional
        final newProfessional = ProfessionalModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _userModel!.id,
          specialties: [],
          experience: _experienceController.text.trim(),
          portfolioUrls: _portfolioImages,
          rating: 0.0,
          ratingCount: 0,
          available: true,
          professionalId: _professionalIdController.text.trim(),
        );
        
        await _professionalService.createProfessionalProfile(newProfessional);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar perfil: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Editar Perfil Profissional'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto de perfil
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickProfileImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.cardBackground,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : _profileImageUrl != null
                                        ? NetworkImage(_profileImageUrl!) as ImageProvider
                                        : null,
                                child: _profileImage == null && _profileImageUrl == null
                                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Toque para alterar a foto',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Número de registro profissional (CAU/CREA)
                      const Text(
                        'Número de Registro Profissional (CAU/CREA)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _professionalIdController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ex: A123456-7 ou 123456/D-SP',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // CPF
                      const Text(
                        'CPF',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cpfController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Digite seu CPF (apenas números)',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length != 11) {
                            return 'CPF deve ter 11 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Experiência
                      const Text(
                        'Experiência Profissional',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _experienceController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Descreva sua experiência profissional',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, descreva sua experiência';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Portfólio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Portfólio',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          ElevatedButton.icon(
                            onPressed: _pickPortfolioImage,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Adicionar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Grid de imagens do portfólio
                      _portfolioImages.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhuma imagem no portfólio',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _portfolioImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(File(_portfolioImages[index])),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _portfolioImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                      const SizedBox(height: 32),
                      
                      // Botão de salvar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            'SALVAR PERFIL',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}