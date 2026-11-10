import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'barra_global.dart';

/// Moldura das telas sem sessão (login, carregando, sem conexão): fundo branco e a barra global.
class MolduraDeEntrada extends StatelessWidget {
  const MolduraDeEntrada({super.key, required this.filho});

  final Widget filho;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.branco,
      body: Column(
        children: [
          const BarraGlobal(),
          Expanded(child: SafeArea(top: false, child: filho)),
        ],
      ),
    );
  }
}
