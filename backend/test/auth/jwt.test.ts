import { SignJWT, createLocalJWKSet, exportJWK, generateKeyPair } from 'jose';
import { beforeAll, describe, expect, it } from 'vitest';
import { criarVerificadorJwt, extrairBearer } from '../../src/shared/auth/jwt.js';
import { NaoAutorizado } from '../../src/shared/errors/app-error.js';

type ChavePrivada = Awaited<ReturnType<typeof generateKeyPair>>['privateKey'];

const URL_PROJETO = 'https://projeto-ficticio.supabase.co';
const ISSUER = `${URL_PROJETO}/auth/v1`;

let chavePrivada: ChavePrivada;
let verificar: ReturnType<typeof criarVerificadorJwt>;

async function assinar(
  opcoes: { alg?: string; aud?: string; iss?: string; exp?: string; sub?: string | null } = {},
) {
  const jwt = new SignJWT({ role: 'authenticated', email: 'a@b.com' })
    .setProtectedHeader({ alg: opcoes.alg ?? 'ES256', kid: 'k1' })
    .setIssuer(opcoes.iss ?? ISSUER)
    .setAudience(opcoes.aud ?? 'authenticated')
    .setIssuedAt()
    .setExpirationTime(opcoes.exp ?? '1h');
  if (opcoes.sub !== null) jwt.setSubject(opcoes.sub ?? 'usuario-1');
  return jwt.sign(chavePrivada);
}

beforeAll(async () => {
  const { publicKey, privateKey } = await generateKeyPair('ES256');
  chavePrivada = privateKey;
  const jwk = { ...(await exportJWK(publicKey)), kid: 'k1', alg: 'ES256', use: 'sig' };
  verificar = criarVerificadorJwt({
    supabaseUrl: URL_PROJETO,
    jwks: createLocalJWKSet({ keys: [jwk] }),
  });
});

describe('validação do JWT do Supabase', () => {
  it('aceita token válido e devolve as claims', async () => {
    const claims = await verificar(await assinar());
    expect(claims.sub).toBe('usuario-1');
  });

  it('recusa token expirado', async () => {
    await expect(verificar(await assinar({ exp: '-1h' }))).rejects.toBeInstanceOf(NaoAutorizado);
  });

  it('recusa audiência diferente de authenticated', async () => {
    await expect(verificar(await assinar({ aud: 'anon' }))).rejects.toBeInstanceOf(NaoAutorizado);
  });

  it('recusa emissor de outro projeto', async () => {
    await expect(
      verificar(await assinar({ iss: 'https://outro.supabase.co/auth/v1' })),
    ).rejects.toBeInstanceOf(NaoAutorizado);
  });

  it('recusa token sem sub', async () => {
    await expect(verificar(await assinar({ sub: null }))).rejects.toBeInstanceOf(NaoAutorizado);
  });

  it('recusa token HS256 (sem fallback por segredo)', async () => {
    const hs = await new SignJWT({})
      .setProtectedHeader({ alg: 'HS256' })
      .setSubject('x')
      .setIssuer(ISSUER)
      .setAudience('authenticated')
      .setExpirationTime('1h')
      .sign(new TextEncoder().encode('segredo-compartilhado-de-teste'));
    await expect(verificar(hs)).rejects.toThrow(/Algoritmo/);
  });

  it('recusa token assinado por outra chave', async () => {
    const { privateKey } = await generateKeyPair('ES256');
    const forjado = await new SignJWT({})
      .setProtectedHeader({ alg: 'ES256', kid: 'k1' })
      .setSubject('x')
      .setIssuer(ISSUER)
      .setAudience('authenticated')
      .setExpirationTime('1h')
      .sign(privateKey);
    await expect(verificar(forjado)).rejects.toBeInstanceOf(NaoAutorizado);
  });

  it('recusa token malformado sem vazar a causa', async () => {
    await expect(verificar('isto-nao-e-jwt')).rejects.toThrow('Token malformado');
  });
});

describe('extração do Bearer', () => {
  it('lê o token do cabeçalho Authorization', () => {
    expect(extrairBearer('Bearer abc')).toBe('abc');
    expect(extrairBearer('bearer abc')).toBe('abc');
  });
  it('devolve null quando falta ou está fora do formato', () => {
    expect(extrairBearer(undefined)).toBeNull();
    expect(extrairBearer('Basic abc')).toBeNull();
    expect(extrairBearer('Bearer')).toBeNull();
  });
});
