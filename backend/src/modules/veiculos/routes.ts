import { Router } from 'express';
import { registrarRota } from '../../shared/http/rota.js';
import { ErroSchema, IdParamSchema } from '../../shared/openapi/zod.js';
import { servicoDeClientes } from '../clientes/index.js';
import { autenticar, exigirPerfis } from '../usuarios/index.js';
import { repositorioPrisma } from './repository.js';
import {
  AlterarVeiculoSchema,
  BuscaVeiculosQuerySchema,
  CriarVeiculoSchema,
  ListaVeiculosDoClienteQuerySchema,
  ListaVeiculosSchema,
  TransferirVeiculoSchema,
  VeiculoSchema,
} from './schemas.js';
import {
  criarServicoVeiculos,
  type DependenciasVeiculos,
  type ServicoVeiculos,
} from './service.js';

export const veiculosRouter = Router();

let dependencias: Partial<DependenciasVeiculos> | undefined;

/** Testes injetam um repositório em memória; a consulta de cliente padrão passa por `clientes`. */
export function definirDependenciasDeVeiculos(deps: Partial<DependenciasVeiculos> | undefined) {
  dependencias = deps;
}

function servico(): ServicoVeiculos {
  return criarServicoVeiculos({
    repo: dependencias?.repo ?? repositorioPrisma,
    buscarCliente: dependencias?.buscarCliente ?? ((id) => servicoDeClientes().resumo(id)),
  });
}

const apenasAtendente = [autenticar, exigirPerfis('ATENDENTE')];

const respostasComuns = {
  401: { descricao: 'Sem token ou token inválido', schema: ErroSchema },
  403: { descricao: 'Sem permissão (só o atendente gere veículos)', schema: ErroSchema },
};

registrarRota(veiculosRouter, {
  metodo: 'get',
  caminho: '/clientes/:id/veiculos',
  resumo: 'Lista os veículos do cliente',
  tags: ['veiculos'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  params: IdParamSchema,
  query: ListaVeiculosDoClienteQuerySchema,
  respostas: {
    200: { descricao: 'Veículos do cliente', schema: ListaVeiculosSchema },
    404: { descricao: 'Cliente não encontrado', schema: ErroSchema },
    422: { descricao: 'Parâmetros inválidos', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params, query }) => ({
    corpo: await servico().listarDoCliente(params.id, query),
  }),
});

registrarRota(veiculosRouter, {
  metodo: 'post',
  caminho: '/clientes/:id/veiculos',
  resumo: 'Cadastra veículo do cliente',
  descricao:
    'Valida a placa (ABC1234 ou ABC1D23). Placa já cadastrada devolve 409 com o veículo existente em `detalhes.existente`.',
  tags: ['veiculos'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  params: IdParamSchema,
  body: CriarVeiculoSchema,
  respostas: {
    201: { descricao: 'Veículo criado', schema: VeiculoSchema },
    404: { descricao: 'Cliente não encontrado', schema: ErroSchema },
    409: { descricao: 'Placa já cadastrada', schema: ErroSchema },
    422: { descricao: 'Dados inválidos', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params, body }) => ({
    status: 201,
    corpo: await servico().criar(params.id, body),
  }),
});

registrarRota(veiculosRouter, {
  metodo: 'get',
  caminho: '/veiculos',
  resumo: 'Busca veículos por placa',
  tags: ['veiculos'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  query: BuscaVeiculosQuerySchema,
  respostas: {
    200: { descricao: 'Veículos', schema: ListaVeiculosSchema },
    422: { descricao: 'Parâmetros inválidos', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ query }) => ({ corpo: await servico().buscar(query) }),
});

registrarRota(veiculosRouter, {
  metodo: 'get',
  caminho: '/veiculos/:id',
  resumo: 'Detalha veículo',
  tags: ['veiculos'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  params: IdParamSchema,
  respostas: {
    200: { descricao: 'Veículo', schema: VeiculoSchema },
    404: { descricao: 'Veículo não encontrado', schema: ErroSchema },
    422: { descricao: 'Identificador inválido', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params }) => ({ corpo: await servico().detalhar(params.id) }),
});

registrarRota(veiculosRouter, {
  metodo: 'patch',
  caminho: '/veiculos/:id',
  resumo: 'Altera veículo',
  descricao: 'Envia só o que mudou. `cor` aceita `null` para limpar o campo.',
  tags: ['veiculos'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  params: IdParamSchema,
  body: AlterarVeiculoSchema,
  respostas: {
    200: { descricao: 'Veículo alterado', schema: VeiculoSchema },
    404: { descricao: 'Veículo não encontrado', schema: ErroSchema },
    409: { descricao: 'Placa já cadastrada', schema: ErroSchema },
    422: { descricao: 'Dados inválidos', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params, body }) => ({ corpo: await servico().alterar(params.id, body) }),
});

registrarRota(veiculosRouter, {
  metodo: 'post',
  caminho: '/veiculos/:id/transferir',
  resumo: 'Transfere o veículo para outro cliente',
  descricao: 'Muda o dono. As OS já abertas mantêm o dono anterior.',
  tags: ['veiculos'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  params: IdParamSchema,
  body: TransferirVeiculoSchema,
  respostas: {
    200: { descricao: 'Veículo transferido', schema: VeiculoSchema },
    404: { descricao: 'Veículo ou cliente não encontrado', schema: ErroSchema },
    422: { descricao: 'Dados inválidos', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params, body }) => ({
    corpo: await servico().transferir(params.id, body.clienteId),
  }),
});

registrarRota(veiculosRouter, {
  metodo: 'post',
  caminho: '/veiculos/:id/inativar',
  resumo: 'Inativa veículo',
  tags: ['veiculos'],
  seguranca: 'bearer',
  middlewares: apenasAtendente,
  params: IdParamSchema,
  respostas: {
    200: { descricao: 'Veículo inativado', schema: VeiculoSchema },
    404: { descricao: 'Veículo não encontrado', schema: ErroSchema },
    422: { descricao: 'Identificador inválido', schema: ErroSchema },
    ...respostasComuns,
  },
  handler: async ({ params }) => ({ corpo: await servico().inativar(params.id) }),
});
