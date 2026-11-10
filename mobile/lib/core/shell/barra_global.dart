import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Barra global preta de 52 px: símbolo e nome do app à esquerda e, se houver, a conta à direita.
/// O preto avança sob a barra de status do aparelho.
class BarraGlobal extends StatelessWidget {
  const BarraGlobal({super.key, this.conta});

  final Widget? conta;

  static const altura = 52.0;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return ColoredBox(
      color: AppTheme.preto,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
        child: SizedBox(
          height: altura,
          child: Row(
            children: [
              const SizedBox(width: 20),
              const ExcludeSemantics(child: _Simbolo(tamanho: 24)),
              const SizedBox(width: 10),
              Text(
                'OficinaFácil',
                style: tema.titleSmall!.copyWith(
                  color: AppTheme.branco,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              if (conta != null) Flexible(child: conta!),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Símbolo da marca (porca sextavada com o check vazado), em branco.
class _Simbolo extends StatelessWidget {
  const _Simbolo({required this.tamanho});

  final double tamanho;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(tamanho), painter: _PintorDoSimbolo());
}

class _PintorDoSimbolo extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 256;
    final caminho = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(128 * k, 16 * k)
      ..lineTo(225 * k, 72 * k)
      ..lineTo(225 * k, 184 * k)
      ..lineTo(128 * k, 240 * k)
      ..lineTo(31 * k, 184 * k)
      ..lineTo(31 * k, 72 * k)
      ..close()
      ..moveTo(67 * k, 134 * k)
      ..lineTo(89 * k, 112 * k)
      ..lineTo(111 * k, 134 * k)
      ..lineTo(167 * k, 78 * k)
      ..lineTo(189 * k, 100 * k)
      ..lineTo(111 * k, 178 * k)
      ..close();
    canvas.drawPath(caminho, Paint()..color = AppTheme.branco);
  }

  @override
  bool shouldRepaint(covariant CustomPainter antigo) => false;
}
