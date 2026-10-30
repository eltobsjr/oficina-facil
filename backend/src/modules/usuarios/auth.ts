/**
 * Middlewares de autenticação e autorização.
 *
 * `autenticar` valida o Bearer token do Supabase (JWKS), carrega o perfil e o coloca em
 * `res.locals.usuario`. `exigirPerfis` restringe a rota aos perfis permitidos (RN09).
 */

import type { RequestHandler, Response } from 'express';
import { env } from '../../config/env.js';
import { criarVerificadorJwt, extrairBearer, type VerificadorJwt } from '../../shared/auth/jwt.js';
import type { Papel } from '../../shared/db/prisma.js';
import { NaoAutorizado, Proibido } from '../../shared/errors/app-error.js';
import { usuarioDoToken, type UsuarioAutenticado } from './service.js';
import type { BuscarPerfil } from './repository.js';

let verificador: VerificadorJwt | undefined;
let buscaPerfil: BuscarPerfil | undefined;

function verificadorJwt(): VerificadorJwt {
  verificador ??= criarVerificadorJwt({ supabaseUrl: env().SUPABASE_URL });
  return verificador;
}

/** Testes injetam um verificador com JWKS local e uma busca de perfil em memória. */
export function definirDependenciasDeAuth(deps: {
  verificador?: VerificadorJwt;
  buscaPerfil?: BuscarPerfil;
}) {
  verificador = deps.verificador;
  buscaPerfil = deps.buscaPerfil;
}

export const autenticar: RequestHandler = async (req, res, next) => {
  const token = extrairBearer(req.headers.authorization);
  if (!token) {
    next(new NaoAutorizado());
    return;
  }
  const claims = await verificadorJwt()(token);
  res.locals['usuario'] = await usuarioDoToken(claims, buscaPerfil);
  next();
};

export function usuarioDe(res: Response): UsuarioAutenticado {
  const usuario = res.locals['usuario'] as UsuarioAutenticado | undefined;
  if (!usuario) throw new NaoAutorizado();
  return usuario;
}

export function exigirPerfis(...perfis: Papel[]): RequestHandler {
  return (_req, res, next) => {
    const usuario = usuarioDe(res);
    if (!perfis.includes(usuario.perfil)) {
      next(new Proibido(`Requer um dos perfis: ${perfis.join(', ')}`));
      return;
    }
    next();
  };
}
