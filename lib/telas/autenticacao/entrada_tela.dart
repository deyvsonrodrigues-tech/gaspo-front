import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../utils/mensagens.dart';

class EntradaTela extends StatelessWidget {
  const EntradaTela({super.key});

  Widget botaoPerfil(
    BuildContext context,
    String titulo,
  ) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // Usuário e Funcionário usam o mesmo login por enquanto.
            Navigator.pushNamed(context, Rotas.login);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: GaspoCores.azul,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // LOGO HORIZONTAL DO GASPO
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/logo_gaspo_horizontal.png',
                  width: 180,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 55),

              // TEXTO ENTRAR COMO
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Entrar como:',
                  style: TextStyle(
                    fontSize: 16,
                    color: GaspoCores.azulEscuro,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // BOTÕES USUÁRIO E FUNCIONÁRIO
              Row(
                children: [
                  botaoPerfil(context, 'Usuário'),

                  const SizedBox(width: 16),

                  botaoPerfil(context, 'Funcionário'),
                ],
              ),

              const Spacer(),

              // CADASTRAR-SE
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Ainda não tem uma conta?',
                    style: TextStyle(
                      fontSize: 13,
                      color: GaspoCores.azulEscuro,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Rotas.cadastro);
                    },
                    child: const Text(
                      'Cadastrar-se',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: GaspoCores.azulEscuro,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // BOTÃO AJUDA
              ElevatedButton(
                onPressed: () {
                  mostrarEmDesenvolvimento(context, 'Ajuda');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GaspoCores.azul,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(55, 35),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Ajuda'),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
