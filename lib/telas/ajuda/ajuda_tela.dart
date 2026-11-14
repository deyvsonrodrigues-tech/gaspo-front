import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/tema.dart';
import '../../dados/dados_exemplo.dart';
import '../../utils/mensagens.dart';
import '../../widgets/gaspo_header.dart';

/// Ajuda: perguntas frequentes sobre o uso do app e contatos da unidade.
class AjudaTela extends StatelessWidget {
  const AjudaTela({super.key});

  static const _perguntasPaciente = [
    (
      'Como agendo uma consulta?',
      'Toque em Agendar no menu de baixo (ou em "Agendar consulta" no perfil de um especialista). '
          'Escolha o profissional, um dia com vagas e o horário, e toque em Confirmar.',
    ),
    (
      'Onde vejo minhas consultas?',
      'No Histórico, pelo menu de baixo. Lá aparecem as consultas agendadas, realizadas e canceladas.',
    ),
    (
      'Como avalio um atendimento?',
      'Em Início > Avaliação, ou tocando na notificação "Avalie seu atendimento", que chega quando a consulta é finalizada.',
    ),
    (
      'Como sei se minha consulta mudou?',
      'Você recebe uma notificação quando ela é agendada, confirmada, cancelada pela unidade ou finalizada. '
          'Toque no sino, no topo do Início.',
    ),
    (
      'Onde fica a unidade e qual o horário?',
      'Em Início > Localização. Os contatos também estão no fim desta página.',
    ),
    (
      'Como troco minha foto?',
      'No Perfil, toque na sua foto e escolha tirar uma foto, escolher da galeria ou remover.',
    ),
    (
      'O que é o Modo Silencioso?',
      'No Perfil > Configurações. Ele esconde o contador e os destaques das notificações; elas continuam na lista.',
    ),
    (
      'Esqueci minha senha. E agora?',
      'Ainda não é possível redefinir a senha pelo aplicativo. Fale com a sua unidade de saúde pelos contatos abaixo.',
    ),
  ];

  static const _perguntasFuncionario = [
    (
      'Como entro como funcionário?',
      'Na tela inicial, toque em Funcionário e entre com o seu CPF e a sua senha. '
          'No Painel você gerencia médicos, horários, consultas e avisos.',
    ),
  ];

  Widget _secao(BuildContext context, String titulo) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        titulo,
        style: TextStyle(fontSize: 16, color: context.cores.titulo, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _perguntas(BuildContext context, List<(String, String)> itens) {
    return Material(
      color: context.cores.superficie,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.cores.borda),
      ),
      child: Column(
        children: [
          for (final (indice, (pergunta, resposta)) in itens.indexed) ...[
            if (indice > 0) Divider(height: 1, color: context.cores.borda),
            ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              iconColor: context.cores.destaque,
              collapsedIconColor: context.cores.textoSecundario,
              title: Text(
                pergunta,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.cores.texto),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resposta,
                  style: TextStyle(fontSize: 14, height: 1.4, color: context.cores.textoSecundario),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _contato(BuildContext context, IconData icone, String rotulo, String valor, {bool copiar = false}) {
    return ListTile(
      leading: Icon(icone, color: context.cores.destaque),
      title: Text(rotulo, style: TextStyle(fontSize: 12, color: context.cores.textoSecundario)),
      subtitle: Text(valor, style: TextStyle(fontSize: 15, color: context.cores.texto)),
      trailing: copiar
          ? IconButton(
              tooltip: 'Copiar $rotulo',
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: valor));
                if (context.mounted) mostrarMensagem(context, '$rotulo copiado.');
              },
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final unidade = unidadeSaude;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GaspoHeader(),
                  const SizedBox(height: 12),
                  Text(
                    'Ajuda',
                    style: TextStyle(fontSize: 22, color: context.cores.tituloForte, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Respostas rápidas sobre o uso do aplicativo.',
                    style: TextStyle(fontSize: 14, color: context.cores.textoSecundario),
                  ),
                  _secao(context, 'Pacientes'),
                  _perguntas(context, _perguntasPaciente),
                  _secao(context, 'Funcionários'),
                  _perguntas(context, _perguntasFuncionario),
                  _secao(context, 'Fale com a unidade'),
                  Material(
                    color: context.cores.superficie,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: context.cores.borda),
                    ),
                    child: Column(
                      children: [
                        _contato(context, Icons.location_on_outlined, 'Endereço', unidade.endereco),
                        if (unidade.telefone != null)
                          _contato(context, Icons.phone_outlined, 'Telefone', unidade.telefone!, copiar: true),
                        if (unidade.horarioFuncionamento != null)
                          _contato(context, Icons.access_time, 'Horário', unidade.horarioFuncionamento!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
