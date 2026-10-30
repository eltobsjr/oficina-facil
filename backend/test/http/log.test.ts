import { Writable } from 'node:stream';
import pino from 'pino';
import { describe, expect, it } from 'vitest';
import { REDACAO } from '../../src/shared/logger.js';

describe('redação de segredos no log', () => {
  it('a configuração real redige authorization, senha e password', () => {
    const saida: string[] = [];
    const destino = new Writable({ write: (c, _e, cb) => (saida.push(String(c)), cb()) });
    const log = pino({ level: 'info', redact: REDACAO }, destino);

    log.info(
      {
        req: {
          headers: { authorization: 'Bearer SEGREDO' },
          body: { senha: 'SEGREDO', password: 'SEGREDO' },
        },
        usuario: { senha: 'SEGREDO' },
      },
      'requisição',
    );

    const linha = saida.join('');
    expect(linha).not.toContain('SEGREDO');
    expect(linha).toContain('[redigido]');
  });
});
