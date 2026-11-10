import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/formatacao/documento.dart';
import '../../../../core/formatacao/telefone.dart';
import '../../../../core/router/redirecionamento.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/validacao/validadores.dart';
import '../../../../core/widgets/botao_com_progresso.dart';
import '../../../../core/widgets/carregador_de_formulario.dart';
import '../../../../core/widgets/corpo_de_formulario.dart';
import '../../../../core/widgets/estado_de_formulario.dart';
import '../../../../core/widgets/campo_documento.dart';
import '../../../../core/widgets/campo_rotulado.dart';
import '../../../../core/widgets/campo_telefone.dart';
import '../../../../core/widgets/chips.dart';
import '../../../../core/widgets/confirmar_dialog.dart';
import '../../../../core/widgets/tela_com_sub_barra.dart';
import '../../domain/entities/cliente.dart';
import '../providers/clientes_providers.dart';

/// T06: cadastrar (sem `clienteId`) ou editar um cliente. Só o atendente chega aqui.
class ClienteFormPage extends ConsumerWidget {
  const ClienteFormPage({super.key, this.clienteId});

  final String? clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = clienteId;
    if (id == null) return const _Formulario();

    return CarregadorDeFormulario<Cliente>(
      dados: ref.watch(clienteDetalheProvider(id)),
      titulo: 'Editar cliente',
      aoVoltar: () => context.go(AppRoutes.clientes),
      rotuloVoltar: 'Voltar para clientes',
      aoTentarDeNovo: () => ref.invalidate(clienteDetalheProvider(id)),
      construir: (cliente) => _Formulario(key: ValueKey(id), cliente: cliente),
    );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({super.key, this.cliente});

  final Cliente? cliente;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario>
    with EstadoDeFormulario<_Formulario> {
  final _chave = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.cliente?.nome ?? '');
  late final _documento = TextEditingController(
    text: formatarDocumento(widget.cliente?.documento ?? ''),
  );
  late final _telefone = TextEditingController(
    text: formatarTelefone(widget.cliente?.telefone ?? ''),
  );
  late final _email = TextEditingController(text: widget.cliente?.email ?? '');
  late final _endereco = TextEditingController(
    text: widget.cliente?.endereco ?? '',
  );
  Cliente? _duplicado;

  bool get _editando => widget.cliente != null;

  @override
  void dispose() {
    _nome.dispose();
    _documento.dispose();
    _telefone.dispose();
    _email.dispose();
    _endereco.dispose();
    super.dispose();
  }

  @override
  void limparErros() => _duplicado = null;

  @override
  bool tratarErro(Object erro) {
    if (erro is! DocumentoDuplicadoException) return false;
    _duplicado = erro.existente;
    return true;
  }

  void _atualizarListas() {
    ref.invalidate(clientesListaProvider);
    final id = widget.cliente?.id;
    if (id != null) ref.invalidate(clienteDetalheProvider(id));
  }

  String? _vazioComoNulo(TextEditingController c) {
    final texto = c.text.trim();
    return texto.isEmpty ? null : texto;
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final repo = ref.read(clientesRepositoryProvider);
    final dados = DadosDoCliente(
      nome: _nome.text.trim(),
      documento: somenteDigitos(_documento.text),
      telefone: somenteDigitos(_telefone.text),
      email: _vazioComoNulo(_email),
      endereco: _vazioComoNulo(_endereco),
    );
    final ok = await executar(() async {
      if (_editando) {
        await repo.alterar(widget.cliente!.id, dados);
      } else {
        await repo.criar(dados);
      }
    });
    if (!ok || !mounted) return;
    _atualizarListas();
    mostrar(_editando ? 'Cliente atualizado.' : 'Cliente cadastrado.');
    context.go(AppRoutes.clientes);
  }

  Future<void> _inativar() async {
    final cliente = widget.cliente!;
    final confirmado = await confirmar(
      context,
      titulo: 'Inativar cliente',
      mensagem:
          '${cliente.nome} será marcado como inativo. O cadastro e o histórico de OS são mantidos.',
      rotuloConfirmar: 'Inativar',
      destrutivo: true,
    );
    if (!confirmado || !mounted) return;
    final repo = ref.read(clientesRepositoryProvider);
    final ok = await executar(() async {
      await repo.inativar(cliente.id);
    });
    if (!ok || !mounted) return;
    _atualizarListas();
    mostrar('Cliente inativado.');
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.cliente;
    final duplicado = _duplicado;

    return TelaComSubBarra(
      titulo: _editando ? 'Editar cliente' : 'Novo cliente',
      aoVoltar: () => context.go(AppRoutes.clientes),
      rotuloVoltar: 'Voltar para clientes',
      filho: CorpoDeFormulario(
        chave: _chave,
        campos: [
          if (cliente != null && !cliente.ativo)
            const Align(
              alignment: Alignment.centerLeft,
              child: ChipDeEstado('Inativo'),
            ),
          CampoRotulado(
            rotulo: 'Nome',
            child: TextFormField(
              controller: _nome,
              enabled: !salvando,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validadores.textoMinimo(2, 'Informe o nome'),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoDocumento(
                controller: _documento,
                enabled: !salvando,
                erro: duplicado == null
                    ? null
                    : 'Este documento já está cadastrado para ${duplicado.nome}.',
                aoMudar: () {
                  if (_duplicado != null) setState(() => _duplicado = null);
                },
              ),
              if (duplicado != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () =>
                        context.go(AppRoutes.cliente(duplicado.id)),
                    child: const Text('Abrir cadastro existente'),
                  ),
                ),
            ],
          ),
          CampoTelefone(controller: _telefone, enabled: !salvando),
          CampoRotulado(
            rotulo: 'E-mail (opcional)',
            child: TextFormField(
              controller: _email,
              enabled: !salvando,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validadores.emailOpcional,
            ),
          ),
          CampoRotulado(
            rotulo: 'Endereço (opcional)',
            child: TextFormField(
              controller: _endereco,
              enabled: !salvando,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
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
          if (cliente != null) ...[
            OutlinedButton(
              onPressed: salvando
                  ? null
                  : () => context.go(AppRoutes.veiculosDoCliente(cliente.id)),
              child: const Text('Veículos do cliente'),
            ),
            if (cliente.ativo)
              OutlinedButton(
                style: AppTheme.estiloDestrutivo,
                onPressed: salvando ? null : _inativar,
                child: const Text('Inativar cliente'),
              ),
          ],
        ],
      ),
    );
  }
}
