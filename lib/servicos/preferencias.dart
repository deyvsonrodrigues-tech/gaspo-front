import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências do usuário guardadas no aparelho (Perfil > Configurações).
class Preferencias extends ChangeNotifier {
  static Preferencias instancia = Preferencias();

  static const _chaveModoEscuro = 'modo_escuro';
  static const _chaveModoSilencioso = 'modo_silencioso';

  bool _modoEscuro = false;
  bool _modoSilencioso = false;

  /// Tema escuro em todo o app.
  bool get modoEscuro => _modoEscuro;

  /// Esconde o contador e os alertas de notificações (e, na integração,
  /// deve impedir o envio de push).
  bool get modoSilencioso => _modoSilencioso;

  /// Lê o que foi salvo no aparelho (chamado antes de abrir o app).
  Future<void> carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _modoEscuro = prefs.getBool(_chaveModoEscuro) ?? false;
      _modoSilencioso = prefs.getBool(_chaveModoSilencioso) ?? false;
      notifyListeners();
    } catch (_) {
      // Sem armazenamento disponível: segue com os valores padrão.
    }
  }

  Future<void> definirModoEscuro(bool valor) => _salvar(_chaveModoEscuro, valor, () => _modoEscuro = valor);

  Future<void> definirModoSilencioso(bool valor) =>
      _salvar(_chaveModoSilencioso, valor, () => _modoSilencioso = valor);

  Future<void> _salvar(String chave, bool valor, VoidCallback aplicar) async {
    aplicar();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(chave, valor);
    } catch (_) {
      // A mudança vale nesta sessão mesmo se não puder ser salva.
    }
  }
}
