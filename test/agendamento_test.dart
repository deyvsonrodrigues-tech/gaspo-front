import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gaspo_front/app/localizacao.dart';
import 'package:gaspo_front/app/rotas.dart';
import 'package:gaspo_front/app/tema.dart';
import 'package:gaspo_front/dados/dados_exemplo.dart';
import 'package:gaspo_front/modelos/agenda.dart';
import 'package:gaspo_front/modelos/consulta.dart';
import 'package:gaspo_front/servicos/agenda_service.dart';
import 'package:gaspo_front/servicos/consulta_service.dart';
import 'package:gaspo_front/telas/agendamento/agendamento_tela.dart';
import 'package:gaspo_front/telas/inicio/home_tela.dart';
import 'package:gaspo_front/utils/formatadores.dart';

final _matheus = profissionais.firstWhere((p) => p.nome == 'Dr. Matheus Castro');

void _usarTelaCelular(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> _abrir(WidgetTester tester, Widget home) async {
  _usarTelaCelular(tester);
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

/// Escolhe a data digitando no modo de texto do calendário.
Future<void> _escolherData(WidgetTester tester, DateTime data) async {
  await tester.tap(find.text(formatarData(DateTime.now())));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.edit_outlined));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).last, formatarData(data));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  group('ConsultaServiceLocal (regras da API)', () {
    final agora = DateTime(2026, 11, 10, 12, 0);
    final amanha = DateTime(2026, 11, 11);
    late AgendaServiceLocal agenda;
    late ConsultaServiceLocal consultas;

    setUp(() async {
      agenda = AgendaServiceLocal();
      consultas = ConsultaServiceLocal(agenda, agora: () => agora);
      await agenda.gerarGrade(
        profissionalId: _matheus.id,
        data: amanha,
        horarios: const [TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 10, minute: 0)],
      );
    });

    test('agendar ocupa o horário e ele some dos disponíveis', () async {
      final consulta = await consultas.agendar(
        profissionalId: _matheus.id,
        dataHora: DateTime(2026, 11, 11, 9, 0),
      );
      expect(consulta.status, StatusConsulta.agendada);
      expect(consulta.nomeProfissional, 'Dr. Matheus Castro');

      final livres = await consultas.horariosDisponiveis(profissionalId: _matheus.id, data: amanha);
      expect(livres.map((h) => h.horario), const [TimeOfDay(hour: 10, minute: 0)]);
      expect(await consultas.listarAtivas(), hasLength(1));
    });

    test('recusa horário ocupado, fora da agenda ou no passado', () async {
      await consultas.agendar(profissionalId: _matheus.id, dataHora: DateTime(2026, 11, 11, 9, 0));

      expect(
        () => consultas.agendar(profissionalId: _matheus.id, dataHora: DateTime(2026, 11, 11, 9, 0)),
        throwsA(isA<AgendamentoException>()
            .having((e) => e.mensagem, 'mensagem', 'Horário indisponível para agendamento')),
      );
      expect(
        () => consultas.agendar(profissionalId: _matheus.id, dataHora: DateTime(2026, 11, 11, 11, 0)),
        throwsA(isA<AgendamentoException>()
            .having((e) => e.mensagem, 'mensagem', 'Horário não cadastrado na agenda do profissional')),
      );
      expect(
        () => consultas.agendar(profissionalId: _matheus.id, dataHora: DateTime(2026, 11, 9, 9, 0)),
        throwsA(isA<AgendamentoException>()
            .having((e) => e.mensagem, 'mensagem', 'A consulta deve ser agendada para uma data futura')),
      );
    });

    test('cancelar devolve o horário para a agenda e vai para o histórico', () async {
      final consulta = await consultas.agendar(
        profissionalId: _matheus.id,
        dataHora: DateTime(2026, 11, 11, 10, 0),
      );
      await consultas.cancelar(consulta.id);

      final livres = await consultas.horariosDisponiveis(profissionalId: _matheus.id, data: amanha);
      expect(livres, hasLength(2));
      expect(await consultas.listarAtivas(), isEmpty);
      expect((await consultas.listarHistorico()).single.status, StatusConsulta.cancelada);
      expect(
        () => consultas.cancelar(consulta.id),
        throwsA(isA<AgendamentoException>()),
      );
    });

    test('Consulta lê o ConsultaResponseDTO e monta o pedido de agendamento', () {
      final consulta = Consulta.fromJson({
        'id': 3,
        'data': '2026-11-11T12:00:00.000+00:00',
        'status': 'AGENDADA',
        'profissionalId': 6,
        'nomeProfissional': 'Dr. Matheus Castro',
        'especialidadeProfissional': 'Clínico Geral',
        'nomeUnidade': null,
        'enderecoUnidade': null,
      });
      expect(consulta.status, StatusConsulta.agendada);
      expect(consulta.dataHora.isUtc, isFalse);
      expect(consulta.dataHora.toUtc(), DateTime.utc(2026, 11, 11, 12));

      final pedido = Consulta.agendamentoJson(
        profissionalId: 6,
        dataHora: DateTime.utc(2026, 11, 11, 12),
      );
      expect(pedido, {'data': '2026-11-11T12:00:00.000Z', 'profissionalId': 6});
    });
  });

  group('Tela de agendamento', () {
    testWidgets('agenda uma consulta e volta ao Início', (tester) async {
      final amanha = DateUtils.addDaysToDate(DateUtils.dateOnly(DateTime.now()), 1);
      final agenda = AgendaServiceLocal();
      await agenda.gerarGrade(
        profissionalId: _matheus.id,
        data: amanha,
        horarios: const [TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 10, minute: 0)],
      );
      final consultas = ConsultaServiceLocal(agenda);

      await _abrir(tester, AgendamentoTela(service: consultas, profissionalInicial: _matheus));
      expect(find.text('Nenhum horário disponível nesta data. Tente outro dia.'), findsOneWidget);

      await _escolherData(tester, amanha);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);

      await tester.tap(find.text('09:00'));
      await tester.pumpAndSettle();
      expect(find.text('Resumo'), findsOneWidget);

      await tester.ensureVisible(find.text('Confirmar agendamento'));
      await tester.tap(find.text('Confirmar agendamento'));
      await tester.pumpAndSettle();
      expect(find.text('Consulta agendada!'), findsOneWidget);

      final horarios = await agenda.listar();
      expect(horarios.first.disponibilidade, Disponibilidade.ocupado);
      expect(horarios.last.disponibilidade, Disponibilidade.disponivel);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeTela), findsOneWidget);
    });

    testWidgets('trocar a especialidade limpa o profissional incompatível', (tester) async {
      await _abrir(
        tester,
        AgendamentoTela(
          service: ConsultaServiceLocal(AgendaServiceLocal()),
          profissionalInicial: _matheus,
        ),
      );

      await tester.tap(find.text('Todas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dentista').last);
      await tester.pumpAndSettle();

      expect(find.text('Escolha um profissional para ver os horários livres.'), findsOneWidget);
      await tester.tap(find.text('Profissional'));
      await tester.pumpAndSettle();
      expect(find.text('Dr. Jonathan Figueredo'), findsWidgets);
      expect(find.text('Dr. Matheus Castro'), findsNothing);
    });

    testWidgets('abre pelo menu inferior e pelos Detalhes do profissional', (tester) async {
      await _abrir(tester, const HomeTela());

      await tester.tap(find.text('Agendar'));
      await tester.pumpAndSettle();
      expect(find.text('Agendar Consulta'), findsOneWidget);

      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Especialistas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dr. Bruno Almeida'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agendar consulta'));
      await tester.pumpAndSettle();

      expect(find.text('Agendar Consulta'), findsOneWidget);
      expect(find.text('Dr. Bruno Almeida — Ortopedista'), findsOneWidget);
    });
  });
}
