/**
 * Acesso ao banco do módulo de veículos. Único lugar do módulo que fala com o Prisma.
 */

import { prisma, type PrismaClient } from '../../shared/db/prisma.js';
import { deslocamento, type Paginacao } from '../../shared/paginacao.js';

export interface VeiculoRegistro {
  id: string;
  clienteId: string;
  placa: string;
  marca: string;
  modelo: string;
  ano: number;
  cor: string | null;
  quilometragem: number;
  ativo: boolean;
}

export interface DadosNovoVeiculo {
  clienteId: string;
  placa: string;
  marca: string;
  modelo: string;
  ano: number;
  cor: string | null;
  quilometragem: number;
}

export type DadosAlteracaoVeiculo = Partial<Omit<DadosNovoVeiculo, 'clienteId'>>;

export interface FiltrosVeiculos extends Paginacao {
  clienteId?: string | undefined;
  /** Parte da placa, já normalizada. */
  placa?: string | undefined;
}

export interface RepositorioVeiculos {
  buscarPorId(id: string): Promise<VeiculoRegistro | null>;
  buscarPorPlaca(placa: string): Promise<VeiculoRegistro | null>;
  listar(filtros: FiltrosVeiculos): Promise<{ itens: VeiculoRegistro[]; total: number }>;
  criar(dados: DadosNovoVeiculo): Promise<VeiculoRegistro>;
  atualizar(id: string, dados: DadosAlteracaoVeiculo): Promise<VeiculoRegistro>;
  /** Muda só o dono do veículo; as OS já abertas guardam o cliente da época e não mudam. */
  transferir(id: string, clienteId: string): Promise<VeiculoRegistro>;
  inativar(id: string): Promise<VeiculoRegistro>;
}

export function criarRepositorioPrisma(cliente: () => PrismaClient): RepositorioVeiculos {
  return {
    buscarPorId: (id) => cliente().veiculo.findUnique({ where: { id } }),

    buscarPorPlaca: (placa) => cliente().veiculo.findUnique({ where: { placa } }),

    async listar(filtros) {
      const where = {
        ...(filtros.clienteId ? { clienteId: filtros.clienteId } : {}),
        ...(filtros.placa ? { placa: { contains: filtros.placa } } : {}),
      };
      const [itens, total] = await cliente().$transaction([
        cliente().veiculo.findMany({
          where,
          orderBy: [{ placa: 'asc' }],
          skip: deslocamento(filtros),
          take: filtros.limite,
        }),
        cliente().veiculo.count({ where }),
      ]);
      return { itens, total };
    },

    criar: (dados) => cliente().veiculo.create({ data: dados }),

    atualizar: (id, dados) => cliente().veiculo.update({ where: { id }, data: dados }),

    transferir: (id, clienteId) => cliente().veiculo.update({ where: { id }, data: { clienteId } }),

    inativar: (id) => cliente().veiculo.update({ where: { id }, data: { ativo: false } }),
  };
}

export const repositorioPrisma = criarRepositorioPrisma(prisma);
