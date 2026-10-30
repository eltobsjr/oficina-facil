import 'package:flutter/material.dart';

/// Pergunta de confirmação para ações que não se desfazem. Devolve `true` se o usuário confirmar.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String rotuloConfirmar = 'Confirmar',
  bool destrutivo = false,
}) async {
  final resposta = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(contexto).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: destrutivo
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(contexto).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.of(contexto).pop(true),
          child: Text(rotuloConfirmar),
        ),
      ],
    ),
  );
  return resposta ?? false;
}
