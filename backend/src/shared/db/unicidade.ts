/**
 * Valor repetido em coluna única (código P2002 do Prisma), comum a todos os cadastros.
 */

import { Prisma } from './prisma.js';

export function violouUnicidade(erro: unknown): erro is Prisma.PrismaClientKnownRequestError {
  return erro instanceof Prisma.PrismaClientKnownRequestError && erro.code === 'P2002';
}

/**
 * Grava; se outra requisição gravou o mesmo valor no meio, devolve o mesmo 409 de duplicidade.
 * `buscarExistente` devolve `null` quando não há o que conferir (o campo único não mudou).
 */
export async function gravarSemDuplicar<T, E>(
  operacao: () => Promise<T>,
  buscarExistente: () => Promise<E | null>,
  duplicado: (existente: E) => Error,
): Promise<T> {
  try {
    return await operacao();
  } catch (erro) {
    if (violouUnicidade(erro)) {
      const existente = await buscarExistente();
      if (existente) throw duplicado(existente);
    }
    throw erro;
  }
}
