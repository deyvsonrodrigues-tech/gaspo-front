import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../widgets/gaspo_bottom_nav.dart';
import '../../widgets/gaspo_header.dart';

/// Dados e mapa da Unidade de Saúde.
class LocalizacaoTela extends StatelessWidget {
  const LocalizacaoTela({super.key});

  Widget _linhaInformacao(IconData icone, String texto, {double tamanhoIcone = 22}) {
    return Row(
      children: [
        Icon(
          icone,
          color: GaspoCores.azul,
          size: tamanhoIcone,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // LOGO E SETA DE VOLTAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    const SizedBox(height: 18),

                    const GaspoHeader(padding: EdgeInsets.zero),

                    const SizedBox(height: 60),

                    // TÍTULO
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Dados da Unidade de Saúde',
                        style: TextStyle(
                          fontSize: 16,
                          color: GaspoCores.azulEscuro,
                        ),
                      ),
                    ),

                    const SizedBox(height: 45),
                  ],
                ),
              ),

              // MAPA DA UNIDADE
              SizedBox(
                width: double.infinity,
                height: 220,
                child: Image.asset(
                  'assets/mapa_gaspo.png',
                  fit: BoxFit.cover,
                ),
              ),

              // INFORMAÇÕES DA UNIDADE
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '••••',
                      style: TextStyle(
                        color: GaspoCores.azul,
                        fontSize: 22,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ENDEREÇO
                    _linhaInformacao(
                      Icons.location_on_outlined,
                      'Av. das Palmeiras, 458 - Jardim Esperança',
                      tamanhoIcone: 23,
                    ),

                    const SizedBox(height: 12),

                    // TELEFONE
                    _linhaInformacao(Icons.phone_in_talk, '(12) 3435-9821'),

                    const SizedBox(height: 12),

                    // HORÁRIO
                    _linhaInformacao(Icons.access_time, 'Seg. a Sex. — 07h às 18h'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(currentIndex: GaspoBottomNav.inicio),
    );
  }
}
