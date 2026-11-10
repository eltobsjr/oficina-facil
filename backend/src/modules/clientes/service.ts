/**
 * Regras do módulo de clientes (UC02, só o atendente).
 *
 * O documento (CPF ou CNPJ) é único e guardado só com dígitos; a duplicidade devolve 409 com o
 * cadastro existente. Inativar mantém o histórico de OS e é barrado se o cliente tem OS ativa.
 * Documento é dado pessoal: nunca vai para log.
 */

import { gravarSemDuplicar } from '../../shared/db/unicidade.js';
import { NaoEncontrado, RegraDeNegocio } from '../../shared/errors/app-error.js';
import { paginaDe } from '../../shared/paginacao.js';
import type {
  ClienteRegistro,
  DadosAlteracaoCliente,
  DadosNovoCliente,
  FiltrosClientes,
  RepositorioClientes,
} from './repository.js';

export interface ClienteResposta {
  id: string;
  nome: string;
  documento: string;
  telefone: string;
  email: string | null;
  endereco: string | null;
  ativo: boolean;
}

/** O que outros módulos precisam saber de um cliente. */
export interface ClienteResumo {
  id: string;
  nome: string;
  ativo: boolean;
}

function paraResposta(c: ClienteRegistro): ClienteResposta {
  return {
    id: c.id,
    nome: c.nome,
    documento: c.documento,
    telefone: c.telefone,
    email: c.email,
    endereco: c.endereco,
    ativo: c.ativo,
  };
}

function documentoDuplicado(existente: ClienteRegistro) {
  return new RegraDeNegocio('documento_duplicado', 'Já existe um cliente com este documento', {
    existente: paraResposta(existente),
  });
}

export interface DependenciasClientes {
  repo: RepositorioClientes;
}

export function criarServicoClientes({ repo }: DependenciasClientes) {
  async function obter(id: string): Promise<ClienteRegistro> {
    const cliente = await repo.buscarPorId(id);
    if (!cliente) throw new NaoEncontrado('Cliente');
    return cliente;
  }

  /** Grava; se outra requisição gravou o mesmo documento no meio, devolve o mesmo 409. */
  function gravar<T>(documento: string | undefined, operacao: () => Promise<T>): Promise<T> {
    return gravarSemDuplicar(
      operacao,
      async () => (documento ? repo.buscarPorDocumento(documento) : null),
      documentoDuplicado,
    );
  }

  return {
    async listar(filtros: FiltrosClientes) {
      const { itens, total } = await repo.listar(filtros);
      return paginaDe(itens.map(paraResposta), total, filtros);
    },

    async detalhar(id: string): Promise<ClienteResposta> {
      return paraResposta(await obter(id));
    },

    async criar(dados: {
      nome: string;
      documento: string;
      telefone: string;
      email?: string | null | undefined;
      endereco?: string | null | undefined;
    }): Promise<ClienteResposta> {
      const existente = await repo.buscarPorDocumento(dados.documento);
      if (existente) throw documentoDuplicado(existente);
      const novo: DadosNovoCliente = {
        nome: dados.nome,
        documento: dados.documento,
        telefone: dados.telefone,
        email: dados.email ?? null,
        endereco: dados.endereco ?? null,
      };
      return paraResposta(await gravar(dados.documento, () => repo.criar(novo)));
    },

    async alterar(id: string, dados: DadosAlteracaoCliente): Promise<ClienteResposta> {
      const atual = await obter(id);
      if (dados.documento !== undefined && dados.documento !== atual.documento) {
        const existente = await repo.buscarPorDocumento(dados.documento);
        if (existente) throw documentoDuplicado(existente);
      }
      return paraResposta(await gravar(dados.documento, () => repo.atualizar(id, dados)));
    },

    async inativar(id: string): Promise<ClienteResposta> {
      const atual = await obter(id);
      if (!atual.ativo) return paraResposta(atual);
      const inativado = await repo.inativarSemOsAtiva(id);
      if (!inativado) {
        throw new RegraDeNegocio(
          'cliente_com_os_ativa',
          'Não é possível inativar: o cliente tem OS em andamento',
        );
      }
      return paraResposta(inativado);
    },

    async resumo(id: string): Promise<ClienteResumo | null> {
      const cliente = await repo.buscarPorId(id);
      return cliente ? { id: cliente.id, nome: cliente.nome, ativo: cliente.ativo } : null;
    },
  };
}

export type ServicoClientes = ReturnType<typeof criarServicoClientes>;
