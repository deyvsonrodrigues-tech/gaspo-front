import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../dados/dados_exemplo.dart';
import '../../utils/sessao.dart';
import '../../widgets/gaspo_bottom_nav.dart';

class PerfilTela extends StatelessWidget {
  const PerfilTela({super.key});

  Widget _criarItemLista({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    bool isSwitch = false,
    bool switchValue = false,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: GaspoCores.azul,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icone, color: Colors.white, size: 20),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 13, color: GaspoCores.azulCabecalho, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitulo,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        trailing: isSwitch
            ? Switch(
                value: switchValue,
                onChanged: (val) {},
                activeThumbColor: Colors.white,
                activeTrackColor: GaspoCores.azul,
              )
            : Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: GaspoCores.azul,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 16),
              ),
      ),
    );
  }

  Widget _criarItemSair(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        onTap: () => sairDaConta(context),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.logout, color: Colors.white, size: 20),
        ),
        title: const Text(
          'Sair da conta',
          style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w500),
        ),
        subtitle: const Text(
          'Voltar para a tela de login',
          style: TextStyle(fontSize: 11, color: Colors.black54),
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
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
                  const SizedBox(width: 15),
                  // TODO: substituir pela foto do usuário.
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 36, color: GaspoCores.azulCabecalho),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuarioLogado.nome,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Online',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CONTEÚDO DO PERFIL
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                children: [
                  // SECÇÃO: SOBRE MIM
                  const Text(
                    'Sobre Mim',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GaspoCores.azulCabecalho),
                  ),
                  const SizedBox(height: 10),
                  _criarItemLista(
                    icone: Icons.person,
                    titulo: usuarioLogado.nome,
                    subtitulo: 'Nome',
                  ),
                  _criarItemLista(
                    icone: Icons.mail,
                    titulo: usuarioLogado.email,
                    subtitulo: 'E-mail',
                  ),
                  _criarItemLista(
                    icone: Icons.phone,
                    titulo: usuarioLogado.telefone,
                    subtitulo: 'Número de Telefone',
                  ),
                  _criarItemLista(
                    icone: Icons.location_on,
                    titulo: usuarioLogado.endereco,
                    subtitulo: 'Endereço',
                  ),

                  const SizedBox(height: 25),

                  // SECÇÃO: CONFIGURAÇÕES
                  const Text(
                    'Configurações',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GaspoCores.azulCabecalho),
                  ),
                  const SizedBox(height: 10),
                  _criarItemLista(
                    icone: Icons.language,
                    titulo: 'Português',
                    subtitulo: 'Linguagem',
                  ),
                  _criarItemLista(
                    icone: Icons.notifications_off,
                    titulo: 'Modo Silencioso',
                    subtitulo: 'Notificações e Mensagens',
                    isSwitch: true,
                    switchValue: true,
                  ),
                  _criarItemLista(
                    icone: Icons.dark_mode,
                    titulo: 'Modo Escuro',
                    subtitulo: 'Tema',
                    isSwitch: true,
                    switchValue: true,
                  ),
                  _criarItemSair(context),

                  const SizedBox(height: 15),

                  // RODAPÉ PRIVACIDADE
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Privacidade & Politica',
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(currentIndex: GaspoBottomNav.perfil),
    );
  }
}
