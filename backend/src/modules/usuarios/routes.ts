import { Router } from 'express';
import { IdParamSchema, ErroSchema } from '../../shared/openapi/zod.js';
import { registrarRota } from '../../shared/http/rota.js';
import { adminAuthDoAmbiente } from '../../shared/supabase/admin.js';
import { autenticar, exigirPerfis, usuarioDe } from './auth.js';
import { repositorioPrisma } from './repository.js';
import {
  AlterarUsuarioSchema,
  CriarUsuarioSchema,
  ListaUsuariosQuerySchema,
  ListaUsuariosSchema,
  RedefinirSenhaSchema,
  UsuarioAtualSchema,
  UsuarioSchema,
} from './schemas.js';
import {
  criarServicoUsuarios,
  type DependenciasUsuarios,
  type ServicoUsuarios,
} from './service.js';

export const usuariosRouter = Router();

let dependencias: DependenciasUsuarios | undefined;

/** Testes injetam um repositório em memória e um Auth falso. */
export function definirDependenciasDeUsuarios(deps: DependenciasUsuarios | undefined) {
  dependencias = deps;
}

function servico(): ServicoUsuarios {
  return criarServicoUsuarios(
    dependencias ?? { repo: repositorioPrisma, admin: adminAuthDoAmbiente },
  );
}

const apenasGerente = [autenticar, exigirPerfis('GERENTE')];

const respostasComuns = {
  401: { descricao: 'Sem token ou token inválido', schema: ErroSchema },
  403: { descricao: 'Sem permissão (só o gerente gere usuários)', schema: ErroSchema },
};

registrarRota(usuariosRouter, {
  metodo: 'get',
  caminho: '/me',
  resumo: 'Usuário autenticado',
  descricao:
    'Nome, e-mail e perfil do usuário dono do token. O app usa para montar o menu do perfil.',
  tags: ['usuarios'],
  seguranca: 'bearer',
  middlewares: [autenticar],
  respostas: {
    200: { descricao: 'Usuário autenticado', schema: UsuarioAtualSchema },
    401: { descricao: 'Sem token ou token inválido', schema: ErroSchema },
    403: { descricao: 'Usuário sem perfil ou inativo', schema: ErroSchema },
  },
  handler: async ({ res }) => ({ corpo: usuarioDe(res) }),
});

registrarRota(usuariosRouter, {
  metodo: 'get',
  caminho: '/usuarios',
  resumo: 'Lista usuários',
  descricao: 'Busca por nome ou e-mail, filtros de perfil e situação, paginada. Só o gerente.',
  tags: ['usuarios'],
  seguranca: 'bearer',
  middlewares: apenasGerente,
  query: ListaUsuariosQuerySchema,
  respostas: { 200: { descricao: 'Usuários', schema: ListaUsuariosSchema }, ...respostasComuns },
  handler: async ({ query }) => ({ corpo: await servico().listar(query) }),
});

registrarRota(usuariosRouter, {
  metodo: 'post',
  caminho: '/usuarios',
  resumo: 'Cria usuário',
  descricao: 'Cria a conta no Supabase Auth e o perfil. Se o perfil falhar, a conta é removida.',
  tags: ['usuarios'],
  seguranca: 'bearer',
  middlewares: apenasGerente,
  body: CriarUsuarioSchema,
  respostas: {
    201: { descricao: 'Usuário criado', schema: UsuarioSchema },
    409: { descricao: 'E-mail já cadastrado', schema: ErroSchema },
    422: { descricao: 'Dados inválidos', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ body }) => ({ status: 201, corpo: await servico().criar(body) }),
});

registrarRota(usuariosRouter, {
  metodo: 'get',
  caminho: '/usuarios/:id',
  resumo: 'Detalha usuário',
  tags: ['usuarios'],
  seguranca: 'bearer',
  middlewares: apenasGerente,
  params: IdParamSchema,
  respostas: {
    200: { descricao: 'Usuário', schema: UsuarioSchema },
    404: { descricao: 'Usuário não encontrado', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params }) => ({ corpo: await servico().detalhar(params.id) }),
});

registrarRota(usuariosRouter, {
  metodo: 'patch',
  caminho: '/usuarios/:id',
  resumo: 'Altera nome e perfil',
  descricao:
    'A troca de perfil vale a partir do próximo login. Não permite remover o último gerente.',
  tags: ['usuarios'],
  seguranca: 'bearer',
  middlewares: apenasGerente,
  params: IdParamSchema,
  body: AlterarUsuarioSchema,
  respostas: {
    200: { descricao: 'Usuário alterado', schema: UsuarioSchema },
    404: { descricao: 'Usuário não encontrado', schema: ErroSchema },
    409: { descricao: 'Último gerente ativo', schema: ErroSchema },
    422: { descricao: 'Dados inválidos', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params, body }) => ({ corpo: await servico().alterar(params.id, body) }),
});

registrarRota(usuariosRouter, {
  metodo: 'post',
  caminho: '/usuarios/:id/redefinir-senha',
  resumo: 'Redefine a senha',
  tags: ['usuarios'],
  seguranca: 'bearer',
  middlewares: apenasGerente,
  params: IdParamSchema,
  body: RedefinirSenhaSchema,
  respostas: {
    204: { descricao: 'Senha redefinida' },
    404: { descricao: 'Usuário não encontrado', schema: ErroSchema },
    422: { descricao: 'Dados inválidos', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params, body }) => {
    await servico().redefinirSenha(params.id, body.senha);
    return { status: 204 };
  },
});

registrarRota(usuariosRouter, {
  metodo: 'post',
  caminho: '/usuarios/:id/inativar',
  resumo: 'Inativa o usuário',
  descricao: 'Marca como inativo e bane a conta no Auth. Nunca o último gerente ativo.',
  tags: ['usuarios'],
  seguranca: 'bearer',
  middlewares: apenasGerente,
  params: IdParamSchema,
  respostas: {
    200: { descricao: 'Usuário inativado', schema: UsuarioSchema },
    404: { descricao: 'Usuário não encontrado', schema: ErroSchema },
    409: { descricao: 'Último gerente ativo', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params }) => ({ corpo: await servico().inativar(params.id) }),
});

registrarRota(usuariosRouter, {
  metodo: 'post',
  caminho: '/usuarios/:id/ativar',
  resumo: 'Reativa o usuário',
  tags: ['usuarios'],
  seguranca: 'bearer',
  middlewares: apenasGerente,
  params: IdParamSchema,
  respostas: {
    200: { descricao: 'Usuário reativado', schema: UsuarioSchema },
    404: { descricao: 'Usuário não encontrado', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params }) => ({ corpo: await servico().ativar(params.id) }),
});
