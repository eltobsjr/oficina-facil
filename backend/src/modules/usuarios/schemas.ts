import { PaginacaoQuerySchema } from '../../shared/paginacao.js';
import { UuidSchema, z } from '../../shared/openapi/zod.js';

export const PerfilSchema = z
  .enum(['ATENDENTE', 'MECANICO', 'ALMOXARIFE', 'GERENTE'])
  .openapi('Perfil');

/** Usuário autenticado (resposta de `GET /me`). */
export const UsuarioAtualSchema = z
  .object({
    id: UuidSchema,
    nome: z.string(),
    email: z.string(),
    perfil: PerfilSchema,
  })
  .openapi('UsuarioAtual');

/** Usuário na gestão (UC06). Nunca inclui senha. */
export const UsuarioSchema = z
  .object({
    id: UuidSchema,
    nome: z.string(),
    email: z.string(),
    perfil: PerfilSchema,
    ativo: z.boolean(),
    criadoEm: z.iso.datetime(),
  })
  .openapi('Usuario');

export const ListaUsuariosSchema = z
  .object({
    itens: z.array(UsuarioSchema),
    total: z.number().int(),
    pagina: z.number().int(),
    limite: z.number().int(),
  })
  .openapi('ListaUsuarios');

export const ListaUsuariosQuerySchema = PaginacaoQuerySchema.extend({
  q: z
    .string()
    .trim()
    .min(1)
    .max(100)
    .optional()
    .openapi({ description: 'Busca por nome ou e-mail' }),
  perfil: PerfilSchema.optional(),
  ativo: z
    .enum(['true', 'false'])
    .transform((v) => v === 'true')
    .optional(),
});

export const CriarUsuarioSchema = z
  .object({
    nome: z.string().trim().min(2).max(120),
    email: z.email().max(254),
    perfil: PerfilSchema,
    senha: z
      .string()
      .min(8)
      .max(72)
      .openapi({ description: 'Senha inicial; nunca é devolvida nem logada' }),
  })
  .openapi('CriarUsuario');

export const AlterarUsuarioSchema = z
  .object({
    nome: z.string().trim().min(2).max(120).optional(),
    perfil: PerfilSchema.optional(),
  })
  .refine((o) => o.nome !== undefined || o.perfil !== undefined, {
    message: 'Informe nome ou perfil',
  })
  .openapi('AlterarUsuario');

export const RedefinirSenhaSchema = z
  .object({ senha: z.string().min(8).max(72) })
  .openapi('RedefinirSenha');
