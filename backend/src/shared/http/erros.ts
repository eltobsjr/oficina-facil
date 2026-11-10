/**
 * Middlewares finais do Express: rota não encontrada e tratador de erros.
 *
 * Converte AppError, ZodError e JSON malformado em respostas padronizadas; qualquer outro erro
 * vira 500 e é logado sem vazar detalhe interno. Sempre os últimos `app.use` de `app.ts`.
 */

import type { ErrorRequestHandler, RequestHandler } from 'express';
import { ZodError } from 'zod';
import { violouUnicidade } from '../db/unicidade.js';
import { AppError, NaoEncontrado } from '../errors/app-error.js';
import { logger } from '../logger.js';
import { caminhoSemQuery } from './log.js';

export const rotaNaoEncontrada: RequestHandler = (req, _res, next) => {
  next(new NaoEncontrado(`Rota ${req.method} ${req.path}`));
};

export const tratadorDeErros: ErrorRequestHandler = (erro, req, res, _next) => {
  if (erro instanceof AppError) {
    if (erro.status >= 500)
      logger.error({ erro, url: caminhoSemQuery(req.originalUrl) }, erro.message);
    res.status(erro.status).json(erro.toJSON());
    return;
  }
  if (violouUnicidade(erro)) {
    res.status(409).json({
      erro: {
        codigo: 'conflito',
        mensagem: 'Registro duplicado',
        detalhes: { campos: erro.meta?.['target'] ?? null },
      },
    });
    return;
  }
  if (erro instanceof ZodError) {
    res
      .status(422)
      .json({ erro: { codigo: 'validacao', mensagem: 'Dados inválidos', detalhes: erro.issues } });
    return;
  }
  if (
    typeof erro === 'object' &&
    erro !== null &&
    'type' in erro &&
    erro.type === 'entity.parse.failed'
  ) {
    res.status(400).json({
      erro: { codigo: 'json_invalido', mensagem: 'Corpo da requisição não é JSON válido' },
    });
    return;
  }
  logger.error({ erro, url: caminhoSemQuery(req.originalUrl) }, 'Erro não tratado');
  res.status(500).json({ erro: { codigo: 'erro_interno', mensagem: 'Erro interno' } });
};
