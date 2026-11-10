import 'package:supabase_flutter/supabase_flutter.dart';

/// Token do Supabase pronto para a API: se a sessão já expirou, renova antes de devolvê-lo.
///
/// Sem isso, ao abrir o app depois de muito tempo a primeira chamada sairia com o token velho,
/// receberia 401 e derrubaria o usuário mesmo com a renovação funcionando. Devolve `null` sem
/// sessão ou quando a renovação falha (refresh inválido); a API responde 401 e o app volta ao login.
Future<String?> tokenDaSessao({
  required Session? Function() sessao,
  required Future<void> Function() renovar,
}) async {
  final atual = sessao();
  if (atual == null) return null;
  if (!atual.isExpired) return atual.accessToken;
  try {
    await renovar();
  } on AuthException {
    return null;
  }
  return sessao()?.accessToken;
}
