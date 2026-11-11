import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../modelos/agenda.dart';
import '../../modelos/consulta.dart';
import '../../modelos/profissional.dart';
import '../../servicos/consulta_service.dart';
import '../../servicos/profissional_service.dart';
import '../../utils/formatadores.dart';
import '../../utils/mensagens.dart';
import '../../widgets/gaspo_bottom_nav.dart';
import '../../widgets/gaspo_header.dart';

/// Argumentos da rota [Rotas.agendamento].
class AgendamentoArgumentos {
  final Profissional profissional;

  /// Horário já escolhido (ex.: tocado no Perfil do Profissional).
  final HorarioAgenda? horario;

  const AgendamentoArgumentos(this.profissional, {this.horario});
}

/// Agendamento de Consultas: o paciente escolhe o profissional, um dia com
/// vaga e um dos horários livres da agenda (cadastrada pelo funcionário).
class AgendamentoTela extends StatefulWidget {
  /// Profissional já escolhido (ex.: vindo do Perfil do Profissional).
  final Profissional? profissionalInicial;

  /// Horário já escolhido; define o dia e fica selecionado se ainda estiver livre.
  final HorarioAgenda? horarioInicial;

  /// Permite injetar outra implementação (ex.: nos testes).
  final ConsultaService? service;

  const AgendamentoTela({
    super.key,
    this.profissionalInicial,
    this.horarioInicial,
    this.service,
  });

  /// Quantos dias aparecem na faixa de dias.
  static const int diasNaFaixa = 14;

  @override
  State<AgendamentoTela> createState() => _AgendamentoTelaState();
}

class _AgendamentoTelaState extends State<AgendamentoTela> {
  static const List<String> _diasDaSemana = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
  static const List<String> _diasDaSemanaExtenso = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo',
  ];

  late final ConsultaService _service = widget.service ?? ConsultaService.instancia;

  List<Profissional> _profissionais = [];
  bool _carregandoProfissionais = true;
  String? _especialidade;
  Profissional? _profissional;

  /// Vagas por profissional (id) e por dia, nos próximos [AgendamentoTela.diasNaFaixa] dias.
  final Map<int, Map<DateTime, List<HorarioAgenda>>> _vagas = {};

  /// Dia escolhido em "Outra data", fora da faixa.
  DateTime? _diaExtra;
  List<HorarioAgenda> _vagasDiaExtra = [];

  DateTime? _dia;
  HorarioAgenda? _horarioEscolhido;
  bool _agendando = false;

  /// Horário vindo de outra tela, selecionado quando as vagas carregam.
  HorarioAgenda? _horarioPendente;

  List<DateTime> get _diasDaFaixa {
    final hoje = DateUtils.dateOnly(DateTime.now());
    return [for (var i = 0; i < AgendamentoTela.diasNaFaixa; i++) DateUtils.addDaysToDate(hoje, i)];
  }

  List<String> get _especialidades =>
      _profissionais.map((p) => p.especialidade).toSet().toList()..sort();

  List<Profissional> get _profissionaisFiltrados => _especialidade == null
      ? _profissionais
      : _profissionais.where((p) => p.especialidade == _especialidade).toList();

  @override
  void initState() {
    super.initState();
    _profissional = widget.profissionalInicial;
    _horarioPendente = widget.horarioInicial;
    _carregarProfissionais();
  }

  Future<void> _carregarProfissionais() async {
    try {
      final lista = await ProfissionalService.instancia.listar();
      if (!mounted) return;
      setState(() {
        _profissionais = lista;
        // O profissional recebido pode ter sido removido nesse meio-tempo.
        if (_profissional != null && !lista.contains(_profissional)) _profissional = null;
      });
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível carregar os profissionais.');
    } finally {
      if (mounted) setState(() => _carregandoProfissionais = false);
    }
    // Vagas de todos (mostradas nos cartões); o escolhido primeiro.
    final escolhido = _profissional;
    if (escolhido != null) await _carregarVagas(escolhido);
    for (final p in _profissionais) {
      if (p != escolhido) _carregarVagas(p);
    }
  }

  /// Busca as vagas do profissional dia a dia (a API consulta um dia por vez).
  Future<void> _carregarVagas(Profissional profissional, {bool recarregar = false}) async {
    if (_vagas.containsKey(profissional.id) && !recarregar) return;
    try {
      final agora = DateTime.now();
      final dias = _diasDaFaixa;
      final resultados = await Future.wait(
        dias.map((dia) => _service.horariosDisponiveis(profissionalId: profissional.id, data: dia)),
      );
      if (!mounted) return;
      setState(() {
        _vagas[profissional.id] = {
          for (var i = 0; i < dias.length; i++)
            // A API só aceita consultas futuras: esconde horários de hoje que já passaram.
            dias[i]: resultados[i].where((h) => _dataHora(h).isAfter(agora)).toList(),
        };
        if (profissional == _profissional) _aplicarDiaInicial();
      });
    } catch (_) {
      if (mounted && profissional == _profissional) {
        mostrarMensagem(context, 'Não foi possível carregar os horários.');
      }
    }
  }

  /// Escolhe o dia do horário recebido ou o primeiro dia com vaga.
  void _aplicarDiaInicial() {
    final vagas = _vagas[_profissional?.id];
    if (vagas == null) return;
    final pendente = _horarioPendente;
    _horarioPendente = null;
    if (pendente != null) {
      final dia = DateUtils.dateOnly(pendente.data);
      final livre = vagas[dia]?.where((h) => h.id == pendente.id).firstOrNull;
      if (livre != null) {
        _dia = dia;
        _horarioEscolhido = livre;
        return;
      }
    }
    // Ao recarregar, continua no dia escolhido se ele ainda tiver vaga.
    final atual = _dia;
    if (atual != null && (vagas[atual]?.isNotEmpty ?? false)) return;
    _dia = vagas.entries.where((e) => e.value.isNotEmpty).map((e) => e.key).firstOrNull;
  }

  DateTime _dataHora(HorarioAgenda h) =>
      DateTime(h.data.year, h.data.month, h.data.day, h.horario.hour, h.horario.minute);

  List<HorarioAgenda> get _vagasDoDia {
    final dia = _dia;
    if (dia == null) return [];
    if (_diaExtra != null && DateUtils.isSameDay(dia, _diaExtra)) return _vagasDiaExtra;
    return _vagas[_profissional?.id]?[dia] ?? [];
  }

  String _diaCurto(DateTime dia) => '${_diasDaSemana[dia.weekday - 1]} ${formatarData(dia).substring(0, 5)}';

  void _escolherProfissional(Profissional profissional) {
    setState(() {
      _profissional = profissional;
      _horarioEscolhido = null;
      _diaExtra = null;
      _dia = null;
      if (_vagas.containsKey(profissional.id)) _aplicarDiaInicial();
    });
    _carregarVagas(profissional);
  }

  void _escolherEspecialidade(String? especialidade) {
    setState(() {
      _especialidade = especialidade;
      if (_profissional != null && !_profissionaisFiltrados.contains(_profissional)) {
        _profissional = null;
        _dia = null;
        _horarioEscolhido = null;
      }
    });
  }

  Future<void> _escolherOutraData() async {
    final profissional = _profissional;
    if (profissional == null) return;
    final hoje = DateUtils.dateOnly(DateTime.now());
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dia ?? hoje,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
    );
    if (escolhida == null || !mounted) return;

    final dia = DateUtils.dateOnly(escolhida);
    if (_diasDaFaixa.any((d) => DateUtils.isSameDay(d, dia))) {
      setState(() {
        _dia = dia;
        _horarioEscolhido = null;
      });
      return;
    }
    try {
      final livres = await _service.horariosDisponiveis(profissionalId: profissional.id, data: dia);
      if (!mounted) return;
      setState(() {
        _diaExtra = dia;
        _vagasDiaExtra = livres;
        _dia = dia;
        _horarioEscolhido = null;
      });
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível carregar os horários.');
    }
  }

  Future<void> _confirmar() async {
    final profissional = _profissional;
    final horario = _horarioEscolhido;
    if (profissional == null || horario == null) return;

    setState(() => _agendando = true);
    final Consulta consulta;
    try {
      consulta = await _service.agendar(
        profissionalId: profissional.id,
        dataHora: _dataHora(horario),
      );
    } on AgendamentoException catch (e) {
      if (!mounted) return;
      setState(() {
        _agendando = false;
        _horarioEscolhido = null;
      });
      mostrarMensagem(context, e.mensagem);
      _carregarVagas(profissional, recarregar: true);
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _agendando = false);
      mostrarMensagem(context, 'Não foi possível agendar. Tente novamente.');
      return;
    }

    if (!mounted) return;
    setState(() => _agendando = false);
    await _mostrarConfirmacao(consulta);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, Rotas.home, (_) => false);
  }

  Future<void> _mostrarConfirmacao(Consulta consulta) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Consulta agendada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _linhaResumo(Icons.person_outline, consulta.nomeProfissional),
            if (consulta.especialidadeProfissional != null)
              _linhaResumo(Icons.medical_services_outlined, consulta.especialidadeProfissional!),
            _linhaResumo(Icons.event, MaterialLocalizations.of(context).formatFullDate(consulta.dataHora)),
            _linhaResumo(Icons.access_time, formatarHora(TimeOfDay.fromDateTime(consulta.dataHora))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _linhaResumo(IconData icone, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icone, size: 20, color: context.cores.destaque),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _secao(String titulo, {Widget? acao}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(fontSize: 16, color: context.cores.titulo, fontWeight: FontWeight.w600),
            ),
          ),
          ?acao,
        ],
      ),
    );
  }

  // ESPECIALIDADE: filtro em botões
  Widget _buildFiltroEspecialidade() {
    Widget chip(String rotulo, String? valor) {
      final selecionado = _especialidade == valor;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(rotulo),
          selected: selecionado,
          showCheckmark: false,
          selectedColor: GaspoCores.azul,
          backgroundColor: context.cores.superficie,
          side: BorderSide(color: selecionado ? GaspoCores.azul : context.cores.textoFraco),
          labelStyle: TextStyle(
            fontSize: 14,
            color: selecionado ? Colors.white : context.cores.titulo,
            fontWeight: FontWeight.w500,
          ),
          onSelected: (_) => _escolherEspecialidade(valor),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Todas', null),
          for (final especialidade in _especialidades) chip(especialidade, especialidade),
        ],
      ),
    );
  }

  // PROFISSIONAL: cartões com status e próxima vaga
  Widget _buildCartaoProfissional(Profissional p) {
    final selecionado = p == _profissional;
    final vagas = _vagas[p.id];
    final proximaVaga = vagas?.entries.where((e) => e.value.isNotEmpty).map((e) => e.key).firstOrNull;
    final detalhe = vagas == null
        ? 'buscando vagas…'
        : proximaVaga == null
            ? 'sem vagas nos próximos ${AgendamentoTela.diasNaFaixa} dias'
            : 'próxima vaga ${_diaCurto(proximaVaga)}';
    final iniciais = p.nome
        .replaceAll(RegExp(r'^(Dra?\.)\s*'), '')
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .take(2)
        .map((parte) => parte[0])
        .join();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.cores.superficie,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selecionado ? GaspoCores.azul : context.cores.borda,
            width: selecionado ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () => _escolherProfissional(p),
          child: Semantics(
            selected: selecionado,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: p.status.cor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: selecionado ? GaspoCores.azul.withValues(alpha: 0.1) : Colors.blueGrey[50],
                      child: Text(
                        iniciais,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: selecionado ? context.cores.destaque : Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.nome,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.cores.texto),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p.especialidade} · $detalhe',
                          style: TextStyle(fontSize: 13, color: context.cores.textoSecundario),
                        ),
                      ],
                    ),
                  ),
                  if (selecionado) Icon(Icons.check_circle, color: context.cores.destaque),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // DIA: faixa com os próximos dias e quantas vagas cada um tem
  Widget _buildFaixaDias() {
    final vagas = _vagas[_profissional?.id];
    if (vagas == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final dias = [..._diasDaFaixa, ?_diaExtra];

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dias.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, indice) {
          final dia = dias[indice];
          final ehExtra = _diaExtra != null && DateUtils.isSameDay(dia, _diaExtra);
          final quantidade = ehExtra ? _vagasDiaExtra.length : (vagas[dia]?.length ?? 0);
          final selecionado = _dia != null && DateUtils.isSameDay(dia, _dia);
          final ativo = quantidade > 0;
          final corTexto = selecionado ? Colors.white : (ativo ? context.cores.tituloForte : context.cores.textoFraco);

          return Semantics(
            button: true,
            selected: selecionado,
            enabled: ativo,
            label: '${_diasDaSemanaExtenso[dia.weekday - 1]}, ${formatarData(dia).substring(0, 5)}, '
                '${ativo ? '$quantidade vagas' : 'sem vagas'}',
            excludeSemantics: true,
            child: Material(
              color: selecionado ? GaspoCores.azul : context.cores.superficie,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: selecionado ? GaspoCores.azul : context.cores.borda),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: ativo
                    ? () => setState(() {
                          _dia = dia;
                          _horarioEscolhido = null;
                        })
                    : null,
                child: SizedBox(
                  width: 66,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_diasDaSemana[dia.weekday - 1], style: TextStyle(fontSize: 13, color: corTexto)),
                      Text(
                        '${dia.day}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: corTexto),
                      ),
                      Text(
                        ativo ? '$quantidade ${quantidade == 1 ? 'vaga' : 'vagas'}' : '–',
                        style: TextStyle(fontSize: 11, color: corTexto),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // HORÁRIO: botões grandes agrupados por período
  Widget _buildHorarios() {
    final vagas = _vagasDoDia;
    if (_dia == null) {
      return Text(
        'Sem vagas nos próximos ${AgendamentoTela.diasNaFaixa} dias. Escolha outra data ou outro profissional.',
        style: TextStyle(fontSize: 14, color: context.cores.textoSecundario),
      );
    }
    if (vagas.isEmpty) {
      return Text(
        'Nenhum horário livre neste dia. Escolha outro dia.',
        style: TextStyle(fontSize: 14, color: context.cores.textoSecundario),
      );
    }

    final periodos = <String, List<HorarioAgenda>>{
      'Manhã': vagas.where((h) => h.horario.hour < 12).toList(),
      'Tarde': vagas.where((h) => h.horario.hour >= 12 && h.horario.hour < 18).toList(),
      'Noite': vagas.where((h) => h.horario.hour >= 18).toList(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final MapEntry(key: periodo, value: horarios) in periodos.entries)
          if (horarios.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(periodo, style: TextStyle(fontSize: 13, color: context.cores.textoSecundario)),
            ),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.4,
              children: [for (final h in horarios) _botaoHorario(h)],
            ),
            const SizedBox(height: 14),
          ],
      ],
    );
  }

  Widget _botaoHorario(HorarioAgenda horario) {
    final selecionado = _horarioEscolhido?.id == horario.id;
    return Semantics(
      selected: selecionado,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: selecionado ? GaspoCores.azul : context.cores.superficie,
          foregroundColor: selecionado ? Colors.white : GaspoCores.azul,
          side: const BorderSide(color: GaspoCores.azul),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: () => setState(() => _horarioEscolhido = horario),
        child: Text(formatarHora(horario.horario)),
      ),
    );
  }

  // RODAPÉ: resumo e confirmação, sempre à vista depois de escolher o horário
  Widget _buildBarraConfirmacao() {
    final horario = _horarioEscolhido!;
    final profissional = _profissional!;
    final dia = horario.data;
    return Material(
      color: context.cores.superficie,
      elevation: 8,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_diasDaSemanaExtenso[dia.weekday - 1]}, ${formatarData(dia).substring(0, 5)} às ${formatarHora(horario.horario)}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.cores.tituloForte),
                    ),
                    Text(
                      profissional.nome,
                      style: TextStyle(fontSize: 13, color: context.cores.textoSecundario),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GaspoCores.azul,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _agendando ? null : _confirmar,
                  child: _agendando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Confirmar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profissional = _profissional;

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
                    'Agendar consulta',
                    style: TextStyle(fontSize: 22, color: context.cores.tituloForte, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Escolha o profissional, o dia e o horário.',
                    style: TextStyle(fontSize: 14, color: context.cores.textoSecundario),
                  ),

                  if (_carregandoProfissionais)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    const SizedBox(height: 18),
                    _buildFiltroEspecialidade(),
                    _secao('Profissional'),
                    if (_profissionaisFiltrados.isEmpty)
                      Text('Nenhum profissional nesta especialidade.', style: TextStyle(color: context.cores.textoSecundario))
                    else
                      for (final p in _profissionaisFiltrados) _buildCartaoProfissional(p),

                    if (profissional != null) ...[
                      _secao(
                        'Dia',
                        acao: TextButton.icon(
                          onPressed: _escolherOutraData,
                          icon: const Icon(Icons.calendar_month_outlined, size: 18),
                          label: const Text('Outra data'),
                        ),
                      ),
                      _buildFaixaDias(),
                      if (_vagas.containsKey(profissional.id)) ...[
                        _secao('Horário'),
                        _buildHorarios(),
                      ],
                    ],
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_horarioEscolhido != null && profissional != null) _buildBarraConfirmacao(),
          const GaspoBottomNav(currentIndex: GaspoBottomNav.agendar),
        ],
      ),
    );
  }
}
