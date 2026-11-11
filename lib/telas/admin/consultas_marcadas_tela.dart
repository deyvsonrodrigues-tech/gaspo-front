import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../modelos/consulta.dart';
import '../../servicos/consulta_service.dart';
import '../../utils/mensagens.dart';
import '../../widgets/consulta_widgets.dart';
import '../../widgets/gaspo_header.dart';

/// Painel do funcionário: todas as consultas marcadas na unidade, com busca,
/// filtro por status e ações para confirmar, finalizar ou cancelar.
class ConsultasMarcadasTela extends StatefulWidget {
  final ConsultaService? service;
  const ConsultasMarcadasTela({super.key, this.service});

  static const filtros = [
    FiltroConsulta.todas,
    FiltroConsulta('Agendadas', GaspoCores.statusAgendada, {StatusConsulta.agendada}),
    FiltroConsulta('Confirmadas', GaspoCores.azulCabecalho, {StatusConsulta.confirmada}),
    FiltroConsulta('Realizadas', GaspoCores.statusRealizada, {StatusConsulta.finalizada}),
    FiltroConsulta('Canceladas', GaspoCores.statusCancelada, {StatusConsulta.cancelada}),
  ];

  @override
  State<ConsultasMarcadasTela> createState() => _ConsultasMarcadasTelaState();
}

class _ConsultasMarcadasTelaState extends State<ConsultasMarcadasTela> {
  late final ConsultaService _service = widget.service ?? ConsultaService.instancia;
  final _busca = TextEditingController();
  FiltroConsulta _filtro = FiltroConsulta.todas;
  List<Consulta>? _consultas;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final consultas = await _service.listarTodas();
      if (!mounted) return;
      setState(() {
        _consultas = consultas;
        _erro = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível carregar as consultas.');
    }
  }

  bool _correspondeBusca(Consulta c) {
    final termo = _busca.text.trim().toLowerCase();
    if (termo.isEmpty) return true;
    return c.nomeProfissional.toLowerCase().contains(termo) ||
        (c.especialidadeProfissional?.toLowerCase().contains(termo) ?? false);
  }

  Future<void> _alterarStatus(Consulta consulta, StatusConsulta novo) async {
    if (novo == StatusConsulta.cancelada) {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancelar consulta?'),
          content: Text(
            'A consulta com ${consulta.nomeProfissional} será cancelada e o horário '
            'voltará para a agenda.',
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
    }

    try {
      await _service.alterarStatus(consulta.id, novo);
      if (!mounted) return;
      mostrarMensagem(context, 'Consulta ${novo.rotuloTela.toLowerCase()}');
      await _carregar();
    } on AgendamentoException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem);
    }
  }

  void _abrirDetalhes(Consulta consulta) {
    final emAberto = consulta.status == StatusConsulta.agendada ||
        consulta.status == StatusConsulta.confirmada;

    void acao(BuildContext sheetContext, StatusConsulta novo) {
      Navigator.pop(sheetContext);
      _alterarStatus(consulta, novo);
    }

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
              Text(
                'Consulta marcada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.cores.titulo,
                ),
              ),
              const SizedBox(height: 12),
              ...detalhesConsulta(consulta),
              if (emAberto) ...[
                const SizedBox(height: 16),
                Text(
                  'Alterar status',
                  style: TextStyle(fontWeight: FontWeight.w600, color: context.cores.titulo),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (consulta.status == StatusConsulta.agendada)
                      _botaoStatus(
                        rotulo: 'Confirmar',
                        icone: Icons.check_circle_outline,
                        cor: GaspoCores.azul,
                        onPressed: () => acao(sheetContext, StatusConsulta.confirmada),
                      ),
                    _botaoStatus(
                      rotulo: 'Marcar como realizada',
                      icone: Icons.task_alt,
                      cor: GaspoCores.statusRealizada,
                      onPressed: () => acao(sheetContext, StatusConsulta.finalizada),
                    ),
                    _botaoStatus(
                      rotulo: 'Cancelar',
                      icone: Icons.event_busy_outlined,
                      cor: GaspoCores.statusCancelada,
                      onPressed: () => acao(sheetContext, StatusConsulta.cancelada),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _botaoStatus({
    required String rotulo,
    required IconData icone,
    required Color cor,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icone, size: 18),
      label: Text(rotulo),
      style: FilledButton.styleFrom(backgroundColor: cor, foregroundColor: Colors.white),
    );
  }

  Widget _campoBusca() {
    return TextField(
      controller: _busca,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar por profissional ou especialidade',
        hintStyle: TextStyle(fontSize: 14, color: context.cores.textoFraco),
        prefixIcon: Icon(Icons.search, color: context.cores.destaque),
        suffixIcon: _busca.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpar busca',
                icon: const Icon(Icons.close),
                onPressed: () => setState(_busca.clear),
              ),
        filled: true,
        fillColor: context.cores.superficie,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: context.cores.borda),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: context.cores.borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: GaspoCores.azul, width: 1.5),
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
    final visiveis =
        consultas.where((c) => _filtro.aceita(c) && _correspondeBusca(c)).toList();
    if (visiveis.isEmpty) {
      return const ListaConsultasVazia(mensagem: 'Nenhuma consulta encontrada.');
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
                    const SizedBox(height: 12),
                    Text(
                      'Consultas',
                      style: TextStyle(
                        fontSize: 19,
                        color: context.cores.titulo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acompanhe e atualize o status das consultas marcadas',
                      style: TextStyle(fontSize: 13, color: context.cores.textoSecundario),
                    ),
                    const SizedBox(height: 16),
                    _campoBusca(),
                    const SizedBox(height: 12),
                    BarraFiltrosConsulta(
                      filtros: ConsultasMarcadasTela.filtros,
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
    );
  }
}
