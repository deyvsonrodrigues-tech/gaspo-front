const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
const _semAcento = 'aaaaaeeeeiiiiooooouuuucn';

/// Minúsculas e sem acentos, para buscas ("Flávia" encontra "flavia").
String normalizarBusca(String texto) {
  final buffer = StringBuffer();
  for (final c in texto.toLowerCase().split('')) {
    final i = _comAcento.indexOf(c);
    buffer.write(i == -1 ? c : _semAcento[i]);
  }
  return buffer.toString().trim();
}
