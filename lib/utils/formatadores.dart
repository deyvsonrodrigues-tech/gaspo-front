import 'package:flutter/material.dart';

String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');

/// 10/11/2026
String formatarData(DateTime data) =>
    '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}/${data.year}';

/// 08:30
String formatarHora(TimeOfDay hora) =>
    '${_doisDigitos(hora.hour)}:${_doisDigitos(hora.minute)}';
