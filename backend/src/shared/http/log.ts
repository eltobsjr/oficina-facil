/**
 * Log HTTP (pino-http): uma linha por requisição com método, caminho, status e tempo.
 *
 * Só o caminho é registrado, nunca a query string: a busca de clientes por documento viaja na
 * query e documento é dado pessoal (R20, R28). Cabeçalhos e corpo também ficam fora do log.
 */

import { pinoHttp } from 'pino-http';
import type { Logger } from '../logger.js';

/** Remove a query string de uma URL de requisição. */
export function caminhoSemQuery(url: string | undefined): string {
  return (url ?? '').split('?')[0] ?? '';
}

/** Falha do servidor é `error`, recusa do cliente é `warn` e o resto é `info`. */
function nivelDoLog(status: number, erro: unknown): 'error' | 'warn' | 'info' {
  if (erro || status >= 500) return 'error';
  if (status >= 400) return 'warn';
  return 'info';
}

export function logHttp(logger: Logger) {
  return pinoHttp({
    logger,
    autoLogging: { ignore: (req) => caminhoSemQuery(req.url) === '/health' },
    customLogLevel: (_req, res, err) => nivelDoLog(res.statusCode, err),
    serializers: {
      req: (req: { method?: string; url?: string }) => ({
        method: req.method,
        url: caminhoSemQuery(req.url),
      }),
      res: (res: { statusCode?: number }) => ({ statusCode: res.statusCode }),
    },
    customSuccessMessage: (req, res, tempoMs) =>
      `${req.method} ${caminhoSemQuery(req.url)} → ${res.statusCode} (${Math.round(tempoMs)} ms)`,
    customErrorMessage: (req, res) =>
      `${req.method} ${caminhoSemQuery(req.url)} → ${res.statusCode}`,
  });
}
