import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:gaspo_front/modelos/consulta.dart';
import 'package:gaspo_front/modelos/perfil_acesso.dart';
import 'package:gaspo_front/servicos/api/cliente_api.dart';
import 'package:gaspo_front/servicos/api/servicos_api.dart';
import 'package:gaspo_front/servicos/auth_service.dart';
import 'package:gaspo_front/servicos/consulta_service.dart';
import 'package:gaspo_front/servicos/sessao_usuario.dart';

/// JWT com o mesmo conteúdo que a Gaspo-api gera (assinatura irrelevante aqui).
String _token(Map<String, dynamic> claims) {
  String parte(Map<String, dynamic> m) => base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${parte({'alg': 'HS256'})}.${parte(claims)}.assinatura';
}

http.Response _json(Object? corpo, [int status = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(corpo)),
      status,
      headers: {'content-type': 'application/json'},
    );

void main() {
  setUp(() => SessaoUsuario.instancia = SessaoUsuario());

  test('login do paciente guarda o token e completa os dados com /me', () async {
    final token = _token({'sub': 'maria@email.com', 'id': 7, 'nome': 'Maria', 'tipo': 'USUARIO'});
    final requisicoes = <http.Request>[];
    final api = ClienteApi(
      baseUrl: 'http://api',
      client: MockClient((req) async {
        requisicoes.add(req);
        return switch (req.url.path) {
          '/api/pacientes/login' => _json({'token': token}),
          '/api/pacientes/me' => _json({'id': 7, 'nome': 'Maria das Dores', 'cpf': '52998224725', 'email': 'maria@email.com'}),
          _ => _json(null, 404),
        };
      }),
    );

    await AuthServiceApi(api).entrar(cpf: '529.982.247-25', senha: 'abc123', perfil: PerfilAcesso.usuario);

    expect(jsonDecode(requisicoes.first.body), {'cpf': '529.982.247-25', 'senha': 'abc123'});
    expect(requisicoes.last.headers['Authorization'], 'Bearer $token');
    final sessao = SessaoUsuario.instancia;
    expect(sessao.token, token);
    expect(sessao.usuario!.id, 7);
    expect(sessao.usuario!.nome, 'Maria das Dores');
    expect(usuarioAtual.email, 'maria@email.com');
  });

  test('token de funcionário abre a sessão como funcionário', () async {
    final token = _token({'sub': 'ana@ubs.gov', 'id': 2, 'nome': 'Ana', 'tipo': 'FUNCIONARIO'});
    final api = ClienteApi(baseUrl: 'http://api', client: MockClient((_) async => _json({'token': token})));

    await AuthServiceApi(api).entrar(cpf: '52998224725', senha: 'x', perfil: PerfilAcesso.funcionario);

    expect(SessaoUsuario.instancia.perfil, PerfilAcesso.funcionario);
    expect(SessaoUsuario.instancia.usuario!.nome, 'Ana');
  });

  test('senha errada vira mensagem amigável', () async {
    final api = ClienteApi(
      baseUrl: 'http://api',
      client: MockClient((_) async => _json({'status': 401, 'message': 'Bad credentials'}, 401)),
    );

    expect(
      () => AuthServiceApi(api).entrar(cpf: '52998224725', senha: 'x', perfil: PerfilAcesso.usuario),
      throwsA(isA<AuthException>().having((e) => e.mensagem, 'mensagem', 'CPF ou senha inválidos.')),
    );
  });

  test('sem servidor, avisa que não conseguiu conectar', () async {
    final api = ClienteApi(
      baseUrl: 'http://api',
      client: MockClient((_) async => throw http.ClientException('Connection refused')),
    );

    expect(
      () => api.get('/api/avisos'),
      throwsA(isA<ApiException>().having((e) => e.semConexao, 'semConexao', isTrue)),
    );
  });

  test('consultas: lê a página da API e repassa a mensagem de erro', () async {
    final api = ClienteApi(
      baseUrl: 'http://api',
      client: MockClient((req) async {
        if (req.url.path == '/api/consultas/ativos') {
          expect(req.url.queryParameters['size'], '200');
          return _json({
            'content': [
              {
                'id': 3,
                'data': '2026-12-01T13:00:00.000+00:00',
                'status': 'AGENDADA',
                'profissionalId': 1,
                'nomeProfissional': 'Dra. Olivia Silva',
              },
            ],
            'page': 0,
            'size': 200,
            'totalElements': 1,
            'totalPages': 1,
            'first': true,
            'last': true,
          });
        }
        return _json({'status': 400, 'message': 'Horário indisponível para agendamento'}, 400);
      }),
    );
    final service = ConsultaServiceApi(api);

    final ativas = await service.listarAtivas();
    expect(ativas.single.status, StatusConsulta.agendada);
    expect(ativas.single.dataHora, DateTime.utc(2026, 12, 1, 13).toLocal());

    expect(
      () => service.agendar(profissionalId: 1, dataHora: DateTime(2026, 12, 2, 9)),
      throwsA(isA<AgendamentoException>()
          .having((e) => e.mensagem, 'mensagem', 'Horário indisponível para agendamento')),
    );
  });
}
