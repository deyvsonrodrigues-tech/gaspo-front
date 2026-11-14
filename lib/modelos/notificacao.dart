/// Notificação do paciente (NotificacaoResponseDTO na API).
class Notificacao {
  final int id;
  final String titulo;
  final String mensagem;
  final DateTime dataEnvio;
  final bool lida;
  final int? consultaId;

  const Notificacao({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.dataEnvio,
    this.lida = false,
    this.consultaId,
  });

  Notificacao copyWith({bool? lida}) => Notificacao(
        id: id,
        titulo: titulo,
        mensagem: mensagem,
        dataEnvio: dataEnvio,
        lida: lida ?? this.lida,
        consultaId: consultaId,
      );

  /// "Avalie seu atendimento" (gerada quando a consulta é finalizada).
  bool get pedeAvaliacao => titulo == 'Avalie seu atendimento';

  factory Notificacao.fromJson(Map<String, dynamic> json) => Notificacao(
        id: json['id'] as int,
        titulo: json['titulo'] as String,
        mensagem: json['mensagem'] as String,
        dataEnvio: DateTime.parse(json['dataEnvio'] as String),
        lida: json['lida'] as bool? ?? false,
        consultaId: json['consultaId'] as int?,
      );
}
