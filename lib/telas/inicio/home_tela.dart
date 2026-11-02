import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../dados/dados_exemplo.dart';
import '../../utils/mensagens.dart';
import '../../widgets/gaspo_bottom_nav.dart';

class HomeTela extends StatelessWidget {
  const HomeTela({super.key});

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
                  const Icon(Icons.keyboard_double_arrow_left, color: Colors.white, size: 24),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, size: 34, color: Colors.white),
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
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, Rotas.notificacoes),
                        borderRadius: BorderRadius.circular(8),
                        child: const Column(
                          children: [
                            Icon(Icons.notifications_none, color: Colors.white, size: 26),
                            Text(
                              'Notificações',
                              style: TextStyle(color: Colors.white, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Categorias',
                style: TextStyle(
                  fontSize: 18,
                  color: GaspoCores.azulTitulo,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                crossAxisCount: 2,
                crossAxisSpacing: 22,
                mainAxisSpacing: 22,
                children: [
                  _buildCategoryCard(
                    context,
                    title: 'Especialistas',
                    icon: Icons.medical_services_outlined,
                    onTap: () => Navigator.pushNamed(context, Rotas.especialistas),
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Comunicados',
                    icon: Icons.forum_outlined,
                    onTap: () => mostrarEmDesenvolvimento(context, 'Comunicados'),
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Avaliação',
                    icon: Icons.check_circle_outline,
                    onTap: () => Navigator.pushNamed(context, Rotas.avaliacaoConsulta),
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'Localização',
                    icon: Icons.local_hospital_outlined,
                    onTap: () => Navigator.pushNamed(context, Rotas.localizacao),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(currentIndex: GaspoBottomNav.inicio),
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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
    );
  }
}
