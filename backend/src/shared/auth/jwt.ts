/**
 * Validação do JWT emitido pelo Supabase Auth (decisão 002).
 *
 * Só aceita assinatura assimétrica (ES256 ou RS256) verificada pelo JWKS do projeto, e confere
 * `iss`, `aud` (`authenticated`) e `exp`. Tokens HS256 são recusados: o fallback por segredo
 * compartilhado não foi adotado (abriria confusão de algoritmo e exigiria o segredo no backend).
 */

import { createRemoteJWKSet, decodeProtectedHeader, jwtVerify, type JWTVerifyGetKey } from 'jose';
import { NaoAutorizado } from '../errors/app-error.js';

export interface ClaimsSupabase {
  sub: string;
  email?: string;
  role?: string;
  exp?: number;
}

export interface OpcoesVerificadorJwt {
  supabaseUrl: string;
  /** Injetável em testes (`createLocalJWKSet`). Padrão: JWKS remoto do projeto, com cache. */
  jwks?: JWTVerifyGetKey;
}

export type VerificadorJwt = (token: string) => Promise<ClaimsSupabase>;

const ALGORITMOS = ['ES256', 'RS256'];

export function criarVerificadorJwt(opcoes: OpcoesVerificadorJwt): VerificadorJwt {
  const issuer = `${opcoes.supabaseUrl.replace(/\/$/, '')}/auth/v1`;
  const jwks = opcoes.jwks ?? createRemoteJWKSet(new URL(`${issuer}/.well-known/jwks.json`));

  return async (token) => {
    try {
      const { alg } = decodeProtectedHeader(token);
      if (!alg || !ALGORITMOS.includes(alg))
        throw new NaoAutorizado('Algoritmo de token não aceito');
    } catch (erro) {
      if (erro instanceof NaoAutorizado) throw erro;
      throw new NaoAutorizado('Token malformado');
    }
    try {
      const { payload } = await jwtVerify(token, jwks, {
        issuer,
        audience: 'authenticated',
        algorithms: ALGORITMOS,
      });
      if (typeof payload['sub'] !== 'string' || payload['sub'].length === 0) {
        throw new NaoAutorizado('Token sem identificador de usuário');
      }
      return payload as unknown as ClaimsSupabase;
    } catch (erro) {
      if (erro instanceof NaoAutorizado) throw erro;
      // Mensagem genérica: não revela se faltou assinatura, validade ou audiência.
      throw new NaoAutorizado('Token inválido ou expirado');
    }
  };
}

export function extrairBearer(cabecalho: string | undefined): string | null {
  if (!cabecalho) return null;
  const [esquema, token] = cabecalho.split(' ');
  if (esquema?.toLowerCase() !== 'bearer' || !token) return null;
  return token;
}
