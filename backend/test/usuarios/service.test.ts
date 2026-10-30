import { beforeEach, describe, expect, it } from 'vitest';
import { criarServicoUsuarios } from '../../src/modules/usuarios/service.js';
import { Conflito, NaoEncontrado, RegraDeNegocio } from '../../src/shared/errors/app-error.js';
import { AdminFalso, RepositorioEmMemoria, perfil } from '../helpers/usuarios-fakes.js';

let repo: RepositorioEmMemoria;
let admin: AdminFalso;
let servico: ReturnType<typeof criarServicoUsuarios>;

beforeEach(() => {
  repo = new RepositorioEmMemoria([
    perfil({ usuarioId: 'g1', nome: 'Gerente Um', perfil: 'GERENTE' }),
    perfil({ usuarioId: 'a1', nome: 'Ana Atendente', perfil: 'ATENDENTE' }),
    perfil({ usuarioId: 'm1', nome: 'Marcos Mecânico', perfil: 'MECANICO', ativo: false }),
  ]);
  admin = new AdminFalso();
  servico = criarServicoUsuarios({ repo, admin: () => admin });
});

describe('criar usuário', () => {
  const dados = {
    nome: 'Nova Pessoa',
    email: 'Nova@Teste.Local',
    perfil: 'ALMOXARIFE' as const,
    senha: 'senha-forte-1',
  };

  it('cria a conta no Auth e o perfil, com e-mail em minúsculas', async () => {
    const criado = await servico.criar(dados);
    expect(criado).toMatchObject({
      nome: 'Nova Pessoa',
      email: 'nova@teste.local',
      perfil: 'ALMOXARIFE',
      ativo: true,
    });
    expect(admin.chamadas).toEqual(['criarUsuario:']);
    expect(repo.dados.has(criado.id)).toBe(true);
  });

  it('recusa e-mail já cadastrado sem criar conta no Auth', async () => {
    await expect(servico.criar({ ...dados, email: 'a1@teste.local' })).rejects.toBeInstanceOf(
      Conflito,
    );
    expect(admin.chamadas).toEqual([]);
  });

  it('nunca devolve a senha', async () => {
    const criado = await servico.criar(dados);
    expect(JSON.stringify(criado)).not.toContain('senha-forte-1');
    expect(Object.keys(criado)).not.toContain('senha');
  });

  it('se o perfil falhar, remove a conta criada no Auth (compensação)', async () => {
    repo.falharAoCriar = true;
    await expect(servico.criar(dados)).rejects.toThrow('falha simulada do banco');
    expect(admin.chamadas).toEqual(['criarUsuario:', 'excluir:conta-1']);
  });

  it('se o Auth falhar, não grava perfil nenhum', async () => {
    admin.falharEm = 'criarUsuario';
    const antes = repo.dados.size;
    await expect(servico.criar(dados)).rejects.toThrow();
    expect(repo.dados.size).toBe(antes);
  });

  it('a falha ao remover a conta de compensação não esconde o erro original', async () => {
    repo.falharAoCriar = true;
    admin.falharEm = 'excluir';
    await expect(servico.criar(dados)).rejects.toThrow('falha simulada do banco');
  });
});

describe('listar e detalhar', () => {
  it('filtra por perfil, situação e texto, e pagina', async () => {
    expect((await servico.listar({ pagina: 1, limite: 20, perfil: 'GERENTE' })).total).toBe(1);
    expect(
      (await servico.listar({ pagina: 1, limite: 20, ativo: false })).itens.map((u) => u.id),
    ).toEqual(['m1']);
    expect(
      (await servico.listar({ pagina: 1, limite: 20, q: 'ANA' })).itens.map((u) => u.id),
    ).toEqual(['a1']);
    const pagina = await servico.listar({ pagina: 2, limite: 2 });
    expect(pagina).toMatchObject({ pagina: 2, limite: 2, total: 3 });
    expect(pagina.itens).toHaveLength(1);
  });

  it('detalha um usuário e devolve 404 para um que não existe', async () => {
    expect((await servico.detalhar('a1')).nome).toBe('Ana Atendente');
    await expect(servico.detalhar('nao-existe')).rejects.toBeInstanceOf(NaoEncontrado);
  });
});

describe('alterar', () => {
  it('troca nome e perfil', async () => {
    const r = await servico.alterar('a1', { nome: 'Ana Souza', perfil: 'ALMOXARIFE' });
    expect(r).toMatchObject({ nome: 'Ana Souza', perfil: 'ALMOXARIFE' });
  });

  it('não permite tirar o perfil do último gerente ativo', async () => {
    const erro = await servico.alterar('g1', { perfil: 'ATENDENTE' }).catch((e: unknown) => e);
    expect(erro).toBeInstanceOf(RegraDeNegocio);
    expect((erro as RegraDeNegocio).codigo).toBe('ultimo_gerente');
    expect(repo.dados.get('g1')?.perfil).toBe('GERENTE');
  });

  it('permite trocar o perfil de um gerente quando há outro ativo', async () => {
    repo.dados.set('g2', perfil({ usuarioId: 'g2', perfil: 'GERENTE' }));
    expect((await servico.alterar('g1', { perfil: 'ATENDENTE' })).perfil).toBe('ATENDENTE');
  });

  it('renomear o último gerente é permitido', async () => {
    expect((await servico.alterar('g1', { nome: 'Gerente Geral' })).nome).toBe('Gerente Geral');
  });

  it('usuário inexistente devolve 404', async () => {
    await expect(servico.alterar('x', { nome: 'Fulano' })).rejects.toBeInstanceOf(NaoEncontrado);
  });
});

describe('redefinir senha', () => {
  it('repassa a senha ao Auth e não devolve nada', async () => {
    await expect(servico.redefinirSenha('a1', 'nova-senha-123')).resolves.toBeUndefined();
    expect(admin.chamadas).toEqual(['definirSenha:a1']);
    expect(admin.senhasRecebidas).toEqual(['nova-senha-123']);
  });

  it('usuário inexistente devolve 404 sem chamar o Auth', async () => {
    await expect(servico.redefinirSenha('x', 'nova-senha-123')).rejects.toBeInstanceOf(
      NaoEncontrado,
    );
    expect(admin.chamadas).toEqual([]);
  });
});

describe('inativar e ativar', () => {
  it('inativa o perfil e bane a conta no Auth', async () => {
    const r = await servico.inativar('a1');
    expect(r.ativo).toBe(false);
    expect(admin.chamadas).toEqual(['banir:a1']);
  });

  it('não inativa o último gerente ativo e não chama o Auth', async () => {
    await expect(servico.inativar('g1')).rejects.toBeInstanceOf(RegraDeNegocio);
    expect(repo.dados.get('g1')?.ativo).toBe(true);
    expect(admin.chamadas).toEqual([]);
  });

  it('inativa um gerente quando há outro ativo', async () => {
    repo.dados.set('g2', perfil({ usuarioId: 'g2', perfil: 'GERENTE' }));
    expect((await servico.inativar('g1')).ativo).toBe(false);
  });

  it('se o banimento falhar, volta o perfil a ativo (sem ficar pela metade)', async () => {
    admin.falharEm = 'banir';
    await expect(servico.inativar('a1')).rejects.toThrow('falha simulada em banir');
    expect(repo.dados.get('a1')?.ativo).toBe(true);
  });

  it('inativar quem já está inativo não chama o Auth', async () => {
    await servico.inativar('m1');
    expect(admin.chamadas).toEqual([]);
  });

  it('ativa o perfil e desbane a conta', async () => {
    const r = await servico.ativar('m1');
    expect(r.ativo).toBe(true);
    expect(admin.chamadas).toEqual(['desbanir:m1']);
  });

  it('se o desbanimento falhar, volta o perfil a inativo', async () => {
    admin.falharEm = 'desbanir';
    await expect(servico.ativar('m1')).rejects.toThrow('falha simulada em desbanir');
    expect(repo.dados.get('m1')?.ativo).toBe(false);
  });
});
