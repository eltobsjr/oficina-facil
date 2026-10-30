/**
 * Acesso ao banco do módulo de usuários. Único lugar do módulo que fala com o Prisma.
 */

import { prisma, type Papel, type PrismaClient } from '../../shared/db/prisma.js';
import { deslocamento, type Paginacao } from '../../shared/paginacao.js';

export interface PerfilRegistrado {
  usuarioId: string;
  nome: string;
  email: string;
  perfil: Papel;
  ativo: boolean;
}

export interface PerfilCompleto extends PerfilRegistrado {
  criadoEm: Date;
}

/** Busca usada pela autenticação (cada requisição). */
export type BuscarPerfil = (usuarioId: string) => Promise<PerfilRegistrado | null>;

export const buscarPerfil: BuscarPerfil = (usuarioId) =>
  prisma().perfilUsuario.findUnique({ where: { usuarioId } });

export interface FiltrosUsuarios extends Paginacao {
  q?: string | undefined;
  perfil?: Papel | undefined;
  ativo?: boolean | undefined;
}

export interface RepositorioPerfis {
  buscarPorId(usuarioId: string): Promise<PerfilCompleto | null>;
  buscarPorEmail(email: string): Promise<PerfilCompleto | null>;
  listar(filtros: FiltrosUsuarios): Promise<{ itens: PerfilCompleto[]; total: number }>;
  criar(dados: {
    usuarioId: string;
    nome: string;
    email: string;
    perfil: Papel;
  }): Promise<PerfilCompleto>;
  /**
   * Atualiza o perfil. Com `exigirOutroGerenteAtivo`, a checagem e a escrita são atômicas:
   * devolve `null`, sem alterar nada, se não restaria nenhum outro gerente ativo.
   */
  atualizar(
    usuarioId: string,
    dados: { nome?: string; perfil?: Papel; ativo?: boolean },
    opcoes: { exigirOutroGerenteAtivo: boolean },
  ): Promise<PerfilCompleto | null>;
}

/** O cliente é injetável para os testes de integração usarem o banco de teste. */
export function criarRepositorioPrisma(cliente: () => PrismaClient): RepositorioPerfis {
  return {
    buscarPorId: (usuarioId) => cliente().perfilUsuario.findUnique({ where: { usuarioId } }),

    buscarPorEmail: (email) => cliente().perfilUsuario.findUnique({ where: { email } }),

    async listar(filtros) {
      const where = {
        ...(filtros.perfil ? { perfil: filtros.perfil } : {}),
        ...(filtros.ativo !== undefined ? { ativo: filtros.ativo } : {}),
        ...(filtros.q
          ? {
              OR: [
                { nome: { contains: filtros.q, mode: 'insensitive' as const } },
                { email: { contains: filtros.q, mode: 'insensitive' as const } },
              ],
            }
          : {}),
      };
      const [itens, total] = await cliente().$transaction([
        cliente().perfilUsuario.findMany({
          where,
          orderBy: { nome: 'asc' },
          skip: deslocamento(filtros),
          take: filtros.limite,
        }),
        cliente().perfilUsuario.count({ where }),
      ]);
      return { itens, total };
    },

    criar: (dados) => cliente().perfilUsuario.create({ data: dados }),

    atualizar: (usuarioId, dados, opcoes) =>
      cliente().$transaction(async (tx) => {
        if (opcoes.exigirOutroGerenteAtivo) {
          // Trava os gerentes ativos até o fim da transação: dois pedidos simultâneos não
          // conseguem, juntos, remover o último gerente.
          const gerentes = await tx.$queryRaw<{ usuario_id: string }[]>`
          SELECT usuario_id FROM perfis WHERE perfil = 'GERENTE' AND ativo = true FOR UPDATE`;
          if (!gerentes.some((g) => g.usuario_id !== usuarioId)) return null;
        }
        return tx.perfilUsuario.update({ where: { usuarioId }, data: dados });
      }),
  };
}

export const repositorioPrisma = criarRepositorioPrisma(prisma);
