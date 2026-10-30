/**
 * Cliente administrativo do Supabase Auth (chave de serviço, que só existe no backend).
 *
 * É a única porta para criar, banir e excluir contas. Fica atrás de uma interface pequena
 * (`AdminAuth`) para os serviços serem testados sem rede. Senhas passam por aqui e nunca são logadas.
 */

import { createClient } from '@supabase/supabase-js';
import { env } from '../../config/env.js';
import { AppError, Conflito, ErroValidacao } from '../errors/app-error.js';

export interface AdminAuth {
  criarUsuario(dados: { email: string; senha: string }): Promise<{ id: string }>;
  definirSenha(usuarioId: string, senha: string): Promise<void>;
  banir(usuarioId: string): Promise<void>;
  desbanir(usuarioId: string): Promise<void>;
  excluir(usuarioId: string): Promise<void>;
}

/** Ban "para sempre" (100 anos): o Auth não aceita um banimento sem prazo. */
const BAN_PERMANENTE = '876000h';

interface ErroDoAuth {
  code?: string;
  status?: number;
  message: string;
}

/** Traduz o erro do Auth em erro de aplicação, sem repetir senha nem e-mail na mensagem. */
function traduzir(erro: ErroDoAuth): AppError {
  if (erro.code === 'email_exists' || erro.code === 'user_already_exists') {
    return new Conflito('E-mail já cadastrado');
  }
  if (erro.code === 'weak_password') {
    return new ErroValidacao([{ campo: 'senha', mensagem: 'Senha fraca demais' }]);
  }
  return new AppError(502, 'auth_indisponivel', 'Falha ao falar com o serviço de autenticação');
}

export function criarAdminAuth(url: string, chaveDeServico: string): AdminAuth {
  const supabase = createClient(url, chaveDeServico, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const admin = supabase.auth.admin;

  return {
    async criarUsuario({ email, senha }) {
      const { data, error } = await admin.createUser({
        email,
        password: senha,
        email_confirm: true,
      });
      if (error || !data.user) throw traduzir(error ?? { message: 'sem usuário' });
      return { id: data.user.id };
    },
    async definirSenha(usuarioId, senha) {
      const { error } = await admin.updateUserById(usuarioId, { password: senha });
      if (error) throw traduzir(error);
    },
    async banir(usuarioId) {
      const { error } = await admin.updateUserById(usuarioId, { ban_duration: BAN_PERMANENTE });
      if (error) throw traduzir(error);
    },
    async desbanir(usuarioId) {
      const { error } = await admin.updateUserById(usuarioId, { ban_duration: 'none' });
      if (error) throw traduzir(error);
    },
    async excluir(usuarioId) {
      const { error } = await admin.deleteUser(usuarioId);
      if (error) throw traduzir(error);
    },
  };
}

/** Cliente do ambiente. Falha com 503 clara se a chave de serviço não foi configurada. */
export function adminAuthDoAmbiente(): AdminAuth {
  const e = env();
  if (!e.SUPABASE_SERVICE_ROLE_KEY) {
    throw new AppError(
      503,
      'servico_indisponivel',
      'Gestão de usuários indisponível: a chave de serviço não está configurada',
    );
  }
  return criarAdminAuth(e.SUPABASE_URL, e.SUPABASE_SERVICE_ROLE_KEY);
}
