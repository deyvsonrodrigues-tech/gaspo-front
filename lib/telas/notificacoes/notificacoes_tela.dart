import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../dados/dados_exemplo.dart';
import '../../servicos/preferencias.dart';
import '../../widgets/gaspo_bottom_nav.dart';

class NotificacoesTela extends StatelessWidget {
  const NotificacoesTela({super.key});

  Widget _criarItemNotificacao(
    BuildContext context,
    String titulo,
    String tempo, {
    bool temAlerta = false,
    bool silencioso = false,
  }) {
    // No Modo Silencioso o alerta vermelho some (a notificação continua na lista).
    final mostrarAlerta = temAlerta && !silencioso;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.cores.borda, width: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: const CircleAvatar(
          backgroundColor: GaspoCores.azulClaro,
          radius: 22,
          child: Icon(
            Icons.mark_chat_unread_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          titulo,
          style: TextStyle(fontSize: 15, color: context.cores.texto),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tempo,
              style: TextStyle(
                fontSize: 12,
                color: context.cores.textoSecundario,
              ),
            ),
            if (mostrarAlerta) ...[
              const SizedBox(width: 8),
              const CircleAvatar(
                backgroundColor: Colors.red,
                radius: 10,
                child: Icon(Icons.priority_high, color: Colors.white, size: 14),
              ),
            ] else ...[
              const SizedBox(
                width: 28,
              ), // Espaçamento para alinhar com os que têm alerta
            ],
          ],
        ),
        onTap: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Preferencias.instancia,
      builder: (context, _) =>
          _buildTela(context, Preferencias.instancia.modoSilencioso),
    );
  }

  Widget _avisoSilencioso(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 8),
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        color: context.cores.superficieAlternativa,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 20,
            color: context.cores.textoSecundario,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo silencioso ligado: alertas ocultos.',
              style: TextStyle(
                fontSize: 13,
                color: context.cores.textoSecundario,
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                Preferencias.instancia.definirModoSilencioso(false),
            child: const Text('Desligar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTela(BuildContext context, bool silencioso) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // CABEÇALHO AZUL
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: context.cores.cabecalho,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.keyboard_double_arrow_left,
                      color: Colors.white,
                      size: 30,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 10),
                  // TODO: substituir pela foto do usuário.
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: context.cores.cabecalho,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bem-vindo ao GASPO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          usuarioLogado.nome,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Stack(
                        children: [
                          Icon(
                            silencioso
                                ? Icons.notifications_off_outlined
                                : Icons.notifications_none,
                            color: Colors.white,
                            size: 30,
                          ),
                          if (!silencioso)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                child: const Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
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

            if (silencioso) _avisoSilencioso(context),

            // LISTA DE NOTIFICAÇÕES
            Expanded(
              child: ListView(
                children: [
                  _criarItemNotificacao(
                    context,
                    'Consulta reagendada',
                    '08:00',
                    silencioso: silencioso,
                  ),
                  _criarItemNotificacao(
                    context,
                    'Consulta reagendada',
                    '07:30',
                    temAlerta: true,
                    silencioso: silencioso,
                  ),
                  _criarItemNotificacao(
                    context,
                    'Avalie seu atendimento',
                    '23/04',
                    temAlerta: true,
                    silencioso: silencioso,
                  ),
                  _criarItemNotificacao(
                    context,
                    'Consulta próxima de iniciar',
                    '23/04',
                    silencioso: silencioso,
                  ),
                  _criarItemNotificacao(
                    context,
                    'Lembrete de consulta',
                    '23/04',
                    silencioso: silencioso,
                  ),
                  _criarItemNotificacao(
                    context,
                    'Consulta confirmada',
                    '12/05/26',
                    silencioso: silencioso,
                  ),
                  _criarItemNotificacao(
                    context,
                    'Médico disponível para atendimento',
                    '08/12/25',
                    silencioso: silencioso,
                  ),
                  _criarItemNotificacao(
                    context,
                    'Consulta confirmada',
                    '12/05/26',
                    silencioso: silencioso,
                  ),
                  _criarItemNotificacao(
                    context,
                    'Médico disponível para atendimento',
                    '08/12/25',
                    silencioso: silencioso,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(
        currentIndex: GaspoBottomNav.inicio,
      ),
    );
  }
}
