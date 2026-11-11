import 'package:flutter/material.dart';

import '../app/tema.dart';

/// Linha de 5 estrelas selecionáveis usada nas telas de avaliação.
class SeletorEstrelas extends StatelessWidget {
  final int estrelasSelecionadas;
  final ValueChanged<int> onChanged;

  const SeletorEstrelas({
    super.key,
    required this.estrelasSelecionadas,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => onChanged(index + 1),
          icon: Icon(
            Icons.star,
            size: 44,
            color: index < estrelasSelecionadas
                ? GaspoCores.estrelaAtiva
                : context.cores.estrelaInativa,
          ),
        );
      }),
    );
  }
}

/// Caixa cinza arredondada para comentários das avaliações.
class CampoComentario extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const CampoComentario({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: context.cores.superficieAlternativa,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          icon: Icon(Icons.chat_bubble, color: context.cores.destaque),
          hintText: hint,
          hintStyle: TextStyle(color: context.cores.textoSecundario, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

/// Botão secundário (Cancelar / Voltar) das telas de avaliação.
class BotaoSecundario extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const BotaoSecundario({
    super.key,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 260,
        height: 42,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.cores.botaoSecundarioFundo,
            foregroundColor: context.cores.botaoSecundarioTexto,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onPressed,
          child: Text(texto, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
