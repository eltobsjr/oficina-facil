/**
 * Dublês dos testes de usuários: repositório em memória e Auth falso. Nada toca em rede nem banco.
 */

import type { AdminAuth } from '../../src/shared/supabase/admin.js';
import type {
  FiltrosUsuarios,
  PerfilCompleto,
  RepositorioPerfis,
} from '../../src/modules/usuarios/repository.js';

export function perfil(parcial: Partial<PerfilCompleto> & { usuarioId: string }): PerfilCompleto {
  return {
    nome: 'Fulano de Tal',
    email: `${parcial.usuarioId}@teste.local`,
    perfil: 'ATENDENTE',
    ativo: true,
    criadoEm: new Date('2026-11-02T12:00:00Z'),
    ...parcial,
  };
}

export class RepositorioEmMemoria implements RepositorioPerfis {
  readonly dados = new Map<string, PerfilCompleto>();
  /** Faz a próxima criação falhar, simulando erro de banco depois da conta criada no Auth. */
  falharAoCriar = false;

  constructor(iniciais: PerfilCompleto[] = []) {
    for (const p of iniciais) this.dados.set(p.usuarioId, p);
  }

  async buscarPorId(id: string) {
    return this.dados.get(id) ?? null;
  }

  async buscarPorEmail(email: string) {
    return [...this.dados.values()].find((p) => p.email === email) ?? null;
  }

  async listar(f: FiltrosUsuarios) {
    const q = f.q?.toLowerCase();
    const filtrados = [...this.dados.values()]
      .filter((p) => (f.perfil ? p.perfil === f.perfil : true))
      .filter((p) => (f.ativo === undefined ? true : p.ativo === f.ativo))
      .filter((p) =>
        q ? p.nome.toLowerCase().includes(q) || p.email.toLowerCase().includes(q) : true,
      )
      .sort((a, b) => a.nome.localeCompare(b.nome));
    const inicio = (f.pagina - 1) * f.limite;
    return { itens: filtrados.slice(inicio, inicio + f.limite), total: filtrados.length };
  }

  async criar(dados: {
    usuarioId: string;
    nome: string;
    email: string;
    perfil: PerfilCompleto['perfil'];
  }) {
    if (this.falharAoCriar) throw new Error('falha simulada do banco');
    const novo = perfil({ ...dados });
    this.dados.set(novo.usuarioId, novo);
    return novo;
  }

  async atualizar(
    id: string,
    dados: { nome?: string; perfil?: PerfilCompleto['perfil']; ativo?: boolean },
    opcoes: { exigirOutroGerenteAtivo: boolean },
  ) {
    const atual = this.dados.get(id);
    if (!atual) throw new Error('não existe');
    if (opcoes.exigirOutroGerenteAtivo) {
      const outros = [...this.dados.values()].filter(
        (p) => p.perfil === 'GERENTE' && p.ativo && p.usuarioId !== id,
      );
      if (outros.length === 0) return null;
    }
    const novo = { ...atual, ...dados };
    this.dados.set(id, novo);
    return novo;
  }
}

export class AdminFalso implements AdminAuth {
  readonly chamadas: string[] = [];
  readonly senhasRecebidas: string[] = [];
  /** Nome da operação que deve falhar. */
  falharEm: 'criarUsuario' | 'definirSenha' | 'banir' | 'desbanir' | 'excluir' | undefined;
  private contador = 0;

  private registrar(op: NonNullable<AdminFalso['falharEm']>, id = '') {
    this.chamadas.push(`${op}:${id}`);
    if (this.falharEm === op) throw new Error(`falha simulada em ${op}`);
  }

  async criarUsuario({ senha }: { email: string; senha: string }) {
    this.senhasRecebidas.push(senha);
    this.registrar('criarUsuario');
    this.contador += 1;
    return { id: `conta-${this.contador}` };
  }
  async definirSenha(id: string, senha: string) {
    this.senhasRecebidas.push(senha);
    this.registrar('definirSenha', id);
  }
  async banir(id: string) {
    this.registrar('banir', id);
  }
  async desbanir(id: string) {
    this.registrar('desbanir', id);
  }
  async excluir(id: string) {
    this.registrar('excluir', id);
  }
}
