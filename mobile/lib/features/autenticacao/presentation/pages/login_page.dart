import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/erro/mensagem_de_erro.dart';
import '../../../../core/shell/moldura_de_entrada.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/validacao/validadores.dart';
import '../../../../core/widgets/aviso_de_erro.dart';
import '../../../../core/widgets/botao_com_progresso.dart';
import '../../../../core/widgets/campo_rotulado.dart';
import '../../../../core/widgets/largura_maxima.dart';
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
    return MolduraDeEntrada(
      filho: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: LarguraMaxima(
            largura: 400,
            child: AutofillGroup(
              child: Form(
                key: _formulario,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 88,
                          height: 88,
                          semanticLabel: 'Logo do OficinaFácil',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Entrar',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    CampoRotulado(
                      rotulo: 'E-mail',
                      child: TextFormField(
                        controller: _email,
                        enabled: !_entrando,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        validator: Validadores.emailObrigatorio,
                      ),
                    ),
                    const SizedBox(height: AppTheme.espacoEntreCampos),
                    CampoRotulado(
                      rotulo: 'Senha',
                      child: TextFormField(
                        controller: _senha,
                        enabled: !_entrando,
                        obscureText: !_senhaVisivel,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _entrar(),
                        decoration: InputDecoration(
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
                        validator: Validadores.obrigatorio(
                          'Informe a senha',
                          aparar: false,
                        ),
                      ),
                    ),
                    if (_erro != null) ...[
                      const SizedBox(height: AppTheme.espacoEntreCampos),
                      AvisoDeErro(_erro!),
                    ],
                    const SizedBox(height: 24),
                    BotaoComProgresso(
                      rotulo: 'Entrar',
                      rotuloDeProgresso: 'Entrando',
                      carregando: _entrando,
                      aoPressionar: _entrar,
                    ),
                  ],
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
