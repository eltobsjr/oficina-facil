/// Configuração do app, lida em tempo de compilação por `--dart-define-from-file=env.json`.
///
/// Só a chave publicável do Supabase pode estar aqui; a chave de serviço existe apenas no backend.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Base da API, já com `/api/v1`. No emulador Android use `http://10.0.2.2:3000/api/v1`.
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  /// Falha cedo, com instrução clara, se o app foi iniciado sem a configuração.
  static void validar() {
    if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
      throw StateError(
        'Configuração ausente. Rode com --dart-define-from-file=env.json '
        '(copie env.example.json para env.json e preencha).',
      );
    }
  }
}
