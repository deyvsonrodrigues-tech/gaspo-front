import 'package:flutter/material.dart';

import 'unidade_saude.dart';

enum StatusProfissional {
  presente('Presente', Colors.green),
  ocupado('Ocupado', Colors.orange),
  ausente('Ausente', Colors.red);

  final String rotulo;
  final Color cor;

  const StatusProfissional(this.rotulo, this.cor);
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
    required this.nota,
    required this.totalAvaliacoes,
    required this.status,
    this.email,
    this.telefone,
    this.unidade,
  });

  String get notaFormatada => '$nota ($totalAvaliacoes Reviews)';
}
