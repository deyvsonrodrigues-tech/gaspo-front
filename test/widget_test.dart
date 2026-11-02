import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gaspo_front/app/rotas.dart';
import 'package:gaspo_front/app/tema.dart';
import 'package:gaspo_front/main.dart';
import 'package:gaspo_front/telas/autenticacao/splash_tela.dart';
import 'package:gaspo_front/telas/inicio/home_tela.dart';

/// Tamanho de tela de celular para os testes.
void _usarTelaCelular(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Abre o app direto no Início (pula splash e login).
Future<void> _abrirNoInicio(WidgetTester tester) async {
  _usarTelaCelular(tester);
  await tester.pumpWidget(MaterialApp(
    theme: criarTemaGaspo(),
    home: const HomeTela(),
    onGenerateRoute: Rotas.gerarRota,
  ));
}

void main() {
  group('Fluxo de acesso', () {
    testWidgets('Splash segue para a tela de Entrada', (tester) async {
      _usarTelaCelular(tester);
      await tester.pumpWidget(const GaspoApp());
      expect(find.byType(SplashTela), findsOneWidget);

      await tester.pump(SplashTela.duracao);
      await tester.pumpAndSettle();
      expect(find.text('Entrar como:'), findsOneWidget);
    });

    testWidgets('Entrada → Login → Início', (tester) async {
      _usarTelaCelular(tester);
      await tester.pumpWidget(const GaspoApp());
      await tester.pump(SplashTela.duracao);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Usuário'));
      await tester.pumpAndSettle();
      expect(find.text('Conecte-se para acessar o aplicativo:'), findsOneWidget);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeTela), findsOneWidget);
      expect(find.text('Categorias'), findsOneWidget);
    });

    testWidgets('Cadastro valida campos e leva ao Login', (tester) async {
      _usarTelaCelular(tester);
      await tester.pumpWidget(const GaspoApp());
      await tester.pump(SplashTela.duracao);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cadastrar-se'));
      await tester.pumpAndSettle();
      expect(find.text('Preencha os dados abaixo para começar:'), findsOneWidget);

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();
      expect(find.text('Preencha todos os campos!'), findsOneWidget);

      await tester.tap(find.textContaining('Fazer login', findRichText: true));
      await tester.pumpAndSettle();
      expect(find.text('Conecte-se para acessar o aplicativo:'), findsOneWidget);
    });
  });

  group('Módulos a partir do Início', () {
    testWidgets('Especialistas → Detalhes do profissional', (tester) async {
      await _abrirNoInicio(tester);

      await tester.tap(find.text('Especialistas'));
      await tester.pumpAndSettle();
      expect(find.text('Dra. Olivia Silva'), findsOneWidget);

      await tester.tap(find.text('Dr. Bruno Almeida'));
      await tester.pumpAndSettle();
      expect(find.text('AUSENTE'), findsOneWidget);

      await tester.tap(find.text('Voltar para a Lista'));
      await tester.pumpAndSettle();
      expect(find.text('Dra. Olivia Silva'), findsOneWidget);
    });

    testWidgets('Avaliação: médico escolhido chega pré-selecionado', (tester) async {
      await _abrirNoInicio(tester);

      await tester.tap(find.text('Avaliação'));
      await tester.pumpAndSettle();
      expect(find.text('Avaliação da Consulta'), findsOneWidget);

      await tester.tap(find.text('Profissional'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dr. Matheus Castro').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Avançar para Profissional'));
      await tester.tap(find.text('Avançar para Profissional'));
      await tester.pumpAndSettle();
      expect(find.text('Avaliação do Profissional'), findsOneWidget);
      expect(find.text('Dr. Matheus Castro'), findsOneWidget);

      await tester.ensureVisible(find.text('Enviar Avaliação Final'));
      await tester.tap(find.text('Enviar Avaliação Final'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeTela), findsOneWidget);
    });

    testWidgets('Localização da unidade', (tester) async {
      await _abrirNoInicio(tester);

      await tester.tap(find.text('Localização'));
      await tester.pumpAndSettle();
      expect(find.text('Dados da Unidade de Saúde'), findsOneWidget);
    });

    testWidgets('Notificações pelo cabeçalho do Início', (tester) async {
      await _abrirNoInicio(tester);

      await tester.tap(find.byIcon(Icons.notifications_none));
      await tester.pumpAndSettle();
      expect(find.text('Lembrete de consulta'), findsOneWidget);
    });

    testWidgets('Menu inferior: Perfil e volta ao Início', (tester) async {
      await _abrirNoInicio(tester);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      expect(find.text('Sobre Mim'), findsOneWidget);

      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      expect(find.text('Categorias'), findsOneWidget);
    });
  });
}
