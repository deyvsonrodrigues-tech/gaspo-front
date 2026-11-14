import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gaspo_front/app/localizacao.dart';
import 'package:gaspo_front/app/rotas.dart';
import 'package:gaspo_front/app/tema.dart';
import 'package:gaspo_front/modelos/consulta.dart';
import 'package:gaspo_front/servicos/agenda_service.dart';
import 'package:gaspo_front/servicos/consulta_service.dart';
import 'package:gaspo_front/servicos/foto_usuario.dart';
import 'package:gaspo_front/servicos/notificacao_service.dart';
import 'package:gaspo_front/telas/ajuda/ajuda_tela.dart';
import 'package:gaspo_front/telas/especialistas/especialistas_tela.dart';
import 'package:gaspo_front/telas/inicio/home_tela.dart';
import 'package:gaspo_front/telas/notificacoes/notificacoes_tela.dart';
import 'package:gaspo_front/telas/perfil/perfil_tela.dart';
import 'package:gaspo_front/utils/texto.dart';

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

/// Serviço de notificações novo durante o teste.
NotificacaoServiceLocal _notificacoesNovas() {
  final original = NotificacaoService.instancia;
  final novo = NotificacaoServiceLocal();
  NotificacaoService.instancia = novo;
  addTearDown(() => NotificacaoService.instancia = original);
  return novo;
}

// PNG 1x1 válido, para simular uma foto.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

void main() {
  group('Busca de médicos', () {
    test('ignora acentos e maiúsculas', () {
      expect(normalizarBusca('  Flávia DÁVALLO '), 'flavia davallo');
      expect(normalizarBusca('Clínico Geral'), 'clinico geral');
    });

    testWidgets('busca por nome, especialidade e filtra por especialidade', (tester) async {
      await _abrir(tester, const EspecialistasTela());

      await tester.enterText(find.byType(TextField), 'flavia');
      await tester.pumpAndSettle();
      expect(find.text('Dra. Flávia Dávallo'), findsOneWidget);
      expect(find.text('Dra. Olivia Silva'), findsNothing);
      expect(find.text('1 encontrado'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'ortoped');
      await tester.pumpAndSettle();
      expect(find.text('Dr. Bruno Almeida'), findsOneWidget);
      expect(find.text('Dra. Flávia Dávallo'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();
      expect(find.text('Nenhum especialista encontrado.'), findsOneWidget);
      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(find.text('Dra. Olivia Silva'), findsOneWidget);

      await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Dentista'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Dentista'));
      await tester.pumpAndSettle();
      expect(find.text('Dr. Jonathan Figueredo'), findsOneWidget);
      expect(find.text('Dra. Olivia Silva'), findsNothing);
    });
  });

  group('Ajuda', () {
    testWidgets('abre pela Entrada e mostra perguntas e contatos', (tester) async {
      await _abrir(tester, Builder(builder: (context) {
        return Scaffold(
          body: TextButton(
            onPressed: () => Navigator.pushNamed(context, Rotas.ajuda),
            child: const Text('abrir'),
          ),
        );
      }));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.byType(AjudaTela), findsOneWidget);

      await tester.tap(find.text('Como agendo uma consulta?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Escolha o profissional, um dia com vagas'), findsOneWidget);

      final copiado = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copiado.add((call.arguments as Map)['text'] as String);
        return null;
      });
      await tester.ensureVisible(find.byTooltip('Copiar Telefone'));
      await tester.tap(find.byTooltip('Copiar Telefone'));
      await tester.pumpAndSettle();
      expect(copiado, ['(12) 3435-9821']);
      expect(find.text('Telefone copiado.'), findsOneWidget);
    });
  });

  group('Foto do usuário', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FotoUsuario.instancia = FotoUsuario();
    });

    testWidgets('aparece no Perfil e no Início e pode ser removida', (tester) async {
      await FotoUsuario.instancia.definir(_png);
      expect((await SharedPreferences.getInstance()).getString('foto_usuario'), isNotNull);

      await _abrir(tester, const PerfilTela());
      expect(find.byWidgetPredicate((w) => w is CircleAvatar && w.backgroundImage is MemoryImage), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Alterar foto do perfil'));
      await tester.pumpAndSettle();
      expect(find.text('Tirar foto'), findsOneWidget);
      expect(find.text('Escolher da galeria'), findsOneWidget);
      await tester.tap(find.text('Remover foto'));
      await tester.pumpAndSettle();

      expect(FotoUsuario.instancia.temFoto, isFalse);
      expect(find.text('Foto removida.'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is CircleAvatar && w.backgroundImage is MemoryImage), findsNothing);
    });

    test('é lida de novo ao abrir o app', () async {
      SharedPreferences.setMockInitialValues({'foto_usuario': base64Encode(_png)});
      final foto = FotoUsuario();
      await foto.carregar();
      expect(foto.bytes, _png);
    });
  });

  group('Notificações', () {
    testWidgets('consultas geram notificações; tocar marca como lida', (tester) async {
      final notificacoes = _notificacoesNovas();
      final amanha = DateUtils.addDaysToDate(DateUtils.dateOnly(DateTime.now()), 1);
      final agenda = AgendaServiceLocal();
      await agenda.gerarGrade(profissionalId: 6, data: amanha, horarios: const [TimeOfDay(hour: 9, minute: 0)]);
      final consultas = ConsultaServiceLocal(agenda);
      final consulta = await consultas.agendar(
        profissionalId: 6,
        dataHora: DateTime(amanha.year, amanha.month, amanha.day, 9),
      );
      await consultas.alterarStatus(consulta.id, StatusConsulta.confirmada);

      final lista = await notificacoes.listar();
      expect(lista.map((n) => n.titulo), containsAll(['Consulta agendada', 'Consulta confirmada']));
      expect(lista.first.mensagem, contains('Dr. Matheus Castro'));
      expect(await notificacoes.contarNaoLidas(), 2);

      await _abrir(tester, NotificacoesTela(service: notificacoes));
      expect(find.byKey(const ValueKey('nao-lida')), findsNWidgets(2));

      await tester.tap(find.text('Consulta agendada'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('nao-lida')), findsOneWidget);
      expect(await notificacoes.contarNaoLidas(), 1);

      await tester.tap(find.text('Marcar todas como lidas'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('nao-lida')), findsNothing);
      expect(find.text('Marcar todas como lidas'), findsNothing);
    });

    testWidgets('"Avalie seu atendimento" abre a avaliação', (tester) async {
      final notificacoes = _notificacoesNovas()
        ..notificar(titulo: 'Avalie seu atendimento', mensagem: 'Conte como foi.');
      await _abrir(tester, NotificacoesTela(service: notificacoes));
      await tester.tap(find.text('Avalie seu atendimento'));
      await tester.pumpAndSettle();
      expect(find.text('Avaliação da Consulta'), findsOneWidget);
    });

    testWidgets('sino do Início mostra as não lidas', (tester) async {
      _notificacoesNovas()
        ..notificar(titulo: 'Consulta agendada', mensagem: 'a')
        ..notificar(titulo: 'Consulta confirmada', mensagem: 'b')
        ..notificar(titulo: 'Consulta cancelada', mensagem: 'c', lida: true);
      await _abrir(tester, const HomeTela());
      expect(find.text('2'), findsOneWidget);
    });

    test('textos iguais aos da API', () {
      final texto = textoNotificacaoConsulta(StatusConsulta.cancelada, 'Dr. X', DateTime(2026, 11, 20, 9, 30));
      expect(texto!.titulo, 'Consulta cancelada');
      expect(texto.mensagem, 'Sua consulta com Dr. X em 20/11/2026 às 09:30 foi cancelada pela unidade. Agende um novo horário.');
    });
  });
}
