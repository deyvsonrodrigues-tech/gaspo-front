import 'package:flutter/material.dart';

import 'agenda.dart';

/// Avaliação do atendimento de uma consulta (AvaliacaoConsultaResponseDTO).
class AvaliacaoConsulta {
  final int id;
  final int nota;
  final String? comentario;
  final String? especialidade;
  final int profissionalId;
  final String? nomeProfissional;
  final DateTime dataConsulta;
  final TimeOfDay? horarioConsulta;
  final String? unidade;
  final String? nomePaciente;
  final DateTime dataAvaliacao;

  const AvaliacaoConsulta({
    required this.id,
    required this.nota,
    this.comentario,
    this.especialidade,
    required this.profissionalId,
    this.nomeProfissional,
    required this.dataConsulta,
    this.horarioConsulta,
    this.unidade,
    this.nomePaciente,
    required this.dataAvaliacao,
  });

  factory AvaliacaoConsulta.fromJson(Map<String, dynamic> json) {
    TimeOfDay? hora(String? texto) {
      if (texto == null) return null;
      final partes = texto.split(':');
      return TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
    }

    return AvaliacaoConsulta(
      id: json['id'] as int,
      nota: json['nota'] as int,
      comentario: json['comentario'] as String?,
      especialidade: json['especialidade'] as String?,
      profissionalId: json['profissionalId'] as int,
      nomeProfissional: json['nomeProfissional'] as String?,
      dataConsulta: DateTime.parse(json['dataConsulta'] as String),
      horarioConsulta: hora(json['horarioConsulta'] as String?),
      unidade: json['unidade'] as String?,
      nomePaciente: json['nomePaciente'] as String?,
      dataAvaliacao: DateTime.parse(json['dataAvaliacao'] as String),
    );
  }
}

/// Dados do formulário (AvaliacaoConsultaRequestDTO). O paciente vem do login.
class DadosAvaliacaoConsulta {
  final int nota;
  final String? comentario;
  final String? especialidade;
  final int profissionalId;
  final DateTime dataConsulta;
  final TimeOfDay? horarioConsulta;
  final String? unidade;

  const DadosAvaliacaoConsulta({
    required this.nota,
    this.comentario,
    this.especialidade,
    required this.profissionalId,
    required this.dataConsulta,
    this.horarioConsulta,
    this.unidade,
  });

  Map<String, dynamic> toJson() => {
        'nota': nota,
        'comentario': comentario,
        'especialidade': especialidade,
        'profissionalId': profissionalId,
        'dataConsulta': HorarioAgenda.dataApi(dataConsulta),
        'horarioConsulta': horarioConsulta == null ? null : HorarioAgenda.horaApi(horarioConsulta!),
        'unidade': unidade,
      };
}
