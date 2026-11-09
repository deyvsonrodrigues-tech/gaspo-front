import 'package:flutter/material.dart';

import '../dados/dados_exemplo.dart';
import '../modelos/agenda.dart';

/// Agenda de atendimento dos profissionais (RF013).
///
/// Os métodos seguem os endpoints de /api/agendas da Gaspo-api, para que a
/// implementação HTTP substitua a [AgendaServiceLocal] sem mudar as telas.
abstract class AgendaService {
  static AgendaService instancia = AgendaServiceLocal();

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
    final profissional = profissionais.firstWhere(
      (p) => p.id == profissionalId,
      orElse: () => throw ArgumentError('Profissional não encontrado'),
    );
    for (final hora in horarios) {
      _horarios.add(HorarioAgenda(
        id: _proximoId++,
        data: DateUtils.dateOnly(data),
        horario: hora,
        disponibilidade: Disponibilidade.disponivel,
        profissionalId: profissional.id,
        nomeProfissional: profissional.nome,
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
