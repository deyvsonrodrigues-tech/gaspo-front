import 'package:flutter/material.dart';

import '../app/tema.dart';

/// Cabeçalho padrão: seta de voltar + logo horizontal do GASPO.
///
/// Usa o logo oficial (assets/logo_gaspo_horizontal.png) no lugar do logo
/// desenhado por código que existia antes da integração.
class GaspoHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final double larguraLogo;
  final EdgeInsetsGeometry padding;

  const GaspoHeader({
    super.key,
    this.onBack,
    this.larguraLogo = 135,
    this.padding = const EdgeInsets.only(
      top: 16.0,
      bottom: 8.0,
      left: 16.0,
      right: 16.0,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          InkWell(
            onTap: onBack ?? () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.keyboard_double_arrow_left,
                size: 30,
                color: context.cores.texto,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            context.temaEscuro ? 'assets/logo_gaspo_horizontal_escuro.png' : 'assets/logo_gaspo_horizontal.png',
            width: larguraLogo,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
