/**
 * Acesso ao banco do módulo de clientes. Único lugar do módulo que fala com o Prisma.
 */

import { prisma, type PrismaClient, type StatusOs } from '../../shared/db/prisma.js';
import { deslocamento, type Paginacao } from '../../shared/paginacao.js';

export interface ClienteRegistro {
  id: string;
  nome: string;
  documento: string;
  telefone: string;
  email: string | null;
  endereco: string | null;
  ativo: boolean;
}

export interface DadosNovoCliente {
  nome: string;
  documento: string;
  telefone: string;
  email: string | null;
  endereco: string | null;
}

export type DadosAlteracaoCliente = Partial<DadosNovoCliente>;

export interface FiltrosClientes extends Paginacao {
  q?: string | undefined;
}

export interface RepositorioClientes {
  buscarPorId(id: string): Promise<ClienteRegistro | null>;
  buscarPorDocumento(documento: string): Promise<ClienteRegistro | null>;
  listar(filtros: FiltrosClientes): Promise<{ itens: ClienteRegistro[]; total: number }>;
  criar(dados: DadosNovoCliente): Promise<ClienteRegistro>;
  atualizar(id: string, dados: DadosAlteracaoCliente): Promise<ClienteRegistro>;
  /**
   * Inativa o cliente se ele não tiver OS ativa. A checagem e a escrita acontecem na mesma
   * transação, com o cliente travado. Devolve `null`, sem alterar nada, se houver OS ativa.
   */
  inativarSemOsAtiva(id: string): Promise<ClienteRegistro | null>;
}

/** Estados finais: a OS entregue ou cancelada já não bloqueia a inativação do cliente. */
const ESTADOS_FINAIS: StatusOs[] = ['ENTREGUE', 'CANCELADA'];

/** Parte do texto que parece documento (só dígitos e pontuação de máscara). */
const PARECE_DOCUMENTO = /^[\d.\-/\s]+$/;

export function criarRepositorioPrisma(cliente: () => PrismaClient): RepositorioClientes {
  return {
    buscarPorId: (id) => cliente().cliente.findUnique({ where: { id } }),

    buscarPorDocumento: (documento) => cliente().cliente.findUnique({ where: { documento } }),

    async listar(filtros) {
      const digitos =
        filtros.q && PARECE_DOCUMENTO.test(filtros.q) ? filtros.q.replace(/\D/g, '') : '';
      const where = filtros.q
        ? {
            OR: [
              { nome: { contains: filtros.q, mode: 'insensitive' as const } },
              ...(digitos ? [{ documento: { contains: digitos } }] : []),
            ],
          }
        : {};
      const [itens, total] = await cliente().$transaction([
        cliente().cliente.findMany({
          where,
          orderBy: [{ nome: 'asc' }, { id: 'asc' }],
          skip: deslocamento(filtros),
          take: filtros.limite,
        }),
        cliente().cliente.count({ where }),
      ]);
      return { itens, total };
    },

    criar: (dados) => cliente().cliente.create({ data: dados }),

    atualizar: (id, dados) => cliente().cliente.update({ where: { id }, data: dados }),

    inativarSemOsAtiva: (id) =>
      cliente().$transaction(async (tx) => {
        await tx.$queryRaw`SELECT id FROM clientes WHERE id = ${id}::uuid FOR UPDATE`;
        const osAtivas = await tx.ordemServico.count({
          where: { clienteId: id, status: { notIn: ESTADOS_FINAIS } },
        });
        if (osAtivas > 0) return null;
        return tx.cliente.update({ where: { id }, data: { ativo: false } });
      }),
  };
}

export const repositorioPrisma = criarRepositorioPrisma(prisma);
