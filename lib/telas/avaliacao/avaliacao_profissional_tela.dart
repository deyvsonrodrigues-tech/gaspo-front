import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../dados/dados_exemplo.dart';
import '../../utils/mensagens.dart';
import '../../widgets/avaliacao_widgets.dart';
import '../../widgets/gaspo_bottom_nav.dart';
import '../../widgets/gaspo_header.dart';

class AvaliacaoProfissionalTela extends StatefulWidget {
  // Parâmetro opcional para receber o médico selecionado na tela anterior
  final String? medicoPreSelecionado;

  const AvaliacaoProfissionalTela({super.key, this.medicoPreSelecionado});

  @override
  State<AvaliacaoProfissionalTela> createState() => _AvaliacaoProfissionalTelaState();
}

class _AvaliacaoProfissionalTelaState extends State<AvaliacaoProfissionalTela> {
  int _estrelasSelecionadas = 3;
  final TextEditingController _comentarioController = TextEditingController();

  String? _medicoSelecionado;
  final List<String> _medicosSistema = profissionais.map((p) => p.nome).toList();

  @override
  void initState() {
    super.initState();
    // Se o médico foi preenchido na tela de avaliação da consulta, ele já vem selecionado aqui
    if (widget.medicoPreSelecionado != null && _medicosSistema.contains(widget.medicoPreSelecionado)) {
      _medicoSelecionado = widget.medicoPreSelecionado;
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GaspoHeader(),
              const SizedBox(height: 16),
              const Text(
                'Avaliação do Profissional',
                style: TextStyle(fontSize: 19, color: GaspoCores.azulTitulo, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                'Informações do Profissional',
                style: TextStyle(fontSize: 15, color: GaspoCores.azulTitulo, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _medicoSelecionado,
                icon: const Icon(Icons.arrow_drop_down, color: GaspoCores.azulTitulo),
                decoration: InputDecoration(
                  labelText: 'Selecione o Médico',
                  labelStyle: const TextStyle(color: GaspoCores.azulTitulo),
                  prefixIcon: const Icon(Icons.badge_outlined, color: GaspoCores.azulTitulo),
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
                ),
                items: _medicosSistema.map((String medico) {
                  return DropdownMenuItem<String>(
                    value: medico,
                    child: Text(medico, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (novoValor) {
                  setState(() {
                    _medicoSelecionado = novoValor;
                  });
                },
              ),

              const SizedBox(height: 24),
              const Divider(height: 1, color: Colors.black26),
              const SizedBox(height: 24),

              const Text(
                'Adicionar Comentário',
                style: TextStyle(fontSize: 15, color: GaspoCores.azulTitulo, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              CampoComentario(
                controller: _comentarioController,
                hint: 'Como foi o atendimento do profissional?',
              ),
              const SizedBox(height: 24),

              SeletorEstrelas(
                estrelasSelecionadas: _estrelasSelecionadas,
                onChanged: (valor) => setState(() => _estrelasSelecionadas = valor),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GaspoCores.azul,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    mostrarMensagem(context, 'Avaliação enviada com sucesso!');
                    Navigator.pushNamedAndRemoveUntil(context, Rotas.home, (_) => false);
                  },
                  child: const Text('Enviar Avaliação Final', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),

              BotaoSecundario(
                texto: 'Voltar',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(currentIndex: GaspoBottomNav.inicio),
    );
  }
}
