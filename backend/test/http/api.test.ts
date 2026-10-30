import { SignJWT, createLocalJWKSet, exportJWK, generateKeyPair } from 'jose';
type ChavePrivada = Awaited<ReturnType<typeof generateKeyPair>>['privateKey'];

import type * as PrismaCompartilhado from '../../src/shared/db/prisma.js';
import type { Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';

// Só este arquivo usa um limite de escrita baixo, para provar o 429.
vi.hoisted(() => {
  process.env['RATE_LIMIT_ESCRITA_POR_MINUTO'] = '3';
});

// A sonda de saúde fala com o banco; aqui é simulada. Nenhum teste deste arquivo toca em banco real.
vi.mock('../../src/shared/db/prisma.js', async (original) => ({
  ...(await original<typeof PrismaCompartilhado>()),
  pingBanco: vi.fn(async () => true),
}));

import { criarApp } from '../../src/app.js';
import { definirDependenciasDeAuth } from '../../src/modules/usuarios/index.js';
import { criarVerificadorJwt } from '../../src/shared/auth/jwt.js';
import { pingBanco } from '../../src/shared/db/prisma.js';

const URL_PROJETO = 'https://projeto-ficticio.supabase.co';
const perfis = new Map([
  [
    'id-atendente',
    {
      usuarioId: 'id-atendente',
      nome: 'Ana',
      email: 'ana@teste.local',
      perfil: 'ATENDENTE' as const,
      ativo: true,
    },
  ],
  [
    'id-inativo',
    {
      usuarioId: 'id-inativo',
      nome: 'Inativo',
      email: 'i@teste.local',
      perfil: 'MECANICO' as const,
      ativo: false,
    },
  ],
]);

let servidor: Server;
let base: string;
let chave: ChavePrivada;

async function token(sub: string) {
  return new SignJWT({})
    .setProtectedHeader({ alg: 'ES256', kid: 'k1' })
    .setSubject(sub)
    .setIssuer(`${URL_PROJETO}/auth/v1`)
    .setAudience('authenticated')
    .setExpirationTime('1h')
    .sign(chave);
}
interface CorpoErro {
  erro: { codigo: string; mensagem: string };
}
interface DocumentoApi {
  paths: Record<string, { get: { security: unknown[] } }>;
}
const get = (caminho: string, t?: string) =>
  fetch(base + caminho, { headers: t ? { authorization: `Bearer ${t}` } : {} });

beforeAll(async () => {
  const { publicKey, privateKey } = await generateKeyPair('ES256');
  chave = privateKey;
  const jwk = { ...(await exportJWK(publicKey)), kid: 'k1', alg: 'ES256' };
  definirDependenciasDeAuth({
    verificador: criarVerificadorJwt({
      supabaseUrl: URL_PROJETO,
      jwks: createLocalJWKSet({ keys: [jwk] }),
    }),
    buscaPerfil: async (id) => perfis.get(id) ?? null,
  });
  servidor = criarApp().listen(0);
  base = `http://127.0.0.1:${(servidor.address() as AddressInfo).port}`;
});
afterAll(() => servidor.close());

describe('GET /health', () => {
  it('responde 200 quando o banco responde', async () => {
    const r = await get('/health');
    expect(r.status).toBe(200);
    expect(await r.json()).toMatchObject({ status: 'ok', banco: 'ok' });
  });
  it('responde 503 quando o banco não responde', async () => {
    vi.mocked(pingBanco).mockResolvedValueOnce(false);
    const r = await get('/health');
    expect(r.status).toBe(503);
    expect(await r.json()).toMatchObject({ status: 'degradado', banco: 'indisponivel' });
  });
});

describe('GET /api/v1/me', () => {
  it('sem token recebe 401 no formato padrão de erro', async () => {
    const r = await get('/api/v1/me');
    expect(r.status).toBe(401);
    expect(await r.json()).toEqual({
      erro: { codigo: 'nao_autorizado', mensagem: 'Autenticação necessária' },
    });
  });
  it('com token inválido recebe 401', async () => {
    expect((await get('/api/v1/me', 'lixo')).status).toBe(401);
  });
  it('com token válido e perfil ativo devolve o usuário e o perfil', async () => {
    const r = await get('/api/v1/me', await token('id-atendente'));
    expect(r.status).toBe(200);
    expect(await r.json()).toEqual({
      id: 'id-atendente',
      nome: 'Ana',
      email: 'ana@teste.local',
      perfil: 'ATENDENTE',
    });
  });
  it('token válido de quem não tem perfil recebe 403', async () => {
    const r = await get('/api/v1/me', await token('id-sem-perfil'));
    expect(r.status).toBe(403);
    expect(((await r.json()) as CorpoErro).erro.codigo).toBe('usuario_sem_perfil');
  });
  it('token válido de usuário inativo recebe 403', async () => {
    const r = await get('/api/v1/me', await token('id-inativo'));
    expect(r.status).toBe(403);
    const corpo = (await r.json()) as CorpoErro;
    expect(corpo.erro.mensagem).toBe('Usuário inativo');
    expect(corpo.erro.codigo).toBe('usuario_inativo');
  });
});

describe('comportamento geral da API', () => {
  it('rota inexistente devolve 404 em JSON', async () => {
    const r = await get('/api/v1/nao-existe');
    expect(r.status).toBe(404);
    expect(((await r.json()) as CorpoErro).erro.codigo).toBe('nao_encontrado');
  });
  it('não revela a tecnologia (sem x-powered-by) e envia cabeçalhos do helmet', async () => {
    const r = await get('/health');
    expect(r.headers.get('x-powered-by')).toBeNull();
    expect(r.headers.get('x-content-type-options')).toBe('nosniff');
  });
  it('CORS libera localhost em desenvolvimento e barra origem desconhecida', async () => {
    const ok = await fetch(base + '/health', { headers: { origin: 'http://localhost:51234' } });
    expect(ok.headers.get('access-control-allow-origin')).toBe('http://localhost:51234');
    const barrada = await fetch(base + '/health', {
      headers: { origin: 'https://site-malicioso.com' },
    });
    expect(barrada.headers.get('access-control-allow-origin')).toBeNull();
  });
  it('JSON malformado devolve 400 sem vazar detalhe', async () => {
    const r = await fetch(base + '/api/v1/me', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: '{quebrado',
    });
    expect(r.status).toBe(400);
    expect(((await r.json()) as CorpoErro).erro.codigo).toBe('json_invalido');
  });
  it('limita as escritas por IP (429 depois do limite)', async () => {
    const status: number[] = [];
    for (let i = 0; i < 6; i++)
      status.push((await fetch(base + '/api/v1/me', { method: 'POST' })).status);
    expect(status).toContain(429);
  });
  it('documenta GET /me no OpenAPI', async () => {
    const doc = (await (await get('/openapi.json')).json()) as DocumentoApi;
    expect(doc.paths['/me']?.get.security).toEqual([{ bearerAuth: [] }]);
  });
});
