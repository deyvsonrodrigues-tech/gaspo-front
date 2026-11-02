import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../utils/mensagens.dart';
import '../../widgets/gaspo_header.dart';

class CadastroTela extends StatefulWidget {
  const CadastroTela({super.key});

  @override
  State<CadastroTela> createState() => _CadastroTelaState();
}

class _CadastroTelaState extends State<CadastroTela> {
  final nome = TextEditingController();
  final nascimento = TextEditingController();
  final cpf = TextEditingController();
  final telefone = TextEditingController();
  final senha = TextEditingController();
  final confirmarSenha = TextEditingController();

  bool mostrarSenha = false;

  @override
  void dispose() {
    nome.dispose();
    nascimento.dispose();
    cpf.dispose();
    telefone.dispose();
    senha.dispose();
    confirmarSenha.dispose();
    super.dispose();
  }

  // CRIAR CAMPOS DO CADASTRO
  Widget criarCampo(
    String titulo,
    TextEditingController controle, {
    bool campoSenha = false,
  }) {
    return SizedBox(
      width: 220,
      height: 38,
      child: TextField(
        controller: controle,
        obscureText: campoSenha && !mostrarSenha,
        decoration: InputDecoration(
          hintText: titulo,
          hintStyle: const TextStyle(fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: GaspoCores.azul),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: GaspoCores.azul, width: 2),
          ),
        ),
      ),
    );
  }

  // BOTÃO CADASTRAR
  void cadastrar() {
    String mensagem;

    if (nome.text.trim().isEmpty ||
        nascimento.text.trim().isEmpty ||
        cpf.text.trim().isEmpty ||
        telefone.text.trim().isEmpty ||
        senha.text.isEmpty ||
        confirmarSenha.text.isEmpty) {
      mensagem = 'Preencha todos os campos!';
    } else if (senha.text != confirmarSenha.text) {
      mensagem = 'As senhas não coincidem!';
    } else {
      // TODO: enviar o cadastro quando a API estiver disponível.
      mensagem = 'Cadastro em desenvolvimento!';
    }

    mostrarMensagem(context, mensagem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Column(
            children: [
              const SizedBox(height: 18),

              // LOGO E SETA DE VOLTAR
              const GaspoHeader(padding: EdgeInsets.zero),

              const SizedBox(height: 65),

              // FORMULÁRIO
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Preencha os dados abaixo para começar:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: GaspoCores.azulEscuro,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // CAMPOS CENTRALIZADOS
                      criarCampo('Nome Completo:', nome),
                      const SizedBox(height: 16),

                      criarCampo(
                        'Data de Nascimento:',
                        nascimento,
                      ),
                      const SizedBox(height: 16),

                      criarCampo('CPF:', cpf),
                      const SizedBox(height: 16),

                      criarCampo('Telefone:', telefone),
                      const SizedBox(height: 16),

                      criarCampo(
                        'Criar Senha:',
                        senha,
                        campoSenha: true,
                      ),
                      const SizedBox(height: 16),

                      criarCampo(
                        'Confirmar Senha:',
                        confirmarSenha,
                        campoSenha: true,
                      ),

                      // MOSTRAR SENHAS
                      SizedBox(
                        width: 220,
                        child: Row(
                          children: [
                            Checkbox(
                              value: mostrarSenha,
                              onChanged: (valor) {
                                setState(() {
                                  mostrarSenha = valor ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Mostrar senhas',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // BOTÃO CADASTRAR
              const SizedBox(height: 15),

              SizedBox(
                width: 166,
                height: 36,
                child: ElevatedButton(
                  onPressed: cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GaspoCores.azul,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // FAZER LOGIN
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Rotas.login);
                },
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Já possui uma conta? '),
                      TextSpan(
                        text: 'Fazer login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: GaspoCores.azulEscuro,
                  ),
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
