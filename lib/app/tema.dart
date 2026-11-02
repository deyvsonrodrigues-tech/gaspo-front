import 'package:flutter/material.dart';

/// Paleta única do GASPO.
///
/// Os módulos foram desenvolvidos separadamente e cada um definia seus
/// próprios tons. Tons praticamente idênticos foram unificados aqui
/// (ex.: o azul primário era 0xFF002BFF, 0xFF0835FF e 0xFF0D3BFF).
class GaspoCores {
  GaspoCores._();

  /// Azul primário: botões, ícones e destaques.
  static const Color azul = Color(0xFF002BFF);

  /// Azul escuro dos textos das telas de acesso (entrada, login, cadastro).
  static const Color azulEscuro = Color(0xFF00195B);

  /// Azul dos títulos das telas internas.
  static const Color azulTitulo = Color(0xFF1A3B7A);

  /// Fundo dos cabeçalhos com dados do usuário (início, notificações, perfil).
  static const Color azulCabecalho = Color(0xFF395591);

  /// Azul claro dos ícones de notificação.
  static const Color azulClaro = Color(0xFF2879C9);

  /// Azul do indicador de carregamento da splash.
  static const Color azulLogo = Color(0xFF174B9B);

  /// Fundo padrão das telas.
  static const Color fundo = Color(0xFFF8F7FC);

  /// Botão secundário (Cancelar / Voltar).
  static const Color botaoSecundarioFundo = Color(0xFFDCE2F0);
  static const Color botaoSecundarioTexto = Color(0xFF0055D4);

  /// Caixa de comentário das avaliações.
  static const Color fundoComentario = Color(0xFFE6E6E6);

  /// Estrelas das avaliações.
  static const Color estrelaAtiva = Color(0xFFFFB321);
  static const Color estrelaInativa = Color(0xFFD2D2D2);
}

ThemeData criarTemaGaspo() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    primaryColor: GaspoCores.azul,
    scaffoldBackgroundColor: GaspoCores.fundo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: GaspoCores.azul,
      primary: GaspoCores.azul,
      surface: GaspoCores.fundo,
    ),
  );
}
