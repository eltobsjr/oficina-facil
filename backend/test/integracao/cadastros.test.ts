/**
 * Integração dos repositórios de clientes e veículos: unicidade, inativação com OS ativa (índice
 * e estados de `ordens_servico`) e transferência de dono preservando o cliente das OS.
 *
 * Só roda com TEST_DATABASE_URL e TEST_DIRECT_URL definidas (regra R19) e nunca contra produção.
 * Cria os próprios dados fictícios (R28) e os remove no fim.
 */

import { PrismaPg } from '@prisma/adapter-pg';
import dotenv from 'dotenv';
import pg from 'pg';
import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { PrismaClient } from '../../src/generated/prisma/client.js';
import { criarRepositorioPrisma as criarRepoClientes } from '../../src/modules/clientes/repository.js';
import { criarRepositorioPrisma as criarRepoVeiculos } from '../../src/modules/veiculos/repository.js';

dotenv.config({ quiet: true });

const urlApi = process.env['TEST_DATABASE_URL'];
const urlDireta = process.env['TEST_DIRECT_URL'];

describe.skipIf(!urlApi || !urlDireta)(
  'repositórios de clientes e veículos (projeto de teste)',
  () => {
    const direto = new pg.Client({ connectionString: urlDireta });
    const prisma = new PrismaClient({ adapter: new PrismaPg({ connectionString: urlApi ?? '' }) });
    const clientes = criarRepoClientes(() => prisma);
    const veiculos = criarRepoVeiculos(() => prisma);

    const sufixo = randomUUID().replace(/\D/g, '').slice(0, 8).padEnd(8, '0');
    const usuarioId = randomUUID();
    const clientesCriados: string[] = [];
    const veiculosCriados: string[] = [];
    const osCriadas: string[] = [];

    // Documentos fictícios distintos por execução (o banco não valida o dígito verificador).
    const doc = (n: number) => `00${sufixo}${n}`;

    async function novoCliente(n: number) {
      const c = await clientes.criar({
        nome: `Cliente de teste ${n}`,
        documento: doc(n),
        telefone: '1100000000',
        email: null,
        endereco: null,
      });
      clientesCriados.push(c.id);
      return c;
    }

    async function novoVeiculo(clienteId: string, placa: string) {
      const v = await veiculos.criar({
        clienteId,
        placa,
        marca: 'Marca',
        modelo: 'Modelo',
        ano: 2015,
        cor: null,
        quilometragem: 1000,
      });
      veiculosCriados.push(v.id);
      return v;
    }

    async function novaOs(clienteId: string, veiculoId: string, status: string) {
      const r = await direto.query<{ id: string }>(
        `INSERT INTO ordens_servico (cliente_id, veiculo_id, queixa, quilometragem_entrada, status, aberta_por)
       VALUES ($1, $2, 'Teste', 1000, $3::status_enum, $4) RETURNING id`,
        [clienteId, veiculoId, status, usuarioId],
      );
      const id = r.rows[0]!.id;
      osCriadas.push(id);
      return id;
    }

    beforeAll(async () => {
      await direto.connect();
      await direto.query(
        "INSERT INTO auth.users (id, aud, role, email) VALUES ($1, 'authenticated', 'authenticated', $2)",
        [usuarioId, `${usuarioId}@teste.local`],
      );
      await direto.query(
        "INSERT INTO perfis (usuario_id, nome, email, perfil) VALUES ($1, 'Atendente de teste', $2, 'ATENDENTE')",
        [usuarioId, `${usuarioId}@teste.local`],
      );
    });

    afterAll(async () => {
      if (osCriadas.length > 0) {
        await direto.query('DELETE FROM ordens_servico WHERE id = ANY($1)', [osCriadas]);
      }
      if (veiculosCriados.length > 0) {
        await direto.query('DELETE FROM veiculos WHERE id = ANY($1)', [veiculosCriados]);
      }
      if (clientesCriados.length > 0) {
        await direto.query('DELETE FROM clientes WHERE id = ANY($1)', [clientesCriados]);
      }
      await direto.query('DELETE FROM perfis WHERE usuario_id = $1', [usuarioId]);
      await direto.query('DELETE FROM auth.users WHERE id = $1', [usuarioId]);
      await direto.end();
      await prisma.$disconnect();
    });

    it('documento e placa são únicos no banco', async () => {
      const c = await novoCliente(1);
      await expect(
        clientes.criar({
          nome: 'Outro',
          documento: c.documento,
          telefone: '1100000000',
          email: null,
          endereco: null,
        }),
      ).rejects.toMatchObject({ code: 'P2002' });
      await novoVeiculo(c.id, `ZZZ${sufixo.slice(0, 4)}`);
      await expect(novoVeiculo(c.id, `ZZZ${sufixo.slice(0, 4)}`)).rejects.toMatchObject({
        code: 'P2002',
      });
    });

    it('busca por nome e por parte do documento', async () => {
      const c = await novoCliente(2);
      const porNome = await clientes.listar({ pagina: 1, limite: 20, q: 'cliente de teste 2' });
      expect(porNome.itens.some((i) => i.id === c.id)).toBe(true);
      const porDoc = await clientes.listar({ pagina: 1, limite: 20, q: c.documento.slice(0, 8) });
      expect(porDoc.itens.some((i) => i.id === c.id)).toBe(true);
    });

    it('inativa cliente sem OS ativa', async () => {
      const c = await novoCliente(3);
      const inativo = await clientes.inativarSemOsAtiva(c.id);
      expect(inativo?.ativo).toBe(false);
    });

    it('cliente com OS ativa não é inativado; com OS entregue ou cancelada, é', async () => {
      const c = await novoCliente(4);
      const v = await novoVeiculo(c.id, `YYY${sufixo.slice(0, 4)}`);
      const os = await novaOs(c.id, v.id, 'EM_EXECUCAO');
      expect(await clientes.inativarSemOsAtiva(c.id)).toBeNull();
      expect((await clientes.buscarPorId(c.id))?.ativo).toBe(true);

      await direto.query("UPDATE ordens_servico SET status = 'ENTREGUE' WHERE id = $1", [os]);
      expect((await clientes.inativarSemOsAtiva(c.id))?.ativo).toBe(false);
    });

    it('transferir o veículo mantém o cliente das OS já abertas', async () => {
      const antigo = await novoCliente(5);
      const novo = await novoCliente(6);
      const v = await novoVeiculo(antigo.id, `XXX${sufixo.slice(0, 4)}`);
      const os = await novaOs(antigo.id, v.id, 'CANCELADA');

      const transferido = await veiculos.transferir(v.id, novo.id);
      expect(transferido.clienteId).toBe(novo.id);
      const linha = await direto.query<{ cliente_id: string }>(
        'SELECT cliente_id FROM ordens_servico WHERE id = $1',
        [os],
      );
      expect(linha.rows[0]?.cliente_id).toBe(antigo.id);
    });
  },
);
