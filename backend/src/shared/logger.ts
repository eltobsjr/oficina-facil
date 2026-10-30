/**
 * Logger estruturado (Pino) compartilhado por todo o processo.
 *
 * Em desenvolvimento usa pino-pretty; em produção emite JSON. Credenciais e senhas são redigidas
 * para nunca vazarem em log (regra R20).
 */

import pino from 'pino';

/** Campos que nunca podem aparecer em log. Exportado para o teste usar a configuração real. */
export const REDACAO = {
  paths: [
    'req.headers.authorization',
    'req.headers.cookie',
    'req.body.senha',
    'req.body.password',
    '*.senha',
    '*.password',
    '*.authorization',
  ],
  censor: '[redigido]',
};

const desenvolvimento = (process.env['NODE_ENV'] ?? 'development') === 'development';

export const logger = pino({
  level: process.env['LOG_LEVEL'] ?? (process.env['NODE_ENV'] === 'test' ? 'silent' : 'info'),
  ...(desenvolvimento
    ? {
        transport: {
          target: 'pino-pretty',
          options: { colorize: true, translateTime: 'HH:MM:ss' },
        },
      }
    : {}),
  redact: REDACAO,
});

export type Logger = typeof logger;
