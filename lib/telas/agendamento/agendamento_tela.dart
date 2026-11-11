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
import '../../widgets/campos_formulario.dart';
import '../../widgets/gaspo_bottom_nav.dart';
import '../../widgets/gaspo_header.dart';

/// Argumentos da rota [Rotas.agendamento].
class AgendamentoArgumentos {
  final Profissional profissional;

  /// Horário já escolhido (ex.: tocado no Perfil do Profissional).
  final HorarioAgenda? horario;

  const AgendamentoArgumentos(this.profissional, {this.horario});
}

/// Agendamento de Consultas: o paciente escolhe o profissional, a data e um
/// dos horários livres da agenda (cadastrada pelo funcionário).
class AgendamentoTela extends StatefulWidget {
  /// Profissional já escolhido (ex.: vindo do Perfil do Profissional).
  final Profissional? profissionalInicial;

  /// Horário já escolhido; define a data e fica selecionado se ainda estiver livre.
  final HorarioAgenda? horarioInicial;

  /// Permite injetar outra implementação (ex.: nos testes).
  final ConsultaService? service;

  const AgendamentoTela({
    super.key,
    this.profissionalInicial,
    this.horarioInicial,
    this.service,
  });

  @override
  State<AgendamentoTela> createState() => _AgendamentoTelaState();
}

class _AgendamentoTelaState extends State<AgendamentoTela> {
  late final ConsultaService _service =
      widget.service ?? ConsultaService.instancia;

  List<Profissional> _profissionais = [];
  bool _carregandoProfissionais = true;

  List<String> get _especialidades =>
      _profissionais.map((p) => p.especialidade).toSet().toList()..sort();

  String? _especialidade;
  Profissional? _profissional;
  DateTime _data = DateUtils.dateOnly(DateTime.now());

  List<HorarioAgenda> _horarios = [];
  HorarioAgenda? _horarioEscolhido;
  bool _carregandoHorarios = false;
  bool _agendando = false;

  /// Evita que uma busca antiga sobrescreva a mais recente.
  int _buscaAtual = 0;

  /// Horário vindo de outra tela, selecionado na primeira busca.
  HorarioAgenda? _horarioPendente;

  @override
  void initState() {
    super.initState();
    _profissional = widget.profissionalInicial;
    _horarioPendente = widget.horarioInicial;
    if (_horarioPendente != null) {
      _data = DateUtils.dateOnly(_horarioPendente!.data);
    }
    _carregarProfissionais();
  }

  Future<void> _carregarProfissionais() async {
    try {
      final lista = await ProfissionalService.instancia.listar();
      if (!mounted) return;
      setState(() {
        _profissionais = lista;
        // O profissional recebido pode ter sido removido nesse meio-tempo.
        if (_profissional != null && !lista.contains(_profissional)) {
          _profissional = null;
        }
      });
      if (_profissional != null) _carregarHorarios();
    } catch (_) {
      if (mounted) {
        mostrarMensagem(context, 'Não foi possível carregar os profissionais.');
      }
    } finally {
      if (mounted) setState(() => _carregandoProfissionais = false);
    }
  }

  List<Profissional> get _profissionaisFiltrados => _especialidade == null
      ? _profissionais
      : _profissionais.where((p) => p.especialidade == _especialidade).toList();

  Future<void> _carregarHorarios() async {
    final profissional = _profissional;
    final busca = ++_buscaAtual;
    setState(() {
      _horarioEscolhido = null;
      _horarios = [];
      _carregandoHorarios = profissional != null;
    });
    if (profissional == null) return;

    try {
      final livres = await _service.horariosDisponiveis(
        profissionalId: profissional.id,
        data: _data,
      );
      if (!mounted || busca != _buscaAtual) return;
      // A API só aceita consultas futuras: esconde horários de hoje que já passaram.
      final agora = DateTime.now();
      setState(() {
        _horarios = livres.where((h) => _dataHora(h).isAfter(agora)).toList();
        final pendente = _horarioPendente;
        _horarioPendente = null;
        if (pendente != null) {
          _horarioEscolhido = _horarios
              .where((h) => h.id == pendente.id)
              .firstOrNull;
        }
      });
    } catch (_) {
      if (mounted) {
        mostrarMensagem(context, 'Não foi possível carregar os horários.');
      }
    } finally {
      if (mounted && busca == _buscaAtual) {
        setState(() => _carregandoHorarios = false);
      }
    }
  }

  DateTime _dataHora(HorarioAgenda h) => DateTime(
    h.data.year,
    h.data.month,
    h.data.day,
    h.horario.hour,
    h.horario.minute,
  );

  void _escolherEspecialidade(String? especialidade) {
    setState(() {
      _especialidade = especialidade;
      if (_profissional != null &&
          !_profissionaisFiltrados.contains(_profissional)) {
        _profissional = null;
      }
    });
    _carregarHorarios();
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
      setState(() => _agendando = false);
      mostrarMensagem(context, e.mensagem);
      _carregarHorarios();
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
              _linhaResumo(
                Icons.medical_services_outlined,
                consulta.especialidadeProfissional!,
              ),
            _linhaResumo(
              Icons.event,
              MaterialLocalizations.of(context)
                  .formatFullDate(consulta.dataHora),
            ),
            _linhaResumo(
              Icons.access_time,
              formatarHora(TimeOfDay.fromDateTime(consulta.dataHora)),
            ),
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
          Icon(icone, size: 20, color: GaspoCores.azul),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _subtitulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 15,
        color: GaspoCores.azulTitulo,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildHorarios() {
    if (_profissional == null) {
      return const Text(
        'Escolha um profissional para ver os horários livres.',
        style: TextStyle(fontSize: 13, color: Colors.black54),
      );
    }
    if (_carregandoHorarios) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_horarios.isEmpty) {
      return const Text(
        'Nenhum horário disponível nesta data. Tente outro dia.',
        style: TextStyle(fontSize: 13, color: Colors.black54),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final horario in _horarios)
          ChoiceChip(
            label: Text(formatarHora(horario.horario)),
            selected: _horarioEscolhido?.id == horario.id,
            showCheckmark: false,
            selectedColor: GaspoCores.azul,
            backgroundColor: Colors.white,
            side: const BorderSide(color: GaspoCores.azul),
            labelStyle: TextStyle(
              color: _horarioEscolhido?.id == horario.id
                  ? Colors.white
                  : GaspoCores.azul,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => setState(() => _horarioEscolhido = horario),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profissional = _profissional;
    final horario = _horarioEscolhido;

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
                  const Text(
                    'Agendar Consulta',
                    style: TextStyle(
                      fontSize: 19,
                      color: GaspoCores.azulTitulo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Os campos só são montados depois de carregar, para já virem preenchidos.
                  if (_carregandoProfissionais)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    DropdownButtonFormField<String?>(
                      isExpanded: true,
                      initialValue: _especialidade,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: GaspoCores.azulTitulo,
                      ),
                      decoration: decoracaoCampo(
                        'Especialidade',
                        Icons.medical_services_outlined,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas', style: TextStyle(fontSize: 14)),
                        ),
                        for (final especialidade in _especialidades)
                          DropdownMenuItem<String?>(
                            value: especialidade,
                            child: Text(
                              especialidade,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                      ],
                      onChanged: _escolherEspecialidade,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<Profissional>(
                      // Recria o campo quando o filtro muda a lista de opções.
                      key: ValueKey('profissional-$_especialidade'),
                      isExpanded: true,
                      initialValue: _profissional,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: GaspoCores.azulTitulo,
                      ),
                      decoration: decoracaoCampo(
                        'Profissional',
                        Icons.person_outline,
                      ),
                      items: [
                        for (final p in _profissionaisFiltrados)
                          DropdownMenuItem<Profissional>(
                            value: p,
                            child: Text(
                              _especialidade == null
                                  ? '${p.nome} — ${p.especialidade}'
                                  : p.nome,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (p) {
                        setState(() => _profissional = p);
                        _carregarHorarios();
                      },
                    ),
                  ],
                  const SizedBox(height: 16),

                  CampoData(
                    data: _data,
                    onChanged: (data) {
                      setState(() => _data = data);
                      _carregarHorarios();
                    },
                  ),

                  const Divider(
                    color: Colors.black26,
                    thickness: 0.8,
                    height: 40,
                  ),
                  _subtitulo('Horários disponíveis'),
                  const SizedBox(height: 12),
                  _buildHorarios(),
                  const SizedBox(height: 24),

                  if (profissional != null && horario != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _subtitulo('Resumo'),
                          const SizedBox(height: 6),
                          _linhaResumo(
                            Icons.person_outline,
                            '${profissional.nome} — ${profissional.especialidade}',
                          ),
                          _linhaResumo(
                            Icons.event,
                            MaterialLocalizations.of(context)
                                .formatFullDate(_data),
                          ),
                          _linhaResumo(
                            Icons.access_time,
                            formatarHora(horario.horario),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  BotaoPrincipal(
                    texto: 'Confirmar agendamento',
                    carregando: _agendando,
                    onPressed: horario == null ? null : _confirmar,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(
        currentIndex: GaspoBottomNav.agendar,
      ),
    );
  }
}
