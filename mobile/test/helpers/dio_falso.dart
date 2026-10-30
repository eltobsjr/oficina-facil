import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Resposta combinada para um caminho.
class RespostaFalsa {
  const RespostaFalsa(this.status, [this.corpo]);

  final int status;
  final Object? corpo;
}

/// Adaptador de `dio` sem rede: devolve respostas por "MÉTODO /caminho" e registra as chamadas.
class AdaptadorFalso implements HttpClientAdapter {
  AdaptadorFalso(this.respostas, {this.semRede = false});

  final Map<String, RespostaFalsa> respostas;
  final bool semRede;
  final List<RequestOptions> chamadas = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    chamadas.add(options);
    if (semRede) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    final chave = '${options.method} ${options.path}';
    final resposta = respostas[chave];
    if (resposta == null) {
      throw StateError('Chamada não prevista no teste: $chave');
    }
    return ResponseBody.fromString(
      jsonEncode(resposta.corpo ?? {}),
      resposta.status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
