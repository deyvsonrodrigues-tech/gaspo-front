import 'package:flutter/material.dart';

import '../dados/dados_exemplo.dart';
import '../modelos/agenda.dart';
import '../modelos/consulta.dart';
import 'agenda_service.dart';

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
  static ConsultaService instancia = ConsultaServiceLocal(AgendaService.instancia);

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
    final profissional = profissionais.where((p) => p.id == profissionalId).firstOrNull;
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

    // Devolve o horário para a agenda.
    final horario = (await _agenda.listar())
        .where((h) =>
            h.profissionalId == consulta.profissionalId &&
            DateUtils.isSameDay(h.data, consulta.dataHora) &&
            h.horario == TimeOfDay.fromDateTime(consulta.dataHora))
        .firstOrNull;
    if (horario != null) {
      await _agenda.atualizar(horario.copyWith(disponibilidade: Disponibilidade.disponivel));
    }
    _consultas[indice] = consulta.copyWith(status: StatusConsulta.cancelada);
  }
}
