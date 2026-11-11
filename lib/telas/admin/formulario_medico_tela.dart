import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../dados/dados_exemplo.dart';
import '../../modelos/profissional.dart';
import '../../servicos/profissional_service.dart';
import '../../utils/mensagens.dart';
import '../../utils/validadores.dart';
import '../../widgets/campos_formulario.dart';
import '../../widgets/gaspo_header.dart';

/// Cadastro (sem [profissional]) ou edição de um médico.
/// Ao salvar, volta com a mensagem de sucesso para a tela anterior mostrar.
class FormularioMedicoTela extends StatefulWidget {
  final Profissional? profissional;

  /// Permite injetar outra implementação (ex.: nos testes).
  final ProfissionalService? service;

  const FormularioMedicoTela({super.key, this.profissional, this.service});

  @override
  State<FormularioMedicoTela> createState() => _FormularioMedicoTelaState();
}

class _FormularioMedicoTelaState extends State<FormularioMedicoTela> {
  late final ProfissionalService _service = widget.service ?? ProfissionalService.instancia;
  final _formKey = GlobalKey<FormState>();

  late final _nome = TextEditingController(text: widget.profissional?.nome);
  late final _especialidade = TextEditingController(text: widget.profissional?.especialidade);
  late final _email = TextEditingController(text: widget.profissional?.email);
  late final _telefone = TextEditingController(text: widget.profissional?.telefone);

  final _mascaraTelefone = mascaraTelefone();

  late StatusProfissional _status = widget.profissional?.status ?? StatusProfissional.presente;
  late bool _atendeNaUnidade = widget.profissional == null || widget.profissional!.unidade != null;
  bool _salvando = false;

  bool get _editando => widget.profissional != null;

  @override
  void dispose() {
    _nome.dispose();
    _especialidade.dispose();
    _email.dispose();
    _telefone.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? valor, String campo) =>
      (valor == null || valor.trim().isEmpty) ? 'Informe $campo.' : null;

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final dados = DadosProfissional(
      nome: _nome.text,
      especialidade: _especialidade.text,
      email: _email.text,
      telefone: _telefone.text,
      status: _status,
      unidade: _atendeNaUnidade ? unidadeSaude : null,
    );

    setState(() => _salvando = true);
    try {
      final salvo = _editando
          ? await _service.atualizar(widget.profissional!.id, dados)
          : await _service.cadastrar(dados);
      if (!mounted) return;
      Navigator.pop(context, _editando ? 'Dados de ${salvo.nome} atualizados.' : '${salvo.nome} foi cadastrado.');
    } on ProfissionalException catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      mostrarMensagem(context, e.mensagem);
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      mostrarMensagem(context, 'Não foi possível salvar. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GaspoHeader(),
                    const SizedBox(height: 12),
                    Text(
                      _editando ? 'Editar médico' : 'Novo médico',
                      style: TextStyle(fontSize: 19, color: context.cores.titulo, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Campos com * são obrigatórios.',
                      style: TextStyle(fontSize: 13, color: context.cores.textoSecundario),
                    ),
                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _nome,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: decoracaoCampo(context, 'Nome completo *', Icons.person_outline)
                          .copyWith(hintText: 'Ex.: Dra. Ana Souza'),
                      validator: (v) => _obrigatorio(v, 'o nome'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _especialidade,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: decoracaoCampo(context, 'Especialidade *', Icons.medical_services_outlined)
                          .copyWith(hintText: 'Ex.: Cardiologista'),
                      validator: (v) => _obrigatorio(v, 'a especialidade'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: decoracaoCampo(context, 'E-mail', Icons.mail_outline),
                      validator: (v) => validarEmail(v, obrigatorio: false),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _telefone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_mascaraTelefone],
                      decoration: decoracaoCampo(context, 'Telefone', Icons.phone_outlined)
                          .copyWith(hintText: '(00) 00000-0000'),
                      validator: validarTelefone,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<StatusProfissional>(
                      initialValue: _status,
                      icon: Icon(Icons.arrow_drop_down, color: context.cores.titulo),
                      decoration: decoracaoCampo(context, 'Status', Icons.work_outline),
                      items: [
                        for (final s in StatusProfissional.values)
                          DropdownMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 10, color: s.cor),
                                const SizedBox(width: 8),
                                Text(s.rotulo, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (s) => setState(() => _status = s ?? _status),
                    ),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _atendeNaUnidade,
                      activeTrackColor: GaspoCores.azul,
                      title: const Text('Atende na Unidade de Saúde', style: TextStyle(fontSize: 14)),
                      subtitle: Text(unidadeSaude.endereco, style: const TextStyle(fontSize: 12)),
                      onChanged: (valor) => setState(() => _atendeNaUnidade = valor),
                    ),
                    const SizedBox(height: 20),

                    BotaoPrincipal(
                      texto: _editando ? 'Salvar alterações' : 'Cadastrar médico',
                      carregando: _salvando,
                      onPressed: _salvar,
                    ),
                    const SizedBox(height: 20),
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
