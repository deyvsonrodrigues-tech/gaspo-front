import 'package:flutter/material.dart';

/// Espelha o enum Disponibilidade da Gaspo-api.
enum Disponibilidade {
  disponivel('DISPONIVEL', 'Disponível', Colors.green),
  ocupado('OCUPADO', 'Ocupado', Colors.orange),
  bloqueado('BLOQUEADO', 'Bloqueado', Colors.blueGrey),
  ausente('AUSENTE', 'Ausente', Colors.red);

  final String valorApi;
  final String rotulo;
  final Color cor;

  const Disponibilidade(this.valorApi, this.rotulo, this.cor);

  static Disponibilidade daApi(String valor) =>
      values.firstWhere((d) => d.valorApi == valor);
}

/// Um horário da agenda de um profissional (tb_agenda na API).
class HorarioAgenda {
  final int? id;
  final DateTime data;
  final TimeOfDay horario;
  final Disponibilidade disponibilidade;
  final int profissionalId;
  final String nomeProfissional;

  const HorarioAgenda({
    this.id,
    required this.data,
    required this.horario,
    required this.disponibilidade,
    required this.profissionalId,
    required this.nomeProfissional,
  });

  HorarioAgenda copyWith({int? id, Disponibilidade? disponibilidade}) {
    return HorarioAgenda(
      id: id ?? this.id,
      data: data,
      horario: horario,
      disponibilidade: disponibilidade ?? this.disponibilidade,
      profissionalId: profissionalId,
      nomeProfissional: nomeProfissional,
    );
  }

  /// AgendaDisponibilidadeResponseDTO
  factory HorarioAgenda.fromJson(Map<String, dynamic> json) {
    final partesHora = (json['horario'] as String).split(':');
    return HorarioAgenda(
      id: json['id'] as int,
      data: DateTime.parse(json['data'] as String),
      horario: TimeOfDay(
        hour: int.parse(partesHora[0]),
        minute: int.parse(partesHora[1]),
      ),
      disponibilidade: Disponibilidade.daApi(json['disponibilidade'] as String),
      profissionalId: json['profissionalId'] as int,
      nomeProfissional: json['nomeProfissional'] as String,
    );
  }

  /// AgendaRequestDTO (usado no PUT /api/agendas/{id})
  Map<String, dynamic> toRequestJson() => {
        'data': dataApi(data),
        'horario': horaApi(horario),
        'disponibilidade': disponibilidade.valorApi,
        'profissionalId': profissionalId,
      };

  static String dataApi(DateTime data) =>
      '${data.year.toString().padLeft(4, '0')}-${_doisDigitos(data.month)}-${_doisDigitos(data.day)}';

  static String horaApi(TimeOfDay hora) =>
      '${_doisDigitos(hora.hour)}:${_doisDigitos(hora.minute)}:00';

  static String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');
}

int compararHorarios(TimeOfDay a, TimeOfDay b) =>
    (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);
