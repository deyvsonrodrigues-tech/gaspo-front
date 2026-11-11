import '../dados/dados_exemplo.dart';
import '../modelos/profissional.dart';

/// Erro de regra de negócio no cadastro de profissionais.
class ProfissionalException implements Exception {
  final String mensagem;
  const ProfissionalException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Médicos e demais profissionais de saúde.
///
/// Os métodos seguem os endpoints de /api/profissionais da Gaspo-api, para que
/// a implementação HTTP substitua a [ProfissionalServiceLocal] sem mudar as telas.
abstract class ProfissionalService {
  static ProfissionalService instancia = ProfissionalServiceLocal.comExemplos();

  /// GET /api/profissionais
  Future<List<Profissional>> listar();

  /// GET /api/profissionais/{id}
  Future<Profissional?> buscarPorId(int id);

  /// POST /api/profissionais
  Future<Profissional> cadastrar(DadosProfissional dados);

  /// PUT /api/profissionais/{id}
  Future<Profissional> atualizar(int id, DadosProfissional dados);

  /// PUT /api/profissionais/status
  Future<Profissional> atualizarStatus(int id, StatusProfissional status);

  /// DELETE /api/profissionais/{id}
  Future<void> remover(int id);
}

/// Guarda os profissionais em memória enquanto o app não está integrado à API.
class ProfissionalServiceLocal implements ProfissionalService {
  final List<Profissional> _profissionais;
  int _proximoId;

  ProfissionalServiceLocal([List<Profissional> iniciais = const []])
      : _profissionais = List.of(iniciais),
        _proximoId = iniciais.fold<int>(0, (maior, p) => p.id > maior ? p.id : maior) + 1;

  /// Começa com os médicos de exemplo de [profissionais].
  factory ProfissionalServiceLocal.comExemplos() => ProfissionalServiceLocal(profissionais);

  @override
  Future<List<Profissional>> listar() async => List.unmodifiable(_profissionais);

  @override
  Future<Profissional?> buscarPorId(int id) async =>
      _profissionais.where((p) => p.id == id).firstOrNull;

  int _indice(int id) {
    final indice = _profissionais.indexWhere((p) => p.id == id);
    if (indice == -1) throw const ProfissionalException('Profissional não encontrado');
    return indice;
  }

  /// Nome obrigatório (como na API) e e-mail único (coluna unique na API).
  void _validar(DadosProfissional dados, {int? id}) {
    if (dados.nome.trim().isEmpty) {
      throw const ProfissionalException('Nome do profissional é obrigatório');
    }
    final email = dados.email?.trim().toLowerCase();
    if (email != null && email.isNotEmpty) {
      final repetido = _profissionais.any((p) => p.id != id && p.email?.toLowerCase() == email);
      if (repetido) {
        throw const ProfissionalException('Já existe um profissional com este e-mail');
      }
    }
  }

  Profissional _montar(int id, DadosProfissional dados, {Profissional? anterior}) {
    String? limpo(String? valor) => (valor == null || valor.trim().isEmpty) ? null : valor.trim();
    return Profissional(
      id: id,
      nome: dados.nome.trim(),
      especialidade: dados.especialidade.trim(),
      nota: anterior?.nota ?? 0,
      totalAvaliacoes: anterior?.totalAvaliacoes ?? 0,
      status: dados.status,
      email: limpo(dados.email),
      telefone: limpo(dados.telefone),
      unidade: dados.unidade,
    );
  }

  @override
  Future<Profissional> cadastrar(DadosProfissional dados) async {
    _validar(dados);
    final profissional = _montar(_proximoId++, dados);
    _profissionais.add(profissional);
    return profissional;
  }

  @override
  Future<Profissional> atualizar(int id, DadosProfissional dados) async {
    final indice = _indice(id);
    _validar(dados, id: id);
    final atualizado = _montar(id, dados, anterior: _profissionais[indice]);
    _profissionais[indice] = atualizado;
    return atualizado;
  }

  @override
  Future<Profissional> atualizarStatus(int id, StatusProfissional status) async {
    final indice = _indice(id);
    final atualizado = _profissionais[indice].copyWith(status: status);
    _profissionais[indice] = atualizado;
    return atualizado;
  }

  @override
  Future<void> remover(int id) async {
    _profissionais.removeWhere((p) => p.id == id);
  }
}
