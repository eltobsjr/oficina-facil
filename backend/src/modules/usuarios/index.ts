/**
 * Porta pública do módulo de usuários: só o que os outros módulos podem importar.
 */

export { usuariosRouter, definirDependenciasDeUsuarios } from './routes.js';
export { autenticar, exigirPerfis, usuarioDe, definirDependenciasDeAuth } from './auth.js';
export type { UsuarioAutenticado } from './service.js';
