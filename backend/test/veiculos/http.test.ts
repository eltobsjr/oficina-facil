import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { iniciarApi, type ApiDeTeste } from '../helpers/api.js';
import {
  ClientesEmMemoria,
  VeiculosEmMemoria,
  cliente,
  veiculo,
} from '../helpers/cadastros-fakes.js';
import { RepositorioEmMemoria, perfil } from '../helpers/usuarios-fakes.js';

let api: ApiDeTeste;
let veiculos: VeiculosEmMemoria;
const dono = cliente({ nome: 'Maria Souza' });
const outroDono = cliente({ nome: 'João Pereira', documento: '11144477735' });
const existente = veiculo({ clienteId: dono.id, placa: 'ABC1234' });

interface CorpoErro {
  erro: { codigo: string; detalhes?: { existente?: { id: string } } };
}

beforeAll(async () => {
  veiculos = new VeiculosEmMemoria([existente]);
  api = await iniciarApi(
    new RepositorioEmMemoria([
      perfil({ usuarioId: 'atendente', perfil: 'ATENDENTE' }),
      perfil({ usuarioId: 'mecanico', perfil: 'MECANICO' }),
      perfil({ usuarioId: 'almoxarife', perfil: 'ALMOXARIFE' }),
      perfil({ usuarioId: 'gerente', perfil: 'GERENTE' }),
    ]),
    { clientes: new ClientesEmMemoria([dono, outroDono]), veiculos },
  );
});
afterAll(() => api.encerrar());

const corpoValido = {
  placa: 'DEF-5678',
  marca: 'VW',
  modelo: 'Gol',
  ano: 2018,
  quilometragem: 42000,
};

const rotas: [string, string, unknown?][] = [
  ['GET', `/clientes/${dono.id}/veiculos`],
  ['POST', `/clientes/${dono.id}/veiculos`, corpoValido],
  ['GET', '/veiculos'],
  ['GET', `/veiculos/${existente.id}`],
  ['PATCH', `/veiculos/${existente.id}`, { cor: 'Preto' }],
  ['POST', `/veiculos/${existente.id}/transferir`, { clienteId: outroDono.id }],
  ['POST', `/veiculos/${existente.id}/inativar`],
];

describe('permissões: só o atendente gere veículos', () => {
  it.each(['mecanico', 'almoxarife', 'gerente'])(
    '%s recebe 403 em todas as rotas',
    async (quem) => {
      const token = await api.token(quem);
      for (const [metodo, caminho, corpo] of rotas) {
        const r = await api.requisitar(metodo, caminho, { token, corpo });
        expect(r.status, `${metodo} ${caminho}`).toBe(403);
      }
    },
  );

  it('sem token recebe 401 em todas as rotas', async () => {
    for (const [metodo, caminho, corpo] of rotas) {
      const r = await api.requisitar(metodo, caminho, { corpo });
      expect(r.status, `${metodo} ${caminho}`).toBe(401);
    }
  });

  it('o 403 não altera nada', () => {
    expect(veiculos.dados.size).toBe(1);
    expect(veiculos.dados.get(existente.id)).toMatchObject({ clienteId: dono.id, ativo: true });
  });
});

describe('atendente', () => {
  let token: string;
  beforeAll(async () => {
    token = await api.token('atendente');
  });

  it('cadastra veículo (201) com a placa normalizada', async () => {
    const r = await api.requisitar('POST', `/clientes/${dono.id}/veiculos`, {
      token,
      corpo: corpoValido,
    });
    expect(r.status).toBe(201);
    expect(await r.json()).toMatchObject({ placa: 'DEF5678', clienteId: dono.id, cor: null });
  });

  it('aceita placa Mercosul', async () => {
    const r = await api.requisitar('POST', `/clientes/${dono.id}/veiculos`, {
      token,
      corpo: { ...corpoValido, placa: 'ghi1j23' },
    });
    expect(r.status).toBe(201);
  });

  it('placa duplicada: 409 com o veículo existente', async () => {
    const r = await api.requisitar('POST', `/clientes/${outroDono.id}/veiculos`, {
      token,
      corpo: { ...corpoValido, placa: 'abc-1234' },
    });
    expect(r.status).toBe(409);
    const corpo = (await r.json()) as CorpoErro;
    expect(corpo.erro.codigo).toBe('placa_duplicada');
    expect(corpo.erro.detalhes?.existente?.id).toBe(existente.id);
  });

  it('placa inválida, ano fora da faixa e km negativa devolvem 422', async () => {
    const antes = veiculos.dados.size;
    for (const parcial of [
      { placa: 'ABC12' },
      { ano: 1800 },
      { quilometragem: -1 },
      { ano: 2018.5 },
    ]) {
      const r = await api.requisitar('POST', `/clientes/${dono.id}/veiculos`, {
        token,
        corpo: { ...corpoValido, placa: 'JKL9012', ...parcial },
      });
      expect(r.status, JSON.stringify(parcial)).toBe(422);
    }
    expect(veiculos.dados.size).toBe(antes);
  });

  it('cliente inexistente devolve 404', async () => {
    const r = await api.requisitar(
      'POST',
      '/clientes/00000000-0000-4000-8000-000000000000/veiculos',
      {
        token,
        corpo: { ...corpoValido, placa: 'MNO3456' },
      },
    );
    expect(r.status).toBe(404);
  });

  it('lista os veículos do cliente e busca por placa', async () => {
    const lista = await api.requisitar('GET', `/clientes/${dono.id}/veiculos`, { token });
    expect(lista.status).toBe(200);
    expect(((await lista.json()) as { total: number }).total).toBeGreaterThanOrEqual(1);
    const busca = await api.requisitar('GET', '/veiculos?placa=abc-12', { token });
    expect(((await busca.json()) as { itens: { id: string }[] }).itens.map((v) => v.id)).toEqual([
      existente.id,
    ]);
  });

  it('detalha, altera e recusa corpo vazio', async () => {
    expect((await api.requisitar('GET', `/veiculos/${existente.id}`, { token })).status).toBe(200);
    const ok = await api.requisitar('PATCH', `/veiculos/${existente.id}`, {
      token,
      corpo: { cor: 'Preto', quilometragem: 90000 },
    });
    expect(ok.status).toBe(200);
    expect(await ok.json()).toMatchObject({ cor: 'Preto', quilometragem: 90000 });
    const vazio = await api.requisitar('PATCH', `/veiculos/${existente.id}`, { token, corpo: {} });
    expect(vazio.status).toBe(422);
  });

  it('transfere de dono e inativa', async () => {
    const t = await api.requisitar('POST', `/veiculos/${existente.id}/transferir`, {
      token,
      corpo: { clienteId: outroDono.id },
    });
    expect(t.status).toBe(200);
    expect(((await t.json()) as { clienteId: string }).clienteId).toBe(outroDono.id);

    const i = await api.requisitar('POST', `/veiculos/${existente.id}/inativar`, { token });
    expect(i.status).toBe(200);
    expect(((await i.json()) as { ativo: boolean }).ativo).toBe(false);
  });

  it('transferir sem clienteId devolve 422', async () => {
    const r = await api.requisitar('POST', `/veiculos/${existente.id}/transferir`, {
      token,
      corpo: {},
    });
    expect(r.status).toBe(422);
  });
});
