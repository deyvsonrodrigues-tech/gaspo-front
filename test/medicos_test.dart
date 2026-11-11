import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gaspo_front/app/localizacao.dart';
import 'package:gaspo_front/app/rotas.dart';
import 'package:gaspo_front/app/tema.dart';
import 'package:gaspo_front/dados/dados_exemplo.dart';
import 'package:gaspo_front/modelos/profissional.dart';
import 'package:gaspo_front/servicos/profissional_service.dart';
import 'package:gaspo_front/telas/admin/painel_funcionario_tela.dart';
import 'package:gaspo_front/telas/especialistas/especialistas_tela.dart';

late ProfissionalServiceLocal _service;

/// Cada teste usa uma lista nova de médicos (a partir dos exemplos).
void _usarServicoNovo() {
  final original = ProfissionalService.instancia;
  _service = ProfissionalServiceLocal.comExemplos();
  ProfissionalService.instancia = _service;
  addTearDown(() => ProfissionalService.instancia = original);
}

Future<void> _abrir(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: criarTemaGaspo(),
    locale: localeGaspo,
    supportedLocales: const [localeGaspo],
    localizationsDelegates: delegatesGaspo,
    home: home,
    onGenerateRoute: Rotas.gerarRota,
  ));
  await tester.pumpAndSettle();
}

Finder _campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  group('ProfissionalServiceLocal', () {
    test('cadastra com id novo, sem nota e exige e-mail único', () async {
      final service = ProfissionalServiceLocal.comExemplos();
      final nova = await service.cadastrar(const DadosProfissional(
        nome: '  Dra. Ana Souza ',
        especialidade: 'Dermatologista',
        email: 'ana@gaspo.com',
      ));
      expect(nova.id, 7);
      expect(nova.nome, 'Dra. Ana Souza');
      expect(nova.notaFormatada, 'Sem avaliações');
      expect(await service.listar(), hasLength(7));

      expect(
        () => service.cadastrar(const DadosProfissional(
          nome: 'Outro',
          especialidade: 'Pediatra',
          email: 'ANA@gaspo.com',
        )),
        throwsA(isA<ProfissionalException>()
            .having((e) => e.mensagem, 'mensagem', 'Já existe um profissional com este e-mail')),
      );
      // Editar mantendo o próprio e-mail é permitido.
      final editada = await service.atualizar(
        nova.id,
        const DadosProfissional(nome: 'Dra. Ana Souza', especialidade: 'Dermatologia', email: 'ana@gaspo.com'),
      );
      expect(editada.especialidade, 'Dermatologia');
    });

    test('status usa os valores da API', () {
      expect(StatusProfissional.presente.valorApi, 'ATENDENDO');
      expect(StatusProfissional.daApi('PAUSA'), StatusProfissional.ocupado);
    });
  });

  testWidgets('cadastra um médico pelo painel e ele aparece para o paciente', (tester) async {
    _usarServicoNovo();
    await _abrir(tester, const PainelFuncionarioTela());

    await _tocar(tester, find.text('Médicos'));
    expect(find.text('Dr. Matheus Castro'), findsOneWidget);

    await _tocar(tester, find.text('Cadastrar médico'));
    expect(find.text('Novo médico'), findsOneWidget);

    // Obrigatórios vazios.
    await _tocar(tester, find.text('Cadastrar médico'));
    expect(find.text('Informe o nome.'), findsOneWidget);
    expect(find.text('Informe a especialidade.'), findsOneWidget);

    await tester.enterText(_campo('Nome completo *'), 'Dra. Ana Souza');
    await tester.enterText(_campo('Especialidade *'), 'Dermatologista');
    await tester.enterText(_campo('E-mail'), 'ana@');
    await _tocar(tester, find.text('Cadastrar médico'));
    expect(find.text('E-mail inválido.'), findsOneWidget);

    await tester.enterText(_campo('E-mail'), 'ana@gaspo.com');
    await tester.enterText(_campo('Telefone'), '64999990000');
    await _tocar(tester, find.text('Cadastrar médico'));

    expect(find.text('Médicos'), findsOneWidget);
    expect(find.text('Dra. Ana Souza foi cadastrado.'), findsOneWidget);
    expect(find.text('Dra. Ana Souza'), findsOneWidget);

    final nova = (await _service.listar()).last;
    expect(nova.telefone, '(64) 99999-0000');
    expect(nova.unidade, unidadeSaude);

    // A lista do paciente vem do mesmo serviço (app novo, sem reaproveitar a navegação).
    await tester.pumpWidget(const SizedBox());
    await _abrir(tester, const EspecialistasTela());
    expect(find.text('Dra. Ana Souza'), findsOneWidget);
    expect(find.text('Sem avaliações'), findsOneWidget);
  });

  testWidgets('recusa e-mail repetido sem sair do formulário', (tester) async {
    _usarServicoNovo();
    await _service.atualizar(
      6,
      const DadosProfissional(nome: 'Dr. Matheus Castro', especialidade: 'Clínico Geral', email: 'matheus@gaspo.com'),
    );
    await _abrir(tester, const PainelFuncionarioTela());
    await _tocar(tester, find.text('Médicos'));
    await _tocar(tester, find.text('Cadastrar médico'));

    await tester.enterText(_campo('Nome completo *'), 'Dr. Outro');
    await tester.enterText(_campo('Especialidade *'), 'Pediatra');
    await tester.enterText(_campo('E-mail'), 'matheus@gaspo.com');
    await _tocar(tester, find.text('Cadastrar médico'));

    expect(find.text('Já existe um profissional com este e-mail'), findsOneWidget);
    expect(find.text('Novo médico'), findsOneWidget);
    expect(await _service.listar(), hasLength(6));
  });

  testWidgets('edita, muda o status e remove um médico', (tester) async {
    _usarServicoNovo();
    await _abrir(tester, const PainelFuncionarioTela());
    await _tocar(tester, find.text('Médicos'));

    // Editar o Dr. Bruno Almeida (1º em ordem alfabética: "Dr." vem antes de "Dra.").
    await _tocar(tester, find.byTooltip('Editar médico').first);
    expect(find.text('Editar médico'), findsOneWidget);
    await tester.enterText(_campo('Especialidade *'), 'Ortopedia e Traumatologia');
    await _tocar(tester, find.text('Salvar alterações'));
    expect(find.text('Dados de Dr. Bruno Almeida atualizados.'), findsOneWidget);
    expect(find.text('Ortopedia e Traumatologia'), findsOneWidget);

    // Status: Ausente → Presente.
    await _tocar(tester, find.text('Ausente'));
    await _tocar(tester, find.text('Presente').last);
    expect((await _service.buscarPorId(3))!.status, StatusProfissional.presente);

    // Remover.
    await _tocar(tester, find.byTooltip('Remover médico').first);
    await _tocar(tester, find.text('Remover'));
    expect(find.text('Dr. Bruno Almeida'), findsNothing);
    expect(await _service.buscarPorId(3), isNull);
  });
}
