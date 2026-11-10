import { describe, expect, it } from 'vitest';
import { criarServicoVeiculos } from '../../src/modules/veiculos/service.js';
import { VeiculosEmMemoria, cliente, veiculo } from '../helpers/cadastros-fakes.js';

const dono = cliente({ nome: 'Maria Souza' });
const outroDono = cliente({ nome: 'João Pereira', documento: '11144477735' });
const inativo = cliente({ nome: 'Antigo', documento: '39053344705', ativo: false });
const clientes = new Map([dono, outroDono, inativo].map((c) => [c.id, c]));
const IDEXISTE = '00000000-0000-4000-8000-000000000000';

function montar(iniciais = [veiculo({ clienteId: dono.id })]) {
  const repo = new VeiculosEmMemoria(iniciais);
  const servico = criarServicoVeiculos({
    repo,
    buscarCliente: async (id) => {
      const c = clientes.get(id);
      return c ? { id: c.id, nome: c.nome, ativo: c.ativo } : null;
    },
  });
  return { repo, servico };
}

const dados = { placa: 'DEF5678', marca: 'VW', modelo: 'Gol', ano: 2018, quilometragem: 42000 };

describe('criar (CA01, CA02)', () => {
  it('cadastra vinculado ao cliente, com cor opcional', async () => {
    const { servico } = montar([]);
    const criado = await servico.criar(dono.id, { ...dados, cor: 'Prata' });
    expect(criado).toMatchObject({ ...dados, clienteId: dono.id, cor: 'Prata', ativo: true });
    expect((await servico.criar(dono.id, { ...dados, placa: 'GHI1J23' })).cor).toBeNull();
  });

  it('cliente inexistente devolve 404 e nada é gravado', async () => {
    const { servico, repo } = montar([]);
    await expect(servico.criar(IDEXISTE, dados)).rejects.toMatchObject({ status: 404 });
    expect(repo.dados.size).toBe(0);
  });

  it('placa duplicada: 409 com o veículo existente', async () => {
    const existente = veiculo({ clienteId: outroDono.id, placa: 'DEF5678' });
    const { servico, repo } = montar([existente]);
    await expect(servico.criar(dono.id, dados)).rejects.toMatchObject({
      status: 409,
      codigo: 'placa_duplicada',
      detalhes: { existente: { id: existente.id, clienteId: outroDono.id } },
    });
    expect(repo.dados.size).toBe(1);
  });

  it('duplicidade detectada só na gravação (concorrência) devolve o mesmo 409', async () => {
    const { servico, repo } = montar([]);
    const concorrente = veiculo({ placa: 'DEF5678', clienteId: outroDono.id });
    repo.concorrenciaNaPlaca = concorrente;
    await expect(servico.criar(dono.id, dados)).rejects.toMatchObject({
      status: 409,
      detalhes: { existente: { id: concorrente.id } },
    });
  });
});

describe('listar e buscar (CA04)', () => {
  const a = veiculo({ clienteId: dono.id, placa: 'AAA1111' });
  const b = veiculo({ clienteId: outroDono.id, placa: 'BBB2B22' });

  it('lista só os veículos do cliente', async () => {
    const { servico } = montar([a, b]);
    const r = await servico.listarDoCliente(dono.id, { pagina: 1, limite: 20 });
    expect(r.itens.map((v) => v.placa)).toEqual(['AAA1111']);
  });

  it('lista de cliente inexistente devolve 404', async () => {
    const { servico } = montar([a]);
    await expect(
      servico.listarDoCliente(IDEXISTE, { pagina: 1, limite: 20 }),
    ).rejects.toMatchObject({ status: 404 });
  });

  it('busca por placa normaliza o texto (hífen e minúsculas)', async () => {
    const { servico } = montar([a, b]);
    const r = await servico.buscar({ pagina: 1, limite: 20, placa: 'bbb-2b' });
    expect(r.itens.map((v) => v.placa)).toEqual(['BBB2B22']);
  });

  it('busca sem placa lista todos', async () => {
    const { servico } = montar([a, b]);
    expect((await servico.buscar({ pagina: 1, limite: 20 })).total).toBe(2);
  });

  it('detalha e devolve 404 se não existe', async () => {
    const { servico } = montar([a]);
    expect((await servico.detalhar(a.id)).placa).toBe('AAA1111');
    await expect(servico.detalhar(IDEXISTE)).rejects.toMatchObject({ status: 404 });
  });
});

describe('alterar (CA04)', () => {
  it('altera só o enviado e limpa a cor com null', async () => {
    const v = veiculo({ clienteId: dono.id, cor: 'Azul', quilometragem: 1000 });
    const { servico } = montar([v]);
    const r = await servico.alterar(v.id, { quilometragem: 1500, cor: null });
    expect(r).toMatchObject({ quilometragem: 1500, cor: null, marca: v.marca });
  });

  it('trocar a placa por uma já usada devolve 409 com o existente', async () => {
    const a = veiculo({ placa: 'AAA1111' });
    const b = veiculo({ placa: 'BBB2222' });
    const { servico } = montar([a, b]);
    await expect(servico.alterar(a.id, { placa: 'BBB2222' })).rejects.toMatchObject({
      status: 409,
      detalhes: { existente: { id: b.id } },
    });
  });

  it('reenviar a própria placa não é duplicidade', async () => {
    const a = veiculo({ placa: 'AAA1111' });
    const { servico } = montar([a]);
    await expect(servico.alterar(a.id, { placa: 'AAA1111' })).resolves.toBeDefined();
  });
});

describe('transferir (CA05)', () => {
  it('muda só o dono do veículo', async () => {
    const v = veiculo({ clienteId: dono.id });
    const { servico, repo } = montar([v]);
    const r = await servico.transferir(v.id, outroDono.id);
    expect(r.clienteId).toBe(outroDono.id);
    expect(repo.dados.get(v.id)).toMatchObject({ placa: v.placa, marca: v.marca });
  });

  it('transferir para o mesmo dono não altera nada', async () => {
    const v = veiculo({ clienteId: dono.id });
    const { servico } = montar([v]);
    expect((await servico.transferir(v.id, dono.id)).clienteId).toBe(dono.id);
  });

  it('novo dono inexistente ou veículo inexistente devolve 404', async () => {
    const v = veiculo({ clienteId: dono.id });
    const { servico, repo } = montar([v]);
    await expect(servico.transferir(v.id, IDEXISTE)).rejects.toMatchObject({ status: 404 });
    await expect(servico.transferir(IDEXISTE, dono.id)).rejects.toMatchObject({ status: 404 });
    expect(repo.dados.get(v.id)?.clienteId).toBe(dono.id);
  });
});

describe('inativar', () => {
  it('inativa e mantém o cadastro; repetir não falha', async () => {
    const v = veiculo({ clienteId: dono.id });
    const { servico, repo } = montar([v]);
    expect((await servico.inativar(v.id)).ativo).toBe(false);
    expect((await servico.inativar(v.id)).ativo).toBe(false);
    expect(repo.dados.has(v.id)).toBe(true);
  });

  it('veículo inexistente devolve 404', async () => {
    const { servico } = montar([]);
    await expect(servico.inativar(IDEXISTE)).rejects.toMatchObject({ status: 404 });
  });
});
