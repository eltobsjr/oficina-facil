/**
 * Integração do repositório de usuários: a trava do "último gerente" sob concorrência.
 *
 * Só roda contra o projeto Supabase de TESTE (regra R19): exige TEST_DATABASE_URL e TEST_DIRECT_URL.
 * Cria os próprios dados fictícios e os remove no fim; desativa temporariamente outros gerentes
 * que existam no projeto de teste e os restaura.
 */

import { PrismaPg } from '@prisma/adapter-pg';
import dotenv from 'dotenv';
import pg from 'pg';
import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { PrismaClient } from '../../src/generated/prisma/client.js';
import { criarRepositorioPrisma } from '../../src/modules/usuarios/repository.js';

dotenv.config({ quiet: true });

const urlApi = process.env['TEST_DATABASE_URL'];
const urlDireta = process.env['TEST_DIRECT_URL'];

describe.skipIf(!urlApi || !urlDireta)('repositório de usuários (projeto de teste)', () => {
  const direto = new pg.Client({ connectionString: urlDireta });
  const prisma = new PrismaClient({ adapter: new PrismaPg({ connectionString: urlApi ?? '' }) });
  const repo = criarRepositorioPrisma(() => prisma);
  const criados: string[] = [];
  let gerentesDesativados: string[] = [];

  async function novoGerente(): Promise<string> {
    const id = randomUUID();
    await direto.query(
      "INSERT INTO auth.users (id, aud, role, email) VALUES ($1, 'authenticated', 'authenticated', $2)",
      [id, `${id}@teste.local`],
    );
    await repo.criar({
      usuarioId: id,
      nome: 'Gerente de Teste',
      email: `${id}@teste.local`,
      perfil: 'GERENTE',
    });
    criados.push(id);
    return id;
  }

  beforeAll(async () => {
    await direto.connect();
    const outros = await direto.query<{ usuario_id: string }>(
      "SELECT usuario_id FROM perfis WHERE perfil = 'GERENTE' AND ativo = true",
    );
    gerentesDesativados = outros.rows.map((r) => r.usuario_id);
    if (gerentesDesativados.length > 0) {
      await direto.query('UPDATE perfis SET ativo = false WHERE usuario_id = ANY($1)', [
        gerentesDesativados,
      ]);
    }
  });

  afterAll(async () => {
    if (criados.length > 0) {
      await direto.query('DELETE FROM perfis WHERE usuario_id = ANY($1)', [criados]);
      await direto.query('DELETE FROM auth.users WHERE id = ANY($1)', [criados]);
    }
    if (gerentesDesativados.length > 0) {
      await direto.query('UPDATE perfis SET ativo = true WHERE usuario_id = ANY($1)', [
        gerentesDesativados,
      ]);
    }
    await direto.end();
    await prisma.$disconnect();
  });

  it('com um só gerente ativo, a inativação é recusada e nada muda', async () => {
    const unico = await novoGerente();
    expect(
      await repo.atualizar(unico, { ativo: false }, { exigirOutroGerenteAtivo: true }),
    ).toBeNull();
    expect((await repo.buscarPorId(unico))?.ativo).toBe(true);
    await direto.query('DELETE FROM perfis WHERE usuario_id = $1', [unico]);
    await direto.query('DELETE FROM auth.users WHERE id = $1', [unico]);
  });

  it('dois gerentes inativando um ao outro ao mesmo tempo: só um consegue', async () => {
    const a = await novoGerente();
    const b = await novoGerente();
    const resultados = await Promise.all([
      repo.atualizar(a, { ativo: false }, { exigirOutroGerenteAtivo: true }),
      repo.atualizar(b, { ativo: false }, { exigirOutroGerenteAtivo: true }),
    ]);
    expect(resultados.filter((r) => r !== null)).toHaveLength(1);
    const ativos = await direto.query(
      "SELECT count(*)::int AS n FROM perfis WHERE perfil = 'GERENTE' AND ativo = true AND usuario_id = ANY($1)",
      [[a, b]],
    );
    expect(ativos.rows[0]?.n).toBe(1);
  });
});
