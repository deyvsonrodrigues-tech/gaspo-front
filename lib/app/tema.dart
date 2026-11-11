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

  /// Status das consultas (Histórico e Consultas Marcadas).
  static const Color statusAgendada = Color(0xFFF2A62C);
  static const Color statusRealizada = Color(0xFF1FA84A);
  static const Color statusCancelada = Color(0xFFE53935);
}

/// Cores que mudam entre o tema claro e o escuro.
///
/// No claro, os valores são os mesmos que as telas usavam fixos (branco,
/// black87, black54, ...), então o visual claro não muda.
/// Nas telas: `final cores = context.cores;`.
@immutable
class CoresGaspo extends ThemeExtension<CoresGaspo> {
  /// Fundo das telas.
  final Color fundo;

  /// Cartões, campos, listas e barras (era `Colors.white`).
  final Color superficie;

  /// Caixas de comentário e áreas de apoio.
  final Color superficieAlternativa;

  /// Texto principal (era `Colors.black87`).
  final Color texto;

  /// Texto de apoio (era `Colors.black54`).
  final Color textoSecundario;

  /// Datas, dicas e placeholders (era `Colors.black45` / `black26`).
  final Color textoFraco;

  /// Bordas e divisórias (era `Colors.black12`).
  final Color borda;

  /// Títulos das telas internas (era `GaspoCores.azulTitulo`).
  final Color titulo;

  /// Títulos das telas de acesso (era `GaspoCores.azulEscuro`).
  final Color tituloForte;

  /// Ícones e textos em azul sobre o fundo (era `GaspoCores.azul`).
  /// Botões continuam com fundo `GaspoCores.azul`.
  final Color destaque;

  /// Cabeçalhos azuis com os dados do usuário.
  final Color cabecalho;

  final Color botaoSecundarioFundo;
  final Color botaoSecundarioTexto;
  final Color estrelaInativa;

  const CoresGaspo({
    required this.fundo,
    required this.superficie,
    required this.superficieAlternativa,
    required this.texto,
    required this.textoSecundario,
    required this.textoFraco,
    required this.borda,
    required this.titulo,
    required this.tituloForte,
    required this.destaque,
    required this.cabecalho,
    required this.botaoSecundarioFundo,
    required this.botaoSecundarioTexto,
    required this.estrelaInativa,
  });

  static const claro = CoresGaspo(
    fundo: GaspoCores.fundo,
    superficie: Colors.white,
    superficieAlternativa: GaspoCores.fundoComentario,
    texto: Colors.black87,
    textoSecundario: Colors.black54,
    textoFraco: Colors.black45,
    borda: Colors.black12,
    titulo: GaspoCores.azulTitulo,
    tituloForte: GaspoCores.azulEscuro,
    destaque: GaspoCores.azul,
    cabecalho: GaspoCores.azulCabecalho,
    botaoSecundarioFundo: GaspoCores.botaoSecundarioFundo,
    botaoSecundarioTexto: GaspoCores.botaoSecundarioTexto,
    estrelaInativa: GaspoCores.estrelaInativa,
  );

  static const escuro = CoresGaspo(
    fundo: Color(0xFF11151F),
    superficie: Color(0xFF1C2230),
    superficieAlternativa: Color(0xFF283044),
    texto: Color(0xFFE6E8EE),
    textoSecundario: Color(0xFFAEB4C2),
    textoFraco: Color(0xFF8A90A0),
    borda: Color(0x29FFFFFF),
    titulo: Color(0xFFA9BEFF),
    tituloForte: Color(0xFFD6E0FF),
    destaque: Color(0xFF8AA2FF),
    cabecalho: Color(0xFF26386A),
    botaoSecundarioFundo: Color(0xFF26324D),
    botaoSecundarioTexto: Color(0xFFA9C1FF),
    estrelaInativa: Color(0xFF4A5163),
  );

  @override
  CoresGaspo copyWith() => this;

  @override
  CoresGaspo lerp(CoresGaspo? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return CoresGaspo(
      fundo: c(fundo, other.fundo),
      superficie: c(superficie, other.superficie),
      superficieAlternativa: c(superficieAlternativa, other.superficieAlternativa),
      texto: c(texto, other.texto),
      textoSecundario: c(textoSecundario, other.textoSecundario),
      textoFraco: c(textoFraco, other.textoFraco),
      borda: c(borda, other.borda),
      titulo: c(titulo, other.titulo),
      tituloForte: c(tituloForte, other.tituloForte),
      destaque: c(destaque, other.destaque),
      cabecalho: c(cabecalho, other.cabecalho),
      botaoSecundarioFundo: c(botaoSecundarioFundo, other.botaoSecundarioFundo),
      botaoSecundarioTexto: c(botaoSecundarioTexto, other.botaoSecundarioTexto),
      estrelaInativa: c(estrelaInativa, other.estrelaInativa),
    );
  }
}

extension CoresDoTema on BuildContext {
  CoresGaspo get cores => Theme.of(this).extension<CoresGaspo>() ?? CoresGaspo.claro;
  bool get temaEscuro => Theme.of(this).brightness == Brightness.dark;
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
    extensions: const [CoresGaspo.claro],
  );
}

ThemeData criarTemaGaspoEscuro() {
  const cores = CoresGaspo.escuro;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    primaryColor: GaspoCores.azul,
    scaffoldBackgroundColor: cores.fundo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: GaspoCores.azul,
      brightness: Brightness.dark,
      primary: cores.destaque,
      surface: cores.superficie,
    ),
    dividerColor: cores.borda,
    extensions: const [cores],
  );
}
