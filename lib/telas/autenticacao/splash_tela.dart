import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';

/// Tela de abertura com o logo do GASPO. Segue para a Entrada após 2s.
class SplashTela extends StatefulWidget {
  const SplashTela({super.key});

  static const Duration duracao = Duration(seconds: 2);

  @override
  State<SplashTela> createState() => _SplashTelaState();
}

class _SplashTelaState extends State<SplashTela> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashTela.duracao, () {
      // No web, uma URL direta (ex.: /home) empilha outra tela sobre a splash.
      if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
        Navigator.pushReplacementNamed(context, Rotas.entrada);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              context.temaEscuro ? 'assets/logo_gaspo_escuro.png' : 'assets/logo_gaspo.png',
              width: 350,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 25),
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: GaspoCores.azulLogo,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
