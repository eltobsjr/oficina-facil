import { z } from '../../shared/openapi/zod.js';
import { UuidSchema } from '../../shared/openapi/zod.js';

export const PerfilSchema = z
  .enum(['ATENDENTE', 'MECANICO', 'ALMOXARIFE', 'GERENTE'])
  .openapi('Perfil');

export const UsuarioAtualSchema = z
  .object({
    id: UuidSchema,
    nome: z.string(),
    email: z.string(),
    perfil: PerfilSchema,
  })
  .openapi('UsuarioAtual');
