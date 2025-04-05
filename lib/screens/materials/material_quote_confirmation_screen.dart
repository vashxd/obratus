import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/material_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MaterialQuoteConfirmationScreen extends StatelessWidget {
  final MaterialQuote quote;
  
  const MaterialQuoteConfirmationScreen({Key? key, required this.quote}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Orçamento Enviado'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: SvgPicture.asset('assets/images/logo.svg', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 16),
            // Nome do app
            const Text(
              'OBRATUS',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'CONECTANDO SUA OBRA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 40),
            // Mensagem de confirmação
            const Text(
              'Obrigado por solicitar\nseu orçamento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Em breve enviaremos\no orçamento de volta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),
            // Botões de ação
            if (quote.projectId != null)
              // Se o orçamento está associado a um projeto, mostrar botão para voltar ao projeto
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Voltar para a tela de detalhes do projeto
                    Navigator.pop(context);
                    Navigator.pop(context); // Volta duas vezes para chegar à tela de detalhes do projeto
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('VOLTAR PARA DETALHES DA OBRA'),
                ),
              )
            else
              // Se não está associado a um projeto, mostrar botões padrão
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar para a tela de lista de orçamentos do cliente
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          '/client_home', 
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('JÁ TEM UMA LISTA? CLIQUE PARA ANEXAR'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar para a tela de seleção de especialidades profissionais
                        Navigator.pushNamed(context, '/professionals');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('QUER CONTRATAR UM PROFISSIONAL?'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}