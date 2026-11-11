/// Avaliação de um profissional (AvaliacaoResponseDTO na API).
class Avaliacao {
  final int id;
  final int nota;
  final String? comentario;
  final String? nomePaciente;
  final int profissionalId;
  final DateTime dataAvaliacao;

  const Avaliacao({
    required this.id,
    required this.nota,
    this.comentario,
    this.nomePaciente,
    required this.profissionalId,
    required this.dataAvaliacao,
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      id: json['id'] as int,
      nota: json['nota'] as int,
      comentario: json['comentario'] as String?,
      nomePaciente: json['nomePaciente'] as String?,
      profissionalId: json['profissionalId'] as int,
      dataAvaliacao: DateTime.parse(json['dataAvaliacao'] as String).toLocal(),
    );
  }

  /// AvaliacaoRequestDTO (POST /api/avaliacoes).
  static Map<String, dynamic> requestJson({
    required int nota,
    String? comentario,
    required int pacienteId,
    required int profissionalId,
  }) =>
      {
        'nota': nota,
        'comentario': comentario,
        'pacienteId': pacienteId,
        'profissionalId': profissionalId,
      };
}

/// Média das notas, ou null quando não há avaliações.
double? mediaDasNotas(List<Avaliacao> avaliacoes) {
  if (avaliacoes.isEmpty) return null;
  return avaliacoes.fold<int>(0, (soma, a) => soma + a.nota) / avaliacoes.length;
}
