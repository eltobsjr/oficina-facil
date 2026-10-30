/**
 * Acesso ao banco do módulo de usuários. Único lugar do módulo que fala com o Prisma.
 */

import { prisma, type Papel } from '../../shared/db/prisma.js';

export interface PerfilRegistrado {
  usuarioId: string;
  nome: string;
  email: string;
  perfil: Papel;
  ativo: boolean;
}

export type BuscarPerfil = (usuarioId: string) => Promise<PerfilRegistrado | null>;

export const buscarPerfil: BuscarPerfil = (usuarioId) =>
  prisma().perfilUsuario.findUnique({ where: { usuarioId } });
