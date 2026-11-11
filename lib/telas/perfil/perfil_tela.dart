import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../dados/dados_exemplo.dart';
import '../../servicos/preferencias.dart';
import '../../utils/sessao.dart';
import '../../widgets/gaspo_bottom_nav.dart';

class PerfilTela extends StatelessWidget {
  const PerfilTela({super.key});

  /// Títulos do Perfil: azul do cabeçalho no tema claro; azul claro no escuro.
  Color _corTitulo(BuildContext context) =>
      context.temaEscuro ? context.cores.titulo : context.cores.cabecalho;

  Widget _criarItemLista(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required String subtitulo,
    bool isSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitch,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.cores.borda, width: 1),
        ),
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
          style: TextStyle(
            fontSize: 13,
            color: _corTitulo(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: TextStyle(fontSize: 11, color: context.cores.textoSecundario),
        ),
        trailing: isSwitch
            ? Switch(
                value: switchValue,
                onChanged: onSwitch,
                activeThumbColor: Colors.white,
                activeTrackColor: GaspoCores.azul,
              )
            : Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: GaspoCores.azul,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                  size: 16,
                ),
              ),
      ),
    );
  }

  Widget _criarItemSair(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.cores.borda, width: 1),
        ),
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
          style: TextStyle(
            fontSize: 13,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Voltar para a tela de login',
          style: TextStyle(fontSize: 11, color: context.cores.textoSecundario),
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
                  const SizedBox(width: 15),
                  // TODO: substituir pela foto do usuário.
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: _corTitulo(context),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuarioLogado.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                  Text(
                    'Sobre Mim',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _corTitulo(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _criarItemLista(
                    context,
                    icone: Icons.person,
                    titulo: usuarioLogado.nome,
                    subtitulo: 'Nome',
                  ),
                  _criarItemLista(
                    context,
                    icone: Icons.mail,
                    titulo: usuarioLogado.email,
                    subtitulo: 'E-mail',
                  ),
                  _criarItemLista(
                    context,
                    icone: Icons.phone,
                    titulo: usuarioLogado.telefone,
                    subtitulo: 'Número de Telefone',
                  ),
                  _criarItemLista(
                    context,
                    icone: Icons.location_on,
                    titulo: usuarioLogado.endereco,
                    subtitulo: 'Endereço',
                  ),

                  const SizedBox(height: 25),

                  // SECÇÃO: CONFIGURAÇÕES
                  Text(
                    'Configurações',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _corTitulo(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _criarItemLista(
                    context,
                    icone: Icons.language,
                    titulo: 'Português',
                    subtitulo: 'Linguagem',
                  ),
                  // Preferências salvas no aparelho; a tela acompanha as mudanças.
                  ListenableBuilder(
                    listenable: Preferencias.instancia,
                    builder: (context, _) {
                      final preferencias = Preferencias.instancia;
                      return Column(
                        children: [
                          _criarItemLista(
                            context,
                            icone: Icons.notifications_off,
                            titulo: 'Modo Silencioso',
                            subtitulo: preferencias.modoSilencioso
                                ? 'Alertas de notificações ocultos'
                                : 'Notificações e Mensagens',
                            isSwitch: true,
                            switchValue: preferencias.modoSilencioso,
                            onSwitch: preferencias.definirModoSilencioso,
                          ),
                          _criarItemLista(
                            context,
                            icone: Icons.dark_mode,
                            titulo: 'Modo Escuro',
                            subtitulo: preferencias.modoEscuro
                                ? 'Tema escuro'
                                : 'Tema claro',
                            isSwitch: true,
                            switchValue: preferencias.modoEscuro,
                            onSwitch: preferencias.definirModoEscuro,
                          ),
                        ],
                      );
                    },
                  ),
                  _criarItemSair(context),

                  const SizedBox(height: 15),

                  // RODAPÉ PRIVACIDADE
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Privacidade & Politica',
                      style: TextStyle(
                        fontSize: 10,
                        color: context.cores.textoSecundario,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(
        currentIndex: GaspoBottomNav.perfil,
      ),
    );
  }
}
