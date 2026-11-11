import 'package:flutter/material.dart';

import '../modelos/perfil_acesso.dart';
import '../modelos/profissional.dart';
import '../telas/admin/cadastro_horarios_tela.dart';
import '../telas/agendamento/agendamento_tela.dart';
import '../telas/autenticacao/cadastro_tela.dart';
import '../telas/autenticacao/entrada_tela.dart';
import '../telas/autenticacao/login_tela.dart';
import '../telas/autenticacao/splash_tela.dart';
import '../telas/avaliacao/avaliacao_consulta_tela.dart';
import '../telas/avaliacao/avaliacao_profissional_tela.dart';
import '../telas/especialistas/perfil_profissional_tela.dart';
import '../telas/especialistas/especialistas_tela.dart';
import '../telas/inicio/home_tela.dart';
import '../telas/notificacoes/notificacoes_tela.dart';
import '../telas/perfil/perfil_tela.dart';
import '../telas/unidade/localizacao_tela.dart';

/// Rotas nomeadas de todo o aplicativo.
///
/// Fluxo: Splash → Entrada → Login/Cadastro → Início → módulos.
/// Funcionário: Entrada → Login → Cadastro de Horários.
class Rotas {
  Rotas._();

  static const String splash = '/';
  static const String entrada = '/entrada';

  /// Argumento opcional: [PerfilAcesso] (padrão: usuário).
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/home';
  static const String especialistas = '/especialistas';

  /// Argumento obrigatório: [Profissional].
  static const String perfilProfissional = '/perfil-profissional';
  static const String avaliacaoConsulta = '/avaliacao-consulta';

  /// Argumento opcional: nome do médico ([String]) ou [AvaliacaoProfissionalArgumentos].
  static const String avaliacaoProfissional = '/avaliacao-profissional';
  static const String localizacao = '/localizacao';
  static const String notificacoes = '/notificacoes';
  static const String perfil = '/perfil';

  /// Argumento opcional: [AgendamentoArgumentos].
  static const String agendamento = '/agendamento';

  // Painel Admin (funcionário)
  static const String cadastroHorarios = '/cadastro-horarios';

  static Route<dynamic> gerarRota(RouteSettings settings) {
    final Widget tela = switch (settings.name) {
      splash => const SplashTela(),
      entrada => const EntradaTela(),
      login => LoginTela(
          perfil: settings.arguments as PerfilAcesso? ?? PerfilAcesso.usuario,
        ),
      cadastro => const CadastroTela(),
      home => const HomeTela(),
      especialistas => const EspecialistasTela(),
      perfilProfissional => PerfilProfissionalTela(
          profissional: settings.arguments as Profissional,
        ),
      avaliacaoConsulta => const AvaliacaoConsultaTela(),
      avaliacaoProfissional => switch (settings.arguments) {
          AvaliacaoProfissionalArgumentos args => AvaliacaoProfissionalTela(
              medicoPreSelecionado: args.medico,
              voltarAoEnviar: args.voltarAoEnviar,
            ),
          final args => AvaliacaoProfissionalTela(medicoPreSelecionado: args as String?),
        },
      localizacao => const LocalizacaoTela(),
      notificacoes => const NotificacoesTela(),
      perfil => const PerfilTela(),
      agendamento => AgendamentoTela(
          profissionalInicial: (settings.arguments as AgendamentoArgumentos?)?.profissional,
          horarioInicial: (settings.arguments as AgendamentoArgumentos?)?.horario,
        ),
      cadastroHorarios => const CadastroHorariosTela(),
      _ => const SplashTela(),
    };

    return MaterialPageRoute(builder: (_) => tela, settings: settings);
  }
}
