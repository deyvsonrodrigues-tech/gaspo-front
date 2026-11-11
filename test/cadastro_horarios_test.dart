import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gaspo_front/app/localizacao.dart';
import 'package:gaspo_front/app/rotas.dart';
import 'package:gaspo_front/app/tema.dart';
import 'package:gaspo_front/main.dart';
import 'package:gaspo_front/modelos/agenda.dart';
import 'package:gaspo_front/servicos/agenda_service.dart';
import 'package:gaspo_front/telas/admin/cadastro_horarios_tela.dart';
import 'package:gaspo_front/telas/autenticacao/splash_tela.dart';

void _usarTelaCelular(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> _abrirTela(WidgetTester tester, AgendaService service) async {
  _usarTelaCelular(tester);
  await tester.pumpWidget(MaterialApp(
    theme: criarTemaGaspo(),
    locale: localeGaspo,
    supportedLocales: const [localeGaspo],
    localizationsDelegates: delegatesGaspo,
    home: CadastroHorariosTela(service: service),
    onGenerateRoute: Rotas.gerarRota,
  ));
  await tester.pumpAndSettle();
}

Future<void> _selecionarProfissional(WidgetTester tester, String nome) async {
  await tester.tap(find.text('Profissional'));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining(nome).last);
  await tester.pumpAndSettle();
}

/// Abre o relógio e confirma o horário sugerido.
Future<void> _adicionarHorarioSugerido(WidgetTester tester) async {
  await tester.tap(find.text('Adicionar horário'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _gerarGrade(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Gerar grade'));
  await tester.tap(find.text('Gerar grade'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Funcionário entra no painel e abre o Cadastro de Horários', (tester) async {
    _usarTelaCelular(tester);
    await tester.pumpWidget(const GaspoApp());
    await tester.pump(SplashTela.duracao);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Funcionário'));
    await tester.pumpAndSettle();
    expect(find.text('Acesso do funcionário'), findsOneWidget);
    expect(find.text('Criar conta'), findsNothing);
    await tester.enterText(find.widgetWithText(TextFormField, 'CPF'), '52998224725');
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'segredo');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Painel do Funcionário'), findsOneWidget);

    await tester.tap(find.text('Cadastro de Horários'));
    await tester.pumpAndSettle();
    expect(find.text('Gere a grade de atendimento de um profissional.'), findsOneWidget);
  });

  testWidgets('Gera a grade e não duplica horários do mesmo dia', (tester) async {
    final service = AgendaServiceLocal();
    await _abrirTela(tester, service);
    expect(find.text('Nenhum horário cadastrado.'), findsOneWidget);

    await _gerarGrade(tester);
    expect(find.text('Selecione o profissional.'), findsOneWidget);

    await _selecionarProfissional(tester, 'Dr. Matheus Castro');
    await _gerarGrade(tester);
    expect(find.text('Adicione pelo menos um horário.'), findsOneWidget);

    // 08:00 e, em seguida, a sugestão de 30 min depois.
    await _adicionarHorarioSugerido(tester);
    await _adicionarHorarioSugerido(tester);
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('08:30'), findsOneWidget);

    await _gerarGrade(tester);
    expect(find.text('Grade horária gerada com sucesso!'), findsOneWidget);

    final cadastrados = await service.listar();
    expect(cadastrados.map((h) => h.horario), const [
      TimeOfDay(hour: 8, minute: 0),
      TimeOfDay(hour: 8, minute: 30),
    ]);
    expect(cadastrados.every((h) => h.disponibilidade == Disponibilidade.disponivel), isTrue);
    expect(cadastrados.every((h) => h.profissionalId == 6), isTrue);

    // Tentar gerar 08:00 de novo para o mesmo dia não cria outro horário.
    await _adicionarHorarioSugerido(tester);
    await _gerarGrade(tester);
    expect(find.text('Todos os horários escolhidos já estão cadastrados para esse dia.'), findsOneWidget);
    expect(await service.listar(), hasLength(2));
  });

  testWidgets('Altera a disponibilidade e remove um horário', (tester) async {
    final service = AgendaServiceLocal();
    await service.gerarGrade(
      profissionalId: 1,
      data: DateTime.now(),
      horarios: const [TimeOfDay(hour: 14, minute: 0)],
    );
    await _abrirTela(tester, service);
    expect(find.text('14:00'), findsOneWidget);
    expect(find.text('Dra. Olivia Silva'), findsOneWidget);

    await tester.tap(find.text('Disponível'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bloqueado').last);
    await tester.pumpAndSettle();
    expect((await service.listar()).single.disponibilidade, Disponibilidade.bloqueado);

    await tester.tap(find.byTooltip('Remover horário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum horário cadastrado.'), findsOneWidget);
    expect(await service.listar(), isEmpty);
  });

  test('HorarioAgenda converte de/para o formato da API', () {
    final horario = HorarioAgenda.fromJson({
      'id': 7,
      'data': '2026-11-10',
      'horario': '08:30:00',
      'disponibilidade': 'OCUPADO',
      'profissionalId': 3,
      'nomeProfissional': 'Dr. Bruno Almeida',
    });

    expect(horario.horario, const TimeOfDay(hour: 8, minute: 30));
    expect(horario.disponibilidade, Disponibilidade.ocupado);
    expect(horario.toRequestJson(), {
      'data': '2026-11-10',
      'horario': '08:30:00',
      'disponibilidade': 'OCUPADO',
      'profissionalId': 3,
    });
  });
}
