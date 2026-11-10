import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'aviso_de_erro.dart';
import 'largura_maxima.dart';

/// Estrutura comum dos formulários: rolagem, largura de formulário e o espaçamento entre as
/// partes. [campos] ficam separados por [AppTheme.espacoEntreCampos], seguidos do aviso de
/// [erroGeral] se houver. Depois vêm [botaoSalvar] e, mais abaixo, as [acoes] secundárias.
class CorpoDeFormulario extends StatelessWidget {
  const CorpoDeFormulario({
    super.key,
    required this.chave,
    required this.campos,
    required this.botaoSalvar,
    this.erroGeral,
    this.acoes = const [],
  });

  final GlobalKey<FormState> chave;
  final List<Widget> campos;
  final Widget botaoSalvar;
  final String? erroGeral;
  final List<Widget> acoes;

  @override
  Widget build(BuildContext context) {
    final erro = erroGeral;
    return SingleChildScrollView(
      padding: AppTheme.margemDoFormulario,
      child: LarguraMaxima(
        largura: LarguraMaxima.formulario,
        child: Form(
          key: chave,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppTheme.espacoEntreCampos,
                children: [...campos, if (erro != null) AvisoDeErro(erro)],
              ),
              const SizedBox(height: 24),
              botaoSalvar,
              if (acoes.isNotEmpty) ...[
                const SizedBox(height: 32),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: acoes,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
