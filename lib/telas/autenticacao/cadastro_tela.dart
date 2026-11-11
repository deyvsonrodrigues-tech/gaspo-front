import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../utils/mensagens.dart';
import '../../utils/validadores.dart';
import '../../widgets/campos_formulario.dart';
import '../../widgets/gaspo_header.dart';

/// Cadastro de paciente. Os campos seguem o UsuarioCadastroDTO da API
/// (nome, CPF, data de nascimento, telefone, e-mail e senha).
class CadastroTela extends StatefulWidget {
  const CadastroTela({super.key});

  static const int tamanhoMinimoSenha = 6;

  @override
  State<CadastroTela> createState() => _CadastroTelaState();
}

class _CadastroTelaState extends State<CadastroTela> {
  final _formKey = GlobalKey<FormState>();

  final nome = TextEditingController();
  final nascimento = TextEditingController();
  final cpf = TextEditingController();
  final email = TextEditingController();
  final telefone = TextEditingController();
  final senha = TextEditingController();
  final confirmarSenha = TextEditingController();

  final _mascaraData = mascaraData();
  final _mascaraCpf = mascaraCpf();
  final _mascaraTelefone = mascaraTelefone();

  bool mostrarSenha = false;

  @override
  void dispose() {
    nome.dispose();
    nascimento.dispose();
    cpf.dispose();
    email.dispose();
    telefone.dispose();
    senha.dispose();
    confirmarSenha.dispose();
    super.dispose();
  }

  // BOTÃO CRIAR CONTA
  void cadastrar() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: enviar para /api/pacientes/cadastro quando a API estiver disponível.
    mostrarMensagem(context, 'Cadastro em desenvolvimento!');
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) return 'Crie uma senha.';
    if (valor.length < CadastroTela.tamanhoMinimoSenha) {
      return 'Use pelo menos ${CadastroTela.tamanhoMinimoSenha} caracteres.';
    }
    return null;
  }

  String? _validarConfirmacao(String? valor) {
    if (valor == null || valor.isEmpty) return 'Repita a senha.';
    return valor == senha.text ? null : 'As senhas não coincidem.';
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 16, color: GaspoCores.azulTitulo, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _campoSenha(TextEditingController controller, String label, FormFieldValidator<String> validator,
      {TextInputAction acao = TextInputAction.next}) {
    return TextFormField(
      controller: controller,
      obscureText: !mostrarSenha,
      textInputAction: acao,
      onFieldSubmitted: acao == TextInputAction.done ? (_) => cadastrar() : null,
      style: const TextStyle(fontSize: 16),
      decoration: decoracaoCampo(label, Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          tooltip: mostrarSenha ? 'Ocultar senhas' : 'Mostrar senhas',
          icon: Icon(
            mostrarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: GaspoCores.azulTitulo,
          ),
          onPressed: () => setState(() => mostrarSenha = !mostrarSenha),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    const espaco = SizedBox(height: 16);

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

                    // LOGO E SETA DE VOLTAR
                    const GaspoHeader(larguraLogo: 145, padding: EdgeInsets.zero),

                    const SizedBox(height: 32),
                    const Text(
                      'Criar conta',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: GaspoCores.azulEscuro),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Com a conta você agenda consultas e acompanha os avisos da sua unidade.',
                      style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    _secao('Seus dados'),
                    TextFormField(
                      controller: nome,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      style: const TextStyle(fontSize: 16),
                      decoration: decoracaoCampo('Nome completo', Icons.person_outline),
                      validator: (v) => validarObrigatorio(v, 'Informe seu nome.'),
                    ),
                    espaco,
                    TextFormField(
                      controller: nascimento,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [_mascaraData],
                      style: const TextStyle(fontSize: 16),
                      decoration: decoracaoCampo('Data de nascimento', Icons.cake_outlined)
                          .copyWith(hintText: 'dd/mm/aaaa'),
                      validator: validarDataNascimento,
                    ),
                    espaco,
                    TextFormField(
                      controller: cpf,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [_mascaraCpf],
                      style: const TextStyle(fontSize: 16),
                      decoration: decoracaoCampo('CPF', Icons.badge_outlined)
                          .copyWith(hintText: '000.000.000-00'),
                      validator: validarCpf,
                    ),
                    espaco,
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      style: const TextStyle(fontSize: 16),
                      decoration: decoracaoCampo('E-mail', Icons.mail_outline),
                      validator: validarEmail,
                    ),
                    espaco,
                    TextFormField(
                      controller: telefone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [_mascaraTelefone],
                      style: const TextStyle(fontSize: 16),
                      decoration: decoracaoCampo('Telefone (opcional)', Icons.phone_outlined)
                          .copyWith(hintText: '(00) 00000-0000'),
                      validator: validarTelefone,
                    ),
                    const SizedBox(height: 24),

                    _secao('Sua senha'),
                    _campoSenha(senha, 'Senha', _validarSenha),
                    const Padding(
                      padding: EdgeInsets.only(left: 12, top: 6),
                      child: Text(
                        'Pelo menos ${CadastroTela.tamanhoMinimoSenha} caracteres.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                    espaco,
                    _campoSenha(confirmarSenha, 'Confirmar senha', _validarConfirmacao,
                        acao: TextInputAction.done),
                    const SizedBox(height: 28),

                    // BOTÃO CRIAR CONTA
                    BotaoPrincipal(texto: 'Criar conta', onPressed: cadastrar),
                    const SizedBox(height: 16),

                    // JÁ TEM CONTA
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Já possui uma conta?',
                            style: TextStyle(fontSize: 14, color: GaspoCores.azulEscuro),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, Rotas.login),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GaspoCores.azul),
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
