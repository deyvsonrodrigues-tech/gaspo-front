import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gaspo_front/app/localizacao.dart';
import 'package:gaspo_front/app/rotas.dart';
import 'package:gaspo_front/app/tema.dart';
import 'package:gaspo_front/dados/dados_exemplo.dart';
import 'package:gaspo_front/modelos/avaliacao.dart';
import 'package:gaspo_front/servicos/agenda_service.dart';
import 'package:gaspo_front/servicos/avaliacao_service.dart';
import 'package:gaspo_front/servicos/consulta_service.dart';
import 'package:gaspo_front/telas/especialistas/perfil_profissional_tela.dart';

final _matheus = profissionais.firstWhere((p) => p.nome == 'Dr. Matheus Castro');

Future<void> _abrirPerfil(
  WidgetTester tester, {
  required ConsultaService consultas,
  required AvaliacaoService avaliacoes,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  // As telas abertas a partir do perfil usam as instâncias globais.
  final consultaOriginal = ConsultaService.instancia;
  final avaliacaoOriginal = AvaliacaoService.instancia;
  ConsultaService.instancia = consultas;
  AvaliacaoService.instancia = avaliacoes;
  addTearDown(() {
    ConsultaService.instancia = consultaOriginal;
    AvaliacaoService.instancia = avaliacaoOriginal;
  });

  await tester.pumpWidget(MaterialApp(
    theme: criarTemaGaspo(),
    locale: localeGaspo,
    supportedLocales: const [localeGaspo],
    localizationsDelegates: delegatesGaspo,
    home: PerfilProfissionalTela(profissional: _matheus),
    onGenerateRoute: Rotas.gerarRota,
  ));
  await tester.pumpAndSettle();
}

Future<void> _rolarAte(WidgetTester tester, Finder alvo) async {
  await tester.scrollUntilVisible(alvo, 200, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
}

void main() {
  late AgendaServiceLocal agenda;
  late ConsultaServiceLocal consultas;
  late AvaliacaoServiceLocal avaliacoes;
  late DateTime amanha;

  setUp(() async {
    amanha = DateUtils.addDaysToDate(DateUtils.dateOnly(DateTime.now()), 1);
    agenda = AgendaServiceLocal();
    await agenda.gerarGrade(
      profissionalId: _matheus.id,
      data: amanha,
      horarios: const [TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 10, minute: 0)],
    );
    consultas = ConsultaServiceLocal(agenda);
    avaliacoes = AvaliacaoServiceLocal();
  });

  testWidgets('mostra dados, local de atendimento e próximos horários', (tester) async {
    await _abrirPerfil(tester, consultas: consultas, avaliacoes: avaliacoes);

    expect(find.text('Dr. Matheus Castro'), findsOneWidget);
    expect(find.text('Clínico Geral'), findsOneWidget);
    expect(find.text('PRESENTE'), findsOneWidget);
    expect(find.text('4.9 (37 Reviews)'), findsOneWidget);

    await _rolarAte(tester, find.text('Avaliações'));
    expect(find.text('Unidade de Saúde'), findsOneWidget);
    expect(find.textContaining('Av. das Palmeiras, 458'), findsOneWidget);
    expect(find.textContaining('09:00'), findsOneWidget);
    expect(find.textContaining('10:00'), findsOneWidget);
    expect(find.text('Ainda não há avaliações deste profissional.'), findsOneWidget);
  });

  testWidgets('tocar num horário abre o agendamento com ele escolhido', (tester) async {
    await _abrirPerfil(tester, consultas: consultas, avaliacoes: avaliacoes);

    await _rolarAte(tester, find.textContaining('10:00'));
    await tester.tap(find.textContaining('10:00'));
    await tester.pumpAndSettle();

    expect(find.text('Agendar Consulta'), findsOneWidget);
    expect(find.text('Resumo'), findsOneWidget);
    expect(find.text('Dr. Matheus Castro — Clínico Geral'), findsWidgets);
  });

  testWidgets('avaliar volta ao perfil e mostra a nova avaliação', (tester) async {
    await _abrirPerfil(tester, consultas: consultas, avaliacoes: avaliacoes);

    await tester.tap(find.text('Avaliar profissional'));
    await tester.pumpAndSettle();
    expect(find.text('Avaliação do Profissional'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Muito atencioso.');
    await tester.tap(find.byIcon(Icons.star).at(4));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enviar Avaliação Final'));
    await tester.tap(find.text('Enviar Avaliação Final'));
    await tester.pumpAndSettle();

    // Voltou ao perfil, não ao Início.
    expect(find.text('Avaliar profissional'), findsOneWidget);
    expect(find.text('5.0 (1 avaliação)'), findsOneWidget);
    await _rolarAte(tester, find.text('Muito atencioso.'));
    expect(find.text(usuarioLogado.nome), findsOneWidget);
  });

  test('média das notas', () {
    Avaliacao a(int nota) => Avaliacao(id: nota, nota: nota, profissionalId: 1, dataAvaliacao: DateTime(2026));
    expect(mediaDasNotas([]), isNull);
    expect(mediaDasNotas([a(5), a(4), a(3)]), 4.0);
  });
}
