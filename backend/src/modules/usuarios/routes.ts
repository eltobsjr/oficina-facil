import { Router } from 'express';
import { ErroSchema } from '../../shared/openapi/zod.js';
import { registrarRota } from '../../shared/http/rota.js';
import { autenticar, usuarioDe } from './auth.js';
import { UsuarioAtualSchema } from './schemas.js';

export const usuariosRouter = Router();

registrarRota(usuariosRouter, {
  metodo: 'get',
  caminho: '/me',
  resumo: 'Usuário autenticado',
  descricao:
    'Nome, e-mail e perfil do usuário dono do token. O app usa para montar o menu do perfil.',
  tags: ['usuarios'],
  seguranca: 'bearer',
  middlewares: [autenticar],
  respostas: {
    200: { descricao: 'Usuário autenticado', schema: UsuarioAtualSchema },
    401: { descricao: 'Sem token ou token inválido', schema: ErroSchema },
    403: { descricao: 'Usuário sem perfil ou inativo', schema: ErroSchema },
  },
  handler: async ({ res }) => ({ corpo: usuarioDe(res) }),
});
