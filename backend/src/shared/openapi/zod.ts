import { extendZodWithOpenApi } from '@asteasolutions/zod-to-openapi';
import { z } from 'zod';

// Estende o Zod com `.openapi()` uma única vez. Todos os schemas de rota importam `z` daqui.
extendZodWithOpenApi(z);

export { z };

export const UuidSchema = z.uuid().openapi({ example: '2f1a7d9e-0c4b-4f2a-9e3d-6b8c1a5d7e90' });
export const IdParamSchema = z.object({ id: UuidSchema });
export const CentavosSchema = z
  .number()
  .int()
  .nonnegative()
  .openapi({ description: 'Valor em centavos', example: 118000 });
export const ErroSchema = z
  .object({
    erro: z.object({
      codigo: z.string(),
      mensagem: z.string(),
      detalhes: z.unknown().optional(),
    }),
  })
  .openapi('Erro');
