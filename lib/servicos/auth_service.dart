import '../dados/dados_exemplo.dart';
import '../modelos/perfil_acesso.dart';
import '../modelos/usuario.dart';
import 'api/cliente_api.dart';
import 'sessao_usuario.dart';

/// Erro de login ou cadastro, com a mensagem para mostrar ao usuário.
class AuthException implements Exception {
  final String mensagem;

  const AuthException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Login por CPF e senha e cadastro de paciente.
abstract class AuthService {
  static AuthService instancia = AuthServiceLocal();

  /// POST /api/pacientes/login ou /api/funcionarios/login
  Future<void> entrar({required String cpf, required String senha, required PerfilAcesso perfil});

  /// POST /api/pacientes/cadastro
  Future<void> cadastrar(DadosCadastro dados);
}

/// Sem API: aceita qualquer CPF válido e entra com o usuário de exemplo.
class AuthServiceLocal implements AuthService {
  @override
  Future<void> entrar({required String cpf, required String senha, required PerfilAcesso perfil}) async {
    SessaoUsuario.instancia.iniciar(usuario: usuarioLogado, perfil: perfil);
  }

  @override
  Future<void> cadastrar(DadosCadastro dados) async {}
}

class AuthServiceApi implements AuthService {
  final ClienteApi _api;

  AuthServiceApi([ClienteApi? api]) : _api = api ?? ClienteApi.instancia;

  @override
  Future<void> entrar({required String cpf, required String senha, required PerfilAcesso perfil}) async {
    final caminho = perfil == PerfilAcesso.funcionario ? '/api/funcionarios/login' : '/api/pacientes/login';
    final String token;
    try {
      final resposta = await _api.post(caminho, corpo: {'cpf': cpf, 'senha': senha});
      token = (resposta as Map<String, dynamic>)['token'] as String;
    } on ApiException catch (e) {
      throw AuthException(e.status == 401 ? 'CPF ou senha inválidos.' : e.mensagem);
    }

    final sessao = SessaoUsuario.instancia..iniciar(token: token, perfil: perfil);
    if (sessao.perfil == PerfilAcesso.usuario) {
      try {
        final dados = await _api.get('/api/pacientes/me') as Map<String, dynamic>;
        sessao.atualizarUsuario(Usuario.fromJson(dados));
      } on ApiException {
        // Sem os detalhes, o Perfil mostra só o nome (que veio no token).
      }
    }
  }

  @override
  Future<void> cadastrar(DadosCadastro dados) async {
    try {
      await _api.post('/api/pacientes/cadastro', corpo: dados.toJson());
    } on ApiException catch (e) {
      throw AuthException(e.mensagem);
    }
  }
}
