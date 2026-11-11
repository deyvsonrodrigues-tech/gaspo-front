import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../utils/sessao.dart';
import '../../widgets/gaspo_header.dart';

/// Tela inicial do funcionário: atalhos para as funções do Painel Admin.
class PainelFuncionarioTela extends StatelessWidget {
  const PainelFuncionarioTela({super.key});

  Widget _opcao(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required String descricao,
    required VoidCallback onTap,
    Color cor = GaspoCores.azul,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: context.cores.superficie,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: context.cores.borda),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icone, color: Colors.white, size: 24),
          ),
          title: Text(
            titulo,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cor == Colors.red ? Colors.red : context.cores.titulo),
          ),
          subtitle: Text(descricao, style: TextStyle(fontSize: 12, color: context.cores.textoSecundario)),
          trailing: Icon(Icons.chevron_right, color: cor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  GaspoHeader(onBack: () => sairDaConta(context)),
                  const SizedBox(height: 12),
                  Text(
                    'Painel do Funcionário',
                    style: TextStyle(fontSize: 19, color: context.cores.titulo, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'O que você quer gerenciar?',
                    style: TextStyle(fontSize: 13, color: context.cores.textoSecundario),
                  ),
                  const SizedBox(height: 20),
                  _opcao(
                    context,
                    icone: Icons.medical_services_outlined,
                    titulo: 'Médicos',
                    descricao: 'Cadastrar e gerenciar os profissionais',
                    onTap: () => Navigator.pushNamed(context, Rotas.medicos),
                  ),
                  _opcao(
                    context,
                    icone: Icons.calendar_month_outlined,
                    titulo: 'Cadastro de Horários',
                    descricao: 'Gerar a grade de atendimento',
                    onTap: () => Navigator.pushNamed(context, Rotas.cadastroHorarios),
                  ),
                  _opcao(
                    context,
                    icone: Icons.event_note_outlined,
                    titulo: 'Consultas Marcadas',
                    descricao: 'Acompanhar e atualizar o status das consultas',
                    onTap: () => Navigator.pushNamed(context, Rotas.consultasMarcadas),
                  ),
                  _opcao(
                    context,
                    icone: Icons.campaign_outlined,
                    titulo: 'Avisos',
                    descricao: 'Publicar e gerenciar comunicados',
                    onTap: () => Navigator.pushNamed(context, Rotas.avisosPublicados),
                  ),
                  const SizedBox(height: 12),
                  _opcao(
                    context,
                    icone: Icons.logout,
                    titulo: 'Sair da conta',
                    descricao: 'Voltar para a tela de login',
                    cor: Colors.red,
                    onTap: () => sairDaConta(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
