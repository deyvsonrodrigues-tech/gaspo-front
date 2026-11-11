import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../modelos/consulta.dart';
import '../../servicos/consulta_service.dart';
import '../../utils/mensagens.dart';
import '../../widgets/consulta_widgets.dart';
import '../../widgets/gaspo_bottom_nav.dart';
import '../../widgets/gaspo_header.dart';

/// Histórico de Consultas do paciente: as ativas (agendadas) e as demais
/// (realizadas e canceladas), com filtro por status.
class HistoricoConsultasTela extends StatefulWidget {
  final ConsultaService? service;
  const HistoricoConsultasTela({super.key, this.service});

  static const filtros = [
    FiltroConsulta.todas,
    FiltroConsulta('Realizadas', GaspoCores.statusRealizada, {StatusConsulta.finalizada}),
    FiltroConsulta(
      'Agendadas',
      GaspoCores.statusAgendada,
      {StatusConsulta.agendada, StatusConsulta.confirmada},
    ),
    FiltroConsulta('Canceladas', GaspoCores.statusCancelada, {StatusConsulta.cancelada}),
  ];

  @override
  State<HistoricoConsultasTela> createState() => _HistoricoConsultasTelaState();
}

class _HistoricoConsultasTelaState extends State<HistoricoConsultasTela> {
  late final ConsultaService _service = widget.service ?? ConsultaService.instancia;
  FiltroConsulta _filtro = FiltroConsulta.todas;
  List<Consulta>? _consultas;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final ativas = await _service.listarAtivas();
      final historico = await _service.listarHistorico();
      if (!mounted) return;
      // Próximas consultas primeiro; depois o histórico, da mais recente.
      setState(() {
        _consultas = [...ativas, ...historico];
        _erro = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível carregar suas consultas.');
    }
  }

  bool _podeCancelar(Consulta c) =>
      c.status == StatusConsulta.agendada && c.dataHora.isAfter(DateTime.now());

  Future<void> _cancelar(Consulta consulta) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar consulta?'),
        content: Text(
          'A consulta com ${consulta.nomeProfissional} será cancelada e o horário '
          'ficará livre para outros pacientes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: GaspoCores.statusCancelada),
            child: const Text('Cancelar consulta'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      await _service.cancelar(consulta.id);
      if (!mounted) return;
      mostrarMensagem(context, 'Consulta cancelada');
      await _carregar();
    } on AgendamentoException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem);
    }
  }

  void _abrirDetalhes(Consulta consulta) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Detalhes da consulta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: GaspoCores.azulTitulo,
                ),
              ),
              const SizedBox(height: 12),
              ...detalhesConsulta(consulta),
              if (_podeCancelar(consulta)) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _cancelar(consulta);
                  },
                  icon: const Icon(Icons.event_busy_outlined),
                  label: const Text('Cancelar consulta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GaspoCores.statusCancelada,
                    side: const BorderSide(color: GaspoCores.statusCancelada),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _conteudo() {
    if (_erro != null) {
      return Column(
        children: [
          ListaConsultasVazia(mensagem: _erro!),
          TextButton(onPressed: _carregar, child: const Text('Tentar novamente')),
        ],
      );
    }
    final consultas = _consultas;
    if (consultas == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final visiveis = consultas.where(_filtro.aceita).toList();
    if (visiveis.isEmpty) {
      return ListaConsultasVazia(
        mensagem: _filtro == FiltroConsulta.todas
            ? 'Você ainda não tem consultas.\nAgende pelo menu "Agendar".'
            : 'Nenhuma consulta ${_filtro.rotulo.toLowerCase()}.',
      );
    }
    return Column(
      children: [
        for (final consulta in visiveis)
          CartaoConsulta(consulta: consulta, onTap: () => _abrirDetalhes(consulta)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _carregar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GaspoHeader(padding: EdgeInsets.only(top: 16, bottom: 8)),
                    const SizedBox(height: 20),
                    const Text(
                      'Histórico de Consultas',
                      style: TextStyle(
                        fontSize: 19,
                        color: GaspoCores.azulTitulo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    BarraFiltrosConsulta(
                      filtros: HistoricoConsultasTela.filtros,
                      selecionado: _filtro,
                      onSelecionar: (f) => setState(() => _filtro = f),
                    ),
                    const SizedBox(height: 24),
                    _conteudo(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(currentIndex: GaspoBottomNav.historico),
    );
  }
}
