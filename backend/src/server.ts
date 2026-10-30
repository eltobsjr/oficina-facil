/**
 * Ponto de entrada do processo: sobe o HTTP e trata o encerramento limpo (SIGINT/SIGTERM).
 */

import { criarApp } from './app.js';
import { env } from './config/env.js';
import { desconectarPrisma } from './shared/db/prisma.js';
import { logger } from './shared/logger.js';

function iniciar() {
  const e = env();
  const app = criarApp();
  const servidor = app.listen(e.PORT, () => {
    logger.info(
      { porta: e.PORT },
      `OficinaFácil API em http://localhost:${e.PORT} (docs em /docs)`,
    );
  });

  // Mitigação de Slowloris: conexão que arrasta cabeçalho ou corpo é derrubada.
  // headersTimeout precisa ser maior que keepAliveTimeout, senão o Node fecha keep-alive cedo.
  servidor.headersTimeout = e.HTTP_HEADERS_TIMEOUT_MS;
  servidor.requestTimeout = e.HTTP_REQUEST_TIMEOUT_MS;
  servidor.keepAliveTimeout = e.HTTP_KEEP_ALIVE_TIMEOUT_MS;

  let encerrando = false;
  const encerrar = async (sinal: string) => {
    if (encerrando) return;
    encerrando = true;
    logger.info({ sinal }, 'Encerrando');
    servidor.close();
    await desconectarPrisma();
    process.exit(0);
  };
  process.on('SIGINT', () => void encerrar('SIGINT'));
  process.on('SIGTERM', () => void encerrar('SIGTERM'));
}

try {
  iniciar();
} catch (erro) {
  logger.fatal({ erro }, 'Falha ao iniciar');
  process.exit(1);
}
