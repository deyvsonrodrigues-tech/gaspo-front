import 'package:flutter/material.dart';

/// Aviso/comunicado da unidade (AvisoResponseDTO na API).
class Aviso {
  final int id;
  final String titulo;
  final String mensagem;
  final DateTime dataPublicacao;
  final DateTime? dataExpiracao;
  final bool ativo;

  const Aviso({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.dataPublicacao,
    this.dataExpiracao,
    this.ativo = true,
  });

  bool get expirado => dataExpiracao != null && dataExpiracao!.isBefore(DateTime.now());

  /// Só avisos ativos e dentro da validade aparecem para os pacientes.
  bool get visivelParaPacientes => ativo && !expirado;

  bool get publicadoHoje => DateUtils.isSameDay(dataPublicacao, DateTime.now());

  factory Aviso.fromJson(Map<String, dynamic> json) {
    DateTime? data(String campo) =>
        json[campo] == null ? null : DateTime.parse(json[campo] as String).toLocal();
    return Aviso(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      mensagem: json['mensagem'] as String,
      dataPublicacao: data('dataPublicacao') ?? DateTime.now(),
      dataExpiracao: data('dataExpiracao'),
      ativo: json['ativo'] as bool? ?? true,
    );
  }
}

/// Dados do formulário de publicação/edição (AvisoRequestDTO).
class DadosAviso {
  final String titulo;
  final String mensagem;
  final bool ativo;

  const DadosAviso({required this.titulo, required this.mensagem, this.ativo = true});

  Map<String, dynamic> toJson() => {
        'titulo': titulo.trim(),
        'mensagem': mensagem.trim(),
        'ativo': ativo,
      };
}
