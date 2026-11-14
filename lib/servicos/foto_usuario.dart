import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Foto do usuário guardada no aparelho.
///
/// A API ainda não tem campo de foto; na integração, enviar para o servidor
/// e manter esta cópia local como cache.
class FotoUsuario extends ChangeNotifier {
  static FotoUsuario instancia = FotoUsuario();

  static const _chave = 'foto_usuario';

  Uint8List? _bytes;

  Uint8List? get bytes => _bytes;
  bool get temFoto => _bytes != null;

  Future<void> carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salva = prefs.getString(_chave);
      _bytes = salva == null ? null : base64Decode(salva);
      notifyListeners();
    } catch (_) {
      // Sem armazenamento disponível: segue sem foto.
    }
  }

  Future<void> definir(Uint8List bytes) async {
    _bytes = bytes;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chave, base64Encode(bytes));
    } catch (_) {}
  }

  Future<void> remover() async {
    _bytes = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chave);
    } catch (_) {}
  }
}
