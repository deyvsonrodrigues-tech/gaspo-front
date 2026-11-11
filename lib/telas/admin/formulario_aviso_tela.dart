import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../modelos/aviso.dart';
import '../../servicos/aviso_service.dart';
import '../../utils/mensagens.dart';
import '../../widgets/gaspo_header.dart';

/// Publicação (sem [aviso]) ou atualização de um aviso
/// (formulário da Letícia, `AdminCreateScreen`).
/// Ao salvar, volta com a mensagem de sucesso para a tela anterior mostrar.
class FormularioAvisoTela extends StatefulWidget {
  final Aviso? aviso;

  /// Permite injetar outra implementação (ex.: nos testes).
  final AvisoService? service;

  const FormularioAvisoTela({super.key, this.aviso, this.service});

  @override
  State<FormularioAvisoTela> createState() => _FormularioAvisoTelaState();
}

class _FormularioAvisoTelaState extends State<FormularioAvisoTela> {
  late final AvisoService _service = widget.service ?? AvisoService.instancia;
  final _formKey = GlobalKey<FormState>();

  late final _titulo = TextEditingController(text: widget.aviso?.titulo);
  late final _mensagem = TextEditingController(text: widget.aviso?.mensagem);
  late bool _ativo = widget.aviso?.ativo ?? true;
  bool _salvando = false;

  bool get _editando => widget.aviso != null;

  @override
  void dispose() {
    _titulo.dispose();
    _mensagem.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final dados = DadosAviso(
      titulo: _titulo.text,
      mensagem: _mensagem.text,
      ativo: _ativo,
    );

    setState(() => _salvando = true);
    try {
      if (_editando) {
        await _service.editar(widget.aviso!.id, dados);
      } else {
        await _service.publicar(dados);
      }
      if (!mounted) return;
      Navigator.pop(
        context,
        _editando ? 'Aviso atualizado.' : 'Aviso publicado.',
      );
    } on AvisoException catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      mostrarMensagem(context, e.mensagem);
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      mostrarMensagem(
        context,
        'Não foi possível salvar o aviso. Tente novamente.',
      );
    }
  }

  InputDecoration _decoracao(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: context.cores.superficie,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GaspoHeader(),
                  const SizedBox(height: 8),
                  Text(
                    'Avisos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.cores.tituloForte,
                    ),
                  ),
                  Text(
                    'Publique comunicados e acompanhe-os',
                    style: TextStyle(color: context.cores.textoFraco, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Sombra do layout original; o fundo branco fica num Material
                  // para o efeito de toque do interruptor aparecer.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: context.cores.superficie,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _editando ? 'Atualizar Aviso' : 'Novo Aviso',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Título',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _titulo,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: _decoracao('Ex: Vacinação'),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Informe o título.'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Mensagem',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _mensagem,
                                maxLines: 5,
                                maxLength:
                                    AvisoServiceLocal.tamanhoMaximoMensagem,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: _decoracao(
                                  'Digite o conteúdo do aviso',
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Informe a mensagem.'
                                    : null,
                              ),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                value: _ativo,
                                activeTrackColor: GaspoCores.azul,
                                title: const Text(
                                  'Visível para os pacientes',
                                  style: TextStyle(fontSize: 14),
                                ),
                                subtitle: const Text(
                                  'Desligue para ocultar sem apagar.',
                                  style: TextStyle(fontSize: 12),
                                ),
                                onChanged: (valor) =>
                                    setState(() => _ativo = valor),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: GaspoCores.azul,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed: _salvando ? null : _salvar,
                                  child: _salvando
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          _editando ? 'Salvar' : 'Publicar',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
