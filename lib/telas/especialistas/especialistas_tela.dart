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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Especialistas',
                style: TextStyle(
                  fontSize: 20,
                  color: context.cores.titulo,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Divider(height: 1, color: context.cores.borda),
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
                    return Center(
                      child: Text(
                        'Nenhum especialista cadastrado.',
                        style: TextStyle(color: context.cores.textoSecundario),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: profissionais.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: context.cores.borda),
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
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: context.cores.texto,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      profissional.especialidade,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: context.cores.textoSecundario,
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
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.cores.textoFraco,
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
