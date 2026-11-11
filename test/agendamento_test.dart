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
    late DateTime amanha;
    late AgendaServiceLocal agenda;
    late ConsultaServiceLocal consultas;

    setUp(() async {
      amanha = DateUtils.addDaysToDate(DateUtils.dateOnly(DateTime.now()), 1);
      agenda = AgendaServiceLocal();
      await agenda.gerarGrade(
        profissionalId: _matheus.id,
        data: amanha,
        horarios: const [TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 14, minute: 0)],
      );
      consultas = ConsultaServiceLocal(agenda);
    });

    testWidgets('abre no primeiro dia com vaga, agrupa por período e agenda', (tester) async {
      await _abrir(tester, AgendamentoTela(service: consultas, profissionalInicial: _matheus));

      expect(find.textContaining('próxima vaga'), findsOneWidget);
      expect(find.text('Manhã'), findsOneWidget);
      expect(find.text('Tarde'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('14:00'), findsOneWidget);
      expect(find.text('Confirmar'), findsNothing);

      await tester.ensureVisible(find.text('09:00'));
      await tester.tap(find.text('09:00'));
      await tester.pumpAndSettle();
      expect(find.textContaining('às 09:00'), findsOneWidget);

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      expect(find.text('Consulta agendada!'), findsOneWidget);

      final horarios = await agenda.listar();
      expect(horarios.first.disponibilidade, Disponibilidade.ocupado);
      expect(horarios.last.disponibilidade, Disponibilidade.disponivel);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeTela), findsOneWidget);
    });

    testWidgets('horário escolhido no perfil já chega selecionado', (tester) async {
      final tarde = (await agenda.listar()).last;
      await _abrir(
        tester,
        AgendamentoTela(service: consultas, profissionalInicial: _matheus, horarioInicial: tarde),
      );
      expect(find.textContaining('às 14:00'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);
    });

    testWidgets('trocar a especialidade tira o profissional que não combina', (tester) async {
      await _abrir(tester, AgendamentoTela(service: consultas, profissionalInicial: _matheus));
      expect(find.text('Dia'), findsOneWidget);

      await tester.ensureVisible(find.text('Dentista'));
      await tester.tap(find.text('Dentista'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Jonathan Figueredo'), findsOneWidget);
      expect(find.text('Dr. Matheus Castro'), findsNothing);
      expect(find.text('Dia'), findsNothing);
    });

    testWidgets('sem vagas na faixa, "Outra data" encontra o dia', (tester) async {
      final distante = DateUtils.addDaysToDate(DateUtils.dateOnly(DateTime.now()), 20);
      final vazia = AgendaServiceLocal();
      await vazia.gerarGrade(
        profissionalId: _matheus.id,
        data: distante,
        horarios: const [TimeOfDay(hour: 8, minute: 0)],
      );
      await _abrir(tester, AgendamentoTela(service: ConsultaServiceLocal(vazia), profissionalInicial: _matheus));
      expect(find.textContaining('Sem vagas nos próximos 14 dias'), findsOneWidget);

      await tester.ensureVisible(find.text('Outra data'));
      await tester.tap(find.text('Outra data'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, formatarData(distante));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('08:00'));
      expect(find.text('08:00'), findsOneWidget);
    });

    testWidgets('abre pelo menu inferior e pelo Perfil do Profissional', (tester) async {
      await _abrir(tester, const HomeTela());

      await tester.tap(find.text('Agendar'));
      await tester.pumpAndSettle();
      expect(find.text('Escolha o profissional, o dia e o horário.'), findsOneWidget);

      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Especialistas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dr. Bruno Almeida'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agendar consulta'));
      await tester.pumpAndSettle();

      expect(find.text('Escolha o profissional, o dia e o horário.'), findsOneWidget);
      // O profissional do perfil já vem escolhido (a seção Dia só aparece com ele).
      expect(find.text('Dia'), findsOneWidget);
    });
  });
}
