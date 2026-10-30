import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { iniciarApi, type ApiDeTeste } from '../helpers/api.js';
import { RepositorioEmMemoria, perfil } from '../helpers/usuarios-fakes.js';

let api: ApiDeTeste;
const ID_OUTRO = '11111111-1111-4111-8111-111111111111';
const ID_GERENTE = '22222222-2222-4222-8222-222222222222';

interface CorpoErro {
  erro: { codigo: string; mensagem: string };
}

beforeAll(async () => {
  api = await iniciarApi(
    new RepositorioEmMemoria([
      perfil({ usuarioId: ID_GERENTE, nome: 'Gerente', perfil: 'GERENTE' }),
      perfil({ usuarioId: 'atendente', perfil: 'ATENDENTE' }),
      perfil({ usuarioId: 'mecanico', perfil: 'MECANICO' }),
      perfil({ usuarioId: 'almoxarife', perfil: 'ALMOXARIFE' }),
      perfil({ usuarioId: ID_OUTRO, nome: 'Outro Usuário', perfil: 'ATENDENTE' }),
    ]),
  );
});
afterAll(() => api.encerrar());

const corpoCriar = {
  nome: 'Nova Pessoa',
  email: 'nova@teste.local',
  perfil: 'MECANICO',
  senha: 'senha-forte-1',
};

/** Todas as rotas de gestão de usuários: método, caminho e corpo válido. */
const rotas: [string, string, unknown?][] = [
  ['GET', '/usuarios'],
  ['POST', '/usuarios', corpoCriar],
  ['GET', `/usuarios/${ID_OUTRO}`],
  ['PATCH', `/usuarios/${ID_OUTRO}`, { nome: 'Outro Nome' }],
  ['POST', `/usuarios/${ID_OUTRO}/redefinir-senha`, { senha: 'outra-senha-9' }],
  ['POST', `/usuarios/${ID_OUTRO}/inativar`],
  ['POST', `/usuarios/${ID_OUTRO}/ativar`],
];

describe('permissões (RN09): só o gerente gere usuários', () => {
  it.each(['atendente', 'mecanico', 'almoxarife'])(
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

  it('o 403 não executa nada (nenhuma chamada ao Auth)', () => {
    expect(api.admin.chamadas).toEqual([]);
  });
});

describe('gerente', () => {
  let token: string;
  beforeAll(async () => {
    token = await api.token(ID_GERENTE);
  });

  it('lista com filtros e paginação', async () => {
    const r = await api.requisitar('GET', '/usuarios?perfil=ATENDENTE&limite=1&pagina=1', {
      token,
    });
    expect(r.status).toBe(200);
    const corpo = (await r.json()) as { itens: unknown[]; total: number; limite: number };
    expect(corpo).toMatchObject({ total: 2, limite: 1 });
    expect(corpo.itens).toHaveLength(1);
  });

  it('cria um usuário (201) e a resposta não traz senha', async () => {
    const r = await api.requisitar('POST', '/usuarios', { token, corpo: corpoCriar });
    expect(r.status).toBe(201);
    const texto = await r.text();
    expect(texto).not.toContain('senha-forte-1');
    expect(JSON.parse(texto)).toMatchObject({
      nome: 'Nova Pessoa',
      email: 'nova@teste.local',
      perfil: 'MECANICO',
      ativo: true,
    });
  });

  it('e-mail duplicado devolve 409', async () => {
    const r = await api.requisitar('POST', '/usuarios', { token, corpo: corpoCriar });
    expect(r.status).toBe(409);
    expect(((await r.json()) as CorpoErro).erro.mensagem).toBe('E-mail já cadastrado');
  });

  it('altera nome e perfil', async () => {
    const r = await api.requisitar('PATCH', `/usuarios/${ID_OUTRO}`, {
      token,
      corpo: { perfil: 'ALMOXARIFE' },
    });
    expect(r.status).toBe(200);
    expect(await r.json()).toMatchObject({ perfil: 'ALMOXARIFE' });
  });

  it('redefine a senha (204, sem corpo)', async () => {
    const r = await api.requisitar('POST', `/usuarios/${ID_OUTRO}/redefinir-senha`, {
      token,
      corpo: { senha: 'outra-senha-9' },
    });
    expect(r.status).toBe(204);
    expect(await r.text()).toBe('');
  });

  it('inativa, reativa e a conta é banida e desbanida no Auth', async () => {
    const inativado = await api.requisitar('POST', `/usuarios/${ID_OUTRO}/inativar`, { token });
    expect(inativado.status).toBe(200);
    expect(await inativado.json()).toMatchObject({ ativo: false });
    const ativado = await api.requisitar('POST', `/usuarios/${ID_OUTRO}/ativar`, { token });
    expect(await ativado.json()).toMatchObject({ ativo: true });
    expect(api.admin.chamadas).toEqual(
      expect.arrayContaining([`banir:${ID_OUTRO}`, `desbanir:${ID_OUTRO}`]),
    );
  });

  it('não inativa o último gerente (409 ultimo_gerente)', async () => {
    const r = await api.requisitar('POST', `/usuarios/${ID_GERENTE}/inativar`, { token });
    expect(r.status).toBe(409);
    expect(((await r.json()) as CorpoErro).erro.codigo).toBe('ultimo_gerente');
  });

  it('não rebaixa o último gerente (409)', async () => {
    const r = await api.requisitar('PATCH', `/usuarios/${ID_GERENTE}`, {
      token,
      corpo: { perfil: 'ATENDENTE' },
    });
    expect(r.status).toBe(409);
  });

  it('usuário que não existe devolve 404', async () => {
    const r = await api.requisitar('GET', '/usuarios/99999999-9999-4999-8999-999999999999', {
      token,
    });
    expect(r.status).toBe(404);
  });
});

describe('validação de entrada (422)', () => {
  let token: string;
  beforeAll(async () => {
    token = await api.token(ID_GERENTE);
  });

  it.each([
    ['senha curta', { ...corpoCriar, senha: '123' }],
    ['e-mail inválido', { ...corpoCriar, email: 'nao-e-email' }],
    ['perfil inexistente', { ...corpoCriar, perfil: 'DONO' }],
    ['nome vazio', { ...corpoCriar, nome: ' ' }],
    ['corpo vazio', {}],
  ])('criar com %s', async (_nome, corpo) => {
    const r = await api.requisitar('POST', '/usuarios', { token, corpo });
    expect(r.status).toBe(422);
    expect(((await r.json()) as CorpoErro).erro.codigo).toBe('validacao');
  });

  it('a mensagem de erro não repete a senha enviada', async () => {
    const r = await api.requisitar('POST', '/usuarios', {
      token,
      corpo: { ...corpoCriar, senha: 'abc', perfil: 'DONO' },
    });
    expect(await r.text()).not.toContain('"abc"');
  });

  it('alterar sem nome nem perfil', async () => {
    expect(
      (await api.requisitar('PATCH', `/usuarios/${ID_OUTRO}`, { token, corpo: {} })).status,
    ).toBe(422);
  });

  it('id que não é UUID', async () => {
    expect((await api.requisitar('GET', '/usuarios/abc', { token })).status).toBe(422);
  });

  it('filtro de situação inválido na lista', async () => {
    expect((await api.requisitar('GET', '/usuarios?ativo=talvez', { token })).status).toBe(422);
  });
});
