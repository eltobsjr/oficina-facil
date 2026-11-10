import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { iniciarApi, type ApiDeTeste } from '../helpers/api.js';
import { ClientesEmMemoria, VeiculosEmMemoria, cliente } from '../helpers/cadastros-fakes.js';
import { RepositorioEmMemoria, perfil } from '../helpers/usuarios-fakes.js';

let api: ApiDeTeste;
let clientes: ClientesEmMemoria;
const existente = cliente({ nome: 'Maria Souza', documento: '52998224725' });

interface CorpoErro {
  erro: { codigo: string; mensagem: string; detalhes?: { existente?: { id: string } } };
}

beforeAll(async () => {
  clientes = new ClientesEmMemoria([existente]);
  api = await iniciarApi(
    new RepositorioEmMemoria([
      perfil({ usuarioId: 'atendente', perfil: 'ATENDENTE' }),
      perfil({ usuarioId: 'mecanico', perfil: 'MECANICO' }),
      perfil({ usuarioId: 'almoxarife', perfil: 'ALMOXARIFE' }),
      perfil({ usuarioId: 'gerente', perfil: 'GERENTE' }),
    ]),
    { clientes, veiculos: new VeiculosEmMemoria() },
  );
});
afterAll(() => api.encerrar());

const corpoValido = { nome: 'João Pereira', documento: '111.444.777-35', telefone: '11988887777' };

const rotas: [string, string, unknown?][] = [
  ['GET', '/clientes'],
  ['POST', '/clientes', corpoValido],
  ['GET', `/clientes/${existente.id}`],
  ['PATCH', `/clientes/${existente.id}`, { nome: 'Maria S.' }],
  ['POST', `/clientes/${existente.id}/inativar`],
];

describe('permissões: só o atendente gere clientes', () => {
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
    expect(clientes.dados.size).toBe(1);
    expect(clientes.dados.get(existente.id)?.ativo).toBe(true);
  });
});

describe('atendente', () => {
  let token: string;
  beforeAll(async () => {
    token = await api.token('atendente');
  });

  it('cria cliente (201) com o documento só com dígitos', async () => {
    const r = await api.requisitar('POST', '/clientes', { token, corpo: corpoValido });
    expect(r.status).toBe(201);
    const criado = (await r.json()) as { documento: string; nome: string; ativo: boolean };
    expect(criado).toMatchObject({ nome: 'João Pereira', documento: '11144477735', ativo: true });
  });

  it('documento duplicado: 409 com o cadastro existente', async () => {
    const r = await api.requisitar('POST', '/clientes', {
      token,
      corpo: { ...corpoValido, documento: '529.982.247-25' },
    });
    expect(r.status).toBe(409);
    const corpo = (await r.json()) as CorpoErro;
    expect(corpo.erro.codigo).toBe('documento_duplicado');
    expect(corpo.erro.detalhes?.existente?.id).toBe(existente.id);
  });

  it('CA03: campos obrigatórios ausentes e documento inválido devolvem 422 e nada é salvo', async () => {
    const antes = clientes.dados.size;
    const vazio = await api.requisitar('POST', '/clientes', { token, corpo: {} });
    expect(vazio.status).toBe(422);
    const invalido = await api.requisitar('POST', '/clientes', {
      token,
      corpo: { ...corpoValido, documento: '529.982.247-26' },
    });
    expect(invalido.status).toBe(422);
    const emailRuim = await api.requisitar('POST', '/clientes', {
      token,
      corpo: { ...corpoValido, documento: '390.533.447-05', email: 'nao-e-email' },
    });
    expect(emailRuim.status).toBe(422);
    expect((await vazio.json()) as CorpoErro).toMatchObject({ erro: { codigo: 'validacao' } });
    expect(clientes.dados.size).toBe(antes);
  });

  it('lista com busca por nome e por documento', async () => {
    const porNome = await api.requisitar('GET', '/clientes?q=maria', { token });
    expect(porNome.status).toBe(200);
    expect(((await porNome.json()) as { itens: { id: string }[] }).itens.map((c) => c.id)).toEqual([
      existente.id,
    ]);
    const porDoc = await api.requisitar('GET', '/clientes?q=529.982', { token });
    expect(((await porDoc.json()) as { total: number }).total).toBe(1);
  });

  it('detalha, e devolve 404 para id inexistente e 422 para id mal formado', async () => {
    expect((await api.requisitar('GET', `/clientes/${existente.id}`, { token })).status).toBe(200);
    expect(
      (await api.requisitar('GET', '/clientes/00000000-0000-4000-8000-000000000000', { token }))
        .status,
    ).toBe(404);
    expect((await api.requisitar('GET', '/clientes/abc', { token })).status).toBe(422);
  });

  it('altera (200) e recusa corpo vazio (422)', async () => {
    const ok = await api.requisitar('PATCH', `/clientes/${existente.id}`, {
      token,
      corpo: { telefone: '1133334444', email: null },
    });
    expect(ok.status).toBe(200);
    expect(((await ok.json()) as { telefone: string }).telefone).toBe('1133334444');
    const vazio = await api.requisitar('PATCH', `/clientes/${existente.id}`, { token, corpo: {} });
    expect(vazio.status).toBe(422);
  });

  it('inativar com OS ativa devolve 409 e sem OS ativa devolve 200', async () => {
    const comOs = cliente({ nome: 'Com OS', documento: '39053344705' });
    const semOs = cliente({ nome: 'Sem OS', documento: '12345678909' });
    clientes.dados.set(comOs.id, comOs);
    clientes.dados.set(semOs.id, semOs);
    clientes.comOsAtiva.add(comOs.id);

    const barrado = await api.requisitar('POST', `/clientes/${comOs.id}/inativar`, { token });
    expect(barrado.status).toBe(409);
    expect(((await barrado.json()) as CorpoErro).erro.codigo).toBe('cliente_com_os_ativa');

    const ok = await api.requisitar('POST', `/clientes/${semOs.id}/inativar`, { token });
    expect(ok.status).toBe(200);
    expect(((await ok.json()) as { ativo: boolean }).ativo).toBe(false);
  });
});
