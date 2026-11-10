import { PaginacaoQuerySchema, paginaSchema } from '../../shared/paginacao.js';
import { UuidSchema, z } from '../../shared/openapi/zod.js';
import { normalizarPlaca, placaValida } from '../../shared/validadores.js';

const PlacaSchema = z
  .string()
  .trim()
  .refine(placaValida, { message: 'Placa inválida (use ABC1234 ou ABC1D23)' })
  .transform(normalizarPlaca)
  .openapi({ description: 'Padrão antigo (ABC1234) ou Mercosul (ABC1D23); guardada normalizada' });
const MarcaSchema = z.string().trim().min(1).max(60);
const ModeloSchema = z.string().trim().min(1).max(80);
const AnoSchema = z.number().int().min(1900).max(2100);
const CorSchema = z.string().trim().min(1).max(40);
const QuilometragemSchema = z
  .number()
  .int()
  .nonnegative()
  .openapi({ description: 'Quilometragem em km, inteiro' });

export const VeiculoSchema = z
  .object({
    id: UuidSchema,
    clienteId: UuidSchema,
    placa: z.string(),
    marca: z.string(),
    modelo: z.string(),
    ano: z.number().int(),
    cor: z.string().nullable(),
    quilometragem: z.number().int(),
    ativo: z.boolean(),
  })
  .openapi('Veiculo');

export const ListaVeiculosSchema = paginaSchema(VeiculoSchema, 'ListaVeiculos');

export const ListaVeiculosDoClienteQuerySchema = PaginacaoQuerySchema;

export const BuscaVeiculosQuerySchema = PaginacaoQuerySchema.extend({
  placa: z
    .string()
    .trim()
    .min(1)
    .max(10)
    .optional()
    .openapi({ description: 'Placa inteira ou parte dela, com ou sem hífen' }),
});

export const CriarVeiculoSchema = z
  .object({
    placa: PlacaSchema,
    marca: MarcaSchema,
    modelo: ModeloSchema,
    ano: AnoSchema,
    cor: CorSchema.nullish(),
    quilometragem: QuilometragemSchema,
  })
  .openapi('CriarVeiculo');

export const AlterarVeiculoSchema = z
  .object({
    placa: PlacaSchema.optional(),
    marca: MarcaSchema.optional(),
    modelo: ModeloSchema.optional(),
    ano: AnoSchema.optional(),
    cor: CorSchema.nullable().optional(),
    quilometragem: QuilometragemSchema.optional(),
  })
  .refine((o) => Object.values(o).some((v) => v !== undefined), {
    message: 'Informe ao menos um campo para alterar',
  })
  .openapi('AlterarVeiculo');

export const TransferirVeiculoSchema = z
  .object({ clienteId: UuidSchema.openapi({ description: 'Novo dono do veículo' }) })
  .openapi('TransferirVeiculo');
