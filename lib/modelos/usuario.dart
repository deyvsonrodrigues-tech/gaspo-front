/// Pessoa logada. Com a API, vem do token e de GET /api/pacientes/me
/// (UsuarioResponseDTO); a API não guarda endereço.
class Usuario {
  final int? id;
  final String nome;
  final String? cpf;
  final String? email;
  final String? telefone;
  final String? endereco;

  const Usuario({
    this.id,
    required this.nome,
    this.cpf,
    this.email,
    this.telefone,
    this.endereco,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as int?,
        nome: json['nome'] as String? ?? '',
        cpf: json['cpf'] as String?,
        email: json['email'] as String?,
        telefone: json['telefone'] as String?,
      );
}

/// Dados do formulário de cadastro (UsuarioCadastroDTO).
class DadosCadastro {
  final String nome;
  final String cpf;
  final DateTime? dataNascimento;
  final String? telefone;
  final String email;
  final String senha;

  const DadosCadastro({
    required this.nome,
    required this.cpf,
    this.dataNascimento,
    this.telefone,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    String doisDigitos(int valor) => valor.toString().padLeft(2, '0');
    final data = dataNascimento;
    return {
      'nome': nome.trim(),
      'cpf': cpf.replaceAll(RegExp(r'\D'), ''),
      'dataNascimento': data == null ? null : '${data.year}-${doisDigitos(data.month)}-${doisDigitos(data.day)}',
      'telefone': (telefone == null || telefone!.trim().isEmpty) ? null : telefone!.trim(),
      'email': email.trim(),
      'senha': senha,
    };
  }
}
