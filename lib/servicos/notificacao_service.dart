import 'package:flutter/material.dart';

import '../modelos/consulta.dart';
import '../modelos/notificacao.dart';
import '../utils/formatadores.dart';
import 'consulta_service.dart';

/// Notificações do paciente logado.
///
/// Os métodos seguem os endpoints de /api/notificacoes da Gaspo-api. Na API,
/// as notificações são criadas pelo servidor quando a consulta muda; aqui, a
/// [NotificacaoServiceLocal] faz esse papel enquanto o app não está integrado.
abstract class NotificacaoService {
  static NotificacaoService instancia = NotificacaoServiceLocal.comExemplos();

  /// GET /api/notificacoes (mais recentes primeiro).
  Future<List<Notificacao>> listar();

  /// GET /api/notificacoes/nao-lidas
  Future<int> contarNaoLidas();

  /// PUT /api/notificacoes/{id}/lida
  Future<void> marcarComoLida(int id);

  /// PUT /api/notificacoes/lidas
  Future<void> marcarTodasComoLidas();
}

/// Guarda as notificações em memória enquanto o app não usa a API.
class NotificacaoServiceLocal implements NotificacaoService {
  final List<Notificacao> _notificacoes = [];
  int _proximoId = 1;

  NotificacaoServiceLocal();

  /// Notificações das consultas de exemplo (as mesmas de
  /// [ConsultaServiceLocal.exemplosEncerrados]); só a mais recente fica sem ler.
  factory NotificacaoServiceLocal.comExemplos({DateTime? hoje}) {
    final service = NotificacaoServiceLocal();
    final base = DateUtils.dateOnly(hoje ?? DateTime.now());
    for (final (indice, (profissional, dias, hora, minuto, status)) in ConsultaServiceLocal.exemplosEncerrados.indexed) {
      final dia = DateUtils.addDaysToDate(base, dias);
      final dataHora = DateTime(dia.year, dia.month, dia.day, hora, minuto);
      final texto = textoNotificacaoConsulta(status, profissional.nome, dataHora);
      if (texto == null) continue;
      service.notificar(
        titulo: texto.titulo,
        mensagem: texto.mensagem,
        consultaId: indice + 1,
        dataEnvio: dataHora.add(const Duration(hours: 1)),
        lida: indice != 0,
      );
    }
    return service;
  }

  /// Faz o papel do servidor: registra uma notificação para o paciente.
  Notificacao notificar({
    required String titulo,
    required String mensagem,
    int? consultaId,
    DateTime? dataEnvio,
    bool lida = false,
  }) {
    final notificacao = Notificacao(
      id: _proximoId++,
      titulo: titulo,
      mensagem: mensagem,
      dataEnvio: dataEnvio ?? DateTime.now(),
      lida: lida,
      consultaId: consultaId,
    );
    _notificacoes.add(notificacao);
    return notificacao;
  }

  @override
  Future<List<Notificacao>> listar() async =>
      List.of(_notificacoes)..sort((a, b) => b.dataEnvio.compareTo(a.dataEnvio));

  @override
  Future<int> contarNaoLidas() async => _notificacoes.where((n) => !n.lida).length;

  @override
  Future<void> marcarComoLida(int id) async {
    final i = _notificacoes.indexWhere((n) => n.id == id);
    if (i != -1) _notificacoes[i] = _notificacoes[i].copyWith(lida: true);
  }

  @override
  Future<void> marcarTodasComoLidas() async {
    for (var i = 0; i < _notificacoes.length; i++) {
      _notificacoes[i] = _notificacoes[i].copyWith(lida: true);
    }
  }
}

/// Título e mensagem da notificação criada quando a consulta passa a [status]
/// (os mesmos textos da API). Null quando o status não gera notificação.
({String titulo, String mensagem})? textoNotificacaoConsulta(
  StatusConsulta status,
  String profissional,
  DateTime dataHora,
) {
  final quando = '${formatarData(dataHora)} às ${formatarHora(TimeOfDay.fromDateTime(dataHora))}';
  final consulta = 'Sua consulta com $profissional em $quando';
  return switch (status) {
    StatusConsulta.agendada => (titulo: 'Consulta agendada', mensagem: '$consulta foi agendada.'),
    StatusConsulta.confirmada => (titulo: 'Consulta confirmada', mensagem: '$consulta foi confirmada.'),
    StatusConsulta.cancelada => (
        titulo: 'Consulta cancelada',
        mensagem: '$consulta foi cancelada pela unidade. Agende um novo horário.',
      ),
    StatusConsulta.finalizada => (
        titulo: 'Avalie seu atendimento',
        mensagem: 'Conte como foi sua consulta com $profissional em $quando.',
      ),
  };
}
