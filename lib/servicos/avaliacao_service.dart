import '../dados/dados_exemplo.dart';
import '../modelos/avaliacao.dart';

/// Avaliações dos profissionais.
///
/// Os métodos seguem os endpoints de /api/avaliacoes da Gaspo-api, para que a
/// implementação HTTP substitua a [AvaliacaoServiceLocal] sem mudar as telas.
abstract class AvaliacaoService {
  static AvaliacaoService instancia = AvaliacaoServiceLocal();

  /// GET /api/avaliacoes/profissional/{profissionalId} (mais recentes primeiro).
  Future<List<Avaliacao>> listarPorProfissional(int profissionalId);

  /// POST /api/avaliacoes. Na API, o pacienteId é o do usuário logado.
  Future<Avaliacao> avaliar({
    required int profissionalId,
    required int nota,
    String? comentario,
  });
}

/// Guarda as avaliações em memória enquanto o app não está integrado à API.
class AvaliacaoServiceLocal implements AvaliacaoService {
  final List<Avaliacao> _avaliacoes = [];
  int _proximoId = 1;

  @override
  Future<List<Avaliacao>> listarPorProfissional(int profissionalId) async {
    return _avaliacoes.where((a) => a.profissionalId == profissionalId).toList()
      ..sort((a, b) => b.dataAvaliacao.compareTo(a.dataAvaliacao));
  }

  @override
  Future<Avaliacao> avaliar({
    required int profissionalId,
    required int nota,
    String? comentario,
  }) async {
    if (nota < 1 || nota > 5) throw ArgumentError('A nota deve ser de 1 a 5');
    final texto = comentario?.trim();
    final avaliacao = Avaliacao(
      id: _proximoId++,
      nota: nota,
      comentario: (texto == null || texto.isEmpty) ? null : texto,
      nomePaciente: usuarioLogado.nome,
      profissionalId: profissionalId,
      dataAvaliacao: DateTime.now(),
    );
    _avaliacoes.add(avaliacao);
    return avaliacao;
  }
}
