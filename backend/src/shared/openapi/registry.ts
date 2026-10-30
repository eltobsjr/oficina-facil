/**
 * Registro central de OpenAPI e geração do documento.
 *
 * Cada rota se registra via `registrarRota` (shared/http/rota.ts). `gerarDocumentoOpenApi` monta o
 * OpenAPI 3.1 a partir dos schemas Zod: validação e documentação vêm do mesmo lugar.
 */

import { OpenAPIRegistry, OpenApiGeneratorV31 } from '@asteasolutions/zod-to-openapi';

export const registry = new OpenAPIRegistry();

registry.registerComponent('securitySchemes', 'bearerAuth', {
  type: 'http',
  scheme: 'bearer',
  bearerFormat: 'JWT',
  description: 'access_token emitido pelo Supabase Auth',
});

export function gerarDocumentoOpenApi(servidorUrl: string) {
  const gerador = new OpenApiGeneratorV31(registry.definitions);
  return gerador.generateDocument({
    openapi: '3.1.0',
    info: {
      title: 'OficinaFácil API',
      version: '0.1.0',
      description:
        'API do OficinaFácil. Toda regra de negócio vive aqui; o app só exibe. Valores sempre em centavos inteiros.',
    },
    servers: [{ url: servidorUrl }],
    tags: [
      { name: 'usuarios' },
      { name: 'clientes' },
      { name: 'veiculos' },
      { name: 'servicos' },
      { name: 'pecas' },
      { name: 'ordens' },
      { name: 'faturamento' },
      { name: 'avisos' },
    ],
  });
}
