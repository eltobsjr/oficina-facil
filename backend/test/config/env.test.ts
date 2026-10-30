import { describe, expect, it } from 'vitest';
import { carregarEnv, origensCors } from '../../src/config/env.js';

const base = { DATABASE_URL: 'postgresql://u:p@h/db', SUPABASE_URL: 'https://x.supabase.co' };

describe('configuração do ambiente', () => {
  it('aplica os padrões quando só o obrigatório está definido', () => {
    const e = carregarEnv(base);
    expect(e.PORT).toBe(3000);
    expect(e.NODE_ENV).toBe('development');
    expect(e.SUPABASE_SERVICE_ROLE_KEY).toBeUndefined();
  });

  it('recusa subir com configuração incompleta e lista o que falta', () => {
    expect(() => carregarEnv({})).toThrow(/DATABASE_URL/);
    expect(() => carregarEnv({})).toThrow(/SUPABASE_URL/);
  });

  it('recusa SUPABASE_URL que não é URL', () => {
    expect(() => carregarEnv({ ...base, SUPABASE_URL: 'não é url' })).toThrow(/SUPABASE_URL/);
  });

  it('trata variável opcional vazia como não definida', () => {
    const e = carregarEnv({ ...base, SUPABASE_SERVICE_ROLE_KEY: '', DIRECT_URL: '' });
    expect(e.SUPABASE_SERVICE_ROLE_KEY).toBeUndefined();
    expect(e.DIRECT_URL).toBeUndefined();
  });

  it('separa as origens do CORS por vírgula', () => {
    const e = carregarEnv({ ...base, CORS_ORIGINS: 'https://a.com, https://b.com ,' });
    expect(origensCors(e)).toEqual(['https://a.com', 'https://b.com']);
  });

  it('o erro de validação não repete o valor das variáveis', () => {
    try {
      carregarEnv({ ...base, DATABASE_URL: '', SUPABASE_URL: 'segredo-que-nao-e-url' });
    } catch (erro) {
      expect(String(erro)).not.toContain('segredo-que-nao-e-url');
    }
  });
});
