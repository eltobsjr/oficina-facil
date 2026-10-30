/**
 * Testes de integração do banco: restrições, gatilhos, índice parcial, FK para auth.users e RLS.
 *
 * Só rodam contra o projeto Supabase de TESTE (regra R19): exigem TEST_DIRECT_URL, e a sondagem
 * de RLS exige também TEST_SUPABASE_URL e TEST_SUPABASE_PUBLISHABLE_KEY. Sem elas, são ignorados.
 * Cada teste roda numa transação que termina sempre em ROLLBACK: não deixam dado nenhum.
 * Todos os dados são fictícios (regra R28).
 */

import dotenv from 'dotenv';
import pg from 'pg';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

dotenv.config({ quiet: true });

const urlBanco = process.env['TEST_DIRECT_URL'];
const urlApi = process.env['TEST_SUPABASE_URL'];
const chavePublicavel = process.env['TEST_SUPABASE_PUBLISHABLE_KEY'];

describe.skipIf(!urlBanco)('banco (projeto de teste)', () => {
  let cliente: pg.Client;

  beforeAll(async () => {
    cliente = new pg.Client({ connectionString: urlBanco });
    await cliente.connect();
  });
  afterAll(async () => {
    await cliente.end();
  });

  /** Roda `fn` dentro de uma transação e sempre desfaz. */
  async function emTransacao<T>(fn: () => Promise<T>): Promise<T> {
    await cliente.query('BEGIN');
    try {
      return await fn();
    } finally {
      await cliente.query('ROLLBACK');
    }
  }

  /** Executa um comando que deve falhar e devolve a mensagem, sem abortar a transação do teste. */
  async function falha(sql: string, params: unknown[] = []): Promise<string> {
    await cliente.query('SAVEPOINT s');
    try {
      await cliente.query(sql, params);
      return '';
    } catch (erro) {
      await cliente.query('ROLLBACK TO SAVEPOINT s');
      return (erro as Error).message;
    }
  }

  const uuid = async () =>
    (await cliente.query<{ id: string }>('SELECT gen_random_uuid() AS id')).rows[0]!.id;

  /** Cria usuário no Auth, perfil, cliente e veículo fictícios. */
  async function cenario() {
    const usuario = await uuid();
    await cliente.query(
      "INSERT INTO auth.users (id, aud, role, email) VALUES ($1, 'authenticated', 'authenticated', $2)",
      [usuario, `${usuario}@teste.local`],
    );
    await cliente.query(
      "INSERT INTO perfis (usuario_id, nome, email, perfil) VALUES ($1, 'Teste', $2, 'GERENTE')",
      [usuario, `${usuario}@teste.local`],
    );
    const c = await cliente.query<{ id: string }>(
      "INSERT INTO clientes (nome, documento, telefone) VALUES ('Cliente Fictício', $1, '11999990000') RETURNING id",
      [usuario.replace(/\D/g, '').slice(0, 11).padEnd(11, '0')],
    );
    const v = await cliente.query<{ id: string }>(
      "INSERT INTO veiculos (cliente_id, placa, marca, modelo, ano, quilometragem) VALUES ($1, $2, 'Marca', 'Modelo', 2020, 1000) RETURNING id",
      [
        c.rows[0]!.id,
        `T${usuario
          .replace(/[^0-9A-Z]/gi, '')
          .slice(0, 6)
          .toUpperCase()}`,
      ],
    );
    return { usuario, clienteId: c.rows[0]!.id, veiculoId: v.rows[0]!.id };
  }

  async function abrirOs(ctx: { usuario: string; clienteId: string; veiculoId: string }) {
    const r = await cliente.query<{ id: string }>(
      "INSERT INTO ordens_servico (cliente_id, veiculo_id, queixa, quilometragem_entrada, aberta_por) VALUES ($1, $2, 'barulho', 1000, $3) RETURNING id",
      [ctx.clienteId, ctx.veiculoId, ctx.usuario],
    );
    return r.rows[0]!.id;
  }

  it('peça com saldo negativo ou preço zero é recusada', () =>
    emTransacao(async () => {
      expect(
        await falha(
          "INSERT INTO pecas (codigo, descricao, preco_centavos, saldo) VALUES ('X1', 'x', 100, -1)",
        ),
      ).toMatch(/pecas_saldo_nao_negativo/);
      expect(
        await falha("INSERT INTO pecas (codigo, descricao, preco_centavos) VALUES ('X2', 'x', 0)"),
      ).toMatch(/pecas_preco_positivo/);
    }));

  it('perfil sem usuário no Supabase Auth é recusado (FK)', () =>
    emTransacao(async () => {
      const erro = await falha(
        "INSERT INTO perfis (usuario_id, nome, email, perfil) VALUES (gen_random_uuid(), 'x', 'x@x', 'GERENTE')",
      );
      expect(erro).toMatch(/perfis_usuario_id_fkey_auth/);
    }));

  it('desconto maior que o subtotal e total que não confere são recusados', () =>
    emTransacao(async () => {
      const ctx = await cenario();
      const os = await abrirOs(ctx);
      expect(
        await falha(
          'INSERT INTO orcamentos (os_id, subtotal_centavos, desconto_centavos, total_centavos) VALUES ($1, 1000, 1500, -500)',
          [os],
        ),
      ).toMatch(/orcamentos_desconto_coerente/);
      expect(
        await falha(
          'INSERT INTO orcamentos (os_id, subtotal_centavos, desconto_centavos, total_centavos) VALUES ($1, 1000, 100, 1000)',
          [os],
        ),
      ).toMatch(/orcamentos_total_confere/);
      await cliente.query(
        'INSERT INTO orcamentos (os_id, subtotal_centavos, desconto_centavos, total_centavos) VALUES ($1, 1000, 100, 900)',
        [os],
      );
    }));

  it('só uma OS ativa por veículo; depois de cancelada, outra pode abrir', () =>
    emTransacao(async () => {
      const ctx = await cenario();
      const os = await abrirOs(ctx);
      expect(
        await falha(
          "INSERT INTO ordens_servico (cliente_id, veiculo_id, queixa, quilometragem_entrada, aberta_por) VALUES ($1, $2, 'outra', 1, $3)",
          [ctx.clienteId, ctx.veiculoId, ctx.usuario],
        ),
      ).toMatch(/ordens_servico_uma_ativa_por_veiculo/);
      await cliente.query("UPDATE ordens_servico SET status = 'CANCELADA' WHERE id = $1", [os]);
      await abrirOs(ctx);
    }));

  it('movimentação, histórico e pagamentos são só de inserção', () =>
    emTransacao(async () => {
      const ctx = await cenario();
      const os = await abrirOs(ctx);
      const peca = await cliente.query<{ id: string }>(
        "INSERT INTO pecas (codigo, descricao, preco_centavos) VALUES ('P-T', 'x', 100) RETURNING id",
      );
      await cliente.query(
        "INSERT INTO movimentacoes_estoque (peca_id, tipo, quantidade, usuario_id) VALUES ($1, 'ENTRADA', 5, $2)",
        [peca.rows[0]!.id, ctx.usuario],
      );
      await cliente.query(
        "INSERT INTO historico_transicoes (os_id, para, usuario_id) VALUES ($1, 'ABERTA', $2)",
        [os, ctx.usuario],
      );
      await cliente.query(
        "INSERT INTO pagamentos (os_id, forma, valor_centavos, usuario_id) VALUES ($1, 'PIX', 100, $2)",
        [os, ctx.usuario],
      );

      for (const tabela of ['movimentacoes_estoque', 'historico_transicoes', 'pagamentos']) {
        expect(await falha(`DELETE FROM ${tabela}`), `DELETE em ${tabela}`).toMatch(
          /só de inserção/,
        );
        expect(await falha(`TRUNCATE ${tabela}`), `TRUNCATE em ${tabela}`).toMatch(
          /só de inserção/,
        );
      }
      expect(await falha('UPDATE pagamentos SET valor_centavos = 1')).toMatch(/só de inserção/);
      expect(await falha('UPDATE movimentacoes_estoque SET quantidade = 99')).toMatch(
        /só de inserção/,
      );
    }));

  it('autorização de desconto só pode ser decidida com gerente e data', () =>
    emTransacao(async () => {
      const ctx = await cenario();
      const os = await abrirOs(ctx);
      const orc = await cliente.query<{ id: string }>(
        'INSERT INTO orcamentos (os_id, subtotal_centavos, desconto_centavos, total_centavos) VALUES ($1, 1000, 0, 1000) RETURNING id',
        [os],
      );
      const id = orc.rows[0]!.id;
      expect(
        await falha(
          "INSERT INTO autorizacoes_desconto (orcamento_id, atendente_id, status, subtotal_centavos_ref, desconto_solicitado_centavos) VALUES ($1, $2, 'APROVADA', 1000, 200)",
          [id, ctx.usuario],
        ),
      ).toMatch(/desconto_decisao_coerente/);
      expect(
        await falha(
          "INSERT INTO autorizacoes_desconto (orcamento_id, atendente_id, gerente_id, status, subtotal_centavos_ref, desconto_solicitado_centavos, desconto_autorizado_centavos, decidido_em) VALUES ($1, $2, $2, 'APROVADA', 1000, 200, 300, now())",
          [id, ctx.usuario],
        ),
      ).toMatch(/desconto_autorizado_coerente/);
    }));

  it('toda tabela de public tem RLS ligada e o app só tem SELECT em avisos', async () => {
    const sem = await cliente.query(
      "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND NOT rowsecurity",
    );
    expect(sem.rows).toEqual([]);
    const grants = await cliente.query(
      "SELECT table_name, privilege_type FROM information_schema.role_table_grants WHERE table_schema = 'public' AND grantee IN ('anon', 'authenticated')",
    );
    expect(grants.rows).toEqual([{ table_name: 'avisos', privilege_type: 'SELECT' }]);
  });
});

describe.skipIf(!urlApi || !chavePublicavel)(
  'RLS com a chave publicável (projeto de teste)',
  () => {
    const tabelas = [
      'perfis',
      'clientes',
      'veiculos',
      'servicos',
      'pecas',
      'movimentacoes_estoque',
      'ordens_servico',
      'diagnosticos',
      'orcamentos',
      'itens_orcamento',
      'autorizacoes_desconto',
      'aprovacoes',
      'observacoes',
      'pecas_usadas',
      'pagamentos',
      'historico_transicoes',
    ];
    const cabecalhos = {
      apikey: chavePublicavel ?? '',
      authorization: `Bearer ${chavePublicavel ?? ''}`,
    };

    it.each(tabelas)('sem login não lê %s', async (tabela) => {
      const r = await fetch(`${urlApi}/rest/v1/${tabela}?select=*`, { headers: cabecalhos });
      const corpo: unknown = await r.json();
      expect(
        r.status === 401 || (r.status === 200 && Array.isArray(corpo) && corpo.length === 0),
      ).toBe(true);
    });

    it('sem login não escreve em clientes', async () => {
      const r = await fetch(`${urlApi}/rest/v1/clientes`, {
        method: 'POST',
        headers: { ...cabecalhos, 'content-type': 'application/json' },
        body: JSON.stringify({ nome: 'x', documento: '1', telefone: '1' }),
      });
      expect(r.status).toBeGreaterThanOrEqual(400);
    });
  },
);
