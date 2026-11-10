import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/perfil.dart';
import '../../../../core/router/redirecionamento.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/validacao/validadores.dart';
import '../../../../core/widgets/botao_com_progresso.dart';
import '../../../../core/widgets/carregador_de_formulario.dart';
import '../../../../core/widgets/corpo_de_formulario.dart';
import '../../../../core/widgets/estado_de_formulario.dart';
import '../../../../core/widgets/campo_rotulado.dart';
import '../../../../core/widgets/confirmar_dialog.dart';
import '../../../../core/widgets/perfil_rotulo.dart';
import '../../../../core/widgets/tela_com_sub_barra.dart';
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

    return CarregadorDeFormulario<Usuario>(
      dados: ref.watch(usuarioDetalheProvider(id)),
      titulo: 'Editar usuário',
      aoVoltar: () => context.go(AppRoutes.usuarios),
      rotuloVoltar: 'Voltar para usuários',
      aoTentarDeNovo: () => ref.invalidate(usuarioDetalheProvider(id)),
      construir: (usuario) => _Formulario(usuario: usuario),
    );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({this.usuario});

  final Usuario? usuario;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario>
    with EstadoDeFormulario<_Formulario> {
  final _chave = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.usuario?.nome ?? '');
  late final _email = TextEditingController(text: widget.usuario?.email ?? '');
  final _senha = TextEditingController();
  late Perfil? _perfil = widget.usuario?.perfil;
  String? _erroNoEmail;

  bool get _editando => widget.usuario != null;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  void limparErros() => _erroNoEmail = null;

  @override
  bool tratarErro(Object erro) {
    final conflitoDeEmail =
        erro is ApiException && erro.codigo == 'conflito' && !_editando;
    if (conflitoDeEmail) _erroNoEmail = erro.mensagem;
    return conflitoDeEmail;
  }

  void _atualizarListas() {
    ref.invalidate(usuariosListaProvider);
    final id = widget.usuario?.id;
    if (id != null) ref.invalidate(usuarioDetalheProvider(id));
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final repo = ref.read(usuariosRepositoryProvider);
    final ok = await executar(() async {
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
    mostrar(_editando ? 'Usuário atualizado.' : 'Usuário criado.');
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
    final ok = await executar(
      () async => inativando
          ? await repo.inativar(usuario.id)
          : await repo.ativar(usuario.id),
    );
    if (!ok || !mounted) return;
    _atualizarListas();
    mostrar(inativando ? 'Usuário inativado.' : 'Usuário reativado.');
  }

  Future<void> _redefinirSenha() async {
    final nova = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogoNovaSenha(),
    );
    if (nova == null || !mounted) return;
    final repo = ref.read(usuariosRepositoryProvider);
    final ok = await executar(
      () => repo.redefinirSenha(widget.usuario!.id, nova),
    );
    if (ok && mounted) mostrar('Senha redefinida.');
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;

    return TelaComSubBarra(
      titulo: _editando ? 'Editar usuário' : 'Novo usuário',
      aoVoltar: () => context.go(AppRoutes.usuarios),
      rotuloVoltar: 'Voltar para usuários',
      filho: CorpoDeFormulario(
        chave: _chave,
        campos: [
          CampoRotulado(
            rotulo: 'Nome',
            child: TextFormField(
              controller: _nome,
              enabled: !salvando,
              textCapitalization: TextCapitalization.words,
              validator: Validadores.textoMinimo(2, 'Informe o nome'),
            ),
          ),
          CampoRotulado(
            rotulo: 'E-mail',
            child: TextFormField(
              controller: _email,
              enabled: !salvando && !_editando,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                helperText: _editando ? 'O e-mail não pode ser alterado' : null,
                errorText: _erroNoEmail,
              ),
              validator: Validadores.emailObrigatorio,
            ),
          ),
          CampoRotulado(
            rotulo: 'Perfil',
            child: DropdownButtonFormField<Perfil>(
              initialValue: _perfil,
              borderRadius: BorderRadius.circular(AppTheme.raioCampo),
              items: [
                for (final p in Perfil.values)
                  DropdownMenuItem(value: p, child: Text(p.rotulo)),
              ],
              onChanged: salvando ? null : (p) => setState(() => _perfil = p),
              validator: (p) => p == null ? 'Escolha o perfil' : null,
            ),
          ),
          if (!_editando)
            CampoRotulado(
              rotulo: 'Senha inicial',
              child: TextFormField(
                controller: _senha,
                enabled: !salvando,
                obscureText: true,
                decoration: const InputDecoration(
                  helperText: 'No mínimo 8 caracteres',
                ),
                validator: Validadores.senhaMinima,
              ),
            ),
        ],
        erroGeral: erroGeral,
        botaoSalvar: BotaoComProgresso(
          rotulo: 'Salvar',
          carregando: salvando,
          aoPressionar: _salvar,
        ),
        acoes: [
          if (usuario != null) ...[
            OutlinedButton(
              onPressed: salvando ? null : _redefinirSenha,
              child: const Text('Redefinir senha'),
            ),
            OutlinedButton(
              style: usuario.ativo ? AppTheme.estiloDestrutivo : null,
              onPressed: salvando ? null : _alterarSituacao,
              child: Text(
                usuario.ativo ? 'Inativar usuário' : 'Reativar usuário',
              ),
            ),
          ],
        ],
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
        child: CampoRotulado(
          rotulo: 'Nova senha',
          child: TextFormField(
            controller: _senha,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(
              helperText: 'No mínimo 8 caracteres',
            ),
            validator: Validadores.senhaMinima,
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        OutlinedButton(
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
