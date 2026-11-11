import 'package:flutter/material.dart';

import '../app/tema.dart';
import '../modelos/consulta.dart';
import '../utils/formatadores.dart';

/// Rótulo e cor de cada status nas telas de consultas (Histórico e Painel).
///
/// "Finalizada" aparece como "Realizada", como na proposta de interface.
extension StatusConsultaVisual on StatusConsulta {
  String get rotuloTela => switch (this) {
        StatusConsulta.agendada => 'Agendada',
        StatusConsulta.confirmada => 'Confirmada',
        StatusConsulta.finalizada => 'Realizada',
        StatusConsulta.cancelada => 'Cancelada',
      };

  Color get cor => switch (this) {
        StatusConsulta.agendada => GaspoCores.statusAgendada,
        StatusConsulta.confirmada => GaspoCores.azulCabecalho,
        StatusConsulta.finalizada => GaspoCores.statusRealizada,
        StatusConsulta.cancelada => GaspoCores.statusCancelada,
      };
}

/// Uma opção da barra de filtros: rótulo, cor e os status que ela mostra
/// (vazio = todas).
class FiltroConsulta {
  final String rotulo;
  final Color cor;
  final Set<StatusConsulta> status;

  const FiltroConsulta(this.rotulo, this.cor, this.status);

  static const todas = FiltroConsulta('Todas', GaspoCores.azul, {});

  bool aceita(Consulta consulta) => status.isEmpty || status.contains(consulta.status);
}

/// Barra de filtros coloridos ("Todas", "Realizadas", ...).
class BarraFiltrosConsulta extends StatelessWidget {
  final List<FiltroConsulta> filtros;
  final FiltroConsulta selecionado;
  final ValueChanged<FiltroConsulta> onSelecionar;

  const BarraFiltrosConsulta({
    super.key,
    required this.filtros,
    required this.selecionado,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Todos os filtros sempre visíveis: dividem a largura e o texto
      // encolhe em telas estreitas, como na proposta de interface.
      child: Row(
        children: [
          for (final filtro in filtros)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _ChipFiltro(
                  filtro: filtro,
                  ativo: filtro == selecionado,
                  onTap: () => onSelecionar(filtro),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  final FiltroConsulta filtro;
  final bool ativo;
  final VoidCallback onTap;

  const _ChipFiltro({required this.filtro, required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Ativo: preenchido com a cor do status. Inativo: só o contorno, para
    // deixar claro qual filtro está aplicado.
    return Semantics(
      selected: ativo,
      button: true,
      child: Material(
        color: ativo ? filtro.cor : filtro.cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                filtro.rotulo,
                maxLines: 1,
                style: TextStyle(
                  color: ativo ? Colors.white : filtro.cor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão de uma consulta: ícone de calendário à esquerda, data em destaque,
/// profissional, especialidade, horário e status.
class CartaoConsulta extends StatelessWidget {
  final Consulta consulta;
  final VoidCallback? onTap;

  const CartaoConsulta({super.key, required this.consulta, this.onTap});

  static const double _raioIcone = 22;

  @override
  Widget build(BuildContext context) {
    final hora = formatarHora(TimeOfDay.fromDateTime(consulta.dataHora));
    final especialidade = consulta.especialidadeProfissional;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Cartão deslocado para o ícone ficar metade para fora.
          Padding(
            padding: const EdgeInsets.only(left: _raioIcone),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: GaspoCores.azulCabecalho, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(_raioIcone + 14, 12, 14, 12),
                  child: Row(
                    children: [
                      _SeloData(data: consulta.dataHora),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              consulta.nomeProfissional,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              especialidade == null ? hora : '$especialidade • $hora',
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              consulta.status.rotuloTela.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: consulta.status.cor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onTap != null)
                        const Icon(Icons.chevron_right, color: Colors.black38),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const CircleAvatar(
            radius: _raioIcone,
            backgroundColor: GaspoCores.azulCabecalho,
            child: Icon(Icons.calendar_month_outlined, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}

class _SeloData extends StatelessWidget {
  final DateTime data;
  const _SeloData({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: GaspoCores.botaoSecundarioFundo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            mesAbreviado(data),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: GaspoCores.azulTitulo,
            ),
          ),
          Text(
            data.day.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: GaspoCores.azulTitulo,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mensagem centralizada para lista vazia.
class ListaConsultasVazia extends StatelessWidget {
  final String mensagem;
  const ListaConsultasVazia({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.event_busy_outlined, size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/// Linha "rótulo: valor" dos detalhes da consulta.
class LinhaDetalheConsulta extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const LinhaDetalheConsulta({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: GaspoCores.azul),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              rotulo,
              style: const TextStyle(fontWeight: FontWeight.w600, color: GaspoCores.azulTitulo),
            ),
          ),
          Expanded(child: Text(valor, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}

/// Detalhes comuns (profissional, data, horário, unidade e status).
List<Widget> detalhesConsulta(Consulta consulta) => [
      LinhaDetalheConsulta(
        icone: Icons.person_outline,
        rotulo: 'Profissional',
        valor: consulta.nomeProfissional,
      ),
      if (consulta.especialidadeProfissional != null)
        LinhaDetalheConsulta(
          icone: Icons.medical_services_outlined,
          rotulo: 'Especialidade',
          valor: consulta.especialidadeProfissional!,
        ),
      LinhaDetalheConsulta(
        icone: Icons.calendar_today_outlined,
        rotulo: 'Data',
        valor: formatarData(consulta.dataHora),
      ),
      LinhaDetalheConsulta(
        icone: Icons.access_time,
        rotulo: 'Horário',
        valor: formatarHora(TimeOfDay.fromDateTime(consulta.dataHora)),
      ),
      if (consulta.nomeUnidade != null)
        LinhaDetalheConsulta(
          icone: Icons.local_hospital_outlined,
          rotulo: 'Unidade',
          valor: consulta.nomeUnidade!,
        ),
      LinhaDetalheConsulta(
        icone: Icons.info_outline,
        rotulo: 'Status',
        valor: consulta.status.rotuloTela,
      ),
    ];
