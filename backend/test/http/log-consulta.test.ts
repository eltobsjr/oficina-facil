import express from 'express';
import type { Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import { Writable } from 'node:stream';
import pino from 'pino';
import { afterEach, describe, expect, it } from 'vitest';
import { caminhoSemQuery, logHttp } from '../../src/shared/http/log.js';

let servidor: Server | undefined;
afterEach(() => servidor?.close());

describe('log HTTP sem query string', () => {
  it('caminhoSemQuery corta a partir do ponto de interrogação', () => {
    expect(caminhoSemQuery('/api/v1/clientes?q=52998224725&pagina=1')).toBe('/api/v1/clientes');
    expect(caminhoSemQuery('/api/v1/clientes')).toBe('/api/v1/clientes');
    expect(caminhoSemQuery(undefined)).toBe('');
  });

  it('a linha de log de uma busca por documento traz só o caminho', async () => {
    const saida: string[] = [];
    const destino = new Writable({ write: (c, _e, cb) => (saida.push(String(c)), cb()) });
    const app = express();
    app.use(logHttp(pino({ level: 'info' }, destino)));
    app.get('/api/v1/clientes', (_req, res) => res.json({ ok: true }));
    servidor = app.listen(0);
    const porta = (servidor.address() as AddressInfo).port;

    await fetch(`http://127.0.0.1:${porta}/api/v1/clientes?q=52998224725`);
    await new Promise((ok) => setTimeout(ok, 50));

    const linhas = saida.join('');
    expect(linhas).toContain('/api/v1/clientes');
    expect(linhas).not.toContain('52998224725');
    expect(linhas).not.toContain('q=');
  });
});
