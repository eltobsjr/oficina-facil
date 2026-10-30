/**
 * Regras do módulo de usuários.
 *
 * Autenticação: o JWT identifica a pessoa; o perfil vem da tabela `perfis` (nunca de um campo
 * editável pelo usuário). Usuário sem perfil ou inativo recebe 403 mesmo com token válido (RN09).
 *
 * Gestão (UC06, só o gerente): a conta mora no Supabase Auth e o perfil no nosso banco. Como são
 * dois sistemas, cada operação que muda os dois desfaz a primeira metade se a segunda falhar.
 * Nunca se remove o último gerente ativo. Senhas nunca são logadas nem devolvidas.
 */

import type { Papel } from '../../shared/db/prisma.js';
import type { ClaimsSupabase } from '../../shared/auth/jwt.js';
import {
  Conflito,
  NaoEncontrado,
  Proibido,
  RegraDeNegocio,
} from '../../shared/errors/app-error.js';
import { logger } from '../../shared/logger.js';
import { paginaDe } from '../../shared/paginacao.js';
import type { AdminAuth } from '../../shared/supabase/admin.js';
import {
  buscarPerfil,
  type BuscarPerfil,
  type FiltrosUsuarios,
  type PerfilCompleto,
  type RepositorioPerfis,
} from './repository.js';

export interface UsuarioAutenticado {
  id: string;
  nome: string;
  email: string;
  perfil: Papel;
}

export async function usuarioDoToken(
  claims: ClaimsSupabase,
  buscar: BuscarPerfil = buscarPerfil,
): Promise<UsuarioAutenticado> {
  const registro = await buscar(claims.sub);
  if (!registro) throw new Proibido('Usuário sem perfil cadastrado');
  if (!registro.ativo) throw new Proibido('Usuário inativo');
  return {
    id: registro.usuarioId,
    nome: registro.nome,
    email: registro.email,
    perfil: registro.perfil,
  };
}

export interface UsuarioGerido {
  id: string;
  nome: string;
  email: string;
  perfil: Papel;
  ativo: boolean;
  criadoEm: string;
}

function paraResposta(p: PerfilCompleto): UsuarioGerido {
  return {
    id: p.usuarioId,
    nome: p.nome,
    email: p.email,
    perfil: p.perfil,
    ativo: p.ativo,
    criadoEm: p.criadoEm.toISOString(),
  };
}

const ULTIMO_GERENTE = () =>
  new RegraDeNegocio('ultimo_gerente', 'Não é possível: este é o último gerente ativo');

export interface DependenciasUsuarios {
  repo: RepositorioPerfis;
  /** Lazy: se a chave de serviço faltar, só as operações que precisam dela falham. */
  admin: () => AdminAuth;
}

export function criarServicoUsuarios({ repo, admin }: DependenciasUsuarios) {
  async function obter(id: string): Promise<PerfilCompleto> {
    const perfil = await repo.buscarPorId(id);
    if (!perfil) throw new NaoEncontrado('Usuário');
    return perfil;
  }

  return {
    async listar(filtros: FiltrosUsuarios) {
      const { itens, total } = await repo.listar(filtros);
      return paginaDe(itens.map(paraResposta), total, filtros);
    },

    async detalhar(id: string): Promise<UsuarioGerido> {
      return paraResposta(await obter(id));
    },

    async criar(dados: {
      nome: string;
      email: string;
      perfil: Papel;
      senha: string;
    }): Promise<UsuarioGerido> {
      const email = dados.email.trim().toLowerCase();
      if (await repo.buscarPorEmail(email)) throw new Conflito('E-mail já cadastrado');

      const conta = await admin().criarUsuario({ email, senha: dados.senha });
      try {
        return paraResposta(
          await repo.criar({ usuarioId: conta.id, nome: dados.nome, email, perfil: dados.perfil }),
        );
      } catch (erro) {
        // O perfil não foi gravado: remove a conta para não deixar um usuário sem perfil.
        await admin()
          .excluir(conta.id)
          .catch((falha: unknown) =>
            logger.error({ usuarioId: conta.id, falha }, 'Conta criada sem perfil e não removida'),
          );
        throw erro;
      }
    },

    async alterar(id: string, dados: { nome?: string; perfil?: Papel }): Promise<UsuarioGerido> {
      const atual = await obter(id);
      const removeGerente =
        atual.perfil === 'GERENTE' &&
        atual.ativo &&
        dados.perfil !== undefined &&
        dados.perfil !== 'GERENTE';
      const atualizado = await repo.atualizar(id, dados, {
        exigirOutroGerenteAtivo: removeGerente,
      });
      if (!atualizado) throw ULTIMO_GERENTE();
      return paraResposta(atualizado);
    },

    async redefinirSenha(id: string, senha: string): Promise<void> {
      await obter(id);
      await admin().definirSenha(id, senha);
    },

    async inativar(id: string): Promise<UsuarioGerido> {
      const atual = await obter(id);
      if (!atual.ativo) return paraResposta(atual);
      const removeGerente = atual.perfil === 'GERENTE';
      const atualizado = await repo.atualizar(
        id,
        { ativo: false },
        { exigirOutroGerenteAtivo: removeGerente },
      );
      if (!atualizado) throw ULTIMO_GERENTE();
      try {
        await admin().banir(id);
      } catch (erro) {
        // Sem o banimento no Auth a inativação ficaria pela metade: volta o perfil.
        await repo.atualizar(id, { ativo: true }, { exigirOutroGerenteAtivo: false });
        throw erro;
      }
      return paraResposta(atualizado);
    },

    async ativar(id: string): Promise<UsuarioGerido> {
      const atual = await obter(id);
      if (atual.ativo) return paraResposta(atual);
      const atualizado = await repo.atualizar(
        id,
        { ativo: true },
        { exigirOutroGerenteAtivo: false },
      );
      if (!atualizado) throw new NaoEncontrado('Usuário');
      try {
        await admin().desbanir(id);
      } catch (erro) {
        await repo.atualizar(id, { ativo: false }, { exigirOutroGerenteAtivo: false });
        throw erro;
      }
      return paraResposta(atualizado);
    },
  };
}

export type ServicoUsuarios = ReturnType<typeof criarServicoUsuarios>;
