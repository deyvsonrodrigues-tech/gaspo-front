import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../modelos/agenda.dart';
import '../../modelos/avaliacao.dart';
import '../../modelos/profissional.dart';
import '../../servicos/avaliacao_service.dart';
import '../../servicos/consulta_service.dart';
import '../../utils/formatadores.dart';
import '../../widgets/avaliacao_widgets.dart';
import '../../widgets/campos_formulario.dart';
import '../../widgets/gaspo_bottom_nav.dart';
import '../../widgets/gaspo_header.dart';
import '../agendamento/agendamento_tela.dart';
import '../avaliacao/avaliacao_profissional_tela.dart';

/// Perfil do Profissional: dados, local de atendimento, próximos horários
/// livres e avaliações dos pacientes.
class PerfilProfissionalTela extends StatefulWidget {
  final Profissional profissional;

  /// Permitem injetar outras implementações (ex.: nos testes).
  final ConsultaService? consultaService;
  final AvaliacaoService? avaliacaoService;

  const PerfilProfissionalTela({
    super.key,
    required this.profissional,
    this.consultaService,
    this.avaliacaoService,
  });

  @override
  State<PerfilProfissionalTela> createState() => _PerfilProfissionalTelaState();
}

class _PerfilProfissionalTelaState extends State<PerfilProfissionalTela> {
  static const int _diasDeBusca = 7;
  static const int _maximoHorarios = 8;
  static const List<String> _diasDaSemana = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

  late final ConsultaService _consultas = widget.consultaService ?? ConsultaService.instancia;
  late final AvaliacaoService _avaliacoesService = widget.avaliacaoService ?? AvaliacaoService.instancia;

  Profissional get _profissional => widget.profissional;

  List<HorarioAgenda> _horarios = [];
  List<Avaliacao> _avaliacoes = [];
  bool _carregando = true;
  bool _erro = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = false;
    });
    try {
      final resultados = await Future.wait([_buscarProximosHorarios(), _avaliacoesService.listarPorProfissional(_profissional.id)]);
      if (!mounted) return;
      setState(() {
        _horarios = resultados[0] as List<HorarioAgenda>;
        _avaliacoes = resultados[1] as List<Avaliacao>;
      });
    } catch (_) {
      if (mounted) setState(() => _erro = true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// A API busca horários livres por dia; percorre os próximos dias.
  Future<List<HorarioAgenda>> _buscarProximosHorarios() async {
    final agora = DateTime.now();
    final hoje = DateUtils.dateOnly(agora);
    final encontrados = <HorarioAgenda>[];
    for (var i = 0; i < _diasDeBusca && encontrados.length < _maximoHorarios; i++) {
      final dia = DateUtils.addDaysToDate(hoje, i);
      final livres = await _consultas.horariosDisponiveis(profissionalId: _profissional.id, data: dia);
      encontrados.addAll(livres.where((h) => _dataHora(h).isAfter(agora)));
    }
    return encontrados.take(_maximoHorarios).toList();
  }

  DateTime _dataHora(HorarioAgenda h) =>
      DateTime(h.data.year, h.data.month, h.data.day, h.horario.hour, h.horario.minute);

  String _rotuloHorario(HorarioAgenda h) {
    final dia = _diasDaSemana[h.data.weekday - 1];
    return '$dia ${formatarData(h.data).substring(0, 5)} · ${formatarHora(h.horario)}';
  }

  Future<void> _agendar({HorarioAgenda? horario}) async {
    await Navigator.pushNamed(
      context,
      Rotas.agendamento,
      arguments: AgendamentoArgumentos(_profissional, horario: horario),
    );
    if (mounted) _carregar();
  }

  Future<void> _avaliar() async {
    await Navigator.pushNamed(
      context,
      Rotas.avaliacaoProfissional,
      arguments: AvaliacaoProfissionalArgumentos(medico: _profissional.nome, voltarAoEnviar: true),
    );
    if (mounted) _carregar();
  }

  /// Usa a média das avaliações registradas; sem nenhuma, mostra a nota de
  /// exemplo da lista de especialistas (a API não envia nota pronta).
  String get _resumoNota {
    final media = mediaDasNotas(_avaliacoes);
    if (media == null) return _profissional.notaFormatada;
    final total = _avaliacoes.length;
    return '${media.toStringAsFixed(1)} ($total ${total == 1 ? 'avaliação' : 'avaliações'})';
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 15, color: GaspoCores.azulTitulo, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Material (e não Container com cor) para o efeito de toque dos itens aparecer.
  Widget _cartao({required Widget child}) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black12),
        ),
        child: child,
      ),
    );
  }

  Widget _buildCabecalho() {
    // Cor da bolinha e da borda baseada no status
    final corStatus = _profissional.status.cor;

    return Column(
      children: [
        // Foto do Profissional
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: corStatus, width: 3),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blueGrey[100],
            child: const Icon(Icons.person, size: 60, color: Colors.blueGrey),
          ),
        ),

        const SizedBox(height: 20),

        // Nome do Profissional
        Text(
          _profissional.nome,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: GaspoCores.azulTitulo,
          ),
        ),

        const SizedBox(height: 6),

        // Especialidade
        Text(
          _profissional.especialidade,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        // Nota
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(_resumoNota, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),

        const SizedBox(height: 14),

        // Badge / Tag de Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: corStatus.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: corStatus),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: corStatus,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _profissional.status.rotulo.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: corStatus,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAtendimento() {
    final unidade = _profissional.unidade;
    final email = _profissional.email;
    final telefone = _profissional.telefone;

    if (unidade == null && email == null && telefone == null) {
      return const Text(
        'Informações de atendimento não cadastradas.',
        style: TextStyle(fontSize: 13, color: Colors.black54),
      );
    }

    return _cartao(
      child: Column(
        children: [
          if (unidade != null)
            ListTile(
              leading: const Icon(Icons.local_hospital_outlined, color: GaspoCores.azul),
              title: Text(unidade.nome ?? 'Unidade de Saúde', style: const TextStyle(fontSize: 14)),
              subtitle: Text(
                [unidade.endereco, ?unidade.horarioFuncionamento].join('\n'),
                style: const TextStyle(fontSize: 12),
              ),
              isThreeLine: unidade.horarioFuncionamento != null,
              trailing: const Icon(Icons.chevron_right, color: GaspoCores.azul),
              onTap: () => Navigator.pushNamed(context, Rotas.localizacao),
            ),
          if (email != null)
            ListTile(
              leading: const Icon(Icons.mail_outline, color: GaspoCores.azul),
              title: Text(email, style: const TextStyle(fontSize: 14)),
            ),
          if (telefone != null)
            ListTile(
              leading: const Icon(Icons.phone_outlined, color: GaspoCores.azul),
              title: Text(telefone, style: const TextStyle(fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildHorarios() {
    if (_horarios.isEmpty) {
      return const Text(
        'Sem horários livres nos próximos 7 dias.',
        style: TextStyle(fontSize: 13, color: Colors.black54),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final horario in _horarios)
          ActionChip(
            label: Text(_rotuloHorario(horario)),
            labelStyle: const TextStyle(color: GaspoCores.azul, fontWeight: FontWeight.w600),
            backgroundColor: Colors.white,
            side: const BorderSide(color: GaspoCores.azul),
            tooltip: 'Agendar neste horário',
            onPressed: () => _agendar(horario: horario),
          ),
      ],
    );
  }

  Widget _buildAvaliacoes() {
    if (_avaliacoes.isEmpty) {
      return const Text(
        'Ainda não há avaliações deste profissional.',
        style: TextStyle(fontSize: 13, color: Colors.black54),
      );
    }
    return Column(
      children: [
        for (final avaliacao in _avaliacoes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _cartao(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          Icon(
                            Icons.star,
                            size: 16,
                            color: i < avaliacao.nota ? GaspoCores.estrelaAtiva : GaspoCores.estrelaInativa,
                          ),
                        const Spacer(),
                        Text(
                          formatarData(avaliacao.dataAvaliacao),
                          style: const TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      avaliacao.nomePaciente ?? 'Paciente',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    if (avaliacao.comentario != null) ...[
                      const SizedBox(height: 4),
                      Text(avaliacao.comentario!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
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
                  const GaspoHeader(),
                  const SizedBox(height: 20),
                  Center(child: _buildCabecalho()),
                  const SizedBox(height: 24),

                  BotaoPrincipal(texto: 'Agendar consulta', onPressed: () => _agendar()),
                  const SizedBox(height: 12),
                  BotaoSecundario(texto: 'Avaliar profissional', onPressed: _avaliar),

                  _secao('Atendimento'),
                  _buildAtendimento(),

                  _secao('Próximos horários livres'),
                  if (_carregando)
                    const Center(child: CircularProgressIndicator())
                  else if (_erro)
                    TextButton.icon(
                      onPressed: _carregar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Não foi possível carregar. Tentar de novo'),
                    )
                  else
                    _buildHorarios(),

                  _secao('Avaliações'),
                  if (!_carregando && !_erro) _buildAvaliacoes(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(currentIndex: GaspoBottomNav.inicio),
    );
  }
}
