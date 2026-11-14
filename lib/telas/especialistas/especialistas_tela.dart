import 'package:flutter/material.dart';

import '../../app/rotas.dart';
import '../../app/tema.dart';
import '../../modelos/profissional.dart';
import '../../servicos/profissional_service.dart';
import '../../utils/texto.dart';
import '../../widgets/gaspo_bottom_nav.dart';
import '../../widgets/gaspo_header.dart';

/// Lista de especialistas com busca por nome ou especialidade e filtro por
/// especialidade.
class EspecialistasTela extends StatefulWidget {
  const EspecialistasTela({super.key});

  @override
  State<EspecialistasTela> createState() => _EspecialistasTelaState();
}

class _EspecialistasTelaState extends State<EspecialistasTela> {
  final _busca = TextEditingController();

  List<Profissional> _todos = [];
  bool _carregando = true;
  bool _erro = false;
  String? _especialidade;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = false;
    });
    try {
      final lista = await ProfissionalService.instancia.listar();
      if (mounted) setState(() => _todos = lista);
    } catch (_) {
      if (mounted) setState(() => _erro = true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<String> get _especialidades => _todos.map((p) => p.especialidade).toSet().toList()..sort();

  /// Busca no nome e na especialidade, sem diferenciar acentos e maiúsculas.
  List<Profissional> get _filtrados {
    final termo = normalizarBusca(_busca.text);
    return _todos.where((p) {
      if (_especialidade != null && p.especialidade != _especialidade) return false;
      if (termo.isEmpty) return true;
      return normalizarBusca(p.nome).contains(termo) || normalizarBusca(p.especialidade).contains(termo);
    }).toList();
  }

  bool get _temFiltro => _busca.text.trim().isNotEmpty || _especialidade != null;

  void _limparFiltros() {
    _busca.clear();
    setState(() => _especialidade = null);
  }

  Widget _buildBusca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: TextField(
        controller: _busca,
        onChanged: (_) => setState(() {}),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou especialidade',
          prefixIcon: Icon(Icons.search, color: context.cores.titulo),
          suffixIcon: _busca.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpar busca',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _busca.clear();
                    setState(() {});
                  },
                ),
          filled: true,
          fillColor: context.cores.superficie,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: context.cores.borda),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: context.cores.borda),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroEspecialidade() {
    Widget chip(String rotulo, String? valor) {
      final selecionado = _especialidade == valor;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(rotulo),
          selected: selecionado,
          showCheckmark: false,
          selectedColor: GaspoCores.azul,
          backgroundColor: context.cores.superficie,
          side: BorderSide(color: selecionado ? GaspoCores.azul : context.cores.borda),
          labelStyle: TextStyle(
            fontSize: 13,
            color: selecionado ? Colors.white : context.cores.titulo,
            fontWeight: FontWeight.w500,
          ),
          onSelected: (_) => setState(() => _especialidade = valor),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 10),
      child: Row(
        children: [
          chip('Todas', null),
          for (final e in _especialidades) chip(e, e),
        ],
      ),
    );
  }

  Widget _buildItem(Profissional profissional) {
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
  }

  Widget _buildLista() {
    if (_carregando) return const Center(child: CircularProgressIndicator());
    if (_erro) {
      return Center(
        child: TextButton.icon(
          onPressed: _carregar,
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar. Tentar de novo'),
        ),
      );
    }
    if (_todos.isEmpty) {
      return Center(
        child: Text(
          'Nenhum especialista cadastrado.',
          style: TextStyle(color: context.cores.textoSecundario),
        ),
      );
    }
    final filtrados = _filtrados;
    if (filtrados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nenhum especialista encontrado.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.cores.textoSecundario),
              ),
              TextButton(onPressed: _limparFiltros, child: const Text('Limpar filtros')),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: filtrados.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: context.cores.borda),
      itemBuilder: (context, index) => _buildItem(filtrados[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _filtrados.length;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GaspoHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Especialistas',
                      style: TextStyle(
                        fontSize: 20,
                        color: context.cores.titulo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!_carregando && _temFiltro)
                    Text(
                      '$total ${total == 1 ? 'encontrado' : 'encontrados'}',
                      style: TextStyle(fontSize: 13, color: context.cores.textoSecundario),
                    ),
                ],
              ),
            ),
            _buildBusca(),
            if (_especialidades.length > 1) _buildFiltroEspecialidade(),
            Divider(height: 1, color: context.cores.borda),
            Expanded(child: _buildLista()),
          ],
        ),
      ),
      bottomNavigationBar: const GaspoBottomNav(
        currentIndex: GaspoBottomNav.inicio,
      ),
    );
  }
}
