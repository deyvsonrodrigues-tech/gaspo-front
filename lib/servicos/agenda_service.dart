import 'package:flutter/material.dart';

import '../dados/dados_exemplo.dart';
import '../modelos/agenda.dart';
import 'profissional_service.dart';

/// Agenda de atendimento dos profissionais (RF013).
///
/// Os métodos seguem os endpoints de /api/agendas da Gaspo-api, para que a
/// implementação HTTP substitua a [AgendaServiceLocal] sem mudar as telas.
abstract class AgendaService {
  static AgendaService instancia = AgendaServiceLocal.comExemplos();

  /// GET /api/agendas (ordenado por data e horário).
  Future<List<HorarioAgenda>> listar();

  /// POST /api/agendas/gerar-grade?profissionalId=&data= (corpo: horários).
  /// Todos os horários são criados como [Disponibilidade.disponivel].
  Future<void> gerarGrade({
    required int profissionalId,
    required DateTime data,
    required List<TimeOfDay> horarios,
  });

  /// PUT /api/agendas/{id}
  Future<HorarioAgenda> atualizar(HorarioAgenda horario);

  /// DELETE /api/agendas/{id}
  Future<void> remover(int id);
}

/// Guarda a agenda em memória enquanto o app não está integrado à API.
class AgendaServiceLocal implements AgendaService {
  final List<HorarioAgenda> _horarios = [];
  int _proximoId = 1;

  AgendaServiceLocal();

  /// Agenda de exemplo para testar o app sem a API: todos os profissionais
  /// com horários livres nos próximos 3 dias úteis.
  factory AgendaServiceLocal.comExemplos({DateTime? hoje}) {
    const horarios = [
      TimeOfDay(hour: 8, minute: 0),
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 10, minute: 0),
      TimeOfDay(hour: 14, minute: 0),
      TimeOfDay(hour: 15, minute: 0),
    ];
    final service = AgendaServiceLocal();
    var dia = DateUtils.dateOnly(hoje ?? DateTime.now());
    var diasUteis = 0;
    while (diasUteis < 3) {
      dia = DateUtils.addDaysToDate(dia, 1);
      if (dia.weekday == DateTime.saturday || dia.weekday == DateTime.sunday) continue;
      diasUteis++;
      for (final profissional in profissionais) {
        service._adicionarGrade(profissional.id, profissional.nome, dia, horarios);
      }
    }
    return service;
  }

  @override
  Future<List<HorarioAgenda>> listar() async {
    final lista = List.of(_horarios)
      ..sort((a, b) {
        final porData = a.data.compareTo(b.data);
        return porData != 0 ? porData : compararHorarios(a.horario, b.horario);
      });
    return lista;
  }

  @override
  Future<void> gerarGrade({
    required int profissionalId,
    required DateTime data,
    required List<TimeOfDay> horarios,
  }) async {
    final profissional = await ProfissionalService.instancia.buscarPorId(profissionalId);
    if (profissional == null) throw ArgumentError('Profissional não encontrado');
    _adicionarGrade(profissional.id, profissional.nome, data, horarios);
  }

  void _adicionarGrade(int profissionalId, String nome, DateTime data, List<TimeOfDay> horarios) {
    for (final hora in horarios) {
      _horarios.add(HorarioAgenda(
        id: _proximoId++,
        data: DateUtils.dateOnly(data),
        horario: hora,
        disponibilidade: Disponibilidade.disponivel,
        profissionalId: profissionalId,
        nomeProfissional: nome,
      ));
    }
  }

  @override
  Future<HorarioAgenda> atualizar(HorarioAgenda horario) async {
    final indice = _horarios.indexWhere((h) => h.id == horario.id);
    if (indice == -1) throw StateError('Agenda não encontrada');
    _horarios[indice] = horario;
    return horario;
  }

  @override
  Future<void> remover(int id) async {
    _horarios.removeWhere((h) => h.id == id);
  }
}
