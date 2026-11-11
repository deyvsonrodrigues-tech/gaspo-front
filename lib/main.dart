import 'package:flutter/material.dart';

import 'app/localizacao.dart';
import 'app/rotas.dart';
import 'app/tema.dart';
import 'servicos/preferencias.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferencias.instancia.carregar();
  runApp(const GaspoApp());
}

class GaspoApp extends StatelessWidget {
  const GaspoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Reconstrói o app quando o Modo Escuro muda no Perfil.
    return ListenableBuilder(
      listenable: Preferencias.instancia,
      builder: (context, _) => MaterialApp(
        title: 'GASPO',
        debugShowCheckedModeBanner: false,
        theme: criarTemaGaspo(),
        darkTheme: criarTemaGaspoEscuro(),
        themeMode: Preferencias.instancia.modoEscuro ? ThemeMode.dark : ThemeMode.light,
        locale: localeGaspo,
        supportedLocales: const [localeGaspo],
        localizationsDelegates: delegatesGaspo,
        initialRoute: Rotas.splash,
        onGenerateRoute: Rotas.gerarRota,
      ),
    );
  }
}
