import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/erro/mensagem_de_erro.dart';
import '../../domain/entities/falha_login.dart';
import '../providers/sessao_provider.dart';

/// T01: entrada no sistema. Credencial errada mostra mensagem genérica, sem dizer qual campo errou.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formulario = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  var _entrando = false;
  var _senhaVisivel = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() {
      _entrando = true;
      _erro = null;
    });
    try {
      await ref
          .read(sessaoProvider.notifier)
          .entrar(_email.text.trim(), _senha.text);
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _entrando = false;
        _erro = mensagemDeLogin(erro);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AutofillGroup(
                child: Form(
                  key: _formulario,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 96,
                            height: 96,
                            semanticLabel: 'Logo do OficinaFácil',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Entrar',
                        textAlign: TextAlign.center,
                        style: tema.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _email,
                        enabled: !_entrando,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) {
                          final texto = valor?.trim() ?? '';
                          if (texto.isEmpty) return 'Informe o e-mail';
                          if (!texto.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senha,
                        enabled: !_entrando,
                        obscureText: !_senhaVisivel,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _entrar(),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _senhaVisivel
                                ? 'Ocultar senha'
                                : 'Mostrar senha',
                            icon: Icon(
                              _senhaVisivel
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _senhaVisivel = !_senhaVisivel),
                          ),
                        ),
                        validator: (valor) => (valor == null || valor.isEmpty)
                            ? 'Informe a senha'
                            : null,
                      ),
                      if (_erro != null) ...[
                        const SizedBox(height: 16),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _erro!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: tema.colorScheme.error),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _entrando ? null : _entrar,
                        child: _entrando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Texto de erro do login. Credencial errada é genérica de propósito.
String mensagemDeLogin(Object erro) {
  return switch (erro) {
    CredenciaisInvalidas() => 'E-mail ou senha incorretos.',
    UsuarioDesativado() => 'Este usuário está desativado. Procure o gerente.',
    UsuarioSemPerfil() =>
      'Este usuário não tem perfil cadastrado. Procure o gerente.',
    _ => mensagemDeErro(erro),
  };
}
