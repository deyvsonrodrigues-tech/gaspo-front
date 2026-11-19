import 'package:flutter/material.dart';

import '../../modelos/agenda.dart';
import '../../modelos/avaliacao.dart';
import '../../modelos/avaliacao_consulta.dart';
import '../../modelos/aviso.dart';
import '../../modelos/consulta.dart';
import '../../modelos/notificacao.dart';
import '../../modelos/profissional.dart';
import '../agenda_service.dart';
import '../avaliacao_consulta_service.dart';
import '../avaliacao_service.dart';
import '../aviso_service.dart';
import '../consulta_service.dart';
import '../notificacao_service.dart';
import '../profissional_service.dart';
import '../sessao_usuario.dart';
import 'cliente_api.dart';

// Implementações dos serviços que conversam com a Gaspo-api. Os erros da API
// viram as mesmas exceções dos serviços locais, para as telas mostrarem a
// mensagem do servidor.

List<Map<String, dynamic>> _lista(dynamic dados) => (dados as List).cast<Map<String, dynamic>>();

/// Lista paginada (ConsultaResumoPageDTO): só o conteúdo.
List<Map<String, dynamic>> _pagina(dynamic dados) => _lista((dados as Map<String, dynamic>)['content']);

/// Tamanho de página grande o bastante para as listas do app.
const _tamanhoPagina = 200;

class ProfissionalServiceApi implements ProfissionalService {
  final ClienteApi _api;

  ProfissionalServiceApi([ClienteApi? api]) : _api = api ?? ClienteApi.instancia;

  Future<T> _tratar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on ApiException catch (e) {
      throw ProfissionalException(e.mensagem);
    }
  }

  @override
  Future<List<Profissional>> listar() async =>
      _lista(await _api.get('/api/profissionais')).map(Profissional.fromJson).toList();

  @override
  Future<Profissional?> buscarPorId(int id) async {
    try {
      return Profissional.fromJson(await _api.get('/api/profissionais/$id'));
    } on ApiException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Profissional> cadastrar(DadosProfissional dados) => _tratar(() async =>
      Profissional.fromJson(await _api.post('/api/profissionais', corpo: dados.toJson())));

  @override
  Future<Profissional> atualizar(int id, DadosProfissional dados) => _tratar(() async =>
      Profissional.fromJson(await _api.put('/api/profissionais/$id', corpo: dados.toJson())));

  @override
  Future<Profissional> atualizarStatus(int id, StatusProfissional status) => _tratar(() async {
        await _api.put('/api/profissionais/status', corpo: {'profissionalId': id, 'novoStatus': status.valorApi});
        final atualizado = await buscarPorId(id);
        if (atualizado == null) throw const ProfissionalException('Profissional não encontrado');
        return atualizado;
      });

  @override
  Future<void> remover(int id) => _tratar(() => _api.delete('/api/profissionais/$id'));
}

class AgendaServiceApi implements AgendaService {
  final ClienteApi _api;

  AgendaServiceApi([ClienteApi? api]) : _api = api ?? ClienteApi.instancia;

  @override
  Future<List<HorarioAgenda>> listar() async {
    final horarios = _lista(await _api.get('/api/agendas')).map(HorarioAgenda.fromJson).toList();
    return horarios
      ..sort((a, b) {
        final porData = a.data.compareTo(b.data);
        return porData != 0 ? porData : compararHorarios(a.horario, b.horario);
      });
  }

  @override
  Future<void> gerarGrade({
    required int profissionalId,
    required DateTime data,
    required List<TimeOfDay> horarios,
  }) async {
    await _api.post(
      '/api/agendas/gerar-grade',
      query: {'profissionalId': profissionalId, 'data': HorarioAgenda.dataApi(data)},
      corpo: [for (final hora in horarios) HorarioAgenda.horaApi(hora)],
    );
  }

  @override
  Future<HorarioAgenda> atualizar(HorarioAgenda horario) async =>
      HorarioAgenda.fromJson(await _api.put('/api/agendas/${horario.id}', corpo: horario.toRequestJson()));

  @override
  Future<void> remover(int id) => _api.delete('/api/agendas/$id');
}

class ConsultaServiceApi implements ConsultaService {
  final ClienteApi _api;

  ConsultaServiceApi([ClienteApi? api]) : _api = api ?? ClienteApi.instancia;

  Future<T> _tratar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on ApiException catch (e) {
      throw AgendamentoException(e.mensagem);
    }
  }

  Future<List<Consulta>> _consultas(String caminho, {Map<String, Object?>? query}) async {
    final dados = await _api.get(caminho, query: {'size': _tamanhoPagina, ...?query});
    return _pagina(dados).map(Consulta.fromJson).toList();
  }

  @override
  Future<List<HorarioAgenda>> horariosDisponiveis({required int profissionalId, required DateTime data}) async {
    final dados = await _api.get(
      '/api/consultas/horarios-disponiveis',
      query: {'profissionalId': profissionalId, 'data': HorarioAgenda.dataApi(data)},
    );
    return _lista(dados).map(HorarioAgenda.fromJson).toList();
  }

  @override
  Future<Consulta> agendar({required int profissionalId, required DateTime dataHora}) => _tratar(() async =>
      Consulta.fromJson(await _api.post(
        '/api/consultas',
        corpo: Consulta.agendamentoJson(profissionalId: profissionalId, dataHora: dataHora),
      )));

  @override
  Future<List<Consulta>> listarAtivas() async =>
      (await _consultas('/api/consultas/ativos'))..sort((a, b) => a.dataHora.compareTo(b.dataHora));

  @override
  Future<List<Consulta>> listarHistorico() async =>
      (await _consultas('/api/consultas/meu-historico'))..sort((a, b) => b.dataHora.compareTo(a.dataHora));

  @override
  Future<void> cancelar(int id) => _tratar(() => _api.put('/api/consultas/cancelar/$id'));

  @override
  Future<List<Consulta>> listarTodas() async =>
      (await _consultas('/api/consultas'))..sort((a, b) => a.dataHora.compareTo(b.dataHora));

  @override
  Future<Consulta> alterarStatus(int id, StatusConsulta novoStatus) => _tratar(() async =>
      Consulta.fromJson(await _api.put('/api/consultas/$id/status', corpo: {'status': novoStatus.valorApi})));
}

class AvisoServiceApi implements AvisoService {
  final ClienteApi _api;

  AvisoServiceApi([ClienteApi? api]) : _api = api ?? ClienteApi.instancia;

  Future<T> _tratar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on ApiException catch (e) {
      throw AvisoException(e.mensagem);
    }
  }

  @override
  Future<List<Aviso>> listar() async => _lista(await _api.get('/api/avisos')).map(Aviso.fromJson).toList()
    ..sort((a, b) => b.dataPublicacao.compareTo(a.dataPublicacao));

  @override
  Future<Aviso> publicar(DadosAviso dados) =>
      _tratar(() async => Aviso.fromJson(await _api.post('/api/avisos/publicar', corpo: dados.toJson())));

  @override
  Future<Aviso> editar(int id, DadosAviso dados) =>
      _tratar(() async => Aviso.fromJson(await _api.put('/api/avisos/$id', corpo: dados.toJson())));

  @override
  Future<void> remover(int id) => _tratar(() => _api.delete('/api/avisos/$id'));
}

class AvaliacaoServiceApi implements AvaliacaoService {
  final ClienteApi _api;

  AvaliacaoServiceApi([ClienteApi? api]) : _api = api ?? ClienteApi.instancia;

  @override
  Future<List<Avaliacao>> listarPorProfissional(int profissionalId) async =>
      _lista(await _api.get('/api/avaliacoes/profissional/$profissionalId')).map(Avaliacao.fromJson).toList()
        ..sort((a, b) => b.dataAvaliacao.compareTo(a.dataAvaliacao));

  @override
  Future<Avaliacao> avaliar({required int profissionalId, required int nota, String? comentario}) async {
    final pacienteId = SessaoUsuario.instancia.usuario?.id;
    if (pacienteId == null) throw const ApiException('Entre na sua conta para avaliar.');
    final texto = comentario?.trim();
    return Avaliacao.fromJson(await _api.post(
      '/api/avaliacoes',
      corpo: Avaliacao.requestJson(
        nota: nota,
        comentario: (texto == null || texto.isEmpty) ? null : texto,
        pacienteId: pacienteId,
        profissionalId: profissionalId,
      ),
    ));
  }
}

class AvaliacaoConsultaServiceApi implements AvaliacaoConsultaService {
  final ClienteApi _api;

  AvaliacaoConsultaServiceApi([ClienteApi? api]) : _api = api ?? ClienteApi.instancia;

  @override
  Future<AvaliacaoConsulta> avaliar(DadosAvaliacaoConsulta dados) async {
    try {
      return AvaliacaoConsulta.fromJson(await _api.post('/api/avaliacoes-consulta', corpo: dados.toJson()));
    } on ApiException catch (e) {
      throw AvaliacaoConsultaException(e.mensagem);
    }
  }

  @override
  Future<List<AvaliacaoConsulta>> listarMinhas() async =>
      _lista(await _api.get('/api/avaliacoes-consulta/minhas')).map(AvaliacaoConsulta.fromJson).toList()
        ..sort((a, b) => b.dataAvaliacao.compareTo(a.dataAvaliacao));
}

class NotificacaoServiceApi implements NotificacaoService {
  final ClienteApi _api;

  NotificacaoServiceApi([ClienteApi? api]) : _api = api ?? ClienteApi.instancia;

  @override
  Future<List<Notificacao>> listar() async =>
      _lista(await _api.get('/api/notificacoes')).map(Notificacao.fromJson).toList();

  @override
  Future<int> contarNaoLidas() async =>
      ((await _api.get('/api/notificacoes/nao-lidas') as Map<String, dynamic>)['quantidade'] as num).toInt();

  @override
  Future<void> marcarComoLida(int id) => _api.put('/api/notificacoes/$id/lida');

  @override
  Future<void> marcarTodasComoLidas() => _api.put('/api/notificacoes/lidas');
}
