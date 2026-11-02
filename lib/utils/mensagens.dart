import 'package:flutter/material.dart';

void mostrarMensagem(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 2),
      ),
    );
}

/// Aviso padrão para botões cuja tela ainda não foi desenvolvida.
void mostrarEmDesenvolvimento(BuildContext context, String recurso) {
  mostrarMensagem(context, '$recurso: em desenvolvimento');
}
