import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gaspo_front/app/localizacao.dart';
import 'package:gaspo_front/app/rotas.dart';
import 'package:gaspo_front/app/tema.dart';
import 'package:gaspo_front/modelos/avaliacao_consulta.dart';
import 'package:gaspo_front/servicos/avaliacao_consulta_service.dart';
import 'package:gaspo_front/telas/avaliacao/avaliacao_consulta_tela.dart';

Future<void> _abrir(WidgetTester tester, AvaliacaoConsultaService service) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: criarTemaGaspo(),
    locale: localeGaspo,
    supportedLocales: const [localeGaspo],
    localizationsDelegates: delegatesGaspo,
    home: AvaliacaoConsultaTela(service: service),
    onGenerateRoute: Rotas.gerarRota,
  ));
  await tester.pumpAndSettle();
}

Future<void> _avancar(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Avançar para Profissional'));
  await tester.tap(find.text('Avançar para Profissional'));
  await tester.pumpAndSettle();
}

Finder _campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

void main() {
  group('AvaliacaoConsultaServiceLocal (regras da API)', () {
    test('usa a especialidade do profissional quando não é informada', () async {
      final service = AvaliacaoConsultaServiceLocal();
      final avaliacao = await service.avaliar(DadosAvaliacaoConsulta(
        nota: 4,
        comentario: '  Atendimento rápido.  ',
        profissionalId: 6,
        dataConsulta: DateTime(2026, 11, 3),
      ));
      expect(avaliacao.especialidade, 'Clínico Geral');
      expect(avaliacao.comentario, 'Atendimento rápido.');
      expect(await service.listarMinhas(), hasLength(1));
    });

    test('recusa data futura, nota fora de 1 a 5 e profissional inexistente', () async {
      final service = AvaliacaoConsultaServiceLocal();
      final amanha = DateTime.now().add(const Duration(days: 1));
      expect(
        () => service.avaliar(DadosAvaliacaoConsulta(nota: 4, profissionalId: 6, dataConsulta: amanha)),
        throwsA(isA<AvaliacaoConsultaException>()),
      );
      expect(
        () => service.avaliar(DadosAvaliacaoConsulta(nota: 6, profissionalId: 6, dataConsulta: DateTime(2026))),
        throwsA(isA<AvaliacaoConsultaException>()),
      );
      expect(
        () => service.avaliar(DadosAvaliacaoConsulta(nota: 3, profissionalId: 99, dataConsulta: DateTime(2026))),
        throwsA(isA<AvaliacaoConsultaException>()
            .having((e) => e.mensagem, 'mensagem', 'Profissional não encontrado')),
      );
    });

    test('monta o JSON do AvaliacaoConsultaRequestDTO', () {
      final json = DadosAvaliacaoConsulta(
        nota: 5,
        profissionalId: 6,
        dataConsulta: DateTime(2026, 11, 3),
        horarioConsulta: const TimeOfDay(hour: 9, minute: 30),
      ).toJson();
      expect(json['dataConsulta'], '2026-11-03');
      expect(json['horarioConsulta'], '09:30:00');
      expect(json['nota'], 5);
    });
  });

  testWidgets('valida os campos antes de avançar', (tester) async {
    final service = AvaliacaoConsultaServiceLocal();
    await _abrir(tester, service);

    await _avancar(tester);
    expect(find.text('Escolha o profissional.'), findsOneWidget);
    expect(find.text('Informe a data.'), findsOneWidget);

    await tester.enterText(_campo('Data'), '01013000');
    await tester.enterText(_campo('Horário'), '9');
    await _avancar(tester);
    expect(find.text('Data no futuro.'), findsOneWidget);
    expect(find.text('Horário incompleto.'), findsOneWidget);
    expect(await service.listarMinhas(), isEmpty);
  });

  testWidgets('salva a avaliação da consulta e segue para o profissional', (tester) async {
    final service = AvaliacaoConsultaServiceLocal();
    await _abrir(tester, service);

    await tester.tap(find.text('Profissional'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dr. Matheus Castro').last);
    await tester.pumpAndSettle();
    await tester.enterText(_campo('Data'), '03112026');
    await tester.enterText(_campo('Horário'), '0930');
    await tester.enterText(_campo('Unidade de Saúde'), 'UBS Centro');
    await tester.enterText(find.byType(TextField).last, 'Fui bem atendida.');
    await tester.ensureVisible(find.byIcon(Icons.star).at(3));
    await tester.tap(find.byIcon(Icons.star).at(3));
    await tester.pumpAndSettle();

    await _avancar(tester);
    expect(find.text('Avaliação do Profissional'), findsOneWidget);

    final salva = (await service.listarMinhas()).single;
    expect(salva.nota, 4);
    expect(salva.nomeProfissional, 'Dr. Matheus Castro');
    expect(salva.dataConsulta, DateTime(2026, 11, 3));
    expect(salva.horarioConsulta, const TimeOfDay(hour: 9, minute: 30));
    expect(salva.unidade, 'UBS Centro');
    expect(salva.comentario, 'Fui bem atendida.');
  });
}
