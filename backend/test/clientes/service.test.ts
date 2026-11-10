import { describe, expect, it } from 'vitest';
import { criarServicoClientes } from '../../src/modules/clientes/service.js';
import { ClientesEmMemoria, cliente } from '../helpers/cadastros-fakes.js';

function montar(iniciais = [cliente()]) {
  const repo = new ClientesEmMemoria(iniciais);
  return { repo, servico: criarServicoClientes({ repo }) };
}

const novoCliente = {
  nome: 'João Pereira',
  documento: '11144477735',
  telefone: '(11) 98888-7777',
};

describe('criar (CA01, CA02)', () => {
  it('cadastra com os dados informados e os opcionais como nulos', async () => {
    const { servico } = montar([]);
    const criado = await servico.criar(novoCliente);
    expect(criado).toMatchObject({ ...novoCliente, email: null, endereco: null, ativo: true });
  });

  it('guarda e-mail e endereço quando informados', async () => {
    const { servico } = montar([]);
    const criado = await servico.criar({
      ...novoCliente,
      email: 'joao@teste.local',
      endereco: 'Rua Fictícia, 10',
    });
    expect(criado.email).toBe('joao@teste.local');
    expect(criado.endereco).toBe('Rua Fictícia, 10');
  });

  it('documento duplicado: 409 com o cadastro existente e nada é gravado', async () => {
    const existente = cliente({ nome: 'Maria Souza', documento: '11144477735' });
    const { servico, repo } = montar([existente]);
    await expect(servico.criar(novoCliente)).rejects.toMatchObject({
      status: 409,
      codigo: 'documento_duplicado',
      detalhes: { existente: { id: existente.id, nome: 'Maria Souza' } },
    });
    expect(repo.dados.size).toBe(1);
  });

  it('duplicado detectado só na gravação (concorrência) também devolve o 409 com o existente', async () => {
    const { servico, repo } = montar([]);
    const concorrente = cliente({ documento: novoCliente.documento, nome: 'Outra Pessoa' });
    repo.concorrenciaNoDocumento = concorrente;
    await expect(servico.criar(novoCliente)).rejects.toMatchObject({
      status: 409,
      codigo: 'documento_duplicado',
      detalhes: { existente: { id: concorrente.id } },
    });
  });
});

describe('listar e detalhar (CA04)', () => {
  const ana = cliente({ nome: 'Ana Lima', documento: '52998224725' });
  const bruno = cliente({ nome: 'Bruno Alves', documento: '11144477735' });

  it('busca por parte do nome, sem diferenciar maiúsculas', async () => {
    const { servico } = montar([ana, bruno]);
    const r = await servico.listar({ pagina: 1, limite: 20, q: 'BRU' });
    expect(r.itens.map((c) => c.nome)).toEqual(['Bruno Alves']);
  });

  it('busca por documento com ou sem máscara', async () => {
    const { servico } = montar([ana, bruno]);
    const sem = await servico.listar({ pagina: 1, limite: 20, q: '529982' });
    const com = await servico.listar({ pagina: 1, limite: 20, q: '529.982.247-25' });
    expect(sem.itens.map((c) => c.id)).toEqual([ana.id]);
    expect(com.itens.map((c) => c.id)).toEqual([ana.id]);
  });

  it('sem busca lista todos por ordem de nome e pagina', async () => {
    const { servico } = montar([bruno, ana]);
    const r = await servico.listar({ pagina: 2, limite: 1 });
    expect(r).toMatchObject({ total: 2, pagina: 2, limite: 1 });
    expect(r.itens.map((c) => c.nome)).toEqual(['Bruno Alves']);
  });

  it('detalha um cliente e devolve 404 se não existe', async () => {
    const { servico } = montar([ana]);
    expect((await servico.detalhar(ana.id)).nome).toBe('Ana Lima');
    await expect(servico.detalhar('00000000-0000-4000-8000-000000000000')).rejects.toMatchObject({
      status: 404,
    });
  });
});

describe('alterar (CA04)', () => {
  it('altera só os campos enviados', async () => {
    const c = cliente({ nome: 'Ana Lima', telefone: '1130000000' });
    const { servico } = montar([c]);
    const r = await servico.alterar(c.id, { telefone: '11999990000' });
    expect(r).toMatchObject({ nome: 'Ana Lima', telefone: '11999990000' });
  });

  it('limpa e-mail e endereço com null', async () => {
    const c = cliente({ email: 'a@teste.local', endereco: 'Rua X' });
    const { servico } = montar([c]);
    const r = await servico.alterar(c.id, { email: null, endereco: null });
    expect(r).toMatchObject({ email: null, endereco: null });
  });

  it('trocar o documento por um já usado devolve 409 com o existente', async () => {
    const a = cliente({ documento: '52998224725' });
    const b = cliente({ documento: '11144477735' });
    const { servico } = montar([a, b]);
    await expect(servico.alterar(a.id, { documento: b.documento })).rejects.toMatchObject({
      status: 409,
      detalhes: { existente: { id: b.id } },
    });
  });

  it('reenviar o próprio documento não é duplicidade', async () => {
    const a = cliente({ documento: '52998224725' });
    const { servico } = montar([a]);
    await expect(servico.alterar(a.id, { documento: a.documento })).resolves.toBeDefined();
  });

  it('cliente inexistente devolve 404', async () => {
    const { servico } = montar([]);
    await expect(
      servico.alterar('00000000-0000-4000-8000-000000000000', { nome: 'X Y' }),
    ).rejects.toMatchObject({ status: 404 });
  });
});

describe('inativar (CA05)', () => {
  it('inativa o cliente sem OS ativa e mantém o cadastro', async () => {
    const c = cliente();
    const { servico, repo } = montar([c]);
    const r = await servico.inativar(c.id);
    expect(r.ativo).toBe(false);
    expect(repo.dados.get(c.id)?.ativo).toBe(false);
  });

  it('cliente com OS ativa: 409 e continua ativo', async () => {
    const c = cliente();
    const { servico, repo } = montar([c]);
    repo.comOsAtiva.add(c.id);
    await expect(servico.inativar(c.id)).rejects.toMatchObject({
      status: 409,
      codigo: 'cliente_com_os_ativa',
    });
    expect(repo.dados.get(c.id)?.ativo).toBe(true);
  });

  it('inativar de novo não faz nada e não falha', async () => {
    const c = cliente({ ativo: false });
    const { servico, repo } = montar([c]);
    repo.comOsAtiva.add(c.id);
    expect((await servico.inativar(c.id)).ativo).toBe(false);
  });

  it('cliente inexistente devolve 404', async () => {
    const { servico } = montar([]);
    await expect(servico.inativar('00000000-0000-4000-8000-000000000000')).rejects.toMatchObject({
      status: 404,
    });
  });
});

describe('resumo para outros módulos', () => {
  it('devolve id, nome e situação, ou null se não existe', async () => {
    const c = cliente({ nome: 'Ana Lima' });
    const { servico } = montar([c]);
    expect(await servico.resumo(c.id)).toEqual({ id: c.id, nome: 'Ana Lima', ativo: true });
    expect(await servico.resumo('00000000-0000-4000-8000-000000000000')).toBeNull();
  });
});
