import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gaspo_front/app/localizacao.dart';
import 'package:gaspo_front/app/rotas.dart';
import 'package:gaspo_front/app/tema.dart';
import 'package:gaspo_front/modelos/aviso.dart';
import 'package:gaspo_front/servicos/aviso_service.dart';
import 'package:gaspo_front/telas/admin/painel_funcionario_tela.dart';
import 'package:gaspo_front/telas/avisos/avisos_tela.dart';
import 'package:gaspo_front/telas/inicio/home_tela.dart';

late AvisoServiceLocal _service;

/// Cada teste usa uma lista nova de avisos (a partir dos exemplos).
void _usarServicoNovo() {
  final original = AvisoService.instancia;
  _service = AvisoServiceLocal.comExemplos();
  AvisoService.instancia = _service;
  addTearDown(() => AvisoService.instancia = original);
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

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

Finder _campo(String hint) => find.widgetWithText(TextFormField, hint);

void main() {
  group('AvisoServiceLocal (regras da API)', () {
    test('publica com data de hoje e exige título e mensagem', () async {
      final service = AvisoServiceLocal();
      final aviso = await service.publicar(const DadosAviso(titulo: ' Vacinação ', mensagem: 'Campanha aberta.'));
      expect(aviso.titulo, 'Vacinação');
      expect(aviso.publicadoHoje, isTrue);
      expect(aviso.ativo, isTrue);

      expect(
        () => service.publicar(const DadosAviso(titulo: ' ', mensagem: 'x')),
        throwsA(isA<AvisoException>().having((e) => e.mensagem, 'mensagem', 'Título é obrigatório')),
      );
      expect(
        () => service.publicar(DadosAviso(titulo: 'x', mensagem: 'a' * 1001)),
        throwsA(isA<AvisoException>()),
      );
    });

    test('lista do mais recente para o mais antigo', () async {
      final lista = await AvisoServiceLocal.comExemplos().listar();
      expect(lista.map((a) => a.titulo), ['Manutenção no sistema', 'Dengue', 'Gripe']);
    });

    test('lê o AvisoResponseDTO da API', () {
      final aviso = Aviso.fromJson({
        'id': 4,
        'titulo': 'Dengue',
        'mensagem': 'Cuidado com água parada.',
        'dataPublicacao': '2026-04-12T13:00:00.000+00:00',
        'dataExpiracao': '2020-01-01T00:00:00.000+00:00',
        'ativo': true,
      });
      expect(aviso.expirado, isTrue);
      expect(aviso.visivelParaPacientes, isFalse);
    });
  });

  testWidgets('Comunicados do Início abre o feed com os avisos', (tester) async {
    _usarServicoNovo();
    await _abrir(tester, const HomeTela());

    await _tocar(tester, find.text('Comunicados'));
    expect(find.text('Fique por dentro de todas as novidades e comunicados importantes!'), findsOneWidget);
    expect(find.text('Manutenção no sistema'), findsOneWidget);
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('12/04'), findsOneWidget);
    expect(find.text('Gripe'), findsOneWidget);
    // Com 3 avisos não há o que expandir.
    expect(find.text('VER TODOS'), findsNothing);
  });

  testWidgets('VER TODOS mostra além dos 3 mais recentes; ocultos não aparecem', (tester) async {
    _usarServicoNovo();
    await _service.publicar(const DadosAviso(titulo: 'Vacinação', mensagem: 'Campanha aberta.'));
    await _service.publicar(const DadosAviso(titulo: 'Rascunho', mensagem: 'Ainda não.', ativo: false));
    await _abrir(tester, const AvisosTela());

    expect(find.text('Vacinação'), findsOneWidget);
    expect(find.text('Gripe'), findsNothing);
    expect(find.text('Rascunho'), findsNothing);

    await _tocar(tester, find.text('VER TODOS'));
    await tester.scrollUntilVisible(find.text('Gripe'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Gripe'), findsOneWidget);
    expect(find.text('Rascunho'), findsNothing);
  });

  testWidgets('funcionário publica, atualiza e remove avisos', (tester) async {
    _usarServicoNovo();
    await _abrir(tester, const PainelFuncionarioTela());

    await _tocar(tester, find.text('Avisos'));
    expect(find.text('Avisos Publicados'), findsOneWidget);
    expect(find.text('Dengue'), findsOneWidget);

    // Publicar (com validação).
    await _tocar(tester, find.text('Novo Aviso'));
    await _tocar(tester, find.text('Publicar'));
    expect(find.text('Informe o título.'), findsOneWidget);
    expect(find.text('Informe a mensagem.'), findsOneWidget);

    await tester.enterText(_campo('Ex: Vacinação'), 'Vacinação contra gripe');
    await tester.enterText(_campo('Digite o conteúdo do aviso'), 'Vacinação aberta para maiores de 60 anos.');
    await _tocar(tester, find.text('Publicar'));
    expect(find.text('Aviso publicado.'), findsOneWidget);
    expect(find.text('Vacinação contra gripe'), findsOneWidget);

    // Atualizar o mais recente (primeiro da lista) e ocultar.
    await _tocar(tester, find.text('Atualizar').first);
    expect(find.text('Atualizar Aviso'), findsOneWidget);
    await tester.enterText(_campo('Vacinação contra gripe'), 'Vacinação contra a gripe');
    await _tocar(tester, find.text('Visível para os pacientes'));
    await _tocar(tester, find.text('Salvar'));
    expect(find.text('Aviso atualizado.'), findsOneWidget);
    expect(find.text('Vacinação contra a gripe'), findsOneWidget);
    expect(find.text('Oculto'), findsOneWidget);

    // Remover a Dengue.
    final dengue = (await _service.listar()).firstWhere((a) => a.titulo == 'Dengue');
    final indice = (await _service.listar()).indexOf(dengue);
    await _tocar(tester, find.text('Remover').at(indice));
    await _tocar(tester, find.text('Remover').last);
    expect(find.text('Aviso removido.'), findsOneWidget);
    expect(find.text('Dengue'), findsNothing);
    expect(await _service.listar(), hasLength(3));
  });
}
