import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Calendário, relógio e textos padrão do Material em português.
const Locale localeGaspo = Locale('pt', 'BR');

const List<LocalizationsDelegate<dynamic>> delegatesGaspo = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
