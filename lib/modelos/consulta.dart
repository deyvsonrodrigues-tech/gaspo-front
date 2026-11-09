/// Espelha o enum StatusConsulta da Gaspo-api.
enum StatusConsulta {
  agendada('AGENDADA', 'Agendada'),
  confirmada('CONFIRMADA', 'Confirmada'),
  cancelada('CANCELADA', 'Cancelada'),
  finalizada('FINALIZADA', 'Finalizada');

  final String valorApi;
  final String rotulo;

  const StatusConsulta(this.valorApi, this.rotulo);

  static StatusConsulta daApi(String valor) =>
      values.firstWhere((s) => s.valorApi == valor);
}

/// Consulta do paciente (ConsultaResponseDTO na API).
class Consulta {
  final int id;
  final DateTime dataHora;
  final StatusConsulta status;
  final int profissionalId;
  final String nomeProfissional;
  final String? especialidadeProfissional;
  final String? nomeUnidade;
  final String? enderecoUnidade;

  const Consulta({
    required this.id,
    required this.dataHora,
    required this.status,
    required this.profissionalId,
    required this.nomeProfissional,
    this.especialidadeProfissional,
    this.nomeUnidade,
    this.enderecoUnidade,
  });

  Consulta copyWith({StatusConsulta? status}) {
    return Consulta(
      id: id,
      dataHora: dataHora,
      status: status ?? this.status,
      profissionalId: profissionalId,
      nomeProfissional: nomeProfissional,
      especialidadeProfissional: especialidadeProfissional,
      nomeUnidade: nomeUnidade,
      enderecoUnidade: enderecoUnidade,
    );
  }

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      id: json['id'] as int,
      dataHora: DateTime.parse(json['data'] as String).toLocal(),
      status: StatusConsulta.daApi(json['status'] as String),
      profissionalId: json['profissionalId'] as int,
      nomeProfissional: json['nomeProfissional'] as String,
      especialidadeProfissional: json['especialidadeProfissional'] as String?,
      nomeUnidade: json['nomeUnidade'] as String?,
      enderecoUnidade: json['enderecoUnidade'] as String?,
    );
  }

  /// ConsultaAgendamentoRequestDTO (POST /api/consultas).
  static Map<String, dynamic> agendamentoJson({
    required int profissionalId,
    required DateTime dataHora,
  }) =>
      {
        'data': dataHora.toUtc().toIso8601String(),
        'profissionalId': profissionalId,
      };
}
