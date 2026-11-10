/**
 * Dublês dos testes de clientes e veículos: repositórios em memória. Nada toca em rede nem banco.
 * Todos os dados são fictícios (R28).
 */

import { randomUUID } from 'node:crypto';
import type {
  ClienteRegistro,
  DadosAlteracaoCliente,
  DadosNovoCliente,
  FiltrosClientes,
  RepositorioClientes,
} from '../../src/modules/clientes/repository.js';
import type {
  DadosAlteracaoVeiculo,
  DadosNovoVeiculo,
  FiltrosVeiculos,
  RepositorioVeiculos,
  VeiculoRegistro,
} from '../../src/modules/veiculos/repository.js';
import { Prisma } from '../../src/shared/db/prisma.js';

export function cliente(parcial: Partial<ClienteRegistro> = {}): ClienteRegistro {
  return {
    id: randomUUID(),
    nome: 'Maria Souza',
    documento: '52998224725',
    telefone: '(11) 91234-5678',
    email: null,
    endereco: null,
    ativo: true,
    ...parcial,
  };
}

export function veiculo(parcial: Partial<VeiculoRegistro> = {}): VeiculoRegistro {
  return {
    id: randomUUID(),
    clienteId: randomUUID(),
    placa: 'ABC1234',
    marca: 'Fiat',
    modelo: 'Uno',
    ano: 2015,
    cor: null,
    quilometragem: 80000,
    ativo: true,
    ...parcial,
  };
}

function violacaoDeUnicidade(): Prisma.PrismaClientKnownRequestError {
  return new Prisma.PrismaClientKnownRequestError('Unique constraint failed', {
    code: 'P2002',
    clientVersion: 'teste',
  });
}

export class ClientesEmMemoria implements RepositorioClientes {
  readonly dados = new Map<string, ClienteRegistro>();
  /** Clientes que têm OS em andamento (a tabela de OS só ganha dados na feature 007). */
  readonly comOsAtiva = new Set<string>();
  /** Simula outra requisição que gravou o mesmo documento entre a checagem e a escrita. */
  concorrenciaNoDocumento: ClienteRegistro | undefined;

  constructor(iniciais: ClienteRegistro[] = []) {
    for (const c of iniciais) this.dados.set(c.id, c);
  }

  async buscarPorId(id: string) {
    return this.dados.get(id) ?? null;
  }

  async buscarPorDocumento(documento: string) {
    return [...this.dados.values()].find((c) => c.documento === documento) ?? null;
  }

  async listar(f: FiltrosClientes) {
    const q = f.q?.toLowerCase();
    const digitos = f.q && /^[\d.\-/\s]+$/.test(f.q) ? f.q.replace(/\D/g, '') : '';
    const filtrados = [...this.dados.values()]
      .filter((c) =>
        q
          ? c.nome.toLowerCase().includes(q) || (digitos !== '' && c.documento.includes(digitos))
          : true,
      )
      .sort((a, b) => a.nome.localeCompare(b.nome));
    const inicio = (f.pagina - 1) * f.limite;
    return { itens: filtrados.slice(inicio, inicio + f.limite), total: filtrados.length };
  }

  async criar(dados: DadosNovoCliente) {
    if (this.concorrenciaNoDocumento) {
      this.dados.set(this.concorrenciaNoDocumento.id, this.concorrenciaNoDocumento);
      this.concorrenciaNoDocumento = undefined;
      throw violacaoDeUnicidade();
    }
    const novo = cliente(dados);
    this.dados.set(novo.id, novo);
    return novo;
  }

  async atualizar(id: string, dados: DadosAlteracaoCliente) {
    const atual = this.dados.get(id);
    if (!atual) throw new Error('não existe');
    const novo = { ...atual, ...dados };
    this.dados.set(id, novo);
    return novo;
  }

  async inativarSemOsAtiva(id: string) {
    if (this.comOsAtiva.has(id)) return null;
    const inativo = { ...this.dados.get(id)!, ativo: false };
    this.dados.set(id, inativo);
    return inativo;
  }
}

export class VeiculosEmMemoria implements RepositorioVeiculos {
  readonly dados = new Map<string, VeiculoRegistro>();
  concorrenciaNaPlaca: VeiculoRegistro | undefined;

  constructor(iniciais: VeiculoRegistro[] = []) {
    for (const v of iniciais) this.dados.set(v.id, v);
  }

  async buscarPorId(id: string) {
    return this.dados.get(id) ?? null;
  }

  async buscarPorPlaca(placa: string) {
    return [...this.dados.values()].find((v) => v.placa === placa) ?? null;
  }

  async listar(f: FiltrosVeiculos) {
    const filtrados = [...this.dados.values()]
      .filter((v) => (f.clienteId ? v.clienteId === f.clienteId : true))
      .filter((v) => (f.placa ? v.placa.includes(f.placa) : true))
      .sort((a, b) => a.placa.localeCompare(b.placa));
    const inicio = (f.pagina - 1) * f.limite;
    return { itens: filtrados.slice(inicio, inicio + f.limite), total: filtrados.length };
  }

  async criar(dados: DadosNovoVeiculo) {
    if (this.concorrenciaNaPlaca) {
      this.dados.set(this.concorrenciaNaPlaca.id, this.concorrenciaNaPlaca);
      this.concorrenciaNaPlaca = undefined;
      throw violacaoDeUnicidade();
    }
    const novo = veiculo(dados);
    this.dados.set(novo.id, novo);
    return novo;
  }

  private mudar(id: string, mudanca: Partial<VeiculoRegistro>) {
    const atual = this.dados.get(id);
    if (!atual) throw new Error('não existe');
    const novo = { ...atual, ...mudanca };
    this.dados.set(id, novo);
    return novo;
  }

  async atualizar(id: string, dados: DadosAlteracaoVeiculo) {
    return this.mudar(id, dados);
  }

  async transferir(id: string, clienteId: string) {
    return this.mudar(id, { clienteId });
  }

  async inativar(id: string) {
    return this.mudar(id, { ativo: false });
  }
}
