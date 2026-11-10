import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/network/token_da_sessao.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String _jwt({required int exp}) {
  String parte(Map<String, Object> dados) =>
      base64Url.encode(utf8.encode(jsonEncode(dados))).replaceAll('=', '');
  return '${parte({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${parte({'sub': 'u1', 'role': 'authenticated', 'exp': exp})}.x';
}

Session _sessao(String token) => Session(
  accessToken: token,
  tokenType: 'bearer',
  user: const User(
    id: 'u1',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-01-01T00:00:00Z',
  ),
);

int _agora() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

void main() {
  group('tokenDaSessao', () {
    test('sem sessão devolve null e não tenta renovar', () async {
      var renovou = false;
      final token = await tokenDaSessao(
        sessao: () => null,
        renovar: () async => renovou = true,
      );
      expect(token, isNull);
      expect(renovou, isFalse);
    });

    test('sessão válida devolve o token sem renovar', () async {
      final valido = _jwt(exp: _agora() + 3600);
      var renovou = false;
      final token = await tokenDaSessao(
        sessao: () => _sessao(valido),
        renovar: () async => renovou = true,
      );
      expect(token, valido);
      expect(renovou, isFalse);
    });

    test('sessão expirada renova antes e devolve o token novo', () async {
      final velho = _jwt(exp: 1);
      final novo = _jwt(exp: _agora() + 3600);
      var atual = _sessao(velho);
      final token = await tokenDaSessao(
        sessao: () => atual,
        renovar: () async => atual = _sessao(novo),
      );
      expect(token, novo);
    });

    test('sessão expirada com refresh inválido devolve null', () async {
      final token = await tokenDaSessao(
        sessao: () => _sessao(_jwt(exp: 1)),
        renovar: () async => throw const AuthException('refresh inválido'),
      );
      expect(token, isNull);
    });
  });
}
