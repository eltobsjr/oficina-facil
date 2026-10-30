/**
 * Helper que define uma rota Express e a documenta no OpenAPI de uma vez só.
 *
 * `registrarRota(router, { metodo, caminho, body, params, query, handler, ... })`:
 * valida entrada com Zod (400 padronizado em caso de erro), registra o path no OpenAPI,
 * executa os middlewares (autenticação e perfis) e serializa a resposta.
 * O handler recebe dados já tipados e validados; nunca lê `req.body` cru.
 */

import type { Request, RequestHandler, Response, Router } from 'express';
import type { ZodObject, ZodType, z } from 'zod';
import { ErroValidacao } from '../errors/app-error.js';
import { registry } from '../openapi/registry.js';

export type Metodo = 'get' | 'post' | 'put' | 'patch' | 'delete';
export type Seguranca = 'bearer' | 'publica';

type Inferir<T> = T extends ZodType ? z.infer<T> : undefined;

export interface ContextoRota<B, P, Q> {
  body: B;
  params: P;
  query: Q;
  req: Request;
  res: Response;
}

export interface RespostaRota {
  status?: number;
  corpo?: unknown;
}

export interface DefinicaoRota<
  B extends ZodType | undefined,
  P extends ZodType | undefined,
  Q extends ZodType | undefined,
> {
  metodo: Metodo;
  /** Caminho no estilo Express (`/os/:id`). Convertido para `{id}` no OpenAPI. */
  caminho: string;
  resumo: string;
  descricao?: string;
  tags: string[];
  seguranca: Seguranca;
  /** Middlewares executados antes da validação (autenticação e perfis). */
  middlewares?: RequestHandler[];
  body?: B;
  params?: P;
  query?: Q;
  respostas: Record<number, { descricao: string; schema?: ZodType }>;
  handler: (ctx: ContextoRota<Inferir<B>, Inferir<P>, Inferir<Q>>) => Promise<RespostaRota | void>;
}

function paraCaminhoOpenApi(caminho: string): string {
  return caminho.replace(/:([A-Za-z0-9_]+)/g, '{$1}');
}

function validar<T extends ZodType | undefined>(
  schema: T,
  dados: unknown,
  origem: string,
): Inferir<T> {
  if (!schema) return undefined as Inferir<T>;
  const resultado = schema.safeParse(dados);
  if (!resultado.success) {
    throw new ErroValidacao(
      resultado.error.issues.map((i) => ({
        origem,
        caminho: i.path.join('.'),
        mensagem: i.message,
      })),
    );
  }
  return resultado.data as Inferir<T>;
}

export function registrarRota<
  B extends ZodType | undefined = undefined,
  P extends ZodType | undefined = undefined,
  Q extends ZodType | undefined = undefined,
>(router: Router, def: DefinicaoRota<B, P, Q>): void {
  const responses: Record<
    string,
    { description: string; content?: Record<string, { schema: ZodType }> }
  > = {};
  // Toda rota pode devolver 429: os limitadores rodam antes dos routers (`criarApp`).
  responses['429'] = { description: 'Limite de requisições excedido' };
  for (const [status, resposta] of Object.entries(def.respostas)) {
    responses[status] = {
      description: resposta.descricao,
      ...(resposta.schema ? { content: { 'application/json': { schema: resposta.schema } } } : {}),
    };
  }

  registry.registerPath({
    method: def.metodo,
    path: paraCaminhoOpenApi(def.caminho),
    summary: def.resumo,
    ...(def.descricao ? { description: def.descricao } : {}),
    tags: def.tags,
    security: def.seguranca === 'bearer' ? [{ bearerAuth: [] }] : [],
    request: {
      ...(def.params ? { params: def.params as unknown as ZodObject } : {}),
      ...(def.query ? { query: def.query as unknown as ZodObject } : {}),
      ...(def.body
        ? {
            body: {
              required: true,
              content: { 'application/json': { schema: def.body as ZodType } },
            },
          }
        : {}),
    },
    responses,
  });

  const executar: RequestHandler = async (req, res) => {
    const ctx: ContextoRota<Inferir<B>, Inferir<P>, Inferir<Q>> = {
      body: validar(def.body as B, req.body, 'body'),
      params: validar(def.params as P, req.params, 'params'),
      query: validar(def.query as Q, req.query, 'query'),
      req,
      res,
    };
    const resposta = await def.handler(ctx);
    const status = resposta?.status ?? 200;
    if (status === 204 || resposta?.corpo === undefined) {
      res.status(status === 200 && resposta?.corpo === undefined ? 204 : status).end();
      return;
    }
    res.status(status).json(resposta.corpo);
  };

  router[def.metodo](def.caminho, ...(def.middlewares ?? []), executar);
}
