/**
 * Sobe a API de verdade (Express numa porta efêmera) com autenticação e usuários falsos.
 * O JWT é assinado por uma chave local e validado pelo mesmo código de produção, via JWKS local.
 */

import { SignJWT, createLocalJWKSet, exportJWK, generateKeyPair } from 'jose';
import type { Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import { criarApp } from '../../src/app.js';
import {
  definirDependenciasDeAuth,
  definirDependenciasDeUsuarios,
} from '../../src/modules/usuarios/index.js';
import { criarVerificadorJwt } from '../../src/shared/auth/jwt.js';
import { AdminFalso, type RepositorioEmMemoria } from './usuarios-fakes.js';

export const URL_PROJETO = 'https://projeto-ficticio.supabase.co';

type ParDeChaves = Awaited<ReturnType<typeof generateKeyPair>>;

export interface ApiDeTeste {
  base: string;
  repo: RepositorioEmMemoria;
  admin: AdminFalso;
  token(usuarioId: string): Promise<string>;
  requisitar(
    metodo: string,
    caminho: string,
    opcoes?: { token?: string; corpo?: unknown },
  ): Promise<Response>;
  encerrar(): Promise<void>;
}

export async function iniciarApi(repo: RepositorioEmMemoria): Promise<ApiDeTeste> {
  const { publicKey, privateKey }: ParDeChaves = await generateKeyPair('ES256');
  const jwk = { ...(await exportJWK(publicKey)), kid: 'k1', alg: 'ES256' };
  const admin = new AdminFalso();

  definirDependenciasDeAuth({
    verificador: criarVerificadorJwt({
      supabaseUrl: URL_PROJETO,
      jwks: createLocalJWKSet({ keys: [jwk] }),
    }),
    buscaPerfil: (id) => repo.buscarPorId(id),
  });
  definirDependenciasDeUsuarios({ repo, admin: () => admin });

  const servidor: Server = criarApp().listen(0);
  const base = `http://127.0.0.1:${(servidor.address() as AddressInfo).port}/api/v1`;

  return {
    base,
    repo,
    admin,
    token: (usuarioId) =>
      new SignJWT({})
        .setProtectedHeader({ alg: 'ES256', kid: 'k1' })
        .setSubject(usuarioId)
        .setIssuer(`${URL_PROJETO}/auth/v1`)
        .setAudience('authenticated')
        .setExpirationTime('1h')
        .sign(privateKey),
    requisitar: (metodo, caminho, opcoes = {}) =>
      fetch(base + caminho, {
        method: metodo,
        headers: {
          ...(opcoes.token ? { authorization: `Bearer ${opcoes.token}` } : {}),
          ...(opcoes.corpo !== undefined ? { 'content-type': 'application/json' } : {}),
        },
        ...(opcoes.corpo !== undefined ? { body: JSON.stringify(opcoes.corpo) } : {}),
      }),
    encerrar: async () => {
      definirDependenciasDeAuth({});
      definirDependenciasDeUsuarios(undefined);
      await new Promise<void>((ok) => servidor.close(() => ok()));
    },
  };
}
