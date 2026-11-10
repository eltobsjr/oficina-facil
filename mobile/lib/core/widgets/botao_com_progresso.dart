import 'package:flutter/material.dart';

/// Botão de ação principal que vira um indicador de progresso enquanto [carregando] e fica
/// desabilitado. O indicador leva um rótulo para leitores de tela.
class BotaoComProgresso extends StatelessWidget {
  const BotaoComProgresso({
    super.key,
    required this.rotulo,
    required this.carregando,
    required this.aoPressionar,
    this.rotuloDeProgresso = 'Salvando',
  });

  final String rotulo;
  final bool carregando;
  final VoidCallback aoPressionar;
  final String rotuloDeProgresso;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: carregando ? null : aoPressionar,
      child: carregando
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                semanticsLabel: rotuloDeProgresso,
              ),
            )
          : Text(rotulo),
    );
  }
}
