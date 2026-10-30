import { describe, expect, it } from 'vitest';
import { ehCaminhoLivre, ehEscrita } from '../../src/shared/http/rate-limit.js';

describe('classificação das rotas para o rate limit', () => {
  it('sonda de saúde e documentação não entram na conta', () => {
    expect(ehCaminhoLivre('/health')).toBe(true);
    expect(ehCaminhoLivre('/docs')).toBe(true);
    expect(ehCaminhoLivre('/docs/swagger-ui.css')).toBe(true);
    expect(ehCaminhoLivre('/openapi.json')).toBe(true);
    expect(ehCaminhoLivre('/api/v1/me')).toBe(false);
  });
  it('só métodos que mudam estado são escrita', () => {
    for (const m of ['POST', 'PUT', 'PATCH', 'DELETE']) expect(ehEscrita(m)).toBe(true);
    for (const m of ['GET', 'HEAD', 'OPTIONS']) expect(ehEscrita(m)).toBe(false);
  });
});
