/**
 * Regras de autenticação do módulo: quem é o usuário e se pode entrar.
 *
 * O JWT identifica a pessoa; o perfil vem da tabela `perfis` (nunca de um campo editável pelo
 * usuário). Usuário sem perfil ou inativo recebe 403 mesmo com token válido (RN09).
 */

import type { Papel } from '../../shared/db/prisma.js';
import { Proibido } from '../../shared/errors/app-error.js';
import type { ClaimsSupabase } from '../../shared/auth/jwt.js';
import { buscarPerfil, type BuscarPerfil } from './repository.js';

export interface UsuarioAutenticado {
  id: string;
  nome: string;
  email: string;
  perfil: Papel;
}

export async function usuarioDoToken(
  claims: ClaimsSupabase,
  buscar: BuscarPerfil = buscarPerfil,
): Promise<UsuarioAutenticado> {
  const registro = await buscar(claims.sub);
  if (!registro) throw new Proibido('Usuário sem perfil cadastrado');
  if (!registro.ativo) throw new Proibido('Usuário inativo');
  return {
    id: registro.usuarioId,
    nome: registro.nome,
    email: registro.email,
    perfil: registro.perfil,
  };
}
