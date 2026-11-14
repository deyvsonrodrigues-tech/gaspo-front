import 'package:flutter/material.dart';

import '../app/rotas.dart';
import '../servicos/notificacao_service.dart';
import '../servicos/preferencias.dart';

/// Sino do cabeçalho do Início, com o número de notificações não lidas.
/// No Modo Silencioso o contador some.
class SinoNotificacoes extends StatefulWidget {
  const SinoNotificacoes({super.key});

  @override
  State<SinoNotificacoes> createState() => _SinoNotificacoesState();
}

class _SinoNotificacoesState extends State<SinoNotificacoes> {
  int _naoLidas = 0;

  @override
  void initState() {
    super.initState();
    _atualizar();
  }

  Future<void> _atualizar() async {
    try {
      final quantidade = await NotificacaoService.instancia.contarNaoLidas();
      if (mounted) setState(() => _naoLidas = quantidade);
    } catch (_) {}
  }

  Future<void> _abrir() async {
    await Navigator.pushNamed(context, Rotas.notificacoes);
    _atualizar();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Preferencias.instancia,
      builder: (context, _) {
        final silencioso = Preferencias.instancia.modoSilencioso;
        final mostrarContador = !silencioso && _naoLidas > 0;
        return Semantics(
          button: true,
          label: mostrarContador ? 'Notificações, $_naoLidas não lidas' : 'Notificações',
          excludeSemantics: true,
          child: InkWell(
            onTap: _abrir,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      silencioso ? Icons.notifications_off_outlined : Icons.notifications_none,
                      color: Colors.white,
                      size: 26,
                    ),
                    if (mostrarContador)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text(
                            _naoLidas > 9 ? '9+' : '$_naoLidas',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                const Text('Notificações', style: TextStyle(color: Colors.white, fontSize: 9)),
              ],
            ),
          ),
        );
      },
    );
  }
}
