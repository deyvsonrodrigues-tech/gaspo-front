import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../sessao_usuario.dart';

/// Erro devolvido pela Gaspo-api (ou falta de conexão com ela).
class ApiException implements Exception {
  final String mensagem;

  /// Código HTTP; nulo quando o servidor não respondeu.
  final int? status;

  const ApiException(this.mensagem, {this.status});

  bool get semConexao => status == null;

  @override
  String toString() => mensagem;
}

/// Faz as requisições à Gaspo-api, enviando o token do login.
///
/// O endereço vem de `--dart-define=API_URL=...` (padrão: http://localhost:8080).
/// No celular ligado por USB, `adb reverse tcp:8080 tcp:8080` faz o
/// localhost do aparelho chegar ao computador.
class ClienteApi {
  static const String urlPadrao = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
  static const Duration tempoLimite = Duration(seconds: 15);

  static ClienteApi instancia = ClienteApi();

  final String baseUrl;
  final http.Client _http;
  final String? Function() _token;

  ClienteApi({String? baseUrl, http.Client? client, String? Function()? token})
      : baseUrl = baseUrl ?? urlPadrao,
        _http = client ?? http.Client(),
        _token = token ?? (() => SessaoUsuario.instancia.token);

  Future<dynamic> get(String caminho, {Map<String, Object?>? query}) =>
      _enviar('GET', caminho, query: query);

  Future<dynamic> post(String caminho, {Object? corpo, Map<String, Object?>? query}) =>
      _enviar('POST', caminho, corpo: corpo, query: query);

  Future<dynamic> put(String caminho, {Object? corpo}) => _enviar('PUT', caminho, corpo: corpo);

  Future<dynamic> delete(String caminho) => _enviar('DELETE', caminho);

  Uri _uri(String caminho, Map<String, Object?>? query) {
    final parametros = {
      for (final MapEntry(:key, :value) in (query ?? const <String, Object?>{}).entries)
        if (value != null) key: '$value',
    };
    return Uri.parse('$baseUrl$caminho').replace(queryParameters: parametros.isEmpty ? null : parametros);
  }

  Future<dynamic> _enviar(String metodo, String caminho, {Object? corpo, Map<String, Object?>? query}) async {
    final requisicao = http.Request(metodo, _uri(caminho, query));
    requisicao.headers['Accept'] = 'application/json';
    final token = _token();
    if (token != null) requisicao.headers['Authorization'] = 'Bearer $token';
    if (corpo != null) {
      requisicao.headers['Content-Type'] = 'application/json; charset=utf-8';
      requisicao.body = jsonEncode(corpo);
    }

    final http.Response resposta;
    try {
      resposta = await http.Response.fromStream(await _http.send(requisicao).timeout(tempoLimite));
    } on TimeoutException {
      throw const ApiException('O servidor demorou para responder. Tente de novo.');
    } on http.ClientException {
      throw const ApiException('Não foi possível conectar ao servidor. Verifique sua conexão.');
    }

    final texto = utf8.decode(resposta.bodyBytes);
    final dados = _decodificar(texto);
    if (resposta.statusCode >= 200 && resposta.statusCode < 300) return dados;
    throw ApiException(_mensagemDeErro(resposta.statusCode, dados), status: resposta.statusCode);
  }

  static dynamic _decodificar(String texto) {
    if (texto.isEmpty) return null;
    try {
      return jsonDecode(texto);
    } on FormatException {
      return texto; // Alguns endpoints respondem com texto simples.
    }
  }

  /// Usa a mensagem do GlobalExceptionHandler da API quando existe.
  static String _mensagemDeErro(int status, dynamic dados) {
    final mensagem = dados is Map ? dados['message'] : null;
    if (mensagem is String && mensagem.trim().isNotEmpty) return mensagem;
    return switch (status) {
      401 || 403 => 'Sua sessão expirou ou você não tem acesso. Entre novamente.',
      404 => 'Registro não encontrado.',
      _ => 'Não foi possível concluir a operação (erro $status).',
    };
  }
}
