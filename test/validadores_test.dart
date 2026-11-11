import 'package:flutter_test/flutter_test.dart';

import 'package:gaspo_front/utils/validadores.dart';

void main() {
  test('CPF: confere os dígitos verificadores', () {
    expect(cpfValido('529.982.247-25'), isTrue);
    expect(cpfValido('52998224725'), isTrue);
    expect(cpfValido('529.982.247-24'), isFalse);
    expect(cpfValido('111.111.111-11'), isFalse);
    expect(cpfValido('5299822472'), isFalse);
  });

  test('data de nascimento', () {
    expect(lerData('15/03/1958'), DateTime(1958, 3, 15));
    expect(lerData('31/02/2000'), isNull);
    expect(validarDataNascimento('15/03/1958'), isNull);
    expect(validarDataNascimento('01/01/3000'), 'A data não pode ser no futuro.');
    expect(validarDataNascimento(''), 'Informe sua data de nascimento.');
  });

  test('e-mail e telefone', () {
    expect(validarEmail('maria@email.com'), isNull);
    expect(validarEmail('maria@'), 'E-mail inválido.');
    expect(validarEmail('', obrigatorio: false), isNull);
    expect(validarTelefone('(64) 99999-0000'), isNull);
    expect(validarTelefone('(64) 9999'), 'Telefone incompleto.');
  });
}
