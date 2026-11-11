import 'package:flutter/material.dart';

import '../dados/dados_exemplo.dart';
import '../modelos/avaliacao_consulta.dart';
import 'profissional_service.dart';

/// Erro de regra de negócio, com a mesma mensagem que a API devolve.
class AvaliacaoConsultaException implements Exception {
  final String mensagem;
  const AvaliacaoConsultaException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Avaliação do atendimento da consulta.
///
/// Os métodos seguem os endpoints de /api/avaliacoes-consulta da Gaspo-api, para
/// que a implementação HTTP substitua a [AvaliacaoConsultaServiceLocal] sem
/// mudar as telas.
abstract class AvaliacaoConsultaService {
  static AvaliacaoConsultaService instancia = AvaliacaoConsultaServiceLocal();

  /// POST /api/avaliacoes-consulta (paciente logado).
  Future<AvaliacaoConsulta> avaliar(DadosAvaliacaoConsulta dados);

  /// GET /api/avaliacoes-consulta/minhas (mais recentes primeiro).
  Future<List<AvaliacaoConsulta>> listarMinhas();
}

/// Guarda as avaliações em memória e aplica as mesmas regras da API.
class AvaliacaoConsultaServiceLocal implements AvaliacaoConsultaService {
  final List<AvaliacaoConsulta> _avaliacoes = [];
  int _proximoId = 1;

  @override
  Future<AvaliacaoConsulta> avaliar(DadosAvaliacaoConsulta dados) async {
    if (dados.nota < 1 || dados.nota > 5) {
      throw const AvaliacaoConsultaException('A nota deve ser de 1 a 5');
    }
    if (DateUtils.dateOnly(dados.dataConsulta).isAfter(DateUtils.dateOnly(DateTime.now()))) {
      throw const AvaliacaoConsultaException('A data da consulta não pode ser no futuro');
    }
    final comentario = dados.comentario?.trim();
    if (comentario != null && comentario.length > 500) {
      throw const AvaliacaoConsultaException('O comentário deve ter até 500 caracteres');
    }
    final profissional = await ProfissionalService.instancia.buscarPorId(dados.profissionalId);
    if (profissional == null) {
      throw const AvaliacaoConsultaException('Profissional não encontrado');
    }

    String? limpo(String? texto) => (texto == null || texto.trim().isEmpty) ? null : texto.trim();
    final avaliacao = AvaliacaoConsulta(
      id: _proximoId++,
      nota: dados.nota,
      comentario: limpo(comentario),
      // Sem especialidade escolhida, a API usa a do profissional.
      especialidade: limpo(dados.especialidade) ?? profissional.especialidade,
      profissionalId: profissional.id,
      nomeProfissional: profissional.nome,
      dataConsulta: DateUtils.dateOnly(dados.dataConsulta),
      horarioConsulta: dados.horarioConsulta,
      unidade: limpo(dados.unidade),
      nomePaciente: usuarioLogado.nome,
      dataAvaliacao: DateTime.now(),
    );
    _avaliacoes.add(avaliacao);
    return avaliacao;
  }

  @override
  Future<List<AvaliacaoConsulta>> listarMinhas() async =>
      List.of(_avaliacoes)..sort((a, b) => b.dataAvaliacao.compareTo(a.dataAvaliacao));
}
