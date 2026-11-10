/**
 * Regras do módulo de veículos (UC03, só o atendente).
 *
 * A placa é única e guardada normalizada (maiúscula, sem hífen); a duplicidade devolve 409 com o
 * veículo existente. O veículo pertence a um cliente (módulo `clientes`, só pelo `index.ts`).
 * Transferir muda só o dono: as OS já abertas guardam o cliente da época e mantêm o dono anterior.
 */

import { gravarSemDuplicar } from '../../shared/db/unicidade.js';
import { NaoEncontrado, RegraDeNegocio } from '../../shared/errors/app-error.js';
import { paginaDe, type Paginacao } from '../../shared/paginacao.js';
import { normalizarPlaca } from '../../shared/validadores.js';
import type { ClienteResumo } from '../clientes/index.js';
import type {
  DadosAlteracaoVeiculo,
  FiltrosVeiculos,
  RepositorioVeiculos,
  VeiculoRegistro,
} from './repository.js';

export type VeiculoResposta = VeiculoRegistro;

function paraResposta(v: VeiculoRegistro): VeiculoResposta {
  return {
    id: v.id,
    clienteId: v.clienteId,
    placa: v.placa,
    marca: v.marca,
    modelo: v.modelo,
    ano: v.ano,
    cor: v.cor,
    quilometragem: v.quilometragem,
    ativo: v.ativo,
  };
}

function placaDuplicada(existente: VeiculoRegistro) {
  return new RegraDeNegocio('placa_duplicada', 'Já existe um veículo com esta placa', {
    existente: paraResposta(existente),
  });
}

export interface DependenciasVeiculos {
  repo: RepositorioVeiculos;
  /** Consulta de cliente feita pelo módulo `clientes`. */
  buscarCliente: (id: string) => Promise<ClienteResumo | null>;
}

export function criarServicoVeiculos({ repo, buscarCliente }: DependenciasVeiculos) {
  async function obter(id: string): Promise<VeiculoRegistro> {
    const veiculo = await repo.buscarPorId(id);
    if (!veiculo) throw new NaoEncontrado('Veículo');
    return veiculo;
  }

  async function exigirCliente(id: string): Promise<ClienteResumo> {
    const cliente = await buscarCliente(id);
    if (!cliente) throw new NaoEncontrado('Cliente');
    return cliente;
  }

  /** Grava; se outra requisição gravou a mesma placa no meio, devolve o mesmo 409. */
  function gravar<T>(placa: string | undefined, operacao: () => Promise<T>): Promise<T> {
    return gravarSemDuplicar(
      operacao,
      async () => (placa ? repo.buscarPorPlaca(placa) : null),
      placaDuplicada,
    );
  }

  return {
    async listarDoCliente(clienteId: string, paginacao: Paginacao) {
      await exigirCliente(clienteId);
      const { itens, total } = await repo.listar({ ...paginacao, clienteId });
      return paginaDe(itens.map(paraResposta), total, paginacao);
    },

    async buscar(filtros: Omit<FiltrosVeiculos, 'clienteId'>) {
      const placa = filtros.placa ? normalizarPlaca(filtros.placa) : undefined;
      const { itens, total } = await repo.listar({ ...filtros, placa });
      return paginaDe(itens.map(paraResposta), total, filtros);
    },

    async detalhar(id: string): Promise<VeiculoResposta> {
      return paraResposta(await obter(id));
    },

    async criar(
      clienteId: string,
      dados: {
        placa: string;
        marca: string;
        modelo: string;
        ano: number;
        cor?: string | null | undefined;
        quilometragem: number;
      },
    ): Promise<VeiculoResposta> {
      await exigirCliente(clienteId);
      const existente = await repo.buscarPorPlaca(dados.placa);
      if (existente) throw placaDuplicada(existente);
      const novo = { ...dados, clienteId, cor: dados.cor ?? null };
      return paraResposta(await gravar(dados.placa, () => repo.criar(novo)));
    },

    async alterar(id: string, dados: DadosAlteracaoVeiculo): Promise<VeiculoResposta> {
      const atual = await obter(id);
      if (dados.placa !== undefined && dados.placa !== atual.placa) {
        const existente = await repo.buscarPorPlaca(dados.placa);
        if (existente) throw placaDuplicada(existente);
      }
      return paraResposta(await gravar(dados.placa, () => repo.atualizar(id, dados)));
    },

    async transferir(id: string, clienteId: string): Promise<VeiculoResposta> {
      const atual = await obter(id);
      await exigirCliente(clienteId);
      if (atual.clienteId === clienteId) return paraResposta(atual);
      return paraResposta(await repo.transferir(id, clienteId));
    },

    async inativar(id: string): Promise<VeiculoResposta> {
      const atual = await obter(id);
      if (!atual.ativo) return paraResposta(atual);
      return paraResposta(await repo.inativar(id));
    },
  };
}

export type ServicoVeiculos = ReturnType<typeof criarServicoVeiculos>;
