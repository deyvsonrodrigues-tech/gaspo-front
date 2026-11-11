import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../modelos/perfil_acesso.dart';
import '../../utils/validadores.dart';
import '../../widgets/campos_formulario.dart';
import '../../widgets/gaspo_header.dart';

class LoginTela extends StatefulWidget {
  final PerfilAcesso perfil;

  const LoginTela({super.key, this.perfil = PerfilAcesso.usuario});

  @override
  State<LoginTela> createState() => _LoginTelaState();
}

class _LoginTelaState extends State<LoginTela> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final _mascaraCpf = mascaraCpf();

  bool senhaOculta = true;

  bool get _funcionario => widget.perfil == PerfilAcesso.funcionario;

  @override
  void dispose() {
    cpfController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void entrar() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: autenticar CPF e senha quando a API estiver disponível
    // (hoje o login da API usa e-mail; precisa passar a aceitar CPF).
    // Funcionário vai para o Painel Admin; paciente, para o Início.
    final destino = _funcionario ? Rotas.painelFuncionario : Rotas.home;
    Navigator.pushNamedAndRemoveUntil(context, destino, (_) => false);
  }

  /// Indica por qual perfil a pessoa está entrando (escolhido na Entrada).
  Widget _seloPerfil() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: GaspoCores.azul.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _funcionario ? Icons.badge_outlined : Icons.person_outline,
            size: 18,
            color: context.cores.destaque,
          ),
          const SizedBox(width: 6),
          Text(
            _funcionario ? 'Acesso do funcionário' : 'Acesso do paciente',
            style: TextStyle(fontSize: 13, color: context.cores.destaque, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // SETA DE VOLTAR E LOGO
                    const GaspoHeader(larguraLogo: 145, padding: EdgeInsets.zero),

                    const SizedBox(height: 40),
                    _seloPerfil(),
                    const SizedBox(height: 14),
                    Text(
                      'Entrar',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: context.cores.tituloForte),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Informe seu CPF e sua senha para acessar o aplicativo.',
                      style: TextStyle(fontSize: 15, color: context.cores.textoSecundario, height: 1.4),
                    ),
                    const SizedBox(height: 28),

                    // CAMPO CPF
                    TextFormField(
                      controller: cpfController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [_mascaraCpf],
                      style: const TextStyle(fontSize: 16),
                      decoration: decoracaoCampo(context, 'CPF', Icons.badge_outlined)
                          .copyWith(hintText: '000.000.000-00'),
                      validator: validarCpf,
                    ),
                    const SizedBox(height: 16),

                    // CAMPO SENHA
                    TextFormField(
                      controller: senhaController,
                      obscureText: senhaOculta,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => entrar(),
                      style: const TextStyle(fontSize: 16),
                      decoration: decoracaoCampo(context, 'Senha', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          tooltip: senhaOculta ? 'Mostrar senha' : 'Ocultar senha',
                          icon: Icon(
                            senhaOculta ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: context.cores.titulo,
                          ),
                          onPressed: () => setState(() => senhaOculta = !senhaOculta),
                        ),
                      ),
                      validator: (v) => validarObrigatorio(v, 'Informe sua senha.'),
                    ),
                    const SizedBox(height: 28),

                    // BOTÃO DE ENTRAR
                    BotaoPrincipal(texto: 'Entrar', onPressed: entrar),
                    const SizedBox(height: 32),

                    // CRIAR CONTA (só pacientes criam conta pelo app)
                    if (!_funcionario)
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Ainda não tem uma conta?',
                              style: TextStyle(fontSize: 14, color: context.cores.tituloForte),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, Rotas.cadastro),
                              child: Text(
                                'Criar conta',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: context.cores.destaque,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
