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
                : GaspoCores.estrelaInativa,
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
        color: GaspoCores.fundoComentario,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          icon: const Icon(Icons.chat_bubble, color: GaspoCores.azul),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
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
            backgroundColor: GaspoCores.botaoSecundarioFundo,
            foregroundColor: GaspoCores.botaoSecundarioTexto,
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
