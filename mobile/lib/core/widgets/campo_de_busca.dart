import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Busca em pílula de 44 px, com lupa à esquerda e a dica como rótulo.
class CampoDeBusca extends StatelessWidget {
  const CampoDeBusca({
    super.key,
    required this.controller,
    required this.dica,
    required this.aoMudar,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String dica;
  final ValueChanged<String> aoMudar;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder borda(Color cor, double largura) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide(color: cor, width: largura),
    );
    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: aoMudar,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: dica,
        prefixIcon: const Icon(Icons.search),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        isDense: true,
        constraints: const BoxConstraints(minHeight: 44),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 9.5,
        ),
        border: borda(AppTheme.filete, 1),
        enabledBorder: borda(AppTheme.filete, 1),
        focusedBorder: borda(AppTheme.acaoFoco, 2),
      ),
    );
  }
}

/// Espera o usuário parar de digitar para não consultar a cada letra.
const esperaDaBusca = Duration(milliseconds: 400);

/// [CampoDeBusca] que só avisa em [aoBuscar] depois de [esperaDaBusca] sem digitar.
/// [textoInicial] mostra a busca que continua aplicada ao voltar para a tela.
class CampoDeBuscaComEspera extends StatefulWidget {
  const CampoDeBuscaComEspera({
    super.key,
    required this.dica,
    required this.aoBuscar,
    this.textoInicial = '',
    this.autofocus = false,
  });

  final String dica;
  final ValueChanged<String> aoBuscar;
  final String textoInicial;
  final bool autofocus;

  @override
  State<CampoDeBuscaComEspera> createState() => _CampoDeBuscaComEsperaState();
}

class _CampoDeBuscaComEsperaState extends State<CampoDeBuscaComEspera> {
  late final _controller = TextEditingController(text: widget.textoInicial);
  Timer? _espera;

  @override
  void dispose() {
    _espera?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _aoDigitar(String texto) {
    _espera?.cancel();
    _espera = Timer(esperaDaBusca, () => widget.aoBuscar(texto));
  }

  @override
  Widget build(BuildContext context) {
    return CampoDeBusca(
      controller: _controller,
      autofocus: widget.autofocus,
      aoMudar: _aoDigitar,
      dica: widget.dica,
    );
  }
}
