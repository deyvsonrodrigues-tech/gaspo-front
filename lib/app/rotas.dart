import 'package:flutter/material.dart';

import '../modelos/profissional.dart';
import '../telas/autenticacao/cadastro_tela.dart';
import '../telas/autenticacao/entrada_tela.dart';
import '../telas/autenticacao/login_tela.dart';
import '../telas/autenticacao/splash_tela.dart';
import '../telas/avaliacao/avaliacao_consulta_tela.dart';
import '../telas/avaliacao/avaliacao_profissional_tela.dart';
import '../telas/especialistas/detalhes_profissional_tela.dart';
import '../telas/especialistas/especialistas_tela.dart';
import '../telas/inicio/home_tela.dart';
import '../telas/notificacoes/notificacoes_tela.dart';
import '../telas/perfil/perfil_tela.dart';
import '../telas/unidade/localizacao_tela.dart';

/// Rotas nomeadas de todo o aplicativo.
///
/// Fluxo: Splash → Entrada → Login/Cadastro → Início → módulos.
class Rotas {
  Rotas._();

  static const String splash = '/';
  static const String entrada = '/entrada';
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/home';
  static const String especialistas = '/especialistas';

  /// Argumento obrigatório: [Profissional].
  static const String detalhesProfissional = '/detalhes-profissional';
  static const String avaliacaoConsulta = '/avaliacao-consulta';

  /// Argumento opcional: nome do médico pré-selecionado ([String]).
  static const String avaliacaoProfissional = '/avaliacao-profissional';
  static const String localizacao = '/localizacao';
  static const String notificacoes = '/notificacoes';
  static const String perfil = '/perfil';

  static Route<dynamic> gerarRota(RouteSettings settings) {
    final Widget tela = switch (settings.name) {
      splash => const SplashTela(),
      entrada => const EntradaTela(),
      login => const LoginTela(),
      cadastro => const CadastroTela(),
      home => const HomeTela(),
      especialistas => const EspecialistasTela(),
      detalhesProfissional => DetalhesProfissionalTela(
          profissional: settings.arguments as Profissional,
        ),
      avaliacaoConsulta => const AvaliacaoConsultaTela(),
      avaliacaoProfissional => AvaliacaoProfissionalTela(
          medicoPreSelecionado: settings.arguments as String?,
        ),
      localizacao => const LocalizacaoTela(),
      notificacoes => const NotificacoesTela(),
      perfil => const PerfilTela(),
      _ => const SplashTela(),
    };

    return MaterialPageRoute(builder: (_) => tela, settings: settings);
  }
}
