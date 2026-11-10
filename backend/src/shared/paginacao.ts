/**
 * Paginação por página e limite, comum a todas as listas da API.
 */

import { z } from './openapi/zod.js';

export const PaginacaoQuerySchema = z.object({
  pagina: z.coerce.number().int().min(1).default(1).openapi({ example: 1 }),
  limite: z.coerce.number().int().min(1).max(100).default(20).openapi({ example: 20 }),
});

export interface Paginacao {
  pagina: number;
  limite: number;
}

/** Quantas linhas pular para chegar à página pedida. */
export function deslocamento(p: Paginacao): number {
  return (p.pagina - 1) * p.limite;
}

export function paginaDe<T>(itens: T[], total: number, p: Paginacao) {
  return { itens, total, pagina: p.pagina, limite: p.limite };
}

/** Esquema da resposta de uma lista paginada, para o OpenAPI. */
export const paginaSchema = <T extends z.ZodType>(item: T, nome: string) =>
  z
    .object({
      itens: z.array(item),
      total: z.number().int(),
      pagina: z.number().int(),
      limite: z.number().int(),
    })
    .openapi(nome);
