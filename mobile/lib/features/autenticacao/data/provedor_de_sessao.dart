import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_exception.dart';
import '../domain/entities/falha_login.dart';

/// Porta fina para o login do Supabase, para o repositório ser testado sem rede.
abstract interface class ProvedorDeSessao {
  bool get temSessao;

  Stream<bool> get logado;

  /// Lança [CredenciaisInvalidas] ou `SemConexaoException`.
  Future<void> entrar(String email, String senha);

  Future<void> sair();
}

class SupabaseProvedorDeSessao implements ProvedorDeSessao {
  SupabaseProvedorDeSessao(this._auth);

  final GoTrueClient _auth;

  @override
  bool get temSessao => _auth.currentSession != null;

  @override
  Stream<bool> get logado =>
      _auth.onAuthStateChange.map((evento) => evento.session != null);

  @override
  Future<void> entrar(String email, String senha) async {
    try {
      await _auth.signInWithPassword(email: email, password: senha);
    } on AuthRetryableFetchException {
      throw const SemConexaoException();
    } on AuthException {
      throw const CredenciaisInvalidas();
    }
  }

  @override
  Future<void> sair() => _auth.signOut();
}
