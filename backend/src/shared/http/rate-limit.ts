/**
 * Limitadores de taxa por IP (regra R21).
 *
 * Duas camadas: `limitadorGeral` (tudo, exceto sonda de saúde e documentação) e
 * `limitadorEscrita` (métodos que mudam estado). Armazenamento em memória: vale para uma instância
 * só; ao escalar horizontalmente, trocar por um store compartilhado.
 */

import type { RequestHandler } from 'express';
import rateLimit, { ipKeyGenerator, type Options } from 'express-rate-limit';
import { env } from '../../config/env.js';
import { ErroLimiteDeTaxa } from '../errors/app-error.js';

/** Rotas que não entram na conta: sonda de saúde e documentação. */
const CAMINHOS_LIVRES = ['/health', '/docs', '/openapi.json'];
const METODOS_DE_ESCRITA = new Set(['POST', 'PUT', 'PATCH', 'DELETE']);

export function ehCaminhoLivre(caminho: string): boolean {
  return CAMINHOS_LIVRES.includes(caminho) || caminho.startsWith('/docs/');
}

export function ehEscrita(metodo: string): boolean {
  return METODOS_DE_ESCRITA.has(metodo);
}

/** Chave por IP normalizando IPv6 por prefixo, para não burlar o limite trocando de endereço. */
function porIp(req: { ip?: string }): string {
  return ipKeyGenerator(req.ip ?? 'desconhecido');
}

function criar(nome: string, max: number, pular: Options['skip']) {
  return rateLimit({
    windowMs: 60_000,
    limit: max,
    standardHeaders: 'draft-8',
    legacyHeaders: false,
    keyGenerator: porIp,
    skip: pular,
    handler: (_req, _res, next) => next(new ErroLimiteDeTaxa(nome, 60)),
  });
}

export function limitadorGeral(): RequestHandler {
  return criar('geral', env().RATE_LIMIT_GERAL_POR_MINUTO, (req) => ehCaminhoLivre(req.path));
}

export function limitadorEscrita(): RequestHandler {
  return criar('escrita', env().RATE_LIMIT_ESCRITA_POR_MINUTO, (req) => !ehEscrita(req.method));
}
