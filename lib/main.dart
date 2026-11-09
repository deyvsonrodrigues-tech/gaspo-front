import 'package:flutter/material.dart';

import 'app/localizacao.dart';
import 'app/rotas.dart';
import 'app/tema.dart';

void main() {
  runApp(const GaspoApp());
}

class GaspoApp extends StatelessWidget {
  const GaspoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GASPO',
      debugShowCheckedModeBanner: false,
      theme: criarTemaGaspo(),
      locale: localeGaspo,
      supportedLocales: const [localeGaspo],
      localizationsDelegates: delegatesGaspo,
      initialRoute: Rotas.splash,
      onGenerateRoute: Rotas.gerarRota,
    );
  }
}
