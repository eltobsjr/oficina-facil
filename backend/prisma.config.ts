/**
 * Configuração do Prisma 7: caminho do schema, pasta de migrations e URL do banco.
 *
 * Migrations usam DIRECT_URL (conexão direta); a aplicação usa DATABASE_URL via adapter.
 */

import 'dotenv/config';
import { defineConfig } from 'prisma/config';

// O placeholder permite `prisma generate` e `prisma migrate diff` sem banco (build e CI).
const url =
  process.env['DIRECT_URL'] ??
  process.env['DATABASE_URL'] ??
  'postgresql://placeholder:placeholder@localhost:5432/oficina_facil';

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: { url },
});
