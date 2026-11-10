/**
 * Porta pública do módulo de clientes: só o que os outros módulos podem importar.
 */

export { clientesRouter, definirDependenciasDeClientes, servicoDeClientes } from './routes.js';
export type { ClienteResumo } from './service.js';
