import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../dados/dados_exemplo.dart';
import '../../widgets/gaspo_bottom_nav.dart';

class HomeTela extends StatelessWidget {
  const HomeTela({super.key});

  /// A partir desta largura, os cartões de categoria ficam em uma única linha.
  static const double larguraLayoutLargo = 800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: GaspoCores.azulCabecalho,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bem-vindo ao GASPO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              usuarioLogado.nome,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, Rotas.notificacoes),
                        borderRadius: BorderRadius.circular(8),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 26,
                            ),
                            Text(
                              'Notificações',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildQuadroCategorias(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cartoes = [
                    _buildCategoryCard(
                      context,
                      title: 'Especialistas',
                      icon: Icons.medical_services_outlined,
                      onTap: () =>
                          Navigator.pushNamed(context, Rotas.especialistas),
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'Comunicados',
                      icon: Icons.forum_outlined,
                      onTap: () => Navigator.pushNamed(context, Rotas.avisos),
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'Avaliação',
                      icon: Icons.check_circle_outline,
                      onTap: () =>
                          Navigator.pushNamed(context, Rotas.avaliacaoConsulta),
                    ),
                    _buildCategoryCard(
                      context,
                      title: 'Localização',
                      icon: Icons.local_hospital_outlined,
                      onTap: () =>
                          Navigator.pushNamed(context, Rotas.localizacao),
                    ),
                  ];

                  // Telas largas (web/tablet): os 4 cartões em uma única linha.
                  if (constraints.maxWidth >= larguraLayoutLargo) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        child: Row(
                          children: cartoes.map((cartao) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                ),
                                child: SizedBox(height: 180, child: cartao),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }

                  return GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    crossAxisCount: 2,
                    crossAxisSpacing: 22,
                    mainAxisSpacing: 22,
                    children: cartoes,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(
        currentIndex: GaspoBottomNav.inicio,
      ),
    );
  }

  /// Título "Categorias" num quadro no mesmo estilo do banner de Avisos,
  /// com imagem própria no mesmo tom de azul.
  Widget _buildQuadroCategorias() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/banner_categorias.png'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              // Encolhe em vez de estourar com fonte grande (acessibilidade).
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categorias',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Balãozinho decorativo no canto superior direito
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_hospital_outlined, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Escolha o serviço que você precisa.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    bool isHighlighted = false,
    required VoidCallback onTap,
  }) {
    return _CategoryCard(
      title: title,
      icon: icon,
      isHighlighted: isHighlighted,
      onTap: onTap,
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.isHighlighted,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isHighlighted;
  final VoidCallback onTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isBlue = widget.isHighlighted || _isHovered;

    // Material + InkWell: efeito de toque e semântica de botão para
    // leitores de tela e navegação por teclado.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: widget.onTap,
          onHover: (emCima) => setState(() => _isHovered = emCima),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isBlue ? GaspoCores.azul : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 46,
                    color: isBlue ? Colors.white : GaspoCores.azul,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isBlue ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
