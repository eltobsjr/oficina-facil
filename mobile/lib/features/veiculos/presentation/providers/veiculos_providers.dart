import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/veiculos_repository_api.dart';
import '../../domain/entities/veiculo.dart';
import '../../domain/repositories/veiculos_repository.dart';

final veiculosRepositoryProvider = Provider<VeiculosRepository>(
  (ref) => VeiculosRepositoryApi(ref.watch(apiClientProvider)),
);

/// Veículos de um cliente.
final veiculosDoClienteProvider = FutureProvider.autoDispose
    .family<List<Veiculo>, String>(
      (ref, clienteId) =>
          ref.read(veiculosRepositoryProvider).doCliente(clienteId),
      retry: (_, _) => null,
    );

final veiculoDetalheProvider = FutureProvider.autoDispose
    .family<Veiculo, String>(
      (ref, id) => ref.read(veiculosRepositoryProvider).detalhar(id),
      retry: (_, _) => null,
    );
