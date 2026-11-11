import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../modelos/aviso.dart';
import '../../servicos/aviso_service.dart';
import '../../utils/formatadores.dart';
import '../../utils/mensagens.dart';
import '../../widgets/campos_formulario.dart';
import '../../widgets/gaspo_header.dart';

/// Painel Admin: avisos publicados (tela da Letícia, `AdminListScreen`).
class AvisosPublicadosTela extends StatefulWidget {
  /// Permite injetar outra implementação (ex.: nos testes).
  final AvisoService? service;

  const AvisosPublicadosTela({super.key, this.service});

  @override
  State<AvisosPublicadosTela> createState() => _AvisosPublicadosTelaState();
}

class _AvisosPublicadosTelaState extends State<AvisosPublicadosTela> {
  late final AvisoService _service = widget.service ?? AvisoService.instancia;

  List<Aviso> _avisos = [];
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
      if (mounted) setState(() => _avisos = lista);
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível carregar os avisos.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// Abre o formulário; ao voltar com uma mensagem, mostra e recarrega.
  Future<void> _abrirFormulario([Aviso? aviso]) async {
    final mensagem = await Navigator.pushNamed(context, Rotas.formularioAviso, arguments: aviso);
    if (!mounted) return;
    if (mensagem is String) mostrarMensagem(context, mensagem);
    _carregar();
  }

  Future<void> _remover(Aviso aviso) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover aviso'),
        content: Text('Remover o aviso "${aviso.titulo}"? Ele deixará de aparecer para os pacientes.'),
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
      await _service.remover(aviso.id);
      if (!mounted) return;
      setState(() => _avisos.removeWhere((a) => a.id == aviso.id));
      mostrarMensagem(context, 'Aviso removido.');
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível remover o aviso.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GaspoHeader(),
                  const SizedBox(height: 8),
                  const Text(
                    'Avisos Publicados',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: GaspoCores.azulEscuro),
                  ),
                  const Text(
                    'Publique comunicados e acompanhe-os',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  BotaoPrincipal(texto: 'Novo Aviso', onPressed: () => _abrirFormulario()),
                  const SizedBox(height: 16),
                  if (_carregando)
                    const Center(child: CircularProgressIndicator())
                  else if (_avisos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('Nenhum aviso publicado.', style: TextStyle(color: Colors.black54)),
                      ),
                    )
                  else
                    for (final aviso in _avisos) _buildAdminCard(aviso),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(Aviso aviso) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(aviso.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Publicado em ${formatarData(aviso.dataPublicacao)}',
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
              if (!aviso.visivelParaPacientes) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    aviso.expirado ? 'Expirado' : 'Oculto',
                    style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(aviso.mensagem, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: GaspoCores.azul),
                  ),
                  onPressed: () => _abrirFormulario(aviso),
                  child: const Text('Atualizar', style: TextStyle(color: GaspoCores.azul)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GaspoCores.azul,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _remover(aviso),
                  child: const Text('Remover', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
