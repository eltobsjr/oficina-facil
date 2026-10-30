import type { Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import { afterEach, describe, expect, it } from 'vitest';
import { criarApp } from '../../src/app.js';
import { env } from '../../src/config/env.js';

let servidor: Server | undefined;
afterEach(() => servidor?.close());

async function statusDe(nodeEnv: 'test' | 'production', caminho: string): Promise<number> {
  servidor = criarApp({ ...env(), NODE_ENV: nodeEnv }).listen(0);
  const porta = (servidor.address() as AddressInfo).port;
  return (await fetch(`http://127.0.0.1:${porta}${caminho}`)).status;
}

describe('documentação da API (Swagger e OpenAPI)', () => {
  it('fora de produção expõe /docs e /openapi.json', async () => {
    expect(await statusDe('test', '/openapi.json')).toBe(200);
    expect(await statusDe('test', '/docs')).toBe(200);
  });
  it('em produção não expõe o contrato nem o Swagger', async () => {
    expect(await statusDe('production', '/openapi.json')).toBe(404);
    expect(await statusDe('production', '/docs')).toBe(404);
  });
});
