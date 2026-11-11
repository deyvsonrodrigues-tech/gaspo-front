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
import 'package:gaspo_front/telas/admin/consultas_marcadas_tela.dart';
import 'package:gaspo_front/telas/historico/historico_consultas_tela.dart';

final _matheus = profissionais.firstWhere((p) => p.nome == 'Dr. Matheus Castro');

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

/// Serviço com uma consulta agendada amanhã (Dr. Matheus) e os exemplos
/// encerrados (uma cancelada e duas realizadas).
Future<ConsultaServiceLocal> _servicoComConsultas() async {
  final agenda = AgendaServiceLocal();
  final service = ConsultaServiceLocal.comExemplos(agenda);
  final amanha = DateUtils.addDaysToDate(DateUtils.dateOnly(DateTime.now()), 1);
  await agenda.gerarGrade(
    profissionalId: _matheus.id,
    data: amanha,
    horarios: const [TimeOfDay(hour: 9, minute: 0)],
  );
  await service.agendar(
    profissionalId: _matheus.id,
    dataHora: DateTime(amanha.year, amanha.month, amanha.day, 9),
  );
  return service;
}

void main() {
  group('ConsultaServiceLocal.alterarStatus', () {
    test('confirma, finaliza e não volta atrás', () async {
      final service = await _servicoComConsultas();
      final agendada = (await service.listarAtivas()).single;

      final confirmada = await service.alterarStatus(agendada.id, StatusConsulta.confirmada);
      expect(confirmada.status, StatusConsulta.confirmada);

      await service.alterarStatus(agendada.id, StatusConsulta.finalizada);
      expect(
        () => service.alterarStatus(agendada.id, StatusConsulta.cancelada),
        throwsA(isA<AgendamentoException>()),
      );
    });

    test('cancelar pelo painel devolve o horário para a agenda', () async {
      final agenda = AgendaServiceLocal();
      final service = ConsultaServiceLocal(agenda);
      final amanha = DateUtils.addDaysToDate(DateUtils.dateOnly(DateTime.now()), 1);
      await agenda.gerarGrade(
        profissionalId: _matheus.id,
        data: amanha,
        horarios: const [TimeOfDay(hour: 9, minute: 0)],
      );
      final consulta = await service.agendar(
        profissionalId: _matheus.id,
        dataHora: DateTime(amanha.year, amanha.month, amanha.day, 9),
      );

      await service.alterarStatus(consulta.id, StatusConsulta.cancelada);
      expect((await agenda.listar()).single.disponibilidade, Disponibilidade.disponivel);
    });
  });

  testWidgets('Histórico lista as consultas e filtra por status', (tester) async {
    await _abrir(tester, HistoricoConsultasTela(service: await _servicoComConsultas()));

    expect(find.text('Histórico de Consultas'), findsOneWidget);
    expect(find.text('Dr. Matheus Castro'), findsOneWidget);
    expect(find.text('AGENDADA'), findsOneWidget);
    expect(find.text('REALIZADA'), findsNWidgets(2));
    expect(find.text('CANCELADA'), findsOneWidget);

    await tester.tap(find.text('Canceladas'));
    await tester.pumpAndSettle();
    expect(find.text('CANCELADA'), findsOneWidget);
    expect(find.text('AGENDADA'), findsNothing);
    expect(find.text('REALIZADA'), findsNothing);
  });

  testWidgets('Histórico permite cancelar uma consulta agendada', (tester) async {
    await _abrir(tester, HistoricoConsultasTela(service: await _servicoComConsultas()));

    await tester.tap(find.text('Dr. Matheus Castro'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar consulta'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancelar consulta'));
    await tester.pumpAndSettle();

    expect(find.text('AGENDADA'), findsNothing);
    expect(find.text('CANCELADA'), findsNWidgets(2));
  });

  testWidgets('Consultas Marcadas busca e confirma uma consulta', (tester) async {
    await _abrir(tester, ConsultasMarcadasTela(service: await _servicoComConsultas()));

    await tester.enterText(find.byType(TextField), 'matheus');
    await tester.pumpAndSettle();
    expect(find.text('Dr. Matheus Castro'), findsOneWidget);
    expect(find.text('REALIZADA'), findsNothing);

    await tester.tap(find.text('Dr. Matheus Castro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(find.text('CONFIRMADA'), findsOneWidget);
  });
}
