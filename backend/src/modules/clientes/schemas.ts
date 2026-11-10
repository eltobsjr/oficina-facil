import { PaginacaoQuerySchema, paginaSchema } from '../../shared/paginacao.js';
import { UuidSchema, z } from '../../shared/openapi/zod.js';
import { documentoValido, normalizarDocumento } from '../../shared/validadores.js';

const NomeSchema = z.string().trim().min(2).max(120);
const TelefoneSchema = z
  .string()
  .trim()
  .min(8)
  .max(20)
  .openapi({ description: 'Telefone com DDD, com ou sem máscara', example: '(11) 91234-5678' });
const EmailSchema = z.email().max(254);
const EnderecoSchema = z.string().trim().min(1).max(250);
const DocumentoSchema = z
  .string()
  .trim()
  .refine(documentoValido, { message: 'CPF ou CNPJ inválido' })
  .transform(normalizarDocumento)
  .openapi({ description: 'CPF ou CNPJ, com ou sem máscara; guardado só com dígitos' });

export const ClienteSchema = z
  .object({
    id: UuidSchema,
    nome: z.string(),
    documento: z.string().openapi({ description: 'Só dígitos' }),
    telefone: z.string(),
    email: z.string().nullable(),
    endereco: z.string().nullable(),
    ativo: z.boolean(),
  })
  .openapi('Cliente');

export const ListaClientesSchema = paginaSchema(ClienteSchema, 'ListaClientes');

export const ListaClientesQuerySchema = PaginacaoQuerySchema.extend({
  q: z
    .string()
    .trim()
    .min(1)
    .max(100)
    .optional()
    .openapi({ description: 'Busca por nome ou documento (parte do texto)' }),
});

export const CriarClienteSchema = z
  .object({
    nome: NomeSchema,
    documento: DocumentoSchema,
    telefone: TelefoneSchema,
    email: EmailSchema.nullish(),
    endereco: EnderecoSchema.nullish(),
  })
  .openapi('CriarCliente');

export const AlterarClienteSchema = z
  .object({
    nome: NomeSchema.optional(),
    documento: DocumentoSchema.optional(),
    telefone: TelefoneSchema.optional(),
    email: EmailSchema.nullable().optional(),
    endereco: EnderecoSchema.nullable().optional(),
  })
  .refine((o) => Object.values(o).some((v) => v !== undefined), {
    message: 'Informe ao menos um campo para alterar',
  })
  .openapi('AlterarCliente');
