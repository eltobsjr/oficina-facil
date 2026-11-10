import { Router } from 'express';
import { registrarRota } from '../../shared/http/rota.js';
import { ErroSchema, IdParamSchema } from '../../shared/openapi/zod.js';
import { autenticar, exigirPerfis } from '../usuarios/index.js';
import { repositorioPrisma } from './repository.js';
import {
  AlterarClienteSchema,
  ClienteSchema,
  CriarClienteSchema,
  ListaClientesQuerySchema,
  ListaClientesSchema,
} from './schemas.js';
import {
  criarServicoClientes,
  type DependenciasClientes,
  type ServicoClientes,
} from './service.js';

export const clientesRouter = Router();

let dependencias: DependenciasClientes | undefined;

/** Testes injetam um repositório em memória. */
export function definirDependenciasDeClientes(deps: DependenciasClientes | undefined) {
  dependencias = deps;
}

export function servicoDeClientes(): ServicoClientes {
  return criarServicoClientes(dependencias ?? { repo: repositorioPrisma });
}

const apenasAtendente = [autenticar, exigirPerfis('ATENDENTE')];

const respostasComuns = {
  401: { descricao: 'Sem token ou token inválido', schema: ErroSchema },
  403: { descricao: 'Sem permissão (só o atendente gere clientes)', schema: ErroSchema },
};

registrarRota(clientesRouter, {
  metodo: 'get',
  caminho: '/clientes',
  resumo: 'Lista clientes',
  descricao: 'Busca por nome ou documento, paginada. Só o atendente.',
  tags: ['clientes'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  query: ListaClientesQuerySchema,
  respostas: { 200: { descricao: 'Clientes', schema: ListaClientesSchema }, ...respostasComuns },
  handler: async ({ query }) => ({ corpo: await servicoDeClientes().listar(query) }),
});

registrarRota(clientesRouter, {
  metodo: 'post',
  caminho: '/clientes',
  resumo: 'Cadastra cliente',
  descricao:
    'Valida o CPF ou CNPJ. Documento já cadastrado devolve 409 com o cadastro existente em `detalhes.existente`.',
  tags: ['clientes'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  body: CriarClienteSchema,
  respostas: {
    201: { descricao: 'Cliente criado', schema: ClienteSchema },
    409: { descricao: 'Documento já cadastrado', schema: ErroSchema },
    422: { descricao: 'Dados inválidos', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ body }) => ({ status: 201, corpo: await servicoDeClientes().criar(body) }),
});

registrarRota(clientesRouter, {
  metodo: 'get',
  caminho: '/clientes/:id',
  resumo: 'Detalha cliente',
  tags: ['clientes'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  params: IdParamSchema,
  respostas: {
    200: { descricao: 'Cliente', schema: ClienteSchema },
    404: { descricao: 'Cliente não encontrado', schema: ErroSchema },
    422: { descricao: 'Identificador inválido', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params }) => ({ corpo: await servicoDeClientes().detalhar(params.id) }),
});

registrarRota(clientesRouter, {
  metodo: 'patch',
  caminho: '/clientes/:id',
  resumo: 'Altera cliente',
  descricao: 'Envia só o que mudou. `email` e `endereco` aceitam `null` para limpar o campo.',
  tags: ['clientes'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  params: IdParamSchema,
  body: AlterarClienteSchema,
  respostas: {
    200: { descricao: 'Cliente alterado', schema: ClienteSchema },
    404: { descricao: 'Cliente não encontrado', schema: ErroSchema },
    409: { descricao: 'Documento já cadastrado', schema: ErroSchema },
    422: { descricao: 'Dados inválidos', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params, body }) => ({
    corpo: await servicoDeClientes().alterar(params.id, body),
  }),
});

registrarRota(clientesRouter, {
  metodo: 'post',
  caminho: '/clientes/:id/inativar',
  resumo: 'Inativa cliente',
  descricao: 'O histórico de OS é mantido. Cliente com OS ativa devolve 409.',
  tags: ['clientes'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  params: IdParamSchema,
  respostas: {
    200: { descricao: 'Cliente inativado', schema: ClienteSchema },
    404: { descricao: 'Cliente não encontrado', schema: ErroSchema },
    409: { descricao: 'Cliente com OS ativa', schema: ErroSchema },
    422: { descricao: 'Identificador inválido', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params }) => ({ corpo: await servicoDeClientes().inativar(params.id) }),
});
