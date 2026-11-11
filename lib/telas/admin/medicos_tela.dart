import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../modelos/profissional.dart';
import '../../servicos/profissional_service.dart';
import '../../utils/mensagens.dart';
import '../../widgets/campos_formulario.dart';
import '../../widgets/gaspo_header.dart';

/// Painel Admin: lista de médicos, com cadastro, edição, status e remoção.
class MedicosTela extends StatefulWidget {
  /// Permite injetar outra implementação (ex.: nos testes).
  final ProfissionalService? service;

  const MedicosTela({super.key, this.service});

  @override
  State<MedicosTela> createState() => _MedicosTelaState();
}

class _MedicosTelaState extends State<MedicosTela> {
  late final ProfissionalService _service = widget.service ?? ProfissionalService.instancia;

  List<Profissional> _profissionais = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final lista = await _service.listar();
      if (mounted) setState(() => _profissionais = List.of(lista)..sort((a, b) => a.nome.compareTo(b.nome)));
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível carregar os médicos.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// Abre o formulário; ao voltar com uma mensagem, mostra e recarrega.
  Future<void> _abrirFormulario([Profissional? profissional]) async {
    final mensagem = await Navigator.pushNamed(context, Rotas.formularioMedico, arguments: profissional);
    if (!mounted) return;
    if (mensagem is String) mostrarMensagem(context, mensagem);
    _carregar();
  }

  Future<void> _alterarStatus(Profissional profissional, StatusProfissional status) async {
    if (profissional.status == status) return;
    try {
      final atualizado = await _service.atualizarStatus(profissional.id, status);
      if (!mounted) return;
      setState(() {
        final indice = _profissionais.indexOf(profissional);
        if (indice != -1) _profissionais[indice] = atualizado;
      });
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível alterar o status.');
    }
  }

  Future<void> _remover(Profissional profissional) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover médico'),
        content: Text('Remover ${profissional.nome} da lista de médicos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      await _service.remover(profissional.id);
      if (!mounted) return;
      setState(() => _profissionais.remove(profissional));
      mostrarMensagem(context, '${profissional.nome} foi removido.');
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível remover o médico.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GaspoHeader(),
                  const SizedBox(height: 12),
                  Text(
                    'Médicos',
                    style: TextStyle(fontSize: 19, color: context.cores.titulo, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Profissionais que aparecem para os pacientes.',
                    style: TextStyle(fontSize: 13, color: context.cores.textoSecundario),
                  ),
                  const SizedBox(height: 18),
                  BotaoPrincipal(texto: 'Cadastrar médico', onPressed: () => _abrirFormulario()),
                  const SizedBox(height: 20),
                  if (_carregando)
                    const Center(child: CircularProgressIndicator())
                  else if (_profissionais.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('Nenhum médico cadastrado.', style: TextStyle(color: context.cores.textoSecundario)),
                      ),
                    )
                  else
                    for (final profissional in _profissionais)
                      _ItemMedico(
                        profissional: profissional,
                        onStatus: (status) => _alterarStatus(profissional, status),
                        onEditar: () => _abrirFormulario(profissional),
                        onRemover: () => _remover(profissional),
                      ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemMedico extends StatelessWidget {
  final Profissional profissional;
  final ValueChanged<StatusProfissional> onStatus;
  final VoidCallback onEditar;
  final VoidCallback onRemover;

  const _ItemMedico({
    required this.profissional,
    required this.onStatus,
    required this.onEditar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final cor = profissional.status.cor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10, right: 4),
      decoration: BoxDecoration(
        color: context.cores.superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cores.borda),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: cor, width: 2)),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blueGrey[100],
              child: const Icon(Icons.person, size: 24, color: Colors.blueGrey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profissional.nome,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.cores.texto),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  profissional.especialidade,
                  style: TextStyle(fontSize: 12, color: context.cores.textoSecundario),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                PopupMenuButton<StatusProfissional>(
                  tooltip: 'Alterar status',
                  onSelected: onStatus,
                  itemBuilder: (_) => [
                    for (final s in StatusProfissional.values)
                      PopupMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: s.cor),
                            const SizedBox(width: 8),
                            Text(s.rotulo),
                          ],
                        ),
                      ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profissional.status.rotulo,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cor),
                        ),
                        Icon(Icons.arrow_drop_down, size: 18, color: cor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar médico',
            onPressed: onEditar,
            icon: Icon(Icons.edit_outlined, color: context.cores.destaque),
          ),
          IconButton(
            tooltip: 'Remover médico',
            onPressed: onRemover,
            icon: Icon(Icons.delete_outline, color: context.cores.textoSecundario),
          ),
        ],
      ),
    );
  }
}
