import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

/// Indicador discreto de conexão com o servidor (chama `GET /health`).
class ApiStatus extends ConsumerWidget {
  const ApiStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saude = ref.watch(apiSaudeProvider);
    final texto = switch (saude) {
      AsyncData(:final value) =>
        value ? 'Servidor conectado' : 'Servidor indisponível',
      AsyncError() => 'Servidor indisponível',
      _ => 'Verificando servidor…',
    };
    return Text(
      texto,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: Colors.white54),
    );
  }
}
