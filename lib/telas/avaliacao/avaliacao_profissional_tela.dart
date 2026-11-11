import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../modelos/profissional.dart';
import '../../servicos/profissional_service.dart';
import '../../servicos/avaliacao_service.dart';
import '../../utils/mensagens.dart';
import '../../widgets/avaliacao_widgets.dart';
import '../../widgets/gaspo_bottom_nav.dart';
import '../../widgets/gaspo_header.dart';

/// Argumentos da rota [Rotas.avaliacaoProfissional] quando a tela deve
/// voltar para quem a abriu (ex.: Perfil do Profissional) ao enviar.
class AvaliacaoProfissionalArgumentos {
  final String? medico;
  final bool voltarAoEnviar;

  const AvaliacaoProfissionalArgumentos({
    this.medico,
    this.voltarAoEnviar = false,
  });
}

class AvaliacaoProfissionalTela extends StatefulWidget {
  // Parâmetro opcional para receber o médico selecionado na tela anterior
  final String? medicoPreSelecionado;

  /// true: ao enviar, volta para a tela anterior em vez de ir para o Início.
  final bool voltarAoEnviar;

  /// Permite injetar outra implementação (ex.: nos testes).
  final AvaliacaoService? service;

  const AvaliacaoProfissionalTela({
    super.key,
    this.medicoPreSelecionado,
    this.voltarAoEnviar = false,
    this.service,
  });

  @override
  State<AvaliacaoProfissionalTela> createState() =>
      _AvaliacaoProfissionalTelaState();
}

class _AvaliacaoProfissionalTelaState extends State<AvaliacaoProfissionalTela> {
  int _estrelasSelecionadas = 3;
  final TextEditingController _comentarioController = TextEditingController();

  String? _medicoSelecionado;
  List<Profissional> _profissionais = [];
  List<String> get _medicosSistema =>
      _profissionais.map((p) => p.nome).toList();
  bool _carregandoMedicos = true;
  bool _enviando = false;

  Future<void> _carregarMedicos() async {
    try {
      final lista = await ProfissionalService.instancia.listar();
      if (!mounted) return;
      setState(() {
        _profissionais = lista;
        // Se o médico foi preenchido na tela de avaliação da consulta, ele já vem selecionado aqui
        if (widget.medicoPreSelecionado != null &&
            _medicosSistema.contains(widget.medicoPreSelecionado)) {
          _medicoSelecionado = widget.medicoPreSelecionado;
        }
      });
    } catch (_) {
      if (mounted) {
        mostrarMensagem(context, 'Não foi possível carregar os médicos.');
      }
    } finally {
      if (mounted) setState(() => _carregandoMedicos = false);
    }
  }

  Future<void> _enviar() async {
    final profissional = _profissionais
        .where((p) => p.nome == _medicoSelecionado)
        .firstOrNull;
    if (profissional == null) {
      mostrarMensagem(context, 'Selecione o médico.');
      return;
    }

    setState(() => _enviando = true);
    try {
      await (widget.service ?? AvaliacaoService.instancia).avaliar(
        profissionalId: profissional.id,
        nota: _estrelasSelecionadas,
        comentario: _comentarioController.text,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _enviando = false);
      mostrarMensagem(
        context,
        'Não foi possível enviar a avaliação. Tente novamente.',
      );
      return;
    }
    if (!mounted) return;

    mostrarMensagem(context, 'Avaliação enviada com sucesso!');
    if (widget.voltarAoEnviar) {
      Navigator.pop(context, true);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, Rotas.home, (_) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarMedicos();
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
                style: TextStyle(
                  fontSize: 19,
                  color: GaspoCores.azulTitulo,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Informações do Profissional',
                style: TextStyle(
                  fontSize: 15,
                  color: GaspoCores.azulTitulo,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // O campo só é montado depois de carregar, para já vir com o médico escolhido.
              if (_carregandoMedicos)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _medicoSelecionado,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: GaspoCores.azulTitulo,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Selecione o Médico',
                    labelStyle: const TextStyle(color: GaspoCores.azulTitulo),
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: GaspoCores.azulTitulo,
                    ),
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
                      child: Text(
                        medico,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                style: TextStyle(
                  fontSize: 15,
                  color: GaspoCores.azulTitulo,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              CampoComentario(
                controller: _comentarioController,
                hint: 'Como foi o atendimento do profissional?',
              ),
              const SizedBox(height: 24),

              SeletorEstrelas(
                estrelasSelecionadas: _estrelasSelecionadas,
                onChanged: (valor) =>
                    setState(() => _estrelasSelecionadas = valor),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GaspoCores.azul,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _enviando ? null : _enviar,
                  child: const Text(
                    'Enviar Avaliação Final',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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
      bottomNavigationBar: const GaspoBottomNav(
        currentIndex: GaspoBottomNav.inicio,
      ),
    );
  }
}
