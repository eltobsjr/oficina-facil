import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/erro/mensagem_de_erro.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/perfil.dart';
import '../../../../core/router/redirecionamento.dart';
import '../../../../core/widgets/confirmar_dialog.dart';
import '../../../../core/widgets/estados.dart';
import '../../../../core/widgets/perfil_rotulo.dart';
import '../../domain/entities/usuario.dart';
import '../providers/usuarios_providers.dart';

/// T04: criar (sem `usuarioId`) ou editar um usuário. Só o gerente chega aqui.
class UsuarioFormPage extends ConsumerWidget {
  const UsuarioFormPage({super.key, this.usuarioId});

  final String? usuarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = usuarioId;
    if (id == null) return const _Formulario();

    return ref
        .watch(usuarioDetalheProvider(id))
        .when(
          loading: () => const Carregando(),
          error: (erro, _) => EstadoErro(
            mensagem: mensagemDeErro(erro),
            aoTentarDeNovo: () => ref.invalidate(usuarioDetalheProvider(id)),
          ),
          data: (usuario) => _Formulario(usuario: usuario),
        );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({this.usuario});

  final Usuario? usuario;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  final _chave = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.usuario?.nome ?? '');
  late final _email = TextEditingController(text: widget.usuario?.email ?? '');
  final _senha = TextEditingController();
  late Perfil? _perfil = widget.usuario?.perfil;
  var _salvando = false;
  String? _erroNoEmail;
  String? _erroGeral;

  bool get _editando => widget.usuario != null;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _mostrar(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  /// Faz a ação, mostra o erro em português se falhar e devolve se deu certo.
  Future<bool> _executar(Future<void> Function() acao) async {
    setState(() {
      _salvando = true;
      _erroNoEmail = null;
      _erroGeral = null;
    });
    try {
      await acao();
      return true;
    } catch (erro) {
      if (!mounted) return false;
      setState(() {
        if (erro is ApiException && erro.codigo == 'conflito' && !_editando) {
          _erroNoEmail = erro.mensagem;
        } else {
          _erroGeral = mensagemDeErro(erro);
        }
      });
      return false;
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _atualizarListas() {
    ref.invalidate(usuariosListaProvider);
    final id = widget.usuario?.id;
    if (id != null) ref.invalidate(usuarioDetalheProvider(id));
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final repo = ref.read(usuariosRepositoryProvider);
    final ok = await _executar(() async {
      if (_editando) {
        await repo.alterar(
          widget.usuario!.id,
          nome: _nome.text.trim(),
          perfil: _perfil,
        );
      } else {
        await repo.criar(
          nome: _nome.text.trim(),
          email: _email.text.trim(),
          perfil: _perfil!,
          senha: _senha.text,
        );
      }
    });
    if (!ok || !mounted) return;
    _atualizarListas();
    _mostrar(_editando ? 'Usuário atualizado.' : 'Usuário criado.');
    context.go(AppRoutes.usuarios);
  }

  Future<void> _alterarSituacao() async {
    final usuario = widget.usuario!;
    final inativando = usuario.ativo;
    final confirmado = await confirmar(
      context,
      titulo: inativando ? 'Inativar usuário' : 'Reativar usuário',
      mensagem: inativando
          ? '${usuario.nome} não conseguirá mais entrar no sistema. O histórico é mantido.'
          : '${usuario.nome} voltará a poder entrar no sistema.',
      rotuloConfirmar: inativando ? 'Inativar' : 'Reativar',
      destrutivo: inativando,
    );
    if (!confirmado || !mounted) return;
    final repo = ref.read(usuariosRepositoryProvider);
    final ok = await _executar(
      () async => inativando
          ? await repo.inativar(usuario.id)
          : await repo.ativar(usuario.id),
    );
    if (!ok || !mounted) return;
    _atualizarListas();
    _mostrar(inativando ? 'Usuário inativado.' : 'Usuário reativado.');
  }

  Future<void> _redefinirSenha() async {
    final nova = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogoNovaSenha(),
    );
    if (nova == null || !mounted) return;
    final repo = ref.read(usuariosRepositoryProvider);
    final ok = await _executar(
      () => repo.redefinirSenha(widget.usuario!.id, nova),
    );
    if (ok && mounted) _mostrar('Senha redefinida.');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final usuario = widget.usuario;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _chave,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _editando ? 'Editar usuário' : 'Novo usuário',
                  style: tema.textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nome,
                  enabled: !_salvando,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Informe o nome'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  enabled: !_salvando && !_editando,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: const OutlineInputBorder(),
                    helperText: _editando
                        ? 'O e-mail não pode ser alterado'
                        : null,
                    errorText: _erroNoEmail,
                  ),
                  validator: (v) {
                    final texto = v?.trim() ?? '';
                    if (texto.isEmpty) return 'Informe o e-mail';
                    if (!texto.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Perfil>(
                  initialValue: _perfil,
                  decoration: const InputDecoration(
                    labelText: 'Perfil',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final p in Perfil.values)
                      DropdownMenuItem(value: p, child: Text(p.rotulo)),
                  ],
                  onChanged: _salvando
                      ? null
                      : (p) => setState(() => _perfil = p),
                  validator: (p) => p == null ? 'Escolha o perfil' : null,
                ),
                if (!_editando) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senha,
                    enabled: !_salvando,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha inicial',
                      helperText: 'No mínimo 8 caracteres',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.length < 8)
                        ? 'A senha precisa ter pelo menos 8 caracteres'
                        : null,
                  ),
                ],
                if (_erroGeral != null) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _erroGeral!,
                      style: TextStyle(color: tema.colorScheme.error),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
                if (_editando) ...[
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: _salvando ? null : _redefinirSenha,
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Redefinir senha'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _salvando ? null : _alterarSituacao,
                    icon: Icon(
                      usuario!.ativo
                          ? Icons.person_off_outlined
                          : Icons.person_outline,
                    ),
                    label: Text(
                      usuario.ativo ? 'Inativar usuário' : 'Reativar usuário',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogoNovaSenha extends StatefulWidget {
  const _DialogoNovaSenha();

  @override
  State<_DialogoNovaSenha> createState() => _DialogoNovaSenhaState();
}

class _DialogoNovaSenhaState extends State<_DialogoNovaSenha> {
  final _chave = GlobalKey<FormState>();
  final _senha = TextEditingController();

  @override
  void dispose() {
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Redefinir senha'),
      content: Form(
        key: _chave,
        child: TextFormField(
          controller: _senha,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nova senha',
            helperText: 'No mínimo 8 caracteres',
          ),
          validator: (v) => (v == null || v.length < 8)
              ? 'A senha precisa ter pelo menos 8 caracteres'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_chave.currentState!.validate()) {
              Navigator.of(context).pop(_senha.text);
            }
          },
          child: const Text('Redefinir'),
        ),
      ],
    );
  }
}
