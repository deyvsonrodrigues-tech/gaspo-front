import 'package:flutter/material.dart';

import 'unidade_saude.dart';

/// Os rótulos seguem as telas; [valorApi] é o enum StatusProfissional da API.
enum StatusProfissional {
  presente('Presente', Colors.green, 'ATENDENDO'),
  ocupado('Ocupado', Colors.orange, 'PAUSA'),
  ausente('Ausente', Colors.red, 'AUSENTE');

  final String rotulo;
  final Color cor;
  final String valorApi;

  const StatusProfissional(this.rotulo, this.cor, this.valorApi);

  static StatusProfissional daApi(String valor) =>
      values.firstWhere((s) => s.valorApi == valor);
}

class Profissional {
  final int id;
  final String nome;
  final String especialidade;
  final double nota;
  final int totalAvaliacoes;
  final StatusProfissional status;
  final String? email;
  final String? telefone;
  final UnidadeSaude? unidade;

  const Profissional({
    required this.id,
    required this.nome,
    required this.especialidade,
    this.nota = 0,
    this.totalAvaliacoes = 0,
    required this.status,
    this.email,
    this.telefone,
    this.unidade,
  });

  String get notaFormatada =>
      totalAvaliacoes == 0 ? 'Sem avaliações' : '$nota ($totalAvaliacoes Reviews)';

  Profissional copyWith({StatusProfissional? status}) {
    return Profissional(
      id: id,
      nome: nome,
      especialidade: especialidade,
      nota: nota,
      totalAvaliacoes: totalAvaliacoes,
      status: status ?? this.status,
      email: email,
      telefone: telefone,
      unidade: unidade,
    );
  }

  // O mesmo profissional pode vir de buscas diferentes (ex.: da lista e da
  // API); a identidade é o id.
  @override
  bool operator ==(Object other) => other is Profissional && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Dados preenchidos no formulário de cadastro/edição (ProfissionalRequestDTO).
class DadosProfissional {
  final String nome;
  final String especialidade;
  final String? email;
  final String? telefone;
  final StatusProfissional status;
  final UnidadeSaude? unidade;

  const DadosProfissional({
    required this.nome,
    required this.especialidade,
    this.email,
    this.telefone,
    this.status = StatusProfissional.presente,
    this.unidade,
  });
}
