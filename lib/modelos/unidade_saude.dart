/// Unidade de Saúde (UnidadeSaudeModel na API).
class UnidadeSaude {
  final String? nome;
  final String endereco;
  final String? telefone;
  final String? horarioFuncionamento;

  const UnidadeSaude({
    this.nome,
    required this.endereco,
    this.telefone,
    this.horarioFuncionamento,
  });
}
