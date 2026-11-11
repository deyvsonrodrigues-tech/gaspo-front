import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../modelos/agenda.dart';
import '../../modelos/profissional.dart';
import '../../servicos/agenda_service.dart';
import '../../servicos/profissional_service.dart';
import '../../utils/formatadores.dart';
import '../../utils/mensagens.dart';
import '../../widgets/campos_formulario.dart';
import '../../widgets/gaspo_header.dart';

/// Cadastro de Horários (Painel Admin): gera a grade de atendimento de um
/// profissional para um dia e gerencia os horários já cadastrados.
class CadastroHorariosTela extends StatefulWidget {
  /// Permite injetar outra implementação (ex.: nos testes).
  final AgendaService? service;

  const CadastroHorariosTela({super.key, this.service});

  @override
  State<CadastroHorariosTela> createState() => _CadastroHorariosTelaState();
}

class _CadastroHorariosTelaState extends State<CadastroHorariosTela> {
  late final AgendaService _service = widget.service ?? AgendaService.instancia;

  Profissional? _profissional;
  DateTime _data = DateUtils.dateOnly(DateTime.now());
  final List<TimeOfDay> _horariosNovos = [];

  List<Profissional> _profissionais = [];
  List<HorarioAgenda> _cadastrados = [];
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final resultados = await Future.wait([
        _service.listar(),
        ProfissionalService.instancia.listar(),
      ]);
      if (!mounted) return;
      setState(() {
        _cadastrados = resultados[0] as List<HorarioAgenda>;
        _profissionais = resultados[1] as List<Profissional>;
        if (_profissional != null && !_profissionais.contains(_profissional)) _profissional = null;
      });
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível carregar os horários.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _adicionarHorario() async {
    // Sugere 30 min após o último horário escolhido, para agilizar a grade.
    final sugestao = _horariosNovos.isEmpty
        ? const TimeOfDay(hour: 8, minute: 0)
        : _somarMinutos(_horariosNovos.last, 30);

    final hora = await showTimePicker(context: context, initialTime: sugestao);
    if (hora == null || !mounted) return;

    if (_horariosNovos.contains(hora)) {
      mostrarMensagem(context, 'O horário ${formatarHora(hora)} já foi adicionado.');
      return;
    }
    setState(() => _horariosNovos
      ..add(hora)
      ..sort(compararHorarios));
  }

  TimeOfDay _somarMinutos(TimeOfDay hora, int minutos) {
    final total = (hora.hour * 60 + hora.minute + minutos) % (24 * 60);
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  Future<void> _gerarGrade() async {
    final profissional = _profissional;
    if (profissional == null) {
      mostrarMensagem(context, 'Selecione o profissional.');
      return;
    }
    if (_horariosNovos.isEmpty) {
      mostrarMensagem(context, 'Adicione pelo menos um horário.');
      return;
    }

    // A API não impede horários repetidos; evita duplicar a agenda do dia.
    final existentes = _cadastrados
        .where((h) => h.profissionalId == profissional.id && DateUtils.isSameDay(h.data, _data))
        .map((h) => h.horario)
        .toSet();
    final novos = _horariosNovos.where((h) => !existentes.contains(h)).toList();
    final ignorados = _horariosNovos.length - novos.length;

    if (novos.isEmpty) {
      mostrarMensagem(context, 'Todos os horários escolhidos já estão cadastrados para esse dia.');
      return;
    }

    setState(() => _salvando = true);
    try {
      await _service.gerarGrade(profissionalId: profissional.id, data: _data, horarios: novos);
      if (!mounted) return;
      setState(() => _horariosNovos.clear());
      mostrarMensagem(
        context,
        ignorados == 0
            ? 'Grade horária gerada com sucesso!'
            : 'Grade horária gerada. $ignorados horário(s) já existiam e foram ignorados.',
      );
      await _carregar();
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível gerar a grade. Tente novamente.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _alterarDisponibilidade(HorarioAgenda horario, Disponibilidade nova) async {
    if (horario.disponibilidade == nova) return;
    try {
      final atualizado = await _service.atualizar(horario.copyWith(disponibilidade: nova));
      if (!mounted) return;
      setState(() {
        final indice = _cadastrados.indexWhere((h) => h.id == horario.id);
        if (indice != -1) _cadastrados[indice] = atualizado;
      });
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível alterar a disponibilidade.');
    }
  }

  Future<void> _remover(HorarioAgenda horario) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover horário'),
        content: Text(
          'Remover o horário das ${formatarHora(horario.horario)} do dia '
          '${formatarData(horario.data)} (${horario.nomeProfissional})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      await _service.remover(horario.id!);
      if (!mounted) return;
      setState(() => _cadastrados.removeWhere((h) => h.id == horario.id));
      mostrarMensagem(context, 'Horário removido.');
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível remover o horário.');
    }
  }

  Widget _subtitulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 15, color: GaspoCores.azulTitulo, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtitulo('Nova grade'),
        const SizedBox(height: 12),

        DropdownButtonFormField<Profissional>(
          isExpanded: true,
          initialValue: _profissional,
          icon: const Icon(Icons.arrow_drop_down, color: GaspoCores.azulTitulo),
          decoration: decoracaoCampo('Profissional', Icons.person_outline),
          items: _profissionais.map((profissional) {
            return DropdownMenuItem<Profissional>(
              value: profissional,
              child: Text(
                '${profissional.nome} — ${profissional.especialidade}',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (profissional) => setState(() => _profissional = profissional),
        ),
        const SizedBox(height: 16),

        CampoData(data: _data, onChanged: (data) => setState(() => _data = data)),
        const SizedBox(height: 16),

        const Text(
          'Horários',
          style: TextStyle(fontSize: 13, color: GaspoCores.azulTitulo, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final hora in _horariosNovos)
              InputChip(
                label: Text(formatarHora(hora)),
                backgroundColor: Colors.white,
                side: const BorderSide(color: GaspoCores.azul),
                deleteIconColor: GaspoCores.azul,
                onDeleted: () => setState(() => _horariosNovos.remove(hora)),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Adicionar horário'),
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: GaspoCores.azul,
              side: BorderSide.none,
              onPressed: _adicionarHorario,
            ),
          ],
        ),
        const SizedBox(height: 20),

        BotaoPrincipal(texto: 'Gerar grade', carregando: _salvando, onPressed: _gerarGrade),
      ],
    );
  }

  Widget _buildLista() {
    final profissional = _profissional;
    final visiveis = profissional == null
        ? _cadastrados
        : _cadastrados.where((h) => h.profissionalId == profissional.id).toList();

    final itens = <Widget>[];
    DateTime? dataAtual;
    for (final horario in visiveis) {
      if (dataAtual == null || !DateUtils.isSameDay(dataAtual, horario.data)) {
        dataAtual = horario.data;
        itens.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            MaterialLocalizations.of(context).formatFullDate(horario.data),
            style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        ));
      }
      itens.add(_ItemHorario(
        horario: horario,
        mostrarProfissional: profissional == null,
        onDisponibilidade: (nova) => _alterarDisponibilidade(horario, nova),
        onRemover: () => _remover(horario),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtitulo('Horários cadastrados'),
        const SizedBox(height: 2),
        Text(
          profissional == null ? 'Todos os profissionais' : profissional.nome,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        if (_carregando)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (visiveis.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('Nenhum horário cadastrado.', style: TextStyle(color: Colors.black54)),
            ),
          )
        else
          ...itens,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final largo = constraints.maxWidth >= 800;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GaspoHeader(),
                  const SizedBox(height: 12),
                  const Text(
                    'Cadastro de Horários',
                    style: TextStyle(fontSize: 19, color: GaspoCores.azulTitulo, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gere a grade de atendimento de um profissional.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 18),
                  if (largo)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 380, child: _buildFormulario()),
                        const SizedBox(width: 32),
                        Expanded(child: _buildLista()),
                      ],
                    )
                  else ...[
                    _buildFormulario(),
                    const Divider(color: Colors.black26, thickness: 0.8, height: 40),
                    _buildLista(),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ItemHorario extends StatelessWidget {
  final HorarioAgenda horario;
  final bool mostrarProfissional;
  final ValueChanged<Disponibilidade> onDisponibilidade;
  final VoidCallback onRemover;

  const _ItemHorario({
    required this.horario,
    required this.mostrarProfissional,
    required this.onDisponibilidade,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final cor = horario.disponibilidade.cor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(left: 14, top: 6, bottom: 6, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: GaspoCores.azul, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatarHora(horario.horario),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                if (mostrarProfissional)
                  Text(
                    horario.nomeProfissional,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          PopupMenuButton<Disponibilidade>(
            tooltip: 'Alterar disponibilidade',
            onSelected: onDisponibilidade,
            itemBuilder: (_) => [
              for (final d in Disponibilidade.values)
                PopupMenuItem(
                  value: d,
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: d.cor),
                      const SizedBox(width: 8),
                      Text(d.rotulo),
                    ],
                  ),
                ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    horario.disponibilidade.rotulo,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cor),
                  ),
                  Icon(Icons.arrow_drop_down, size: 18, color: cor),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remover horário',
            onPressed: onRemover,
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
