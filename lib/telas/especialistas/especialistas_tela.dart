import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../modelos/profissional.dart';
import '../../servicos/profissional_service.dart';
import '../../widgets/gaspo_bottom_nav.dart';
import '../../widgets/gaspo_header.dart';

class EspecialistasTela extends StatefulWidget {
  const EspecialistasTela({super.key});

  @override
  State<EspecialistasTela> createState() => _EspecialistasTelaState();
}

class _EspecialistasTelaState extends State<EspecialistasTela> {
  late Future<List<Profissional>> _profissionais = ProfissionalService.instancia
      .listar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GaspoHeader(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Especialistas',
                style: TextStyle(
                  fontSize: 20,
                  color: GaspoCores.azulTitulo,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            Expanded(
              child: FutureBuilder<List<Profissional>>(
                future: _profissionais,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: TextButton.icon(
                        onPressed: () => setState(
                          () => _profissionais = ProfissionalService.instancia
                              .listar(),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Não foi possível carregar. Tentar de novo',
                        ),
                      ),
                    );
                  }
                  final profissionais = snapshot.data!;
                  if (profissionais.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum especialista cadastrado.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: profissionais.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Colors.black12),
                    itemBuilder: (context, index) {
                      final profissional = profissionais[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Rotas.perfilProfissional,
                            arguments: profissional,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blueGrey[100],
                                child: const Icon(
                                  Icons.person,
                                  size: 34,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profissional.nome,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      profissional.especialidade,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          profissional.notaFormatada,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
}
