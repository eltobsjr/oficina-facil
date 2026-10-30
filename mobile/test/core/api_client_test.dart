import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/config/app_config.dart';
import 'package:oficina_facil/core/network/api_client.dart';
import 'package:oficina_facil/core/relogio.dart';

/// Adaptador falso: registra a requisição e devolve o status combinado, sem rede.
class _AdaptadorFalso implements HttpClientAdapter {
  _AdaptadorFalso(this.status);

  final int status;
  RequestOptions? ultima;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    ultima = options;
    return ResponseBody.fromString('{}', status);
  }

  @override
  void close({bool force = false}) {}
}

class _RelogioFixo implements Relogio {
  @override
  DateTime agora() => DateTime(2026, 11, 2, 9, 30);
}

void main() {
  group('ApiClient', () {
    test(
      'saude() chama /health na raiz do servidor, fora de /api/v1',
      () async {
        final adaptador = _AdaptadorFalso(200);
        final cliente = ApiClient(
          baseUrl: 'http://localhost:3000/api/v1',
          dio: Dio()..httpClientAdapter = adaptador,
        );

        expect(await cliente.saude(), isTrue);
        expect(
          adaptador.ultima?.uri.toString(),
          'http://localhost:3000/health',
        );
      },
    );

    test('saude() é falso quando o servidor responde 503', () async {
      final cliente = ApiClient(
        baseUrl: 'http://localhost:3000/api/v1',
        dio: Dio()..httpClientAdapter = _AdaptadorFalso(503),
      );

      expect(await cliente.saude(), isFalse);
    });

    test('anexa o token do Supabase quando há sessão', () async {
      final adaptador = _AdaptadorFalso(200);
      final cliente = ApiClient(
        baseUrl: 'http://localhost:3000/api/v1',
        token: () async => 'token-de-teste',
        dio: Dio()..httpClientAdapter = adaptador,
      );

      await cliente.dio.get<dynamic>('/me');

      expect(
        adaptador.ultima?.headers['Authorization'],
        'Bearer token-de-teste',
      );
    });

    test('não envia Authorization sem sessão', () async {
      final adaptador = _AdaptadorFalso(200);
      final cliente = ApiClient(
        baseUrl: 'http://localhost:3000/api/v1',
        token: () async => null,
        dio: Dio()..httpClientAdapter = adaptador,
      );

      await cliente.dio.get<dynamic>('/me');

      expect(adaptador.ultima?.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('AppConfig', () {
    test('recusa iniciar sem a configuração e explica como resolver', () {
      expect(
        AppConfig.validar,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'mensagem',
            contains('--dart-define-from-file=env.json'),
          ),
        ),
      );
    });
  });

  group('Relogio', () {
    test('o relógio do sistema devolve um instante próximo de agora', () {
      final antes = DateTime.now();
      final lido = const RelogioSistema().agora();
      expect(lido.difference(antes).inSeconds.abs(), lessThan(2));
    });

    test('um relógio injetado permite fixar a data nos testes', () {
      final Relogio relogio = _RelogioFixo();
      expect(relogio.agora(), DateTime(2026, 11, 2, 9, 30));
    });
  });
}
