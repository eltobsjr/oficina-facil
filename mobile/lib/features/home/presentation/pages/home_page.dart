import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/status_chips.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _base = Color(0xFF0E2238);

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.marca, _base],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 132,
                        height: 132,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'OficinaFácil',
                      style: texto.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Da entrada do veículo à entrega, cada ordem de serviço no seu lugar.',
                      textAlign: TextAlign.center,
                      style: texto.titleMedium?.copyWith(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const StatusChips(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
