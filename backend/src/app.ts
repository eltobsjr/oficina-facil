/**
 * Montagem do Express: segurança, logs, rotas, Swagger e tratamento de erros.
 *
 * Sem efeitos colaterais além de construir o app, para que testes HTTP possam instanciá-lo.
 * As rotas de negócio ficam sob `/api/v1`; `/health`, `/docs` e `/openapi.json` ficam na raiz.
 */

import cors from 'cors';
import express, { type Express } from 'express';
import helmet from 'helmet';
import { pinoHttp } from 'pino-http';
import swaggerUi from 'swagger-ui-express';
import { type Env, env, origensCors } from './config/env.js';
import { usuariosRouter } from './modules/usuarios/index.js';
import { pingBanco } from './shared/db/prisma.js';
import { rotaNaoEncontrada, tratadorDeErros } from './shared/http/erros.js';
import { limitadorEscrita, limitadorGeral } from './shared/http/rate-limit.js';
import { logger } from './shared/logger.js';
import { gerarDocumentoOpenApi } from './shared/openapi/registry.js';

const BASE = '/api/v1';
const LOCALHOST = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

/** Em desenvolvimento aceita qualquer porta de localhost; em produção, só as origens configuradas. */
function permitirOrigem(origem: string | undefined, e = env()): boolean {
  if (!origem) return true; // app nativo e chamadas sem Origin
  if (e.NODE_ENV !== 'production' && LOCALHOST.test(origem)) return true;
  return origensCors(e).includes(origem);
}

export function criarApp(e: Env = env()): Express {
  const app = express();
  app.disable('x-powered-by');
  app.set('trust proxy', 1);

  app.use(helmet({ contentSecurityPolicy: false }));
  app.use(
    cors({
      origin: (origem, retorno) => retorno(null, permitirOrigem(origem, e)),
      credentials: false,
    }),
  );

  // Antes do parse do corpo: requisição barrada não gasta CPU desserializando JSON.
  app.use(limitadorGeral());
  app.use(limitadorEscrita());

  app.use(express.json({ limit: '1mb' }));
  app.use(
    pinoHttp({
      logger,
      autoLogging: { ignore: (req) => req.url === '/health' },
      customLogLevel: (_req, res, err) =>
        err || res.statusCode >= 500 ? 'error' : res.statusCode >= 400 ? 'warn' : 'info',
      // Uma linha por requisição: método, rota, status e tempo. Cabeçalhos e corpo ficam fora do log.
      serializers: {
        req: (req: { method?: string; url?: string }) => ({ method: req.method, url: req.url }),
        res: (res: { statusCode?: number }) => ({ statusCode: res.statusCode }),
      },
      customSuccessMessage: (req, res, tempoMs) =>
        `${req.method} ${req.url} → ${res.statusCode} (${Math.round(tempoMs)} ms)`,
      customErrorMessage: (req, res) => `${req.method} ${req.url} → ${res.statusCode}`,
    }),
  );

  app.get('/health', async (_req, res) => {
    const banco = await pingBanco();
    res.status(banco ? 200 : 503).json({
      status: banco ? 'ok' : 'degradado',
      banco: banco ? 'ok' : 'indisponivel',
      versao: '0.1.0',
    });
  });

  app.use(BASE, usuariosRouter);

  // Gerado depois de todos os routers registrarem seus paths. Em produção o contrato não é exposto.
  if (e.NODE_ENV !== 'production') {
    const documento = gerarDocumentoOpenApi(`http://localhost:${e.PORT}${BASE}`);
    app.get('/openapi.json', (_req, res) => res.json(documento));
    app.use(
      '/docs',
      swaggerUi.serve,
      swaggerUi.setup(documento, { customSiteTitle: 'OficinaFácil API' }),
    );
  }

  app.use(rotaNaoEncontrada);
  app.use(tratadorDeErros);
  return app;
}
