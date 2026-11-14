import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gaspo_front/app/localizacao.dart';
import 'package:gaspo_front/app/rotas.dart';
import 'package:gaspo_front/app/tema.dart';
import 'package:gaspo_front/servicos/notificacao_service.dart';
import 'package:gaspo_front/servicos/preferencias.dart';
import 'package:gaspo_front/telas/notificacoes/notificacoes_tela.dart';
import 'package:gaspo_front/telas/perfil/perfil_tela.dart';

/// Preferências novas a cada teste, com armazenamento simulado.
void _preferenciasNovas([Map<String, Object> salvas = const {}]) {
  SharedPreferences.setMockInitialValues(salvas);
  final original = Preferencias.instancia;
  Preferencias.instancia = Preferencias();
  addTearDown(() => Preferencias.instancia = original);
}

/// App com tema claro/escuro ligado às preferências, como em main.dart.
Future<void> _abrir(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ListenableBuilder(
    listenable: Preferencias.instancia,
    builder: (context, _) => MaterialApp(
      theme: criarTemaGaspo(),
      darkTheme: criarTemaGaspoEscuro(),
      themeMode: Preferencias.instancia.modoEscuro ? ThemeMode.dark : ThemeMode.light,
      locale: localeGaspo,
      supportedLocales: const [localeGaspo],
      localizationsDelegates: delegatesGaspo,
      home: home,
      onGenerateRoute: Rotas.gerarRota,
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _tocarInterruptor(WidgetTester tester, String titulo) async {
  final interruptor = find.descendant(
    of: find.ancestor(of: find.text(titulo), matching: find.byType(ListTile)),
    matching: find.byType(Switch),
  );
  await tester.ensureVisible(interruptor);
  await tester.tap(interruptor);
  await tester.pumpAndSettle();
}

Brightness _brilho(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

void main() {
  test('carrega e salva as preferências no aparelho', () async {
    SharedPreferences.setMockInitialValues({'modo_escuro': true});
    final preferencias = Preferencias();
    await preferencias.carregar();
    expect(preferencias.modoEscuro, isTrue);
    expect(preferencias.modoSilencioso, isFalse);

    await preferencias.definirModoSilencioso(true);
    final salvas = await SharedPreferences.getInstance();
    expect(salvas.getBool('modo_silencioso'), isTrue);
  });

  testWidgets('Modo Escuro no Perfil troca o tema do app', (tester) async {
    _preferenciasNovas();
    await _abrir(tester, const PerfilTela());
    expect(_brilho(tester), Brightness.light);
    expect(find.text('Tema claro'), findsOneWidget);

    await _tocarInterruptor(tester, 'Modo Escuro');
    expect(Preferencias.instancia.modoEscuro, isTrue);
    expect(_brilho(tester), Brightness.dark);
    expect(find.text('Tema escuro'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getBool('modo_escuro'), isTrue);

    await _tocarInterruptor(tester, 'Modo Escuro');
    expect(_brilho(tester), Brightness.light);
  });

  testWidgets('Modo Silencioso esconde o contador e os destaques', (tester) async {
    _preferenciasNovas();
    final notificacoes = NotificacaoServiceLocal()
      ..notificar(titulo: 'Consulta agendada', mensagem: 'Sua consulta foi agendada.')
      ..notificar(titulo: 'Avalie seu atendimento', mensagem: 'Conte como foi.')
      ..notificar(titulo: 'Consulta confirmada', mensagem: 'Confirmada.', lida: true);
    await _abrir(tester, NotificacoesTela(service: notificacoes));
    expect(find.text('2'), findsOneWidget); // contador do sino
    expect(find.byKey(const ValueKey('nao-lida')), findsNWidgets(2));

    await Preferencias.instancia.definirModoSilencioso(true);
    await tester.pumpAndSettle();
    expect(find.text('2'), findsNothing);
    expect(find.byKey(const ValueKey('nao-lida')), findsNothing);
    expect(find.text('Modo silencioso ligado: alertas ocultos.'), findsOneWidget);
    // As notificações continuam na lista.
    expect(find.text('Avalie seu atendimento'), findsOneWidget);

    await tester.tap(find.text('Desligar'));
    await tester.pumpAndSettle();
    expect(Preferencias.instancia.modoSilencioso, isFalse);
    expect(find.byKey(const ValueKey('nao-lida')), findsNWidgets(2));
  });

  testWidgets('o interruptor do Perfil liga o Modo Silencioso', (tester) async {
    _preferenciasNovas();
    await _abrir(tester, const PerfilTela());
    await _tocarInterruptor(tester, 'Modo Silencioso');
    expect(Preferencias.instancia.modoSilencioso, isTrue);
    expect(find.text('Alertas de notificações ocultos'), findsOneWidget);
  });
}
