import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final RegExp _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String somenteDigitos(String texto) => texto.replaceAll(RegExp(r'\D'), '');

/// Máscaras dos campos de formulário.
MaskTextInputFormatter mascaraCpf() => MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

MaskTextInputFormatter mascaraData() => MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

MaskTextInputFormatter mascaraTelefone() => MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

/// CPF com 11 dígitos e dígitos verificadores corretos.
bool cpfValido(String cpf) {
  final d = somenteDigitos(cpf);
  if (d.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(d)) return false;

  int digito(int tamanho) {
    var soma = 0;
    for (var i = 0; i < tamanho; i++) {
      soma += int.parse(d[i]) * (tamanho + 1 - i);
    }
    final resto = (soma * 10) % 11;
    return resto == 10 ? 0 : resto;
  }

  return digito(9) == int.parse(d[9]) && digito(10) == int.parse(d[10]);
}

bool emailValido(String email) => _formatoEmail.hasMatch(email.trim());

/// Converte dd/mm/aaaa em data, ou null se a data não existir.
DateTime? lerData(String texto) {
  final partes = texto.split('/');
  if (partes.length != 3 || partes[2].length != 4) return null;
  final dia = int.tryParse(partes[0]);
  final mes = int.tryParse(partes[1]);
  final ano = int.tryParse(partes[2]);
  if (dia == null || mes == null || ano == null) return null;
  final data = DateTime(ano, mes, dia);
  // DateTime "corrige" datas como 31/02; aqui elas são inválidas.
  if (data.day != dia || data.month != mes || data.year != ano) return null;
  return data;
}

// Validadores prontos para TextFormField (null = válido).

String? validarObrigatorio(String? valor, String mensagem) =>
    (valor == null || valor.trim().isEmpty) ? mensagem : null;

String? validarCpf(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'Informe seu CPF.';
  return cpfValido(valor) ? null : 'CPF inválido. Confira os números.';
}

String? validarEmail(String? valor, {bool obrigatorio = true}) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return obrigatorio ? 'Informe seu e-mail.' : null;
  return emailValido(texto) ? null : 'E-mail inválido.';
}

String? validarTelefone(String? valor) {
  final digitos = somenteDigitos(valor ?? '');
  if (digitos.isEmpty) return null;
  return (digitos.length == 10 || digitos.length == 11) ? null : 'Telefone incompleto.';
}

String? validarDataNascimento(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'Informe sua data de nascimento.';
  final data = lerData(valor);
  if (data == null) return 'Data inválida. Use dd/mm/aaaa.';
  final hoje = DateTime.now();
  if (data.isAfter(hoje)) return 'A data não pode ser no futuro.';
  if (data.year < hoje.year - 130) return 'Confira o ano de nascimento.';
  return null;
}
