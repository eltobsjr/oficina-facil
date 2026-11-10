import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/redirecionamento.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/validacao/validadores.dart';
import '../../../../core/widgets/botao_com_progresso.dart';
import '../../../../core/widgets/carregador_de_formulario.dart';
import '../../../../core/widgets/corpo_de_formulario.dart';
import '../../../../core/widgets/estado_de_formulario.dart';
import '../../../../core/widgets/campo_placa.dart';
import '../../../../core/widgets/campo_rotulado.dart';
import '../../../../core/widgets/chips.dart';
import '../../../../core/widgets/confirmar_dialog.dart';
import '../../../../core/widgets/tela_com_sub_barra.dart';
import '../../../clientes/domain/entities/cliente.dart';
import '../../../clientes/presentation/widgets/seletor_cliente.dart';
import '../../domain/entities/veiculo.dart';
import '../providers/veiculos_providers.dart';

/// T07 (formulário): cadastrar um veículo do cliente [clienteId] ou, com [veiculoId], editar,
/// transferir de dono e inativar.
class VeiculoFormPage extends ConsumerWidget {
  const VeiculoFormPage({super.key, required this.clienteId, this.veiculoId});

  final String clienteId;
  final String? veiculoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = veiculoId;
    if (id == null) return _Formulario(clienteId: clienteId);

    return CarregadorDeFormulario<Veiculo>(
      dados: ref.watch(veiculoDetalheProvider(id)),
      titulo: 'Editar veículo',
      aoVoltar: () => context.go(AppRoutes.veiculosDoCliente(clienteId)),
      rotuloVoltar: 'Voltar para os veículos',
      aoTentarDeNovo: () => ref.invalidate(veiculoDetalheProvider(id)),
      construir: (veiculo) => _Formulario(
        key: ValueKey(id),
        clienteId: clienteId,
        veiculo: veiculo,
      ),
    );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({super.key, required this.clienteId, this.veiculo});

  final String clienteId;
  final Veiculo? veiculo;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario>
    with EstadoDeFormulario<_Formulario> {
  final _chave = GlobalKey<FormState>();
  late final _placa = TextEditingController(text: widget.veiculo?.placa ?? '');
  late final _marca = TextEditingController(text: widget.veiculo?.marca ?? '');
  late final _modelo = TextEditingController(
    text: widget.veiculo?.modelo ?? '',
  );
  late final _ano = TextEditingController(
    text: widget.veiculo?.ano.toString() ?? '',
  );
  late final _cor = TextEditingController(text: widget.veiculo?.cor ?? '');
  late final _quilometragem = TextEditingController(
    text: widget.veiculo?.quilometragem.toString() ?? '',
  );
  Veiculo? _duplicado;

  bool get _editando => widget.veiculo != null;

  @override
  void dispose() {
    _placa.dispose();
    _marca.dispose();
    _modelo.dispose();
    _ano.dispose();
    _cor.dispose();
    _quilometragem.dispose();
    super.dispose();
  }

  @override
  void limparErros() => _duplicado = null;

  @override
  bool tratarErro(Object erro) {
    if (erro is! PlacaDuplicadaException) return false;
    _duplicado = erro.existente;
    return true;
  }

  void _atualizarListas({String? outroClienteId}) {
    ref.invalidate(veiculosDoClienteProvider(widget.clienteId));
    if (outroClienteId != null) {
      ref.invalidate(veiculosDoClienteProvider(outroClienteId));
    }
    final id = widget.veiculo?.id;
    if (id != null) ref.invalidate(veiculoDetalheProvider(id));
  }

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    final repo = ref.read(veiculosRepositoryProvider);
    final cor = _cor.text.trim();
    final dados = DadosDoVeiculo(
      placa: _placa.text.trim(),
      marca: _marca.text.trim(),
      modelo: _modelo.text.trim(),
      ano: int.parse(_ano.text.trim()),
      cor: cor.isEmpty ? null : cor,
      quilometragem: int.parse(_quilometragem.text.trim()),
    );
    final ok = await executar(() async {
      if (_editando) {
        await repo.alterar(widget.veiculo!.id, dados);
      } else {
        await repo.criar(widget.clienteId, dados);
      }
    });
    if (!ok || !mounted) return;
    _atualizarListas();
    mostrar(_editando ? 'Veículo atualizado.' : 'Veículo cadastrado.');
    context.go(AppRoutes.veiculosDoCliente(widget.clienteId));
  }

  Future<void> _inativar() async {
    final veiculo = widget.veiculo!;
    final confirmado = await confirmar(
      context,
      titulo: 'Inativar veículo',
      mensagem:
          'O veículo ${veiculo.placa} será marcado como inativo. O cadastro e o histórico de OS são mantidos.',
      rotuloConfirmar: 'Inativar',
      destrutivo: true,
    );
    if (!confirmado || !mounted) return;
    final repo = ref.read(veiculosRepositoryProvider);
    final ok = await executar(() async {
      await repo.inativar(veiculo.id);
    });
    if (!ok || !mounted) return;
    _atualizarListas();
    mostrar('Veículo inativado.');
  }

  Future<void> _transferir() async {
    final veiculo = widget.veiculo!;
    final novoDono = await showDialog<Cliente>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Transferir para outro cliente'),
        content: SizedBox(
          width: 480,
          child: SeletorCliente(
            excluirId: veiculo.clienteId,
            aoSelecionar: (c) => Navigator.of(contexto).pop(c),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(contexto).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (novoDono == null || !mounted) return;
    final confirmado = await confirmar(
      context,
      titulo: 'Transferir veículo',
      mensagem:
          'O veículo ${veiculo.placa} passará para ${novoDono.nome}. As OS já abertas continuam no nome do dono anterior.',
      rotuloConfirmar: 'Transferir',
    );
    if (!confirmado || !mounted) return;
    final repo = ref.read(veiculosRepositoryProvider);
    final ok = await executar(() async {
      await repo.transferir(veiculo.id, novoDono.id);
    });
    if (!ok || !mounted) return;
    _atualizarListas(outroClienteId: novoDono.id);
    mostrar('Veículo transferido para ${novoDono.nome}.');
    context.go(AppRoutes.veiculosDoCliente(widget.clienteId));
  }

  @override
  Widget build(BuildContext context) {
    final veiculo = widget.veiculo;
    final duplicado = _duplicado;

    return TelaComSubBarra(
      titulo: _editando ? 'Editar veículo' : 'Novo veículo',
      aoVoltar: () => context.go(AppRoutes.veiculosDoCliente(widget.clienteId)),
      rotuloVoltar: 'Voltar para os veículos',
      filho: CorpoDeFormulario(
        chave: _chave,
        campos: [
          if (veiculo != null && !veiculo.ativo)
            const Align(
              alignment: Alignment.centerLeft,
              child: ChipDeEstado('Inativo'),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoPlaca(
                controller: _placa,
                enabled: !salvando,
                erro: duplicado == null
                    ? null
                    : 'Esta placa já está cadastrada.',
                aoMudar: () {
                  if (_duplicado != null) setState(() => _duplicado = null);
                },
              ),
              if (duplicado != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.go(
                      AppRoutes.veiculo(duplicado.clienteId, duplicado.id),
                    ),
                    child: const Text('Abrir veículo existente'),
                  ),
                ),
            ],
          ),
          CampoRotulado(
            rotulo: 'Marca',
            child: TextFormField(
              controller: _marca,
              enabled: !salvando,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validadores.obrigatorio('Informe a marca'),
            ),
          ),
          CampoRotulado(
            rotulo: 'Modelo',
            child: TextFormField(
              controller: _modelo,
              enabled: !salvando,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validadores.obrigatorio('Informe o modelo'),
            ),
          ),
          CampoRotulado(
            rotulo: 'Ano',
            child: TextFormField(
              controller: _ano,
              enabled: !salvando,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validadores.inteiroEntre(
                vazio: 'Informe o ano',
                invalido: 'Ano inválido. Use um ano entre 1900 e 2100.',
                minimo: 1900,
                maximo: 2100,
              ),
            ),
          ),
          CampoRotulado(
            rotulo: 'Cor (opcional)',
            child: TextFormField(
              controller: _cor,
              enabled: !salvando,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
          ),
          CampoRotulado(
            rotulo: 'Quilometragem',
            child: TextFormField(
              controller: _quilometragem,
              enabled: !salvando,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(suffixText: 'km'),
              validator: Validadores.inteiroEntre(
                vazio: 'Informe a quilometragem',
                invalido: 'Quilometragem inválida',
                minimo: 0,
              ),
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
          if (veiculo != null) ...[
            OutlinedButton(
              onPressed: salvando ? null : _transferir,
              child: const Text('Transferir de dono'),
            ),
            if (veiculo.ativo)
              OutlinedButton(
                style: AppTheme.estiloDestrutivo,
                onPressed: salvando ? null : _inativar,
                child: const Text('Inativar veículo'),
              ),
          ],
        ],
      ),
    );
  }
}
