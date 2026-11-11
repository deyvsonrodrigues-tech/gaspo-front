import 'package:flutter/material.dart';

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

  const Profissional({
    required this.id,
    required this.nome,
    required this.especialidade,
    required this.nota,
    required this.totalAvaliacoes,
    required this.status,
  });

  String get notaFormatada => '$nota ($totalAvaliacoes Reviews)';
}
