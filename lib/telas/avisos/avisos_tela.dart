import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../modelos/aviso.dart';
import '../../servicos/aviso_service.dart';
import '../../utils/formatadores.dart';
import '../../widgets/gaspo_bottom_nav.dart';
import '../../widgets/gaspo_header.dart';

/// Feed de Avisos do paciente (tela da Letícia, `PatientScreen`).
class AvisosTela extends StatefulWidget {
  /// Permite injetar outra implementação (ex.: nos testes).
  final AvisoService? service;

  const AvisosTela({super.key, this.service});

  /// Quantos avisos aparecem antes de tocar em "VER TODOS".
  static const int avisosIniciais = 3;

  @override
  State<AvisosTela> createState() => _AvisosTelaState();
}

class _AvisosTelaState extends State<AvisosTela> {
  // Ícones dos cartões do layout original, aplicados em sequência.
  static final List<(IconData, Color)> _estilos = [
    (Icons.warning_amber_rounded, Colors.amber[700]!),
    (Icons.access_time_filled, GaspoCores.azul),
    (Icons.group, Colors.redAccent),
  ];

  late final AvisoService _service = widget.service ?? AvisoService.instancia;

  List<Aviso> _avisos = [];
  bool _carregando = true;
  bool _erro = false;
  bool _verTodos = false;

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
      if (mounted) setState(() => _avisos = lista.where((a) => a.visivelParaPacientes).toList());
    } catch (_) {
      if (mounted) setState(() => _erro = true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final temMais = _avisos.length > AvisosTela.avisosIniciais;
    final visiveis = _verTodos ? _avisos : _avisos.take(AvisosTela.avisosIniciais).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GaspoHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _carregar,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBanner(temMais),
                          const SizedBox(height: 24),
                          if (_carregando)
                            const Center(child: CircularProgressIndicator())
                          else if (_erro)
                            Center(
                              child: TextButton.icon(
                                onPressed: _carregar,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Não foi possível carregar. Tentar de novo'),
                              ),
                            )
                          else if (_avisos.isEmpty)
                            const Center(
                              child: Text('Nenhum aviso no momento.', style: TextStyle(color: Colors.black54)),
                            )
                          else
                            for (final (indice, aviso) in visiveis.indexed) ...[
                              _buildNoticeCard(aviso, _estilos[indice % _estilos.length]),
                              const SizedBox(height: 16),
                            ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(currentIndex: GaspoBottomNav.inicio),
    );
  }

  // BANNER COM A PROPOSTA VISUAL EXATA E OS BALÕEZINHOS
  Widget _buildBanner(bool temMais) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/banner_avisos.jpg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: GaspoCores.azul.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone de balãozinho superior e Título "Avisos"
            Row(
              children: [
                const Icon(Icons.chat, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Avisos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Balãozinho decorativo no canto superior direito
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.forum_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Fique por dentro de todas as novidades e comunicados importantes!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            if (temMais) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: GaspoCores.azul,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => setState(() => _verTodos = !_verTodos),
                  child: Text(
                    _verTodos ? 'VER MENOS' : 'VER TODOS',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeCard(Aviso aviso, (IconData, Color) estilo) {
    final (icon, iconColor) = estilo;
    final badgeText = aviso.publicadoHoje ? 'Hoje' : formatarData(aviso.dataPublicacao).substring(0, 5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        aviso.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: GaspoCores.azulEscuro,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: GaspoCores.azul,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  aviso.mensagem,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
