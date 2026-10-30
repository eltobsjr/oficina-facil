import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fonte de data e hora injetável: nenhuma regra usa `DateTime.now()` direto, para poder testar.
abstract interface class Relogio {
  DateTime agora();
}

class RelogioSistema implements Relogio {
  const RelogioSistema();

  @override
  DateTime agora() => DateTime.now();
}

final relogioProvider = Provider<Relogio>((ref) => const RelogioSistema());
