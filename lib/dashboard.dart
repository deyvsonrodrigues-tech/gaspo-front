
import 'package:flutter/material.dart';

void main() {
  runApp(const GaspoApp());
}

const Color corPrincipal = Color(0xFF505D9B);
const Color corFundo = Color(0xFFF8F7FC);
const Color corIcone = Color(0xFF3535FF);

class GaspoApp extends StatelessWidget {
  const GaspoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GASPO',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: corFundo,
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _telas = const [
    HomeView(),
    Center(child: Text('Tela de Agendamentos')),
    Center(child: Text('Tela de Histórico')),
    Center(child: Text('Perfil do Cidadão')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(94),
        child: Container(
          color: corPrincipal,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),

                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo ao GASPO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'José da Silva',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notificações'),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const Text(
                        'Notificações',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: _telas[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: corIcone,
        unselectedItemColor: Colors.black87,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 3,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Agendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_outlined),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 46, 5, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Text(
                'Categorias',
                style: TextStyle(
                  color: Color(0xFF152D87),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 42),

           
Expanded(
  child: LayoutBuilder(
    builder: (context, constraints) {
      final larguraTela = MediaQuery.of(context).size.width;
      final isWeb = larguraTela >= 800;

      final cartoes = [
        _buildActionCard(
          icon: Icons.medical_services_outlined,
          title: 'Especialistas',
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.chat_bubble_outline,
          title: 'Comunicados',
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.check_circle_outline,
          title: 'Avaliação',
          onTap: () {},
        ),
        _buildActionCard(
          icon: Icons.location_city_outlined,
          title: 'Localização',
          onTap: () {},
        ),
      ];

      if (isWeb) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cartoes.map((cartao) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      height: 180,
                      child: cartao,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }

      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 42,
        mainAxisSpacing: 55,
        childAspectRatio: 1.0,
        padding: const EdgeInsets.symmetric(horizontal: 1),
        children: cartoes,
      );
    },
  ),
),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 5,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE9EFF1),
              width: 7,
            ),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 39,
                color: corIcone,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}