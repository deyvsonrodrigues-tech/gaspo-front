import 'package:flutter/material.dart';

import '../dados/dados_exemplo.dart';
import '../modelos/agenda.dart';
import '../modelos/consulta.dart';
import 'agenda_service.dart';
import 'profissional_service.dart';

/// Erro de regra de negócio, com a mesma mensagem que a API devolve.
class AgendamentoException implements Exception {
  final String mensagem;
  const AgendamentoException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Consultas do paciente logado.
///
/// Os métodos seguem os endpoints de /api/consultas da Gaspo-api, para que a
/// implementação HTTP substitua a [ConsultaServiceLocal] sem mudar as telas.
abstract class ConsultaService {
  static ConsultaService instancia = ConsultaServiceLocal.comExemplos(AgendaService.instancia);

  /// GET /api/consultas/horarios-disponiveis?profissionalId=&data=
  Future<List<HorarioAgenda>> horariosDisponiveis({
    required int profissionalId,
    required DateTime data,
  });

  /// POST /api/consultas
  Future<Consulta> agendar({required int profissionalId, required DateTime dataHora});

  /// GET /api/consultas/ativos (agendadas e futuras, da mais próxima).
  Future<List<Consulta>> listarAtivas();

  /// GET /api/consultas/meu-historico (as demais, da mais recente).
  Future<List<Consulta>> listarHistorico();

  /// PUT /api/consultas/cancelar/{id}
  Future<void> cancelar(int id);

  /// Painel do funcionário: todas as consultas da unidade, da mais próxima.
  /// GET /api/consultas
  Future<List<Consulta>> listarTodas();

  /// Painel do funcionário: confirma, finaliza ou cancela uma consulta.
  /// PUT /api/consultas/{id}/status
  Future<Consulta> alterarStatus(int id, StatusConsulta novoStatus);
}

/// Mantém as consultas em memória e aplica as mesmas regras da API,
/// ocupando e liberando os horários do [AgendaService].
class ConsultaServiceLocal implements ConsultaService {
  final AgendaService _agenda;
  final DateTime Function() _agora;
  final List<Consulta> _consultas = [];
  int _proximoId = 1;

  ConsultaServiceLocal(this._agenda, {DateTime Function()? agora})
      : _agora = agora ?? DateTime.now;

  /// Consultas de exemplo já encerradas, para o Histórico e o Painel não
  /// abrirem vazios enquanto o app não usa a API. Não ocupam a agenda.
  factory ConsultaServiceLocal.comExemplos(AgendaService agenda, {DateTime? hoje}) {
    final service = ConsultaServiceLocal(agenda);
    final base = DateUtils.dateOnly(hoje ?? DateTime.now());
    final exemplos = [
      (profissionais[0], -12, 14, 30, StatusConsulta.finalizada),
      (profissionais[1], -25, 11, 30, StatusConsulta.cancelada),
      (profissionais[2], -40, 7, 0, StatusConsulta.finalizada),
    ];
    for (final (profissional, dias, hora, minuto, status) in exemplos) {
      final dia = DateUtils.addDaysToDate(base, dias);
      service._consultas.add(Consulta(
        id: service._proximoId++,
        dataHora: DateTime(dia.year, dia.month, dia.day, hora, minuto),
        status: status,
        profissionalId: profissional.id,
        nomeProfissional: profissional.nome,
        especialidadeProfissional: profissional.especialidade,
      ));
    }
    return service;
  }

  @override
  Future<List<HorarioAgenda>> horariosDisponiveis({
    required int profissionalId,
    required DateTime data,
  }) async {
    final todos = await _agenda.listar();
    return todos
        .where((h) =>
            h.profissionalId == profissionalId &&
            DateUtils.isSameDay(h.data, data) &&
            h.disponibilidade == Disponibilidade.disponivel)
        .toList();
  }

  @override
  Future<Consulta> agendar({required int profissionalId, required DateTime dataHora}) async {
    if (!dataHora.isAfter(_agora())) {
      throw const AgendamentoException('A consulta deve ser agendada para uma data futura');
    }
    final profissional = await ProfissionalService.instancia.buscarPorId(profissionalId);
    if (profissional == null) {
      throw const AgendamentoException('Profissional não encontrado');
    }

    final horario = (await _agenda.listar())
        .where((h) =>
            h.profissionalId == profissionalId &&
            DateUtils.isSameDay(h.data, dataHora) &&
            h.horario == TimeOfDay.fromDateTime(dataHora))
        .firstOrNull;
    if (horario == null) {
      throw const AgendamentoException('Horário não cadastrado na agenda do profissional');
    }
    if (horario.disponibilidade != Disponibilidade.disponivel) {
      throw const AgendamentoException('Horário indisponível para agendamento');
    }

    await _agenda.atualizar(horario.copyWith(disponibilidade: Disponibilidade.ocupado));
    final consulta = Consulta(
      id: _proximoId++,
      dataHora: dataHora,
      status: StatusConsulta.agendada,
      profissionalId: profissional.id,
      nomeProfissional: profissional.nome,
      especialidadeProfissional: profissional.especialidade,
    );
    _consultas.add(consulta);
    return consulta;
  }

  bool _ativa(Consulta c) =>
      c.status == StatusConsulta.agendada && !c.dataHora.isBefore(_agora());

  @override
  Future<List<Consulta>> listarAtivas() async =>
      _consultas.where(_ativa).toList()..sort((a, b) => a.dataHora.compareTo(b.dataHora));

  @override
  Future<List<Consulta>> listarHistorico() async =>
      _consultas.where((c) => !_ativa(c)).toList()..sort((a, b) => b.dataHora.compareTo(a.dataHora));

  @override
  Future<void> cancelar(int id) async {
    final indice = _consultas.indexWhere((c) => c.id == id);
    if (indice == -1) throw const AgendamentoException('Consulta não encontrada');
    final consulta = _consultas[indice];
    if (consulta.status != StatusConsulta.agendada) {
      throw const AgendamentoException('Somente consultas agendadas podem ser canceladas');
    }
    if (!consulta.dataHora.isAfter(_agora())) {
      throw const AgendamentoException('Não é possível cancelar consulta antiga ou já realizada');
    }
    await _liberarHorario(consulta);
    _consultas[indice] = consulta.copyWith(status: StatusConsulta.cancelada);
  }

  @override
  Future<List<Consulta>> listarTodas() async =>
      List.of(_consultas)..sort((a, b) => a.dataHora.compareTo(b.dataHora));

  @override
  Future<Consulta> alterarStatus(int id, StatusConsulta novoStatus) async {
    final indice = _consultas.indexWhere((c) => c.id == id);
    if (indice == -1) throw const AgendamentoException('Consulta não encontrada');
    final consulta = _consultas[indice];
    final emAberto = consulta.status == StatusConsulta.agendada ||
        consulta.status == StatusConsulta.confirmada;

    final permitido = switch (novoStatus) {
      StatusConsulta.confirmada => consulta.status == StatusConsulta.agendada,
      StatusConsulta.finalizada || StatusConsulta.cancelada => emAberto,
      StatusConsulta.agendada => false,
    };
    if (!permitido) {
      throw AgendamentoException(
        'Não é possível alterar uma consulta ${consulta.status.rotulo.toLowerCase()} '
        'para ${novoStatus.rotulo.toLowerCase()}',
      );
    }

    if (novoStatus == StatusConsulta.cancelada) await _liberarHorario(consulta);
    final atualizada = consulta.copyWith(status: novoStatus);
    _consultas[indice] = atualizada;
    return atualizada;
  }

  /// Devolve à agenda o horário ocupado pela consulta.
  Future<void> _liberarHorario(Consulta consulta) async {
    final horario = (await _agenda.listar())
        .where((h) =>
            h.profissionalId == consulta.profissionalId &&
            DateUtils.isSameDay(h.data, consulta.dataHora) &&
            h.horario == TimeOfDay.fromDateTime(consulta.dataHora))
        .firstOrNull;
    if (horario != null) {
      await _agenda.atualizar(horario.copyWith(disponibilidade: Disponibilidade.disponivel));
    }
  }
}
