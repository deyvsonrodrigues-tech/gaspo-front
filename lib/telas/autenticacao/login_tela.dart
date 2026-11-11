import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../modelos/perfil_acesso.dart';
import '../../widgets/gaspo_header.dart';

class LoginTela extends StatefulWidget {
  final PerfilAcesso perfil;

  const LoginTela({super.key, this.perfil = PerfilAcesso.usuario});

  @override
  State<LoginTela> createState() => _LoginTelaState();
}

class _LoginTelaState extends State<LoginTela> {
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool senhaOculta = true;

  @override
  void dispose() {
    cpfController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void entrar() {
    // TODO: autenticar CPF e senha quando a API estiver disponível.
    // Funcionário vai para o painel admin (por enquanto, só o Cadastro de Horários).
    final destino = widget.perfil == PerfilAcesso.funcionario
        ? Rotas.cadastroHorarios
        : Rotas.home;
    Navigator.pushNamedAndRemoveUntil(context, destino, (_) => false);
  }

  InputDecoration _decoracaoCampo({Widget? suffixIcon}) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: GaspoCores.azul,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: GaspoCores.azul,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // SETA DE VOLTAR E LOGO
              const GaspoHeader(
                larguraLogo: 145,
                padding: EdgeInsets.zero,
              ),

              const SizedBox(height: 55),

              // TEXTO PRINCIPAL
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Conecte-se para acessar o aplicativo:',
                  style: TextStyle(
                    fontSize: 16,
                    color: GaspoCores.azulEscuro,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CAMPO CPF
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CPF',
                  style: TextStyle(
                    fontSize: 13,
                    color: GaspoCores.azulEscuro,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: cpfController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: _decoracaoCampo(),
              ),

              const SizedBox(height: 12),

              // CAMPO SENHA
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Senha',
                  style: TextStyle(
                    fontSize: 13,
                    color: GaspoCores.azulEscuro,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: senhaController,
                obscureText: senhaOculta,
                decoration: _decoracaoCampo(
                  suffixIcon: IconButton(
                    icon: Icon(
                      senhaOculta
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: GaspoCores.azul,
                    ),
                    onPressed: () {
                      setState(() {
                        senhaOculta = !senhaOculta;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 43),

              // BOTAO DE LOGIN
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: entrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GaspoCores.azul,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),

              const Spacer(),

              // CADASTRAR
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
                      Navigator.pushReplacementNamed(context, Rotas.cadastro);
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

              const SizedBox(height: 65),
            ],
          ),
        ),
      ),
    );
  }
}
