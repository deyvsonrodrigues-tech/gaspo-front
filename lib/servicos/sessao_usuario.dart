import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../dados/dados_exemplo.dart';
import '../modelos/perfil_acesso.dart';
import '../modelos/usuario.dart';

/// Quem está logado e o token JWT usado nas requisições.
///
/// O token fica só na memória: ao fechar o app, é preciso entrar de novo.
class SessaoUsuario extends ChangeNotifier {
  static SessaoUsuario instancia = SessaoUsuario();

  String? _token;
  Usuario? _usuario;
  PerfilAcesso? _perfil;

  String? get token => _token;
  Usuario? get usuario => _usuario;
  PerfilAcesso? get perfil => _perfil;
  bool get logado => _usuario != null;

  /// Começa a sessão. Nome, id e tipo vêm do próprio token (claims da API).
  void iniciar({String? token, Usuario? usuario, PerfilAcesso perfil = PerfilAcesso.usuario}) {
    _token = token;
    final claims = token == null ? null : lerToken(token);
    _usuario = usuario ??
        Usuario(
          id: (claims?['id'] as num?)?.toInt(),
          nome: claims?['nome'] as String? ?? '',
          email: claims?['sub'] as String?,
        );
    _perfil = claims?['tipo'] == 'FUNCIONARIO' ? PerfilAcesso.funcionario : perfil;
    notifyListeners();
  }

  /// Completa os dados do usuário (ex.: depois de GET /api/pacientes/me).
  void atualizarUsuario(Usuario usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  void encerrar() {
    _token = null;
    _usuario = null;
    _perfil = null;
    notifyListeners();
  }

  /// Lê o conteúdo (payload) de um JWT, sem validar a assinatura.
  static Map<String, dynamic>? lerToken(String token) {
    final partes = token.split('.');
    if (partes.length != 3) return null;
    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(partes[1])));
      return jsonDecode(payload) as Map<String, dynamic>;
    } on FormatException {
      return null;
    }
  }
}

/// Usuário mostrado nas telas: o da sessão ou, sem login (modo local e
/// testes), o de exemplo.
Usuario get usuarioAtual => SessaoUsuario.instancia.usuario ?? usuarioLogado;
