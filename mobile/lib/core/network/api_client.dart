import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Cliente HTTP da API do backend. Anexa o token do Supabase quando há sessão.
class ApiClient {
  ApiClient({
    required String baseUrl,
    Future<String?> Function()? token,
    Dio? dio,
  }) : _baseUrl = baseUrl,
       dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 20)
      // As respostas de erro da API têm corpo próprio; quem chama decide o que fazer.
      ..validateStatus = (_) => true;
    if (token != null) {
      this.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final valor = await token();
            if (valor != null) {
              options.headers['Authorization'] = 'Bearer $valor';
            }
            handler.next(options);
          },
        ),
      );
    }
  }

  final String _baseUrl;
  final Dio dio;

  /// `/health` fica na raiz do servidor, fora de `/api/v1`.
  Future<bool> saude() async {
    try {
      final raiz = Uri.parse(_baseUrl).origin;
      final resposta = await dio.get<dynamic>('$raiz/health');
      return resposta.statusCode == 200;
    } on DioException {
      return false;
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: AppConfig.apiUrl,
    token: () async =>
        Supabase.instance.client.auth.currentSession?.accessToken,
  );
});

/// Estado do servidor: `true` quando `/health` responde 200.
final apiSaudeProvider = FutureProvider<bool>((ref) {
  return ref.watch(apiClientProvider).saude();
});
