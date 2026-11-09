import 'package:flutter/material.dart';

import '../app/tema.dart';
import '../utils/formatadores.dart';

/// Decoração padrão dos campos de formulário (fundo branco, borda arredondada).
InputDecoration decoracaoCampo(String label, IconData icone) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: GaspoCores.azulTitulo, fontWeight: FontWeight.w500),
    prefixIcon: Icon(icone, color: GaspoCores.azulTitulo),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black12),
    ),
  );
}

/// Campo que abre o calendário. Só permite datas de hoje até 1 ano à frente.
class CampoData extends StatelessWidget {
  final DateTime data;
  final ValueChanged<DateTime> onChanged;
  final String label;

  const CampoData({
    super.key,
    required this.data,
    required this.onChanged,
    this.label = 'Data',
  });

  Future<void> _escolher(BuildContext context) async {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final escolhida = await showDatePicker(
      context: context,
      initialDate: data.isBefore(hoje) ? hoje : data,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
    );
    if (escolhida != null) onChanged(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _escolher(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: decoracaoCampo(label, Icons.calendar_today_outlined),
        child: Text(formatarData(data), style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

/// Botão principal azul de largura total, com indicador de carregamento.
class BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool carregando;

  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: GaspoCores.azul,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: carregando ? null : onPressed,
        child: carregando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(texto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
