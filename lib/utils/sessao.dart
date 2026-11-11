import 'package:flutter/material.dart';

import '../app/rotas.dart';

/// Pergunta se o usuário quer sair e, se sim, volta para o Login.
Future<void> sairDaConta(BuildContext context) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sair da conta?'),
      content: const Text('Você precisará entrar novamente para acessar o aplicativo.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Sair'),
        ),
      ],
    ),
  );
  if (confirmado != true || !context.mounted) return;

  // TODO: apagar o token salvo quando o login usar a API.
  // Entrada fica por baixo para a seta de voltar do Login funcionar.
  final navigator = Navigator.of(context);
  navigator.pushNamedAndRemoveUntil(Rotas.entrada, (_) => false);
  navigator.pushNamed(Rotas.login);
}
