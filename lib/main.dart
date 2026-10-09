import 'package:flutter/material.dart';

import 'dashboard.dart';

void main() {
  runApp(const GaspoApp());
}

class GaspoApp extends StatelessWidget {
  const GaspoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GASPO',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primaryColor: const Color(0xFF22703E), // Verde institucional configurado
      ),
      // O MaterialApp precisa chamar a DashboardScreen como "home"
      home: const DashboardScreen(), 
    );
  }
}