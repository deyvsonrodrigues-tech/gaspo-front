import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../dados/dados_exemplo.dart';
import '../../widgets/gaspo_bottom_nav.dart';

class NotificacoesTela extends StatelessWidget {
  const NotificacoesTela({super.key});

  Widget _criarItemNotificacao(String titulo, String tempo, {bool temAlerta = false}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: const CircleAvatar(
          backgroundColor: GaspoCores.azulClaro,
          radius: 22,
          child: Icon(Icons.mark_chat_unread_outlined, color: Colors.white, size: 22),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tempo,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            if (temAlerta) ...[
              const SizedBox(width: 8),
              const CircleAvatar(
                backgroundColor: Colors.red,
                radius: 10,
                child: Icon(Icons.priority_high, color: Colors.white, size: 14),
              ),
            ] else ...[
              const SizedBox(width: 28), // Espaçamento para alinhar com os que têm alerta
            ]
          ],
        ),
        onTap: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // CABEÇALHO AZUL
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: GaspoCores.azulCabecalho,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.white, size: 30),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 10),
                  // TODO: substituir pela foto do usuário.
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: GaspoCores.azulCabecalho),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bem-vindo ao GASPO',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          usuarioLogado.nome,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Stack(
                        children: [
                          const Icon(Icons.notifications_none, color: Colors.white, size: 30),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                              child: const Text(
                                '1',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Notificações',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // LISTA DE NOTIFICAÇÕES
            Expanded(
              child: ListView(
                children: [
                  _criarItemNotificacao('Consulta reagendada', '08:00'),
                  _criarItemNotificacao('Consulta reagendada', '07:30', temAlerta: true),
                  _criarItemNotificacao('Avalie seu atendimento', '23/04', temAlerta: true),
                  _criarItemNotificacao('Consulta próxima de iniciar', '23/04'),
                  _criarItemNotificacao('Lembrete de consulta', '23/04'),
                  _criarItemNotificacao('Consulta confirmada', '12/05/26'),
                  _criarItemNotificacao('Médico disponível para atendimento', '08/12/25'),
                  _criarItemNotificacao('Consulta confirmada', '12/05/26'),
                  _criarItemNotificacao('Médico disponível para atendimento', '08/12/25'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(currentIndex: GaspoBottomNav.inicio),
    );
  }
}
