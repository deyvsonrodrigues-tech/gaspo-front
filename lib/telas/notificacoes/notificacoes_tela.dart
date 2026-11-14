import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../dados/dados_exemplo.dart';
import '../../modelos/notificacao.dart';
import '../../servicos/notificacao_service.dart';
import '../../servicos/preferencias.dart';
import '../../utils/formatadores.dart';
import '../../utils/mensagens.dart';
import '../../widgets/avatar_usuario.dart';
import '../../widgets/gaspo_bottom_nav.dart';

/// Central de Notificações do paciente (criadas quando as consultas mudam).
class NotificacoesTela extends StatefulWidget {
  /// Permite injetar outra implementação (ex.: nos testes).
  final NotificacaoService? service;

  const NotificacoesTela({super.key, this.service});

  @override
  State<NotificacoesTela> createState() => _NotificacoesTelaState();
}

class _NotificacoesTelaState extends State<NotificacoesTela> {
  late final NotificacaoService _service = widget.service ?? NotificacaoService.instancia;

  List<Notificacao> _notificacoes = [];
  bool _carregando = true;
  bool _erro = false;

  int get _naoLidas => _notificacoes.where((n) => !n.lida).length;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = false;
    });
    try {
      final lista = await _service.listar();
      if (mounted) setState(() => _notificacoes = lista);
    } catch (_) {
      if (mounted) setState(() => _erro = true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _abrir(Notificacao notificacao) async {
    if (!notificacao.lida) {
      try {
        await _service.marcarComoLida(notificacao.id);
        if (!mounted) return;
        setState(() {
          final i = _notificacoes.indexWhere((n) => n.id == notificacao.id);
          if (i != -1) _notificacoes[i] = notificacao.copyWith(lida: true);
        });
      } catch (_) {
        if (mounted) mostrarMensagem(context, 'Não foi possível atualizar a notificação.');
      }
    }
    if (notificacao.pedeAvaliacao && mounted) {
      Navigator.pushNamed(context, Rotas.avaliacaoConsulta);
    }
  }

  Future<void> _marcarTodas() async {
    try {
      await _service.marcarTodasComoLidas();
      if (!mounted) return;
      setState(() => _notificacoes = [for (final n in _notificacoes) n.copyWith(lida: true)]);
    } catch (_) {
      if (mounted) mostrarMensagem(context, 'Não foi possível atualizar as notificações.');
    }
  }

  /// Ícone conforme o tipo de notificação.
  IconData _icone(Notificacao n) => switch (n.titulo) {
        'Consulta agendada' => Icons.event_available,
        'Consulta confirmada' => Icons.check_circle_outline,
        'Consulta cancelada' => Icons.event_busy,
        'Avalie seu atendimento' => Icons.star_outline,
        _ => Icons.mark_chat_unread_outlined,
      };

  String _quando(DateTime data) {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final dia = DateUtils.dateOnly(data);
    if (dia == hoje) return formatarHora(TimeOfDay.fromDateTime(data));
    if (dia == DateUtils.addDaysToDate(hoje, -1)) return 'Ontem';
    return formatarData(data).substring(0, data.year == hoje.year ? 5 : 10);
  }

  Widget _criarItemNotificacao(BuildContext context, Notificacao n, {required bool silencioso}) {
    // No Modo Silencioso os destaques de "não lida" somem (a notificação continua na lista).
    final destacar = !n.lida && !silencioso;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.cores.borda, width: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: n.lida ? context.cores.superficieAlternativa : GaspoCores.azulClaro,
          radius: 22,
          child: Icon(_icone(n), color: n.lida ? context.cores.textoSecundario : Colors.white, size: 22),
        ),
        title: Text(
          n.titulo,
          style: TextStyle(
            fontSize: 15,
            color: context.cores.texto,
            fontWeight: destacar ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          n.mensagem,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: context.cores.textoSecundario),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _quando(n.dataEnvio),
              style: TextStyle(fontSize: 12, color: context.cores.textoSecundario),
            ),
            const SizedBox(height: 6),
            if (destacar)
              Semantics(
                key: const ValueKey('nao-lida'),
                label: 'Não lida',
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: GaspoCores.azul, shape: BoxShape.circle),
                ),
              )
            else
              const SizedBox(height: 10),
          ],
        ),
        onTap: () => _abrir(n),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Preferencias.instancia,
      builder: (context, _) => _buildTela(context, Preferencias.instancia.modoSilencioso),
    );
  }

  Widget _avisoSilencioso(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 8),
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        color: context.cores.superficieAlternativa,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_off_outlined, size: 20, color: context.cores.textoSecundario),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo silencioso ligado: alertas ocultos.',
              style: TextStyle(fontSize: 13, color: context.cores.textoSecundario),
            ),
          ),
          TextButton(
            onPressed: () => Preferencias.instancia.definirModoSilencioso(false),
            child: const Text('Desligar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(BuildContext context, bool silencioso) {
    if (_carregando) return const Center(child: CircularProgressIndicator());
    if (_erro) {
      return Center(
        child: TextButton.icon(
          onPressed: _carregar,
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar. Tentar de novo'),
        ),
      );
    }
    if (_notificacoes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Você não tem notificações. Elas aparecem aqui quando suas consultas mudam.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.cores.textoSecundario),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        children: [
          for (final n in _notificacoes) _criarItemNotificacao(context, n, silencioso: silencioso),
        ],
      ),
    );
  }

  Widget _buildTela(BuildContext context, bool silencioso) {
    final naoLidas = _naoLidas;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // CABEÇALHO AZUL
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: context.cores.cabecalho,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.white, size: 30),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 10),
                  AvatarUsuario(raio: 25, corIcone: context.cores.cabecalho),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bem-vindo ao GASPO',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          usuarioLogado.nome,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Stack(
                        children: [
                          Icon(
                            silencioso ? Icons.notifications_off_outlined : Icons.notifications_none,
                            color: Colors.white,
                            size: 30,
                          ),
                          if (!silencioso && naoLidas > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                child: Text(
                                  naoLidas > 9 ? '9+' : '$naoLidas',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Text(
                        'Notificações',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (silencioso) _avisoSilencioso(context),

            if (naoLidas > 0)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: _marcarTodas,
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Marcar todas como lidas'),
                  ),
                ),
              ),

            // LISTA DE NOTIFICAÇÕES
            Expanded(child: _buildLista(context, silencioso)),
          ],
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(currentIndex: GaspoBottomNav.inicio),
    );
  }
}
