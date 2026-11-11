import '../modelos/aviso.dart';

/// Erro de regra de negócio nos avisos.
class AvisoException implements Exception {
  final String mensagem;
  const AvisoException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Avisos e comunicados da unidade.
///
/// Os métodos seguem os endpoints de /api/avisos da Gaspo-api, para que a
/// implementação HTTP substitua a [AvisoServiceLocal] sem mudar as telas.
abstract class AvisoService {
  static AvisoService instancia = AvisoServiceLocal.comExemplos();

  /// GET /api/avisos (mais recentes primeiro).
  Future<List<Aviso>> listar();

  /// POST /api/avisos/publicar
  Future<Aviso> publicar(DadosAviso dados);

  /// PUT /api/avisos/{id}
  Future<Aviso> editar(int id, DadosAviso dados);

  /// DELETE /api/avisos/{id}
  Future<void> remover(int id);
}

/// Guarda os avisos em memória enquanto o app não está integrado à API.
class AvisoServiceLocal implements AvisoService {
  static const int tamanhoMaximoMensagem = 1000;

  final List<Aviso> _avisos = [];
  int _proximoId = 1;

  AvisoServiceLocal();

  /// Avisos de exemplo das telas da Letícia (repositório leticiavazx/gaspo_front).
  factory AvisoServiceLocal.comExemplos({DateTime? hoje}) {
    final agora = hoje ?? DateTime.now();
    final service = AvisoServiceLocal();
    service._adicionar(
      'Manutenção no sistema',
      'Informamos que haverá manutenção no sistema no próximo sábado, das 22h às 06h.',
      agora,
    );
    service._adicionar(
      'Dengue',
      'Os casos de dengue estão aumentando na região. Pedimos a colaboração de toda a população no combate ao mosquito.',
      DateTime(agora.year, 4, 12),
    );
    service._adicionar(
      'Gripe',
      'A Unidade de Saúde informa que houve aumento nos casos de gripe e síndromes respiratórias na região. Reforçamos a importância dos cuidados para proteger você e sua família.',
      DateTime(agora.year, 1, 20),
    );
    return service;
  }

  Aviso _adicionar(String titulo, String mensagem, DateTime data, {bool ativo = true}) {
    final aviso = Aviso(
      id: _proximoId++,
      titulo: titulo,
      mensagem: mensagem,
      dataPublicacao: data,
      ativo: ativo,
    );
    _avisos.add(aviso);
    return aviso;
  }

  /// Título e mensagem obrigatórios; mensagem até 1000 caracteres (como na API).
  void _validar(DadosAviso dados) {
    if (dados.titulo.trim().isEmpty) throw const AvisoException('Título é obrigatório');
    if (dados.mensagem.trim().isEmpty) throw const AvisoException('Mensagem é obrigatória');
    if (dados.mensagem.trim().length > tamanhoMaximoMensagem) {
      throw const AvisoException('A mensagem deve ter até 1000 caracteres');
    }
  }

  @override
  Future<List<Aviso>> listar() async =>
      List.of(_avisos)..sort((a, b) => b.dataPublicacao.compareTo(a.dataPublicacao));

  @override
  Future<Aviso> publicar(DadosAviso dados) async {
    _validar(dados);
    return _adicionar(dados.titulo.trim(), dados.mensagem.trim(), DateTime.now(), ativo: dados.ativo);
  }

  @override
  Future<Aviso> editar(int id, DadosAviso dados) async {
    final indice = _avisos.indexWhere((a) => a.id == id);
    if (indice == -1) throw const AvisoException('Aviso não encontrado');
    _validar(dados);
    final anterior = _avisos[indice];
    final editado = Aviso(
      id: id,
      titulo: dados.titulo.trim(),
      mensagem: dados.mensagem.trim(),
      dataPublicacao: anterior.dataPublicacao,
      dataExpiracao: anterior.dataExpiracao,
      ativo: dados.ativo,
    );
    _avisos[indice] = editado;
    return editado;
  }

  @override
  Future<void> remover(int id) async {
    final removidos = _avisos.length;
    _avisos.removeWhere((a) => a.id == id);
    if (_avisos.length == removidos) throw const AvisoException('Aviso não encontrado');
  }
}
