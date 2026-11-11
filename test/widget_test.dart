import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gaspo_front/app/rotas.dart';
import 'package:gaspo_front/app/tema.dart';
import 'package:gaspo_front/main.dart';
import 'package:gaspo_front/telas/autenticacao/splash_tela.dart';
import 'package:gaspo_front/telas/inicio/home_tela.dart';

const _textoLogin = 'Informe seu CPF e sua senha para acessar o aplicativo.';
final _botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');

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

    testWidgets('Entrada → Login (com validação) → Início', (tester) async {
      _usarTelaCelular(tester);
      await tester.pumpWidget(const GaspoApp());
      await tester.pump(SplashTela.duracao);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Usuário'));
      await tester.pumpAndSettle();
      expect(find.text('Acesso do paciente'), findsOneWidget);
      expect(find.text(_textoLogin), findsOneWidget);

      // Vazio.
      await tester.tap(_botaoEntrar);
      await tester.pumpAndSettle();
      expect(find.text('Informe seu CPF.'), findsOneWidget);
      expect(find.text('Informe sua senha.'), findsOneWidget);

      // CPF com dígitos verificadores errados.
      await tester.enterText(find.widgetWithText(TextFormField, 'CPF'), '12345678900');
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'segredo');
      await tester.tap(_botaoEntrar);
      await tester.pumpAndSettle();
      expect(find.text('CPF inválido. Confira os números.'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'CPF'), '52998224725');
      expect(find.text('529.982.247-25'), findsOneWidget);
      await tester.tap(_botaoEntrar);
      await tester.pumpAndSettle();
      expect(find.byType(HomeTela), findsOneWidget);
      expect(find.text('Categorias'), findsOneWidget);
    });

    testWidgets('Cadastro valida os campos e leva ao Login', (tester) async {
      _usarTelaCelular(tester);
      await tester.pumpWidget(const GaspoApp());
      await tester.pump(SplashTela.duracao);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cadastrar-se'));
      await tester.pumpAndSettle();
      expect(find.text('Seus dados'), findsOneWidget);

      final criarConta = find.widgetWithText(ElevatedButton, 'Criar conta');
      await tester.ensureVisible(criarConta);
      await tester.tap(criarConta);
      await tester.pumpAndSettle();
      expect(find.text('Informe seu nome.'), findsOneWidget);
      expect(find.text('Informe seu e-mail.'), findsOneWidget);
      expect(find.text('Crie uma senha.'), findsOneWidget);

      Finder campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);
      await tester.enterText(campo('Nome completo'), 'Maria das Dores');
      await tester.enterText(campo('Data de nascimento'), '31022000');
      await tester.enterText(campo('CPF'), '52998224725');
      await tester.enterText(campo('E-mail'), 'maria@email.com');
      await tester.enterText(campo('Senha'), 'abc123');
      await tester.enterText(campo('Confirmar senha'), 'abc124');
      await tester.ensureVisible(criarConta);
      await tester.tap(criarConta);
      await tester.pumpAndSettle();
      expect(find.text('Data inválida. Use dd/mm/aaaa.'), findsOneWidget);
      expect(find.text('As senhas não coincidem.'), findsOneWidget);

      await tester.enterText(campo('Data de nascimento'), '15031958');
      await tester.enterText(campo('Confirmar senha'), 'abc123');
      await tester.ensureVisible(criarConta);
      await tester.tap(criarConta);
      await tester.pump();
      expect(find.text('Cadastro em desenvolvimento!'), findsOneWidget);

      final entrar = find.widgetWithText(TextButton, 'Entrar');
      await tester.ensureVisible(entrar);
      await tester.tap(entrar);
      await tester.pumpAndSettle();
      expect(find.text(_textoLogin), findsOneWidget);
    });
  });

  group('Módulos a partir do Início', () {
    testWidgets('Especialistas → Perfil do profissional', (tester) async {
      await _abrirNoInicio(tester);

      await tester.tap(find.text('Especialistas'));
      await tester.pumpAndSettle();
      expect(find.text('Dra. Olivia Silva'), findsOneWidget);

      await tester.tap(find.text('Dr. Bruno Almeida'));
      await tester.pumpAndSettle();
      expect(find.text('AUSENTE'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left));
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
      await tester.enterText(find.widgetWithText(TextFormField, 'Data'), '10112026');

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

    testWidgets('Início em tela larga mostra os 4 cartões em uma linha', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: criarTemaGaspo(),
        home: const HomeTela(),
        onGenerateRoute: Rotas.gerarRota,
      ));

      final alturas = ['Especialistas', 'Comunicados', 'Avaliação', 'Localização']
          .map((titulo) => tester.getCenter(find.text(titulo)).dy)
          .toSet();
      expect(alturas, hasLength(1));
    });

    testWidgets('Perfil: sair da conta volta para o Login', (tester) async {
      await _abrirNoInicio(tester);
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Sair da conta'),
        200,
        scrollable: find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)),
      );
      await tester.tap(find.text('Sair da conta'));
      await tester.pumpAndSettle();
      expect(find.text('Sair da conta?'), findsOneWidget);

      // Cancelar mantém o usuário no Perfil.
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Sair da conta?'), findsNothing);
      expect(find.text('Sair da conta'), findsOneWidget);

      await tester.tap(find.text('Sair da conta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();
      expect(find.text(_textoLogin), findsOneWidget);

      // A seta do Login leva à Entrada; não há como voltar ao Perfil.
      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left));
      await tester.pumpAndSettle();
      expect(find.text('Entrar como:'), findsOneWidget);
      expect(find.text('Sobre Mim'), findsNothing);
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
