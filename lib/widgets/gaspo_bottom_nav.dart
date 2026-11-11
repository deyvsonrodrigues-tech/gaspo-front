import 'package:flutter/material.dart';

import '../app/rotas.dart';
import '../app/tema.dart';

/// Menu inferior compartilhado por todas as telas internas.
class GaspoBottomNav extends StatelessWidget {
  static const int inicio = 0;
  static const int agendar = 1;
  static const int historico = 2;
  static const int perfil = 3;

  final int currentIndex;
  const GaspoBottomNav({super.key, this.currentIndex = inicio});

  void _navegar(BuildContext context, int index) {
    switch (index) {
      case inicio:
        Navigator.pushNamedAndRemoveUntil(context, Rotas.home, (_) => false);
      case perfil:
        if (currentIndex != perfil) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Rotas.perfil,
            ModalRoute.withName(Rotas.home),
          );
        }
      case agendar:
        if (currentIndex != agendar) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Rotas.agendamento,
            ModalRoute.withName(Rotas.home),
          );
        }
      case historico:
        if (currentIndex != historico) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Rotas.historico,
            ModalRoute.withName(Rotas.home),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: context.cores.superficie,
      selectedItemColor: context.cores.destaque,
      unselectedItemColor: context.cores.texto,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      onTap: (index) => _navegar(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Agendar'),
        BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Histórico'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
    );
  }
}
